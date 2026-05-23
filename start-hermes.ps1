# Hermes Agent 启动脚本 (PowerShell)
$HERMES_DIR = "$env:USERPROFILE\hermes-agent"
Set-Location $HERMES_DIR

# 激活虚拟环境
$venvPath = "$HERMES_DIR\venv\Scripts\Activate.ps1"
if (Test-Path $venvPath) {
    & $venvPath
} else {
    Write-Host "虚拟环境未找到: $venvPath" -ForegroundColor Red
    exit 1
}

# 启动 Hermes
hermes
