@echo off
setlocal
title P106 PCIe Gen2 - Uninstall
cd /d "%~dp0"

net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Administrator rights required.
    echo         Right-click this file and choose "Run as administrator".
    pause
    exit /b 1
)

set "EXE=C:\Program Files\P106Gen2x4\P106Gen2x4.exe"
if not exist "%EXE%" set "EXE=%~dp0bin\P106Gen2x4.exe"
if not exist "%EXE%" (
    echo [ERROR] P106Gen2x4.exe was not found.
    exit /b 1
)

echo [1/4] Stopping the hold process...
schtasks /end /tn "P106 PCIe Gen2 Bring-up" >nul 2>&1
set /a WAITN=0
:WAITLOOP
tasklist /FI "IMAGENAME eq P106Gen2x4.exe" 2>nul | find /I "P106Gen2x4.exe" >nul
if errorlevel 1 goto PROCGONE
timeout /t 1 /nobreak >nul 2>&1
set /a WAITN+=1
if %WAITN% LSS 8 goto WAITLOOP
echo.
echo   [STOP] The hold process is still running.
echo          A kernel driver handle must not be force-killed.
echo          Reboot, then run uninstall.cmd again.
pause
exit /b 2
:PROCGONE

echo [2/4] Removing task, services and driver policy...
"%EXE%" -uninstall %*

echo [3/4] Restoring GPU registers...
"%EXE%" -off %*

echo [4/4] Removing installed files...
if exist "C:\Program Files\P106Gen2x4" rmdir /S /Q "C:\Program Files\P106Gen2x4"
if exist "C:\ProgramData\P106Gen2x4" rmdir /S /Q "C:\ProgramData\P106Gen2x4"

echo.
echo Uninstalled. Reboot to fully restore the GPU.
pause
