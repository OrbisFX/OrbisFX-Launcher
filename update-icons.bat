@echo off
setlocal
title OrbisFX Launcher - Icon Update Tool
color 0B

echo.
echo ================================================
echo   OrbisFX Launcher - Icon Update Tool
echo ================================================
echo.
echo This script helps update the application icons.
echo.
echo Prerequisites:
echo   - ImageMagick must be installed (https://imagemagick.org/)
echo   - The source logo should be at: public\logo.png
echo.

REM Check if ImageMagick is installed
where magick >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: ImageMagick is not installed or not in PATH.
    echo Please install it from: https://imagemagick.org/script/download.php
    echo.
    echo After installing, run this script again.
    pause
    exit /b 1
)

REM Check if source logo exists
if not exist "public\logo.png" (
    echo ERROR: Source logo not found at public\logo.png
    pause
    exit /b 1
)

echo Found ImageMagick and source logo. Generating icons...
echo.

REM Create icons directory if it doesn't exist
if not exist "src-tauri\icons" mkdir "src-tauri\icons"

REM Generate PNG icons at various sizes
echo Generating PNG icons...
magick "public\logo.png" -resize 32x32 "src-tauri\icons\32x32.png"
magick "public\logo.png" -resize 128x128 "src-tauri\icons\128x128.png"
magick "public\logo.png" -resize 256x256 "src-tauri\icons\128x128@2x.png"
magick "public\logo.png" -resize 512x512 "src-tauri\icons\icon.png"

REM Generate Windows Store logos
echo Generating Windows Store logos...
magick "public\logo.png" -resize 30x30 "src-tauri\icons\Square30x30Logo.png"
magick "public\logo.png" -resize 44x44 "src-tauri\icons\Square44x44Logo.png"
magick "public\logo.png" -resize 71x71 "src-tauri\icons\Square71x71Logo.png"
magick "public\logo.png" -resize 89x89 "src-tauri\icons\Square89x89Logo.png"
magick "public\logo.png" -resize 107x107 "src-tauri\icons\Square107x107Logo.png"
magick "public\logo.png" -resize 142x142 "src-tauri\icons\Square142x142Logo.png"
magick "public\logo.png" -resize 150x150 "src-tauri\icons\Square150x150Logo.png"
magick "public\logo.png" -resize 284x284 "src-tauri\icons\Square284x284Logo.png"
magick "public\logo.png" -resize 310x310 "src-tauri\icons\Square310x310Logo.png"
magick "public\logo.png" -resize 50x50 "src-tauri\icons\StoreLogo.png"

REM Generate ICO file (Windows)
echo Generating Windows ICO file...
magick "public\logo.png" -define icon:auto-resize=256,128,96,64,48,32,16 "src-tauri\icons\icon.ico"

REM Generate ICNS file (macOS)
echo Generating macOS ICNS file...
magick "public\logo.png" -resize 512x512 "src-tauri\icons\icon.icns"

echo.
echo ================================================
echo   Icons Updated Successfully!
echo ================================================
echo.
echo All icon files have been generated in src-tauri\icons\
echo.
echo You can now rebuild the application to use the new icons.
echo.
pause

