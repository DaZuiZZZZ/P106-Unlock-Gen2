@echo off
setlocal
chcp 65001 >nul 2>&1
title Build P106 PCIe Gen2 Tool
cd /d "%~dp0"

set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
set "SRC=%~dp0src\P106Gen2x4.cs"
set "OUT=%~dp0bin\P106Gen2x4.exe"

if not exist "%CSC%" (
    echo [ERROR] .NET Framework 4.x C# compiler was not found:
    echo         %CSC%
    echo.
    echo Windows 10/11 normally includes it. Repair .NET Framework 4.8 first.
    exit /b 1
)

if not exist "%SRC%" (
    echo [ERROR] Source file not found:
    echo         %SRC%
    exit /b 1
)

if not exist "%~dp0bin" mkdir "%~dp0bin"

echo Building:
echo   %SRC%
echo   -^> %OUT%
"%CSC%" /nologo /target:exe /platform:x64 /optimize+ ^
    /codepage:65001 /utf8output ^
    /out:"%OUT%" "%SRC%" ^
    /reference:System.dll /reference:System.Core.dll

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed.
    exit /b 1
)

echo.
echo [OK] Built %OUT%
exit /b 0
