# Hermes Agent 完整修复启动脚本
# 创建时间: 2026-05-03

$HERMES_DIR = "$env:USERPROFILE\hermes-agent"
$VENV_PATH = "$HERMES_DIR\venv\Scripts\Activate.ps1"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Hermes Agent 启动器 (修复版)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 检查虚拟环境
if (-not (Test-Path $VENV_PATH)) {
    Write-Host "错误: 虚拟环境未找到: $VENV_PATH" -ForegroundColor Red
    Write-Host "请先运行: python -m venv venv" -ForegroundColor Yellow
    exit 1
}

# 激活虚拟环境
Write-Host "`n[1/4] 激活虚拟环境..." -ForegroundColor Green
& $VENV_PATH

# 检查 Hermes 安装
Write-Host "`n[2/4] 检查 Hermes 安装..." -ForegroundColor Green
$hermesCheck = & "$HERMES_DIR\venv\Scripts\python.exe" -c "import hermes_cli; print('OK')" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Hermes 模块检查失败，尝试重新安装..." -ForegroundColor Yellow
    Set-Location $HERMES_DIR
    & "$HERMES_DIR\venv\Scripts\pip.exe" install -e .
}

# 检查 LM Studio 连接
Write-Host "`n[3/4] 检查 LM Studio 连接..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://localhost:1234/v1/models" -Method GET -TimeoutSec 3 -ErrorAction Stop
    Write-Host "  LM Studio 运行正常" -ForegroundColor Green
    $models = $response.Content | ConvertFrom-Json
    if ($models.data) {
        Write-Host "  可用模型: $($models.data.id -join ', ')" -ForegroundColor Gray
    }
} catch {
    Write-Host "  警告: 无法连接到 LM Studio (http://localhost:1234)" -ForegroundColor Yellow
    Write-Host "  请确保 LM Studio 已启动并开启 Server 模式" -ForegroundColor Yellow
}

# 加载环境变量
Write-Host "`n[4/4] 加载环境配置..." -ForegroundColor Green
$envFile = "$HERMES_DIR\.env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#][^=]*)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
    Write-Host "  已加载: $envFile" -ForegroundColor Gray
}

# 显示配置摘要
Write-Host "`n------------------------------------------" -ForegroundColor Cyan
Write-Host "配置摘要:" -ForegroundColor Cyan
Write-Host "  模型: $($env:LLM_MODEL)" -ForegroundColor White
Write-Host "  API地址: $($env:OPENAI_BASE_URL)" -ForegroundColor White
Write-Host "  终端模式: local" -ForegroundColor White
Write-Host "------------------------------------------" -ForegroundColor Cyan

# 启动 Hermes
Write-Host "`n启动 Hermes Agent...`n" -ForegroundColor Green
Set-Location $HERMES_DIR
& "$HERMES_DIR\venv\Scripts\hermes.exe" chat
