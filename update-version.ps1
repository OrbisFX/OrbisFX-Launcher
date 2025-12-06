param(
    [Parameter(Mandatory=$true)]
    [string]$NewVersion
)

Write-Host "Updating version to $NewVersion..."

# Update tauri.conf.json
$tauriConf = Get-Content 'src-tauri\tauri.conf.json' -Raw
$tauriConf = $tauriConf -replace '"version": "[^"]+"', "`"version`": `"$NewVersion`""
Set-Content 'src-tauri\tauri.conf.json' $tauriConf -NoNewline
Write-Host "  Updated tauri.conf.json"

# Update Cargo.toml - only the package version (line after [package] and name)
$cargoLines = Get-Content 'src-tauri\Cargo.toml'
$updated = $false
for ($i = 0; $i -lt $cargoLines.Count; $i++) {
    if (-not $updated -and $cargoLines[$i] -match '^version = "') {
        $cargoLines[$i] = "version = `"$NewVersion`""
        $updated = $true
        break
    }
}
$cargoLines | Set-Content 'src-tauri\Cargo.toml'
Write-Host "  Updated Cargo.toml"

# Update package.json - only the top-level version
$pkgLines = Get-Content 'package.json'
$updated = $false
for ($i = 0; $i -lt $pkgLines.Count; $i++) {
    if (-not $updated -and $pkgLines[$i] -match '^\s*"version":\s*"') {
        $pkgLines[$i] = $pkgLines[$i] -replace '"version":\s*"[^"]+"', "`"version`": `"$NewVersion`""
        $updated = $true
        break
    }
}
$pkgLines | Set-Content 'package.json'
Write-Host "  Updated package.json"

Write-Host "Version updated to $NewVersion"

