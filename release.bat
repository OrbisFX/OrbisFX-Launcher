@echo off
setlocal
title OrbisFX Launcher - GitHub Release Tool
color 0B

echo.
echo ================================================
echo   OrbisFX Launcher - GitHub Release Tool
echo ================================================
echo.

REM Check if GitHub CLI is installed
echo Checking for GitHub CLI...
where gh >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: GitHub CLI [gh] is not installed or not in PATH.
    echo Please install it from: https://cli.github.com/
    echo.
    pause
    exit /b 1
)
echo GitHub CLI found.

REM Check if user is authenticated with GitHub CLI
echo Checking GitHub authentication...
gh auth status >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Not authenticated with GitHub CLI.
    echo Please run: gh auth login
    echo.
    pause
    exit /b 1
)
echo GitHub authenticated.

REM Get current version using PowerShell
echo.
echo Reading current version...
for /f "delims=" %%v in ('powershell -Command "(Get-Content 'src-tauri\tauri.conf.json' | ConvertFrom-Json).version"') do set "CURRENT_VERSION=%%v"

REM Parse version into parts
for /f "tokens=1,2,3 delims=." %%a in ("%CURRENT_VERSION%") do (
    set "MAJOR=%%a"
    set "MINOR=%%b"
    set "PATCH=%%c"
)

REM Calculate next versions
set /a "NEXT_PATCH=%PATCH%+1"
set /a "NEXT_MINOR=%MINOR%+1"
set /a "NEXT_MAJOR=%MAJOR%+1"

set "PATCH_VERSION=%MAJOR%.%MINOR%.%NEXT_PATCH%"
set "MINOR_VERSION=%MAJOR%.%NEXT_MINOR%.0"
set "MAJOR_VERSION=%NEXT_MAJOR%.0.0"

echo.
echo Current version: v%CURRENT_VERSION%
echo.
echo ------------------------------------------------
echo   Select version bump type:
echo ------------------------------------------------
echo.
echo   [1] Patch  (bug fixes)      : v%PATCH_VERSION%
echo   [2] Minor  (new features)   : v%MINOR_VERSION%
echo   [3] Major  (breaking changes): v%MAJOR_VERSION%
echo   [4] Custom (enter manually)
echo   [5] No change (use current) : v%CURRENT_VERSION%
echo.
choice /c 12345 /n /m "Select option (1-5): "

if errorlevel 5 set "NEW_VERSION=%CURRENT_VERSION%"
if errorlevel 5 goto :version_selected
if errorlevel 4 goto :custom_version
if errorlevel 3 set "NEW_VERSION=%MAJOR_VERSION%"
if errorlevel 3 goto :version_selected
if errorlevel 2 set "NEW_VERSION=%MINOR_VERSION%"
if errorlevel 2 goto :version_selected
if errorlevel 1 set "NEW_VERSION=%PATCH_VERSION%"
goto :version_selected

:custom_version
set /p "NEW_VERSION=Enter version (e.g., 1.2.3): "
if "%NEW_VERSION%"=="" set "NEW_VERSION=%CURRENT_VERSION%"

:version_selected
echo.
echo New version will be: v%NEW_VERSION%
echo.

REM Update version in config files if different
if not "%NEW_VERSION%"=="%CURRENT_VERSION%" (
    powershell -ExecutionPolicy Bypass -File update-version.ps1 -NewVersion "%NEW_VERSION%"
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
if errorlevel 1 (
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
if not exist "%EXE_PATH%" set "EXE_PATH=src-tauri\target\release\OrbisFX Launcher.exe"

if not exist "%EXE_PATH%" (
    echo ERROR: Could not find built executable.
    echo Expected at: src-tauri\target\release\
    dir src-tauri\target\release\*.exe 2>nul
    pause
    exit /b 1
)

echo Found executable: %EXE_PATH%
echo.

REM Ask for release notes
echo.
echo ------------------------------------------------
echo   Release Notes Options:
echo ------------------------------------------------
echo.
echo   [1] Use RELEASE_NOTES.md file
echo   [2] Enter single-line note
echo   [3] Use default (just version number)
echo.
choice /c 123 /n /m "Select option (1-3): "

if errorlevel 3 goto :default_notes
if errorlevel 2 goto :single_line_notes
if errorlevel 1 goto :file_notes

:file_notes
if not exist "RELEASE_NOTES.md" (
    echo.
    echo RELEASE_NOTES.md not found. Creating template...
    echo ## v%NEW_VERSION%> RELEASE_NOTES.md
    echo.>> RELEASE_NOTES.md
    echo Describe your changes here.>> RELEASE_NOTES.md
    echo.
    echo Template created. Edit RELEASE_NOTES.md and run this script again.
    start notepad RELEASE_NOTES.md
    pause
    exit /b 0
)
set "USE_NOTES_FILE=1"
goto :notes_ready

:single_line_notes
set /p "RELEASE_NOTES=Enter release notes: "
if "%RELEASE_NOTES%"=="" set "RELEASE_NOTES=OrbisFX Launcher v%NEW_VERSION%"
set "USE_NOTES_FILE=0"
goto :notes_ready

:default_notes
set "RELEASE_NOTES=OrbisFX Launcher v%NEW_VERSION%"
set "USE_NOTES_FILE=0"
goto :notes_ready

:notes_ready
echo.
echo ================================================
echo   Creating GitHub Release v%NEW_VERSION%
echo ================================================
echo.

REM Create the release with the executable attached
if "%USE_NOTES_FILE%"=="1" (
    gh release create "v%NEW_VERSION%" "%EXE_PATH%" --title "OrbisFX Launcher v%NEW_VERSION%" --notes-file "RELEASE_NOTES.md"
) else (
    gh release create "v%NEW_VERSION%" "%EXE_PATH%" --title "OrbisFX Launcher v%NEW_VERSION%" --notes "%RELEASE_NOTES%"
)
if errorlevel 1 (
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

