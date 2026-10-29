@echo off
setlocal
chcp 65001 >nul 2>&1
title P106 PCIe Gen2 - Read-only Probe
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

echo.
echo Supported IDs:
echo   10DE:1C06 = P106-100
echo   10DE:1C07 = P106-100 alternate ID
echo   10DE:1C09 = P106-090
echo.
echo Running read-only probe. This does NOT write GPU registers.
echo.
"%~dp0bin\P106Gen2x4.exe" -probe %* > "%~dp0probe-output.txt" 2>&1
set RC=%ERRORLEVEL%
type "%~dp0probe-output.txt"
echo.
if not "%RC%"=="0" (
    echo Probe returned code %RC%.
    echo Keep the output above. Do not run the unlock path until it is reviewed.
)
pause
exit /b %RC%
