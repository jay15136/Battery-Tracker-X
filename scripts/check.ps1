$ErrorActionPreference = "Stop"

Write-Host "Restoring packages..."
flutter pub get

Write-Host "Checking formatting..."
dart format --output=none --set-exit-if-changed .

Write-Host "Running static analysis..."
flutter analyze

Write-Host "Running tests..."
flutter test

Write-Host "Building Windows application..."
flutter build windows

Write-Host "All checks completed successfully."
