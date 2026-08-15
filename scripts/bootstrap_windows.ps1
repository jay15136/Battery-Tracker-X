$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "flutter_sdk.ps1")
$flutterSdk = Resolve-FlutterSdk

Write-Host "Using Flutter SDK from $($flutterSdk.Source): $($flutterSdk.Root)"

Write-Host "Checking Flutter environment..."
& $flutterSdk.Flutter doctor -v

if (-not (Test-Path "windows")) {
    Write-Host "Generating Flutter platform files..."
    & $flutterSdk.Flutter create . --project-name battery_tracker --platforms=windows,android,ios,macos
}

Write-Host "Restoring packages..."
& $flutterSdk.Flutter pub get

Write-Host "Starter bootstrap complete."
Write-Host "Next: review docs/IMPLEMENTATION_PLAN.md and begin the first incomplete phase."
