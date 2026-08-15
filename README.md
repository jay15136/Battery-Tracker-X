# Battery Tracker

Battery Tracker is an offline-first rechargeable-battery inventory and device-management application.

The initial target is **Windows 11**. The architecture is intended to remain portable to Android, iPhone/iPad, and macOS.

> Development status: Phase 4, Battery Types, is complete. Phase 5 Battery Inventory is next. Product requirements are defined in `Battery_Tracker_Master_Codex_Prompt.md`.

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

- Flutter with Material 3
- Dart and Riverpod
- SQLite through Drift
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
├── drift_schemas/
│   └── schema_v1.json
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

## Icon system

Settings → Icon Library provides 54 packaged SVG icons with Battery, Battery Set, Device, and General categories. The reusable chooser supports name/category/keyword search, Built-In/Custom/Recent filters, the required color palette, validated custom hex colors, previews, and owner-specific defaults.

Custom PNG and SVG imports receive permanent UUIDs and are copied into application-managed storage. SVG scripts and external content are rejected. Editing metadata or replacing a file never changes the custom icon UUID. In-use deletion reports the reference count and requires an explicit replacement icon or owner defaults; a missing custom file renders the owner default instead of a broken image.

## Battery Types

Battery Types are reusable, user-managed specifications. Each record has a required, case-insensitively unique active type name; optional description, chemistry, physical size, and notes; optional positive default voltage; an optional positive default capacity paired with a required capacity unit; and a suggested Battery-scope icon and color. Chemistry suggestions (NiMH, NiCd, Li-ion, LiPo, LiFePO4, Lead Acid, Proprietary, and Other) and capacity-unit suggestions (mAh, Ah, and Wh) are editable text suggestions, not closed lists.

The form defaults its visual suggestion to the built-in Generic Battery icon. The suggestion is not a forced inventory visual: future Battery records retain the icon-first rule and can select their own icon and color. A missing, unreadable, or inactive custom suggested icon renders the Battery default rather than a broken image.

A Battery Type receives a permanent UUID when created; editing never changes it. The page supports searchable Active, Inactive, and All views; it searches name, chemistry, physical size, and description. Deactivation is a confirmed, reference-preserving action. The dialog states the exact current usage as Batteries, Battery Sets, and Devices, then explains that existing references remain connected while new records will not use the type by default. Reactivation is also confirmed and refuses a name collision with another active type. Create, update, deactivate, and reactivate each run in a SQLite transaction and append a typed activity event; deactivation activity includes the three usage counts.

## Data identity

Permanent UUIDs are the authoritative identity for Batteries, Battery Sets, Devices, and Custom Icons.

User-facing IDs such as `AA-001` remain editable and must not be used as immutable identity.

## Local data

Battery Tracker resolves an operating-system application-support directory at runtime and creates a `BatteryTracker` directory beneath it. On Windows this is under the current user's roaming application-data directory, normally `%APPDATA%\<publisher>\<product>\BatteryTracker`.

The implemented Phase 3 layout is:

```text
BatteryTracker/
  database/battery_tracker.sqlite
  database/tmp/
  custom_icons/{custom-icon-uuid}/source-{revision-uuid}.png|svg
  logs/battery_tracker.log
```

Later feature phases add:

- `photos/`
- `label_templates/`
- `backups/`

Do not hard-code machine-specific absolute paths into persistent domain records.

The selected logical layout is documented in `docs/ARCHITECTURE.md`. SQLite stores only safe relative asset references. The schema is created through migration version 1, enables foreign keys on every connection, and persists timestamps as UTC ISO-8601 text.

## Database code generation

Drift's generated database API and versioned schema snapshot are committed. After changing table definitions or migrations, regenerate and review them:

```powershell
dart run build_runner build
dart run drift_dev schema dump lib\core\database\app_database.dart drift_schemas\schema_v1.json
```

Released migration snapshots must not be rewritten. Add the next contiguous migration and snapshot instead.

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

The current 151-test suite covers the foundation and icon system plus Battery Type validation, Drift-backed CRUD/restart persistence, UUID stability, case-insensitive active-name and reactivation conflicts, reference-preserving deactivation with exact usage metadata, activity events and transaction rollback, controller refresh behavior, form errors/editable suggestions, icon fallback, and responsive page workflows.

## Version

Initial application version:

`0.1.0`

Use semantic versioning.

## Development plan

See `docs/IMPLEMENTATION_PLAN.md`.

## Known environment limitations

On the inspected Windows workstation, Flutter is installed at `C:\Users\jay15\Develop\flutter` but is not on `PATH`. The repository scripts locate that installation automatically. Flutter detects Visual Studio Professional 2026 with its Windows C++ toolchain, and the Phase 3 Windows Release build succeeds and passes repeated launch checks.

The current Codex workspace is under OneDrive and inherits a delete-deny ACL that prevents Flutter from refreshing generated `build/` and Apple `ephemeral/` directories. Phase 4 final verification ran in the linked normal-ACL TEMP worktree outside the OneDrive checkout. A normal local checkout without that ACL should use the standard commands above. Visual Studio warns when a build output is under `%TEMP%`; the Phase 4 Release build and both five-second launch checks nevertheless completed successfully.
