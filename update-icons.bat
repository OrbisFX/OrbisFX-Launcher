@echo off
setlocal
title OrbisFX Launcher - Icon Update Tool
color 0B

echo.
echo ================================================
echo   OrbisFX Launcher - Icon Update Tool
echo ================================================
echo.

REM Check if source logo exists
if not exist "public\logo.png" (
    echo ERROR: Source logo not found at public\logo.png
    pause
    exit /b 1
)

echo Generating icons from public\logo.png...
echo.

powershell -ExecutionPolicy Bypass -File generate-icons.ps1

echo.
pause

