@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion
title Hermes Agent - 一鍵啟動
color 0A

echo ==========================================
echo    Hermes Agent 一鍵啟動器
echo ==========================================
echo.

:: ── 設定路徑 ──
set "HERMES_DIR=%USERPROFILE%\hermes-agent"
set "VENV_DIR=%HERMES_DIR%\venv"
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
        echo   錯誤: 無法建立虛擬環境！
        pause
        exit /b 1
    )
) else (
    echo   OK
)

:: ── 步驟 2: 檢查 Hermes 安裝 ──
echo.
echo [2/5] 檢查 Hermes 安裝...
"%VENV_PYTHON%" -c "import hermes_cli" >nul 2>&1
if errorlevel 1 (
    echo   正在安裝...
    "%VENV_PIP%" install -e "%HERMES_DIR%" >nul 2>&1
    if errorlevel 1 (
        echo   錯誤: 安裝失敗！
        pause
        exit /b 1
    )
) else (
    echo   OK
)

:: ── 步驟 3: 載入環境變數 ──
echo.
echo [3/5] 載入環境設定...
if exist "%HERMES_HOME%\.env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%HERMES_HOME%\.env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" (
            set "%%a=%%b"
        )
    )
    echo   OK
) else (
    echo   無 .env（可選）
)

:: ── 步驟 4: 檢查 LM Studio 連接 ──
echo.
echo [4/5] 檢查 LM Studio 本地模型...
powershell -Command "try { $null = Invoke-WebRequest -Uri 'http://127.0.0.1:1234/v1/models' -Method GET -TimeoutSec 3; Write-Host '  LM Studio 運行正常' -ForegroundColor Green } catch { Write-Host '  警告: LM Studio 未運行！請先啟動 LM Studio 並開啟 Server 模式。' -ForegroundColor Yellow }"

:: ── 步驟 5: 啟動服務 ──
echo.
echo [5/5] 啟動 Hermes Agent...
echo.

:: ── 在背景啟動 Dashboard（配置管理） ──
echo 正在啟動 Dashboard（背景運行）...
start /b "" "%VENV_HERMES%" dashboard --skip-build --no-open >nul 2>&1
timeout /t 3 /nobreak >nul
start http://127.0.0.1:9119

echo.
echo ==========================================
echo   Hermes Agent 已啟動！
echo.
echo   Dashboard（配置管理）:
echo     http://127.0.0.1:9119
echo.
echo   以下進入聊天對話模式...
echo   輸入訊息即可開始與 AI 對話
echo   輸入 /help 查看所有命令
echo   輸入 /quit 或按 Ctrl+C 退出
echo ==========================================
echo.

:: ── 啟動互動式聊天（前景） ──
cd /d "%HERMES_DIR%"
"%VENV_HERMES%" chat
