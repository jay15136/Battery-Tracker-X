$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "flutter_sdk.ps1")
$flutterSdk = Resolve-FlutterSdk

Write-Host "Using Flutter SDK from $($flutterSdk.Source): $($flutterSdk.Root)"

Write-Host "Restoring packages..."
& $flutterSdk.Flutter pub get

Write-Host "Checking formatting..."
& $flutterSdk.Dart format --output=none --set-exit-if-changed .

Write-Host "Running static analysis..."
& $flutterSdk.Flutter analyze

Write-Host "Running tests..."
& $flutterSdk.Flutter test

Write-Host "Building Windows application..."
& $flutterSdk.Flutter build windows

Write-Host "All checks completed successfully."
