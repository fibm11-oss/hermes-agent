# Hermes Agent 启动脚本 - 简化版
$HERMES_DIR = "$env:USERPROFILE\hermes-agent"
$VENV_PYTHON = "$HERMES_DIR\venv\Scripts\python.exe"
$VENV_HERMES = "$HERMES_DIR\venv\Scripts\hermes.exe"

Write-Host "=== Hermes Agent 启动器 ===" -ForegroundColor Cyan

# 检查虚拟环境
if (!(Test-Path $VENV_PYTHON)) {
    Write-Host "错误: 虚拟环境未找到" -ForegroundColor Red
    exit 1
}

# 加载环境变量
$envFile = "$HERMES_DIR\.env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#][^=]*)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

Write-Host "模型: $($env:LLM_MODEL)" -ForegroundColor Green
Write-Host "API: $($env:OPENAI_BASE_URL)" -ForegroundColor Green
Write-Host ""

# 启动 Hermes
Set-Location $HERMES_DIR
& $VENV_HERMES chat
