@echo off
chcp 65001 >nul 2>&1
title Hermes Agent - 一鍵啟動
color 0A

echo ==========================================
echo    Hermes Agent 一鍵啟動器
echo ==========================================
echo.

:: ── 設定路徑 ──
set "HERMES_DIR=%~dp0"
set "VENV_DIR=%HERMES_DIR%venv"
set "VENV_PYTHON=%VENV_DIR%\Scripts\python.exe"
set "VENV_PIP=%VENV_DIR%\Scripts\pip.exe"
set "VENV_HERMES=%VENV_DIR%\Scripts\hermes.exe"
set "HERMES_HOME=%USERPROFILE%\.hermes"

:: ── 步驟 1: 檢查虛擬環境 ──
echo [1/5] 檢查 Python 虛擬環境...
if not exist "%VENV_PYTHON%" (
    echo   虛擬環境不存在，正在建立...
    python -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo   錯誤: 無法建立虛擬環境！請確認 Python 3.11+ 已安裝。
        pause
        exit /b 1
    )
    echo   虛擬環境已建立。
) else (
    echo   虛擬環境 OK
)

:: ── 步驟 2: 檢查 Hermes 安裝 ──
echo.
echo [2/5] 檢查 Hermes 安裝...
"%VENV_PYTHON%" -c "import hermes_cli; print('OK')" >nul 2>&1
if errorlevel 1 (
    echo   Hermes 未安裝，正在安裝...
    "%VENV_PIP%" install -e "%HERMES_DIR%"
    if errorlevel 1 (
        echo   錯誤: 安裝失敗！
        pause
        exit /b 1
    )
) else (
    echo   Hermes 安裝 OK
)

:: ── 步驟 3: 檢查 Web Dashboard 依賴 ──
echo.
echo [3/5] 檢查 Web Dashboard 依賴...
"%VENV_PYTHON%" -c "import fastapi, uvicorn; print('OK')" >nul 2>&1
if errorlevel 1 (
    echo   安裝 Web Dashboard 依賴 (fastapi, uvicorn)...
    "%VENV_PIP%" install fastapi uvicorn
) else (
    echo   Web Dashboard 依賴 OK
)

:: ── 步驟 4: 檢查 LM Studio 連接 ──
echo.
echo [4/5] 檢查 LM Studio 本地模型...
powershell -Command "try { $null = Invoke-WebRequest -Uri 'http://127.0.0.1:1234/v1/models' -Method GET -TimeoutSec 3; Write-Host '  LM Studio 運行正常' } catch { Write-Host '  警告: LM Studio 未運行！請先啟動 LM Studio 並開啟 Server 模式。' }"
echo   配置: provider=lmstudio, base_url=http://127.0.0.1:1234/v1

:: ── 步驟 5: 載入環境變數 ──
echo.
echo [5/5] 載入環境設定...
if exist "%HERMES_HOME%\.env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%HERMES_HOME%\.env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" (
            set "%%a=%%b"
        )
    )
    echo   已載入: %HERMES_HOME%\.env
) else (
    echo   無 .env 檔案（可選）
)

:: ── 顯示配置摘要 ──
echo.
echo ==========================================
echo   配置摘要:
echo   Provider:  lmstudio (LM Studio 本地模型)
echo   API 地址:  http://127.0.0.1:1234/v1
echo   終端模式:  local (PowerShell)
echo   UI 模式:   Web Dashboard (瀏覽器)
echo ==========================================
echo.
echo 正在啟動 Hermes Web Dashboard...
echo 瀏覽器將自動開啟 http://127.0.0.1:9119
echo.
echo 按 Ctrl+C 可停止伺服器
echo.

:: ── 啟動 Web Dashboard ──
cd /d "%HERMES_DIR%"
"%VENV_HERMES%" dashboard
