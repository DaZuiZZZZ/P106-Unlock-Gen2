@echo off
setlocal EnableExtensions
chcp 65001 >nul 2>&1
title P106 PCIe Gen2 - Install
cd /d "%~dp0"

echo ============================================================
echo   P106-100 / P106-090 PCIe Gen2 - Install
echo ============================================================
echo.

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

set "DEVARG="
set "CHOICE="
echo Select the target card:
echo   1 = P106-100  (10DE:1C06)
echo   2 = P106-090  (10DE:1C09)
echo   3 = P106-100 alternate ID (10DE:1C07)
echo   4 = Auto detect
echo.
set /p "CHOICE=Enter 1/2/3/4 [4]: "
if "%CHOICE%"=="" set "CHOICE=4"
if "%CHOICE%"=="1" set "DEVARG=-dev 1c06"
if "%CHOICE%"=="2" set "DEVARG=-dev 1c09"
if "%CHOICE%"=="3" set "DEVARG=-dev 1c07"
if "%CHOICE%"=="4" set "DEVARG="
if not "%CHOICE%"=="1" if not "%CHOICE%"=="2" if not "%CHOICE%"=="3" if not "%CHOICE%"=="4" (
    echo [ERROR] Invalid choice.
    pause
    exit /b 1
)

echo.
echo [1/5] Read-only compatibility probe...
"%~dp0bin\P106Gen2x4.exe" -probe %DEVARG% > "%~dp0probe-output.txt" 2>&1
set PROBE_RC=%ERRORLEVEL%
type "%~dp0probe-output.txt"
if not "%PROBE_RC%"=="0" (
    echo.
    echo [STOP] Probe failed or the BAR0 fingerprint did not match.
    echo        No GPU registers were written by the probe.
    echo        Saved output: %~dp0probe-output.txt
    pause
    exit /b 2
)

echo.
echo [2/5] Deploying files, driver policy and autostart task...
"%~dp0bin\P106Gen2x4.exe" -install %DEVARG%
if errorlevel 1 (
    echo [ERROR] Install failed.
    pause
    exit /b 3
)

echo.
echo [3/5] First unlock pass...
"C:\Program Files\P106Gen2x4\P106Gen2x4.exe" -once %DEVARG%
set ONCE_RC=%ERRORLEVEL%

echo.
echo [4/5] Register-level check...
"C:\Program Files\P106Gen2x4\P106Gen2x4.exe" -diag %DEVARG%

echo.
echo [5/5] Status summary...
"C:\Program Files\P106Gen2x4\P106Gen2x4.exe" -status

echo.
echo ============================================================
if "%ONCE_RC%"=="0" (
    echo   First unlock pass reached Gen2.
) else (
    echo   First pass did not reach Gen2. The hold task will retry.
)
echo.
echo   A reboot is recommended. After reboot, wait 1-3 minutes,
echo   then run status.cmd.
echo ============================================================
echo.
pause
exit /b 0
