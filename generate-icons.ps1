# OrbisFX Launcher Icon Generator
# Generates all required icons from public/logo.png using .NET

param(
    [string]$SourceImage = "public\logo.png",
    [string]$OutputDir = "src-tauri\icons"
)

Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $SourceImage)) {
    Write-Error "Source image not found: $SourceImage"
    exit 1
}

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "Loading source image: $SourceImage"
$sourceImg = [System.Drawing.Image]::FromFile((Resolve-Path $SourceImage).Path)

function Resize-Image {
    param(
        [System.Drawing.Image]$Image,
        [int]$Width,
        [int]$Height,
        [string]$OutputPath
    )
    
    $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    $graphics.DrawImage($Image, 0, 0, $Width, $Height)
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $bitmap.Dispose()
    
    Write-Host "  Created: $OutputPath ($Width x $Height)"
}

Write-Host ""
Write-Host "Generating PNG icons..."

# Standard Tauri icons
Resize-Image -Image $sourceImg -Width 32 -Height 32 -OutputPath "$OutputDir\32x32.png"
Resize-Image -Image $sourceImg -Width 128 -Height 128 -OutputPath "$OutputDir\128x128.png"
Resize-Image -Image $sourceImg -Width 256 -Height 256 -OutputPath "$OutputDir\128x128@2x.png"
Resize-Image -Image $sourceImg -Width 512 -Height 512 -OutputPath "$OutputDir\icon.png"

Write-Host ""
Write-Host "Generating Windows Store logos..."

# Windows Store logos
Resize-Image -Image $sourceImg -Width 30 -Height 30 -OutputPath "$OutputDir\Square30x30Logo.png"
Resize-Image -Image $sourceImg -Width 44 -Height 44 -OutputPath "$OutputDir\Square44x44Logo.png"
Resize-Image -Image $sourceImg -Width 71 -Height 71 -OutputPath "$OutputDir\Square71x71Logo.png"
Resize-Image -Image $sourceImg -Width 89 -Height 89 -OutputPath "$OutputDir\Square89x89Logo.png"
Resize-Image -Image $sourceImg -Width 107 -Height 107 -OutputPath "$OutputDir\Square107x107Logo.png"
Resize-Image -Image $sourceImg -Width 142 -Height 142 -OutputPath "$OutputDir\Square142x142Logo.png"
Resize-Image -Image $sourceImg -Width 150 -Height 150 -OutputPath "$OutputDir\Square150x150Logo.png"
Resize-Image -Image $sourceImg -Width 284 -Height 284 -OutputPath "$OutputDir\Square284x284Logo.png"
Resize-Image -Image $sourceImg -Width 310 -Height 310 -OutputPath "$OutputDir\Square310x310Logo.png"
Resize-Image -Image $sourceImg -Width 50 -Height 50 -OutputPath "$OutputDir\StoreLogo.png"

Write-Host ""
Write-Host "Generating Windows ICO file..."

# Create proper ICO file with multiple sizes
$icoSizes = @(16, 32, 48, 256)
$icoPath = "$OutputDir\icon.ico"

# Build ICO file manually with proper format
$ms = New-Object System.IO.MemoryStream

# ICO Header: reserved (2 bytes), type (2 bytes), count (2 bytes)
$writer = New-Object System.IO.BinaryWriter($ms)
$writer.Write([UInt16]0)        # Reserved
$writer.Write([UInt16]1)        # Type: 1 = ICO
$writer.Write([UInt16]$icoSizes.Count)  # Number of images

# Calculate header size and initial offset
$headerSize = 6 + ($icoSizes.Count * 16)  # 6 byte header + 16 bytes per entry
$currentOffset = $headerSize

# Store PNG data for each size
$pngDataList = @()
foreach ($size in $icoSizes) {
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.DrawImage($sourceImg, 0, 0, $size, $size)
    $graphics.Dispose()

    $pngStream = New-Object System.IO.MemoryStream
    $bitmap.Save($pngStream, [System.Drawing.Imaging.ImageFormat]::Png)
    $pngData = $pngStream.ToArray()
    $pngDataList += ,@($size, $pngData)
    $pngStream.Dispose()
    $bitmap.Dispose()
}

# Write ICONDIRENTRY for each image
foreach ($entry in $pngDataList) {
    $size = $entry[0]
    $pngData = $entry[1]

    $writer.Write([byte]$(if ($size -ge 256) { 0 } else { $size }))  # Width
    $writer.Write([byte]$(if ($size -ge 256) { 0 } else { $size }))  # Height
    $writer.Write([byte]0)          # Color palette
    $writer.Write([byte]0)          # Reserved (must be 0)
    $writer.Write([UInt16]1)        # Color planes
    $writer.Write([UInt16]32)       # Bits per pixel
    $writer.Write([UInt32]$pngData.Length)  # Image size
    $writer.Write([UInt32]$currentOffset)   # Offset

    $currentOffset += $pngData.Length
}

# Write PNG data for each image
foreach ($entry in $pngDataList) {
    $pngData = $entry[1]
    $writer.Write($pngData)
}

$writer.Flush()
[System.IO.File]::WriteAllBytes($icoPath, $ms.ToArray())
$writer.Dispose()
$ms.Dispose()

Write-Host "  Created: $OutputDir\icon.ico"

# For ICNS (macOS), we'll just create a 512x512 PNG as placeholder
# macOS ICNS requires special tooling that's not available on Windows
Write-Host ""
Write-Host "Note: ICNS file requires macOS tools to create properly."
Write-Host "      Copying 512x512 PNG as placeholder icon.icns"
Copy-Item "$OutputDir\icon.png" "$OutputDir\icon.icns" -Force

$sourceImg.Dispose()

Write-Host ""
Write-Host "================================================"
Write-Host "  Icons Generated Successfully!"
Write-Host "================================================"
Write-Host ""
Write-Host "All icons have been created in $OutputDir"

