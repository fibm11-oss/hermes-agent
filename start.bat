@echo off
echo === Hermes Agent Launcher ===
set HERMES_DIR=%USERPROFILE%\hermes-agent
set VENV_HERMES=%HERMES_DIR%\venv\Scripts\hermes.exe
if not exist "%VENV_HERMES%" (
    echo Error: Hermes not found
    exit /b 1
)
cd /d "%HERMES_DIR%"
echo Starting Hermes...
"%VENV_HERMES%" chat
