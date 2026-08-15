# Battery Tracker

Battery Tracker is an offline-first rechargeable-battery inventory and device-management application.

The initial target is **Windows 11**. The architecture is intended to remain portable to Android, iPhone/iPad, and macOS.

> Development status: Flutter projects reconciled; Phase 1 architecture complete; Phase 2 not started. Product requirements are defined in `Battery_Tracker_Master_Codex_Prompt.md`.

## Core Version 1 scope

- Battery Types
- Individual Battery inventory
- Battery Sets
- Devices
- Battery and Set assignments
- Charge history and Recorded Charges
- Icon-first, photo-optional visual system
- Built-in generic icons
- Icon colors
- Imported PNG/SVG custom icons
- Optional photographs
- Bulk Battery Creation
- Batch IDs
- Bulk Edit and bulk charging
- UUID-based QR codes
- QR label designer and templates
- Label sheet printing
- PDF label export
- Dashboard and activity history
- CSV import/export
- Complete backup and restore

## Technology direction

- Flutter
- Dart
- SQLite
- Local application-managed asset storage
- Repository/data-access layer
- Cross-platform service interfaces

## Repository instructions

Codex must read:

1. `AGENTS.md`
2. `CODEX_INSTRUCTIONS.md`
3. `Battery_Tracker_Master_Codex_Prompt.md`
4. `docs/IMPLEMENTATION_PLAN.md`

before substantial implementation work.

## Bootstrap

The repository contains Flutter-generated Windows, Android, iOS, and macOS project files reconciled with the original authored starter. The control documents and starter source remain intact.

On a Windows development computer, the repository scripts automatically locate Flutter in this order:

1. `BATTERY_TRACKER_FLUTTER_ROOT`
2. `flutter` on `PATH`
3. Common per-user locations, including `Develop\flutter`
4. `C:\src\flutter` and `C:\flutter`

Run the bootstrap script:

```powershell
.\scripts\bootstrap_windows.ps1
```

For a custom SDK location, set a temporary override for the current PowerShell session:

```powershell
$env:BATTERY_TRACKER_FLUTTER_ROOT = "D:\SDKs\flutter"
.\scripts\bootstrap_windows.ps1
```

The override must point to the Flutter SDK root containing `bin\flutter.bat` and `bin\dart.bat`.

If Flutter is already on `PATH`, the equivalent manual package command is:

```powershell
flutter pub get
```

Review generated files and preserve the project-control documents already in this repository.

Then run:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run -d windows
```

For a release build:

```powershell
flutter build windows
```

## Project structure

```text
.
├── AGENTS.md
├── CODEX_INSTRUCTIONS.md
├── CODEX_START_HERE.md
├── Battery_Tracker_Master_Codex_Prompt.md
├── README.md
├── pubspec.yaml
├── docs/
│   ├── IMPLEMENTATION_PLAN.md
│   ├── ARCHITECTURE.md
│   └── DATABASE_PLAN.md
├── lib/
│   ├── app/
│   ├── core/
│   ├── features/
│   └── services/
├── android/
├── ios/
├── macos/
├── windows/
├── scripts/
└── test/
```

## Visual principle

**Icons identify inventory. Photographs add detail.**

The default primary visual is an icon. Photos are optional and remain supplemental unless the user explicitly chooses Photo as Primary.

## Data identity

Permanent UUIDs are the authoritative identity for Batteries, Battery Sets, Devices, and Custom Icons.

User-facing IDs such as `AA-001` remain editable and must not be used as immutable identity.

## Local data

The final implementation must document the actual operating-system storage locations for:

- SQLite database
- photographs
- custom icons
- backups
- logs

Do not hard-code machine-specific absolute paths into persistent domain records.

The selected logical layout is documented in `docs/ARCHITECTURE.md`. Physical paths are resolved at runtime beneath the platform application-support directory. SQLite stores only safe relative asset references.

## Testing

Run the complete PowerShell check script after meaningful changes. It uses the same automatic SDK discovery:

```powershell
.\scripts\check.ps1
```

If Flutter and Dart are on `PATH`, the equivalent individual commands are:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows
```

The complete acceptance scenarios are in `Battery_Tracker_Master_Codex_Prompt.md`.

## Version

Initial application version:

`0.1.0`

Use semantic versioning.

## Development plan

See `docs/IMPLEMENTATION_PLAN.md`.

## Known starter limitation

On the inspected Windows workstation, Flutter is installed at `C:\Users\jay15\Develop\flutter` but is not on `PATH`. The repository scripts now locate that installation automatically. Visual Studio with the Desktop development with C++ workload is not installed, so a Windows executable cannot be compiled until that prerequisite is added.

The current Codex workspace is under OneDrive and inherits a delete-deny ACL that prevents Flutter from refreshing generated `build/` and Apple `ephemeral/` directories. Verification can run from a temporary non-OneDrive snapshot without changing product code. A normal local checkout without that ACL should use the standard commands above.
