@echo off
chcp 65001 >nul
echo === Hermes Agent 启动器 ===

set HERMES_DIR=%USERPROFILE%\hermes-agent
set VENV_HERMES=%HERMES_DIR%\venv\Scripts\hermes.exe

if not exist "%VENV_HERMES%" (
    echo 错误: 虚拟环境未找到
    exit /b 1
)

cd /d "%HERMES_DIR%"
echo 正在启动 Hermes...
echo.
"%VENV_HERMES%" chat
