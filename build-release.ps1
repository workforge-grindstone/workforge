$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$appRoot = Join-Path $repoRoot "1099"
$distRoot = Join-Path $repoRoot "dist"
$bundleRoot = Join-Path $distRoot "BusinessHub-Windows"
$version = if ($env:GITHUB_REF_NAME) { $env:GITHUB_REF_NAME } else { "dev-build" }
$zipPath = Join-Path $distRoot "business-hub-windows-$version.zip"

if (-not (Test-Path -LiteralPath $appRoot)) {
  throw "App folder not found at $appRoot"
}

if (Test-Path -LiteralPath $distRoot) {
  Remove-Item -LiteralPath $distRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $bundleRoot | Out-Null

$filesToCopy = @(
  "app.js",
  "index.html",
  "styles.css",
  "README.md",
  "desktop-launcher.ps1",
  "launch-business-hub.cmd",
  "launch-business-hub.vbs"
)

foreach ($file in $filesToCopy) {
  Copy-Item -LiteralPath (Join-Path $appRoot $file) -Destination (Join-Path $bundleRoot $file)
}

$releaseNotes = @"
Business Hub desktop-ready release

How to launch:
- Double-click launch-business-hub.vbs for the cleanest app-style window.
- If needed, use launch-business-hub.cmd instead.

Included files:
- Business Hub app HTML/CSS/JS
- Windows launchers
- README with setup notes
"@

Set-Content -LiteralPath (Join-Path $bundleRoot "RELEASE-NOTES.txt") -Value $releaseNotes

Compress-Archive -Path (Join-Path $bundleRoot "*") -DestinationPath $zipPath -Force

Write-Host "Created release bundle:"
Write-Host $zipPath
