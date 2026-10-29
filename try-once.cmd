@echo off
setlocal
chcp 65001 >nul 2>&1
title P106 PCIe Gen2 - One-pass Test
cd /d "%~dp0"

net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Administrator rights required.
    echo         Right-click this file and choose "Run as administrator".
    pause
    exit /b 1
)

call "%~dp0build.cmd"
if errorlevel 1 (
    pause
    exit /b 1
)

set "DEVARG=%*"
echo [1/3] Read-only probe...
"%~dp0bin\P106Gen2x4.exe" -probe %DEVARG% > "%~dp0probe-output.txt" 2>&1
set PROBE_RC=%ERRORLEVEL%
type "%~dp0probe-output.txt"
if not "%PROBE_RC%"=="0" (
    echo.
    echo [STOP] Probe failed. No GPU registers were written.
    echo        Saved output: %~dp0probe-output.txt
    pause
    exit /b 2
)

echo.
echo [2/3] One-pass unlock. The PCIe link may disappear briefly.
echo        Do not power off the machine during this step.
echo.
"%~dp0bin\P106Gen2x4.exe" -once %DEVARG%
set ONCE_RC=%ERRORLEVEL%

echo.
echo [3/3] Register-level check...
"%~dp0bin\P106Gen2x4.exe" -diag %DEVARG%

echo.
echo ============================================================
if "%ONCE_RC%"=="0" (
    echo   The one-pass test reached Gen2.
    echo   Run install.cmd to install the hold task.
) else (
    echo   The one-pass test did not reach Gen2.
    echo   Keep this window output for diagnosis.
)
echo ============================================================
echo.
pause
exit /b %ONCE_RC%
