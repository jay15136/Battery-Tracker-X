# Battery Tracker

Battery Tracker is an offline-first rechargeable-battery inventory and device-management application.

The initial target is **Windows 11**. The architecture is intended to remain portable to Android, iPhone/iPad, and macOS.

> Development status: All 17 development phases are complete. Version 1 scope is implemented, tested, and verified with a Windows Release build. Product requirements are defined in `Battery_Tracker_Master_Codex_Prompt.md`.

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

## Dashboard

The opening Dashboard shows nine live inventory counts, the latest 20 activity events, and Batteries needing attention. Configurable reminders use days since the last recorded charge, Recorded Charges totals, and differences within current Sets. Search or hide retired Batteries in the attention list, open a record directly, and use shortcuts to inventory, charging, or labels. Changes refresh automatically from SQLite; no statistics are hard-coded.

See `lib/features/dashboard/README.md` for count definitions, reminder defaults, and persistence behavior.

## QR Labels

Create UUID-based labels for Batteries, Sets, and Devices from the QR Labels screen or inventory details. The designer includes presets, custom dimensions, selectable fields, icon/color and optional photo rendering, reusable templates, live/page previews, PDF export, and native printing. Sheet layouts support partially used sheets through a starting position. Enter/paste QR values or read a QR image to open the current record, including after renaming. Bulk creation can immediately label all or selected new Batteries, or save the selection for later.

See `lib/features/qr_labels/README.md` for label setup, dependencies, validation, and hardware checks.

## Battery Sets

Battery Sets now support editable sequential IDs, permanent UUIDs, icon/color selection, optional photographs, current member details, and membership/assignment/activity history. Add or move batteries with explicit compatibility warnings, record a charge for every current member atomically, and assign/remove the entire Set from a Device.

Set assignment includes a Create Device shortcut backed by the full Device repository. Remove an assigned Set from its Device before changing membership or deactivating/deleting it. Deleting a Set preserves its Batteries and historical records. QR labels are available for the Set itself or its current member Batteries.

See `lib/features/battery_sets/README.md` for persistence rules and workflows. Phase 7 uses the existing schema v1 and adds no production dependencies.

## Devices

Devices support full metadata, custom categories, explicit category icon suggestions, icon/color selection, optional photographs, and optional Battery Type/quantity/voltage requirements. Search and category/status filters locate equipment; details show current Batteries/Sets and retained assignment history.

Whole-Set assignment and removal are available from Device details, with confirmed compatibility overrides. Deactivation/deletion require removing installed inventory first and preserve history. Existing Devices created during Phase 7 retain their UUIDs and assignments. Individual and multi-Battery assignment actions are available through Battery assignments.

See `lib/features/devices/README.md` for lifecycle and persistence rules. Phase 8 uses schema v1 without additional production dependencies.

## Assignments

The Assignments screen handles individual Batteries, multiple Batteries, and whole Sets. Choose installation/removal dates and notes, review compatibility warnings, and remove selected assignments atomically. Available/all filtering helps find inventory; history retains installation details, separate removal notes, and duration.

Battery and Device details open scoped assignment managers. Whole-Set shortcuts use the same transaction implementation. A Battery installed through a Set is removed with its whole Set. Backdated records are allowed without overlapping prior assignment history; future dates and removal before installation are rejected.

See `lib/features/assignments/README.md` for date, status, and history rules. Phase 9 uses schema v1 and adds no production dependencies.

## History

The History screen is a unified, filterable read of the activity every other feature already records — assignments, Set membership, charging, status changes, additions, retirement, QR label output, icon/photo changes, and bulk/CSV operations. Filter by Date, Activity Type, or one Battery/Battery Set/Device at a time; results page 25 at a time and update live while the page is open. Deleted or deactivated records keep their historical text but are no longer clickable.

See `lib/features/history/README.md` for the category catalog and filter behavior. Phase 15 reads the existing schema v1 `activity_log` table and adds no dependency or migration.

## Backup and restore

Settings → **Data Management** → **Create Backup** writes one ZIP archive containing a consistent database snapshot plus every photograph and custom icon file; QR templates, settings, and icon selections already live in the database and travel with it. **Restore Backup** validates the chosen archive (checksums, safe paths, an openable database), asks for confirmation, then replaces the current database/photos/custom icons, keeping the prior state as a recovery copy until the restore is verified. The application reloads its data in place afterward — no restart required.

See `lib/features/backup/README.md` for the archive layout, validation rules, and restore/rollback behavior. Phase 16 adds the `archive` package behind `BackupRepository`.

## CSV import and export

Settings → **Data Management** also exports the current Battery or Battery Set inventory to CSV, and offers a blank import template. CSV import maps header columns automatically, previews every row — flagging validation errors, an unrecognized Battery Type as a warning, and duplicate Battery IDs — and writes nothing until the preview is explicitly confirmed. Only valid, non-duplicate rows are created, inside one transaction, with one summary activity entry.

See `lib/features/import_export/README.md` for field lists, validation rules, and duplicate-detection behavior. Phase 16 adds the `csv` package behind `ImportExportRepository`, built entirely on the existing Battery/Battery Set/Battery Type repositories.

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

## Current verification

Formatting and analysis are clean through Phase 16. See `docs/IMPLEMENTATION_PLAN.md`
for the exact test count, build timing, and runnable-copy hash recorded at each
phase's completion. In-place Flutter generation remains affected by the documented
OneDrive delete-deny ACL; use a normal local checkout or temporary snapshot for
repeated builds/tests. Physical webcam capture and OS-level drag gestures remain
manual verification items.
## Battery inventory

Open **Batteries → Add Battery** to enter an editable Battery ID and optional name,
specifications, purchase details, Batch ID, status, condition, and notes. Every
Battery starts with an icon; photographs are not required. Choose an icon/color
from the existing library, including custom icons imported through Settings.

Select a Battery Type and use **Apply type specifications and icon defaults** to
copy its suggestions, then override any value. Use **Suggest next Battery ID** to
preview the next unused ID for a prefix. Save rejects duplicates without changing
your entered ID. The permanent UUID remains unchanged when the displayed ID changes.

Switch between table and card views, combine the eight inventory filters, search,
and change sort order. Open a Battery for its specifications, purchase information,
current Set/Device summaries, Recorded Charges, and status/activity history. Edit
preserves its identity and related records. Choosing Retired requires confirmation.
All saves use real SQLite transactions, including optional Batch creation and history.
The existing schema remains version 1; no migration is needed for this phase.

## Optional photographs

Open **Batteries → select a Battery → Photographs**. Add a PNG, JPEG, or WebP from
your computer, drop files onto the gallery, or choose Capture Photograph for an
explicit webcam preview and shutter. Files are limited to 25 MB and 40 megapixels.

The default choice after import is **Keep Icon as Primary**. Use Photo as Primary
is explicit. The gallery supports multiple photographs, primary selection,
replacement, removal with confirmation, and switching back to the icon. Missing
or corrupt photographs fall back to the inventory icon; the gallery offers
replacement/removal. Removing a primary photo returns the record to its icon.

Photographs are copied below application-support `photos/` using UUID filenames;
source files are not changed. SQLite stores relative references, dimensions, and
SHA-256 checksums. Photo metadata and activity changes are transactional and reuse
schema version 1. Set/Device storage support is tested; their gallery entry points
will be connected with their planned detail screens in Phases 7 and 8.

Camera access is optional and never starts during normal record creation. Camera
and drop callbacks are tested; physical webcam capture and OS drag gestures remain
manual verification items. The current macOS path supports file import/drop;
webcam support there needs a future platform adapter. See
[photo architecture and dependency decisions](lib/features/photos/README.md).

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

The test suite (see `docs/IMPLEMENTATION_PLAN.md` for the exact count as of the latest completed phase) covers the foundation, icon library, Battery Types, individual inventory, optional photographs, Battery Sets, Devices, Assignments, Charge Tracking, Bulk Creation/Edit, QR Labels, the Dashboard, History, Backup/Restore, and CSV Import/Export. Set coverage includes the four-member acceptance workflow, SQLite restart persistence, UUID stability, compatibility acknowledgment, history, and injected rollback failures for membership moves, charging, assignment, and removal. Device tests additionally cover full-field persistence, requirement validation/overrides, lifecycle rollback, earlier-phase records, explicit photo preference, and missing-photo fallback. Assignment tests cover multi-record rollback, date/overlap validation, membership-linked removal, separate installation/removal notes, warning revalidation, duration, and restart persistence. Dashboard tests cover live counts, attention rules, persisted thresholds, retained recent activity, record navigation, and responsive light/dark layouts. History tests cover every catalogued activity category plus an "Other" fallback, date bounds, entity filtering, pagination, and live updates. Backup tests cover a full create/validate/restore round trip against real files and SQLite, checksum tampering, path traversal, and automatic rollback on a failed restore. CSV tests cover export round trips, every import validation rule, and within-file/existing-record duplicate detection. QR tests cover stable UUID lookup, template/job restart persistence, custom icon/photo rendering, text overflow, sheet positions, PDF export, print cancellation, and the bulk-creation shortcut. Physical printer alignment and live webcam capture still need a hardware check. Widget tests cover real repository-backed screens in light/dark themes, narrow layouts, and application navigation. `DataManagementPage` (backup/restore/CSV UI) is covered indirectly through its underlying repositories and shared dialog/file-selection patterns rather than a dedicated widget test — see the Phase 16 notes in `docs/IMPLEMENTATION_PLAN.md` for why a dedicated widget test for that page was dropped.

## Version

Initial application version:

`0.1.0`

Use semantic versioning.

## Development plan

See `docs/IMPLEMENTATION_PLAN.md`.

## Known environment limitations

On the inspected Windows workstation, Flutter is installed at `C:\Users\jay15\Develop\flutter` but is not on `PATH`. The repository scripts locate that installation automatically. Flutter detects Visual Studio Professional 2026 with its Windows C++ toolchain, and the Phase 14 Windows Release build succeeds and passes its startup check.

The current Codex workspace is under OneDrive and inherits a delete-deny ACL that prevents Flutter from refreshing generated `build/` and Apple `ephemeral/` directories. Phase 14 final verification ran in a normal-ACL temporary snapshot outside the OneDrive checkout. A normal local checkout without that ACL should use the standard commands above. Visual Studio warns when a build output is under `%TEMP%`; the Phase 14 Release build and five-second startup check nevertheless completed successfully. The verified runnable build is available locally in ignored `build/phase14-release`.

## Charge Tracking

Record individual, selected-Battery, or entire-Set charges with a charge date, optional start/end percentages, charger, and notes. Charge Tracking shows each Battery's Recorded Charges, Last Charged, current manual estimate, and history. Battery details and Set history provide scoped access.

Ending percentage defaults to 100. Manual current estimates remain unchanged unless explicitly updated; estimates can also be edited or cleared without recording a charge. Selected and Set actions are all-or-nothing transactions. See `lib/features/charging/README.md` for validation, backdated status behavior, and persistence rules. Phase 10 adds no dependencies or migration.
## Bulk Battery Creation

Open **Batteries → Add Multiple Batteries** to configure shared fields, icon/color, optional Batch ID and tags, and sequential Battery IDs. Generate an editable preview, resolve duplicates by editing/skipping or using next-available IDs, and assign rows to existing or new Sets. Each Battery receives its own UUID and history. A single transaction saves the entire operation, including memberships.

Purchase price supports per-Battery or total purchase modes. Total mode preserves the total and calculates approximate per-Battery cost in the preview. Confirming saves the reviewed values without renumbering. See `lib/features/bulk_operations/README.md` for limits, price allocation behavior, transaction rules, and acceptance coverage.
## Bulk Edit and Retirement

Select Batteries using table/card checkboxes or **Select filtered**, then choose **Bulk Edit**, **Retire Selected Batteries**, or **Mark Selected Charged**. Bulk Edit supports Type, Status, Condition, icons/colors, Set membership, tags, appended shared notes, and purchase information. Each operation shows the selected count and old/new values before confirmation, rechecks for changes since preview, and saves atomically.

Retirement stores a date and reason, preserves history and Set membership, and requires active Device assignments to be removed first. Retirement details appear in Battery details. See `lib/features/bulk_operations/README.md` for validation, restoration behavior, selection rules, and transaction coverage.
