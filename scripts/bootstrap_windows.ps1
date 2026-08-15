$ErrorActionPreference = "Stop"

Write-Host "Checking Flutter environment..."
flutter doctor -v

if (-not (Test-Path "windows")) {
    Write-Host "Generating Flutter platform files..."
    flutter create . --project-name battery_tracker --platforms=windows,android,ios,macos
}

Write-Host "Restoring packages..."
flutter pub get

Write-Host "Starter bootstrap complete."
Write-Host "Next: review docs/IMPLEMENTATION_PLAN.md and begin Phase 1."
