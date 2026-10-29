@echo off
setlocal
chcp 65001 >nul 2>&1
title P106 PCIe Gen2 - Status
cd /d "%~dp0"

set "EXE=C:\Program Files\P106Gen2x4\P106Gen2x4.exe"
if not exist "%EXE%" set "EXE=%~dp0bin\P106Gen2x4.exe"
if not exist "%EXE%" (
    echo [ERROR] P106Gen2x4.exe was not found.
    echo         Run install.cmd as administrator first.
    pause
    exit /b 1
)

"%EXE%" -status %*
echo.
pause
