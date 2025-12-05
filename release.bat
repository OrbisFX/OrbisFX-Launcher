@echo off
setlocal enabledelayedexpansion
title OrbisFX Launcher - GitHub Release Tool
color 0B

echo.
echo ================================================
echo   OrbisFX Launcher - GitHub Release Tool
echo ================================================
echo.

REM Check if GitHub CLI is installed
where gh >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: GitHub CLI (gh) is not installed or not in PATH.
    echo Please install it from: https://cli.github.com/
    echo.
    pause
    exit /b 1
)

REM Check if user is authenticated with GitHub CLI
gh auth status >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Not authenticated with GitHub CLI.
    echo Please run: gh auth login
    echo.
    pause
    exit /b 1
)

REM Get current version from tauri.conf.json
for /f "tokens=2 delims=:," %%a in ('findstr /c:"\"version\":" src-tauri\tauri.conf.json') do (
    set "CURRENT_VERSION=%%~a"
)
set "CURRENT_VERSION=%CURRENT_VERSION: =%"
set "CURRENT_VERSION=%CURRENT_VERSION:"=%"

echo Current version: v%CURRENT_VERSION%
echo.

REM Ask for new version
set /p NEW_VERSION="Enter new version (e.g., 0.0.1) or press Enter to use current: "
if "%NEW_VERSION%"=="" set "NEW_VERSION=%CURRENT_VERSION%"

echo.
echo New version will be: v%NEW_VERSION%
echo.

REM Update version in config files if different
if not "%NEW_VERSION%"=="%CURRENT_VERSION%" (
    echo Updating version in configuration files...
    
    REM Update tauri.conf.json
    powershell -Command "(Get-Content 'src-tauri\tauri.conf.json') -replace '\"version\": \"%CURRENT_VERSION%\"', '\"version\": \"%NEW_VERSION%\"' | Set-Content 'src-tauri\tauri.conf.json'"
    
    REM Update Cargo.toml
    powershell -Command "(Get-Content 'src-tauri\Cargo.toml') -replace 'version = \"%CURRENT_VERSION%\"', 'version = \"%NEW_VERSION%\"' | Set-Content 'src-tauri\Cargo.toml'"
    
    REM Update package.json
    powershell -Command "(Get-Content 'package.json') -replace '\"version\": \"%CURRENT_VERSION%\"', '\"version\": \"%NEW_VERSION%\"' | Set-Content 'package.json'"
    
    echo Version updated to %NEW_VERSION% in all config files.
    echo.
)

REM Build the application
echo ================================================
echo   Building OrbisFX Launcher...
echo ================================================
echo.

REM Kill any existing processes
taskkill /F /IM node.exe 2>nul
timeout /t 2 /nobreak >nul

REM Run Tauri build
call npm run build

if %ERRORLEVEL% neq 0 (
    echo.
    echo ================================================
    echo   BUILD FAILED
    echo ================================================
    echo.
    pause
    exit /b 1
)

echo.
echo Build completed successfully!
echo.

REM Find the built EXE
set "EXE_PATH=src-tauri\target\release\orbisfx-launcher.exe"
if not exist "%EXE_PATH%" (
    REM Try alternative naming
    set "EXE_PATH=src-tauri\target\release\OrbisFX Launcher.exe"
)

if not exist "%EXE_PATH%" (
    echo ERROR: Could not find built executable.
    echo Expected at: src-tauri\target\release\
    pause
    exit /b 1
)

echo Found executable: %EXE_PATH%
echo.

REM Ask for release notes
echo Enter release notes (or press Enter for default):
set /p RELEASE_NOTES="Notes: "
if "%RELEASE_NOTES%"=="" set "RELEASE_NOTES=OrbisFX Launcher v%NEW_VERSION%"

echo.
echo ================================================
echo   Creating GitHub Release v%NEW_VERSION%
echo ================================================
echo.

REM Create the release with the executable attached
gh release create "v%NEW_VERSION%" "%EXE_PATH%" --title "OrbisFX Launcher v%NEW_VERSION%" --notes "%RELEASE_NOTES%"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Failed to create GitHub release.
    echo Make sure you have push access to the repository.
    pause
    exit /b 1
)

echo.
echo ================================================
echo   Release v%NEW_VERSION% Created Successfully!
echo ================================================
echo.
echo The release has been published to GitHub.
echo.
pause

