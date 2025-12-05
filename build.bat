@echo off
title HyFX Installer - Production Build
color 0A

echo.
echo ========================================
echo   HyFX Installer - Production Build
echo ========================================
echo.

REM Kill any existing processes
taskkill /F /IM node.exe 2>nul
timeout /t 1 /nobreak

echo Building React frontend...
call npm run build

if %ERRORLEVEL% neq 0 (
    echo.
    echo ========================================
    echo   BUILD FAILED
    echo ========================================
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo Output location: ./dist/
echo Ready to package with electron-builder
echo.
pause
