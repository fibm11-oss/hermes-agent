# Hermes Agent 一鍵啟動腳本 (PowerShell)
# 雙擊此檔案或執行: .\start-hermes-ui.ps1

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$HERMES_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$VENV_DIR = Join-Path $HERMES_DIR "venv"
$VENV_PYTHON = Join-Path $VENV_DIR "Scripts\python.exe"
$VENV_PIP = Join-Path $VENV_DIR "Scripts\pip.exe"
$VENV_HERMES = Join-Path $VENV_DIR "Scripts\hermes.exe"
$HERMES_HOME = Join-Path $env:USERPROFILE ".hermes"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Hermes Agent 一鍵啟動器 (Web UI)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ── 步驟 1: 檢查虛擬環境 ──
Write-Host "[1/5] 檢查 Python 虛擬環境..." -ForegroundColor Green
if (-not (Test-Path $VENV_PYTHON)) {
    Write-Host "  虛擬環境不存在，正在建立..." -ForegroundColor Yellow
    & python -m venv $VENV_DIR
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  錯誤: 無法建立虛擬環境！" -ForegroundColor Red
        Read-Host "按 Enter 鍵退出"
        exit 1
    }
    Write-Host "  虛擬環境已建立。" -ForegroundColor Green
} else {
    Write-Host "  虛擬環境 OK" -ForegroundColor Green
}

# ── 步驟 2: 檢查 Hermes 安裝 ──
Write-Host ""
Write-Host "[2/5] 檢查 Hermes 安裝..." -ForegroundColor Green
$checkResult = & $VENV_PYTHON -c "import hermes_cli; print('OK')" 2>&1
if ($LASTEXITCODE -ne 0 -or "$checkResult" -ne "OK") {
    Write-Host "  Hermes 未安裝，正在安裝..." -ForegroundColor Yellow
    & $VENV_PIP install -e $HERMES_DIR
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  錯誤: 安裝失敗！" -ForegroundColor Red
        Read-Host "按 Enter 鍵退出"
        exit 1
    }
} else {
    Write-Host "  Hermes 安裝 OK" -ForegroundColor Green
}

# ── 步驟 3: 檢查 Web Dashboard 依賴 ──
Write-Host ""
Write-Host "[3/5] 檢查 Web Dashboard 依賴..." -ForegroundColor Green
$webCheck = & $VENV_PYTHON -c "import fastapi, uvicorn; print('OK')" 2>&1
if ($LASTEXITCODE -ne 0 -or "$webCheck" -ne "OK") {
    Write-Host "  安裝 Web Dashboard 依賴..." -ForegroundColor Yellow
    & $VENV_PIP install fastapi uvicorn
} else {
    Write-Host "  Web Dashboard 依賴 OK" -ForegroundColor Green
}

# ── 步驟 4: 檢查 LM Studio 連接 ──
Write-Host ""
Write-Host "[4/5] 檢查 LM Studio 本地模型..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:1234/v1/models" -Method GET -TimeoutSec 3 -ErrorAction Stop
    Write-Host "  LM Studio 運行正常" -ForegroundColor Green
    $models = $response.Content | ConvertFrom-Json
    if ($models.data) {
        Write-Host "  可用模型:" -ForegroundColor Gray
        foreach ($m in $models.data) {
            Write-Host "    - $($m.id)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "  警告: LM Studio 未運行！" -ForegroundColor Yellow
    Write-Host "  請先啟動 LM Studio 並開啟 Server 模式" -ForegroundColor Yellow
    Write-Host "  下載地址: https://lmstudio.ai/" -ForegroundColor DarkGray
}
Write-Host "  配置: provider=lmstudio, base_url=http://127.0.0.1:1234/v1" -ForegroundColor Gray

# ── 步驟 5: 載入環境變數 ──
Write-Host ""
Write-Host "[5/5] 載入環境設定..." -ForegroundColor Green
$envFile = Join-Path $HERMES_HOME ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#][^=]*)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
    Write-Host "  已載入: $envFile" -ForegroundColor Gray
} else {
    Write-Host "  無 .env 檔案（可選）" -ForegroundColor Gray
}

# ── 顯示配置摘要 ──
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  配置摘要:" -ForegroundColor Cyan
Write-Host "  Provider:  lmstudio (LM Studio 本地模型)" -ForegroundColor White
Write-Host "  API 地址:  http://127.0.0.1:1234/v1" -ForegroundColor White
Write-Host "  終端模式:  local (PowerShell)" -ForegroundColor White
Write-Host "  UI 模式:   Web Dashboard (瀏覽器)" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ── 啟動 Web Dashboard ──
Write-Host "正在啟動 Hermes Web Dashboard..." -ForegroundColor Green
Write-Host "瀏覽器將自動開啟 http://127.0.0.1:9119" -ForegroundColor Gray
Write-Host "按 Ctrl+C 可停止伺服器" -ForegroundColor DarkGray
Write-Host ""

Set-Location $HERMES_DIR
& $VENV_HERMES dashboard
