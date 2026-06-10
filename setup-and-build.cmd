@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-and-build.ps1" -Target Studio
if errorlevel 1 (
    echo.
    echo Deployment or build failed.
    pause
    exit /b 1
)
echo.
echo Firmware is ready in the firmware folder.
pause
