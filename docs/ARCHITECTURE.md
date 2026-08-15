# Battery Tracker — Architecture Guide

**Architecture baseline:** Phase 4 Battery Types, 2026-08-15
**Initial runtime:** Windows 11 desktop  
**Portability targets:** Android, iPhone/iPad, and macOS

## Non-negotiable invariants

- Permanent UUIDs are authoritative for Batteries, Battery Sets, Devices, and Custom Icons. Editable IDs are labels only.
- Icons identify inventory; photographs add detail. Every inventory record retains an icon and missing photos fall back to it.
- Assignments, Set memberships, Recorded Charges, status changes, retirements, and bulk operations preserve history.
- Multi-record workflows execute inside one database transaction.
- Domain and application code do not import Windows-only APIs or persist host-specific absolute paths.

## Layering and dependency direction

```text
Presentation (Flutter widgets and navigation)
                 ↓
Application (Riverpod notifiers and workflows)
                 ↓
Domain (entities, values, rules, repository interfaces)
                 ↓
Repository interfaces / service contracts
                 ↑
Data and platform adapters (Drift, files, camera, printing)
```

Feature code lives under `lib/features/<feature>/`. A feature adds `domain`, `application`, `data`, and `presentation` folders only when it has code for that responsibility. Shared primitives live under `lib/core`; host integrations live behind contracts under `lib/services`.

Substantial business logic does not belong in widgets. Repositories return domain values rather than Drift-generated rows. Platform adapters translate native paths and APIs at the service boundary.

## State management

Use `flutter_riverpod`.

Reasons:

- explicit dependency injection without `BuildContext`
- test containers and provider overrides
- predictable asynchronous loading/error states
- no dependency on a particular desktop or mobile lifecycle

Use Notifier/AsyncNotifier-style providers for application workflows. Do not use Riverpod's experimental persistence as the system of record; SQLite remains authoritative. Keep feature state scoped and expose repositories/services through providers.

## Database and migrations

Use `drift` with `drift_flutter` and generated code from `drift_dev`/`build_runner`.

- SQLite is the only Version 1 system of record.
- `PRAGMA foreign_keys = ON` is required for every connection.
- Schema version 1 is created through the migration system, not ad-hoc startup SQL.
- Every later schema change receives a numbered, contiguous migration and a schema snapshot.
- Migration tests cover a new database, upgrades from each supported prior schema, UUID preservation, history preservation, and foreign-key behavior.
- Production opens the database in a background isolate where supported. Tests inject an in-memory executor.

`MigrationRegistry` rejects missing/non-positive versions before `DriftMigrationRunner` maps the contiguous registry to Drift's migration strategy. Schema version 1 creates all 20 normalized tables, constraints, partial unique indexes, and lookup indexes. Its committed snapshot is `drift_schemas/schema_v1.json`.

The production connection runs in Drift's background connection where supported. The database file is resolved beneath the platform application-support directory as `database/battery_tracker.sqlite`, and SQLite temporary work uses `database/tmp/`. The physical root is supplied by `AppDataDirectoryService`; it is never stored in a domain model.

See `docs/DATABASE_PLAN.md` for the finalized Version 1 schema and transaction boundaries.

## Identity

`PermanentId` is the shared immutable value type. New durable records receive random RFC UUID version 4 values through `PermanentIdGenerator`. UUIDs are generated once on creation and are never regenerated during ordinary edits, import merges, backup/restore, or display-ID changes.

User-facing identifiers such as `AA-001` and `SET-001` have separate unique lookup columns. QR payloads use only stable URIs:

```text
batterytracker://battery/{uuid}
batterytracker://set/{uuid}
batterytracker://device/{uuid}
```

## Repository and transaction model

Repository interfaces live with their feature domain. Drift implementations live in the feature data layer. Repositories accept parameter objects for non-trivial writes and use parameterized Drift expressions/queries.

`DatabaseService.transaction` is the common atomic boundary. Application services own multi-repository workflows and pass the transaction context to participating repositories. They never chain independent repository writes from UI callbacks.

Required transaction groups include:

- bulk Battery creation, optional Batch creation, and optional Set creation/membership
- adding, removing, or moving multiple Set members
- assigning or removing an entire Set and all member assignments
- Mark Entire Set Charged and all individual Recorded Charge rows
- Mark Selected Charged
- multi-record bulk edits/retirements
- confirmed CSV import
- database-side restore validation/swap steps

Any fatal failure rolls back the complete group and records no success activity.

### Battery Type lifecycle

`BatteryTypeRepository` is the feature boundary; `DriftBatteryTypeRepository` owns persistence and `BatteryTypeCatalogController` owns list/filter/selection state. A `BatteryTypeDraft` trims optional text, requires a type name, rejects non-finite or non-positive voltage/capacity, and requires capacity and capacity unit together. Chemistry and capacity-unit controls are editable suggestions, so the domain stores custom values unchanged rather than imposing lookup tables.

Creation generates one `PermanentId` UUID. Updates retain it. Active names are unique case-insensitively; inactive records may retain their names, but reactivation first checks the active-name rule and reports a typed conflict if another active record now owns the name. Every create, update, deactivate, and reactivate operation validates the Battery-scope `IconSelection`, writes inside a single Drift transaction, and appends an activity-log event. A deactivation event includes exact Batteries, Battery Sets, and Devices reference counts in its metadata.

Battery Type deactivation is soft (`deactivated_at`), not delete/purge. It never rewrites the foreign-key references from Batteries, Battery Sets, or Device requirements. The UI obtains those exact counts before the confirmation dialog, communicates that existing references stay connected, and explains that new records will not use the type by default. Reactivation remains explicit and cannot silently resolve a conflicting name.

## History model

Memberships and assignments are temporal rows with start and end timestamps. Removal closes the current row; it does not overwrite who/what/when. Recorded Charges are append-only. A separate activity log stores user-readable/system events and a shared operation UUID groups rows created by one bulk or Set action.

Soft deletion or deactivation protects records referenced by history. Destructive purge is not a normal Version 1 workflow.

## Application-managed storage

`AppDataDirectoryService` resolves one application-support root. Adapters create this logical layout beneath it:

```text
BatteryTracker/
  database/battery_tracker.sqlite
  database/tmp/
  photos/batteries/{uuid}/
  photos/battery_sets/{uuid}/
  photos/devices/{uuid}/
  custom_icons/{uuid}/
  label_templates/
  backups/
  logs/
```

SQLite stores `ManagedRelativePath` values with forward slashes. They reject drive letters, UNC/Unix absolute paths, empty segments, and parent traversal. An adapter resolves a logical reference against the application root and verifies the result remains inside that root before file access.

Imported files are validated, copied to managed storage, and then committed to the database. Failed database writes remove only newly staged files. Missing photo files are logged and rendered with the record's icon. Custom-icon deletion requires a reference check and an explicit replacement/default strategy.

## Icon system

`IconRegistry` is the centralized, platform-neutral catalog. It combines 54 immutable packaged `IconDefinition` values with active custom-icon records, searches display names/keys/categories/keywords, enforces owner scope, resolves deprecated keys, and supplies distinct Battery, Battery Set, and Device defaults. Built-in assets live under `assets/icons/builtin/`; logical keys, not asset paths, are persisted on inventory owners.

Custom icons have permanent UUIDs. `DriftIconRepository` persists categories and metadata, records recent selections and activity, counts live references across Batteries, Battery Sets, Devices, and Battery Types, and replaces those references in one SQLite transaction before deactivation. Custom files live at `custom_icons/{icon-uuid}/source-{revision-uuid}.{png|svg}`. Replacing source content preserves the icon UUID and removes the superseded managed file only after the database update succeeds.

`LocalCustomIconStorage` validates signatures, file type, size, UTF-8 SVG structure, and rejects scripts, event handlers, entity/doctype declarations, image elements, and external/data references. `IconVisual` renders packaged and managed SVG/PNG sources with optional color tint and always falls back to the owner default when a managed file is missing or unreadable.

Battery Types use the existing Battery-scope picker and default to the packaged Generic Battery icon/color. Their icon/color are suggestions for later Battery creation, not an override of a Battery record's selected visual. `BatteryTypeIcon` resolves built-in/custom selections through the registry and falls back to the Battery default if a custom icon cannot be found, so no broken visual is rendered.

Riverpod's `IconCatalogController` exposes scoped Built-In, Custom, Recent, category, and text filters to both the reusable `IconPickerDialog` and Settings `IconLibraryPage`. `FileSelectionService` returns only platform-neutral file URIs; `FileSelectorFileSelectionService` is the replaceable native-dialog adapter. Feature/domain layers never import plugin types or Windows APIs.

## Navigation

Keep the current Material 3 `NavigationRail` shell and typed `AppDestination` values for:

- Dashboard
- Batteries
- Battery Sets
- Devices
- Assignments
- Battery Types
- QR Labels
- History
- Settings

Riverpod owns the selected destination and typed entity route intent. Selecting a new primary destination clears stale detail intent. Detail/edit screens use Navigator routes. QR lookup creates a typed route intent after UUID resolution; URI parsing does not occur inside widgets.

## Appearance

Material 3 supplies Light and Dark themes. `ThemePreferenceController` loads and saves `system`, `light`, and `dark` through the Drift settings repository; the new value is exposed only after persistence succeeds. Icons always have text identifiers, and color is supplemental rather than the sole identifier.

## Logging and user-facing errors

`LocalFileLogService` uses package `logging` and writes scoped technical records to bounded, rotated local files under `logs/`.

Application failures use typed exceptions/results. Presentation maps them to concise messages and never shows raw stack traces. Technical exceptions, causes, and stack traces go only to logs.

## Platform service boundaries

The initial contracts are in `lib/services/`:

- `AppDataDirectoryService`
- `FileSelectionService`
- `CameraService`
- `ImageStorageService`
- `QrCodeService`
- `LabelService`
- `PrintService`
- `BackupService`
- `ImportService`
- `ExportService`

Feature phases may refine request/response types, but domain models cannot depend on plugin classes. Windows-specific adapters live below these contracts and mobile/macOS adapters can replace them without changing domain rules.

## QR, labels, and printing

QR URI construction/parsing is pure Dart. QR rendering and image decoding implement `QrCodeService`. Windows Version 1 supports manual/paste lookup and still-image/webcam decoding where the selected adapter proves reliable; mobile live scanning can use a separate adapter.

Labels render first to a platform-neutral PDF document. `PrintService` sends PDF bytes through the host print workflow. Sheet placement and the starting-label offset are label-domain calculations, not printer-plugin behavior.

## Backup and restore

A backup is one ZIP archive containing:

- `manifest.json` with format version, app version, creation time, schema version, logical file list, sizes, and SHA-256 checksums
- a consistent SQLite database snapshot
- photographs and custom icons
- exported settings and label-template assets not already contained in SQLite

Creation writes to a temporary archive and renames only after validation. Restore extracts to staging, rejects absolute/traversal entries, verifies manifest/checksums and a read-only database open, requires user confirmation, closes the active database, preserves a recovery copy, swaps state, and verifies core queries/assets before deleting recovery data.

## Dependency decisions

Foundation packages are added now; later-phase packages are revalidated when added so unused native plugins do not increase Phase 1 risk.

| Capability | Decision | Timing and rationale |
|---|---|---|
| State/DI | `flutter_riverpod` | Added in Phase 1; testable async state and dependency overrides. |
| SQLite | `drift`, `drift_flutter` | Added in Phase 1; typed queries, transactions, migrations, Windows/mobile/macOS support. |
| Code generation | `drift_dev`, `build_runner` | Added as development dependencies. |
| UUID | `uuid` | Added in Phase 1 behind `PermanentIdGenerator`. |
| App directories | `path_provider` | Added in Phase 1 behind `AppDataDirectoryService`. |
| Logging | `logging` | Added in Phase 1 behind a project service. |
| Native file dialogs | `file_selector` | Added in Phase 3 behind `FileSelectionService`; maintained federated Flutter plugin with Windows/mobile/macOS implementations. |
| SVG | `flutter_svg` | Added in Phase 3 for packaged and validated managed SVG display with icon fallback. |
| Drag/drop | `desktop_drop` | Add in Photos phase; optional UI path, never required for record creation. |
| Camera | `camera` plus a tested Windows adapter | Add in Photos phase after a Windows capture spike; `CameraService` isolates adapter limitations. |
| QR render/decode | `qr_flutter` and pure-Dart `zxing2` | Add in QR phase; mobile live scanning may use `mobile_scanner`, which does not support Windows. |
| PDF/print | `pdf` and `printing` | Add in QR Labels phase; standard PDF is the cross-platform print boundary. |
| CSV | `csv` | Add in Import/Export phase with preview-before-commit validation. |
| ZIP | `archive` | Add in Backup phase; validate every archive entry before extraction. |

No package may introduce a cloud or required-online dependency for Version 1.

## Testing strategy

Prioritize tests where data loss or identity drift is possible:

- permanent UUID parsing/generation/stability
- managed relative-path validation
- migration continuity and schema upgrades
- repository CRUD and foreign keys
- Set membership and assignment history
- bulk/Set transaction rollback
- icon resolution and missing-photo fallback
- QR URI resolution
- backup validation and restore recovery
- CSV preview and duplicate behavior

Widget tests cover high-value workflows, empty states, navigation, and Light/Dark usability rather than every visual detail.
