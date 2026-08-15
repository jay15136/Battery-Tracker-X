# Battery Tracker — Implementation Plan

## Status

**Project stage:** Phase 3 complete; Phase 4 is next
**Target:** Windows 11 first, cross-platform architecture  
**Version:** 0.1.0  
**Authoritative requirements:** `Battery_Tracker_Master_Codex_Prompt.md`

This is a living plan. Codex must update it as implementation proceeds.

## Working rules

- Do not mark a phase complete until its acceptance criteria are met.
- Keep the app runnable between coherent changes.
- Record important architecture decisions.
- Record environment blockers precisely.
- Preserve Version 1 scope.
- Do not substitute mock persistence for real persistence.

---

## Environment checklist

- [x] Flutter SDK installed
- [x] Dart available through Flutter
- [x] `flutter doctor -v` reviewed
- [x] Windows desktop development enabled
- [x] Visual Studio C++ desktop workload available
- [x] `flutter pub get` succeeds
- [x] starter app runs on Windows
- [x] `flutter analyze` succeeds
- [x] `flutter test` succeeds
- [x] `flutter build windows` succeeds

### Environment notes

- Inspected 2026-08-15 on Windows 11 Home Insider Preview 25H2, build 26220.
- Flutter 3.47.0 stable and Dart 3.13.0 are installed at `C:\Users\jay15\Develop\flutter`.
- Flutter and Dart are not currently on `PATH`. Repository PowerShell scripts automatically resolve the SDK through `BATTERY_TRACKER_FLUTTER_ROOT`, `PATH`, per-user folders, or common machine folders.
- Windows desktop support is enabled and a Windows device is detected.
- Flutter detects Visual Studio Professional 2026 18.9.0 and Windows SDK 10.0.26100.0; the required Windows C++ toolchain is available.
- Android SDK is not installed. This does not block the initial Windows-first phase, but it blocks future Android builds.
- The Codex OneDrive workspace inherits an `Everyone: Deny DeleteSubdirectoriesAndFiles` ACL. Flutter cannot refresh ignored `build/` and Apple `ephemeral/` directories there.
- A fresh temporary snapshot with normal ACLs completed `flutter pub get`, formatting, code generation, analysis, and all 28 tests. Generated Drift source and the schema snapshot matched the checked-in artifacts byte-for-byte.
- `flutter build windows --no-pub` produced `build\windows\x64\runner\Release\battery_tracker.exe`. That executable remained healthy for five seconds on each of two launch attempts.
- Phase 3 verification from a refreshed normal-ACL snapshot completed dependency resolution, clean formatting, clean static analysis, all 74 tests, and a Windows Release build. The final executable remained healthy for five seconds on each of two launch attempts; generated Drift source and schema version 1 remained byte-for-byte unchanged.

---

# Phase 1 — Architecture

**Status:** Complete (2026-08-15)

## Goal

Finalize architecture before feature implementation.

## Required decisions

- [x] State-management approach
- [x] SQLite library and migration approach
- [x] Repository pattern
- [x] Application data-directory strategy
- [x] Image/custom-icon storage strategy
- [x] UUID strategy
- [x] Logging strategy
- [x] Navigation strategy
- [x] Printing abstraction
- [x] QR generation/decoding abstraction
- [x] Backup/archive format
- [x] CSV import/export architecture
- [x] Cross-platform service interfaces

## Deliverables

- [x] Update `docs/ARCHITECTURE.md`
- [x] Update `docs/DATABASE_PLAN.md`
- [x] Select dependencies
- [x] Document dependency rationale
- [x] Establish folder/module structure

## Acceptance

- [x] No core model depends on Windows-only APIs
- [x] Permanent UUID strategy defined
- [x] Migration strategy defined
- [x] Multi-record transaction boundaries identified

## Phase 1 implementation notes

- Reconciled Flutter-generated Windows, Android, iOS, and macOS projects with the authored starter without changing project-control documents.
- Added tested `PermanentId`/UUID generation, managed relative-path validation, and contiguous migration metadata.
- Added database transaction and platform-service contracts for storage, file selection, camera, images, QR, labels, printing, backup, import, and export.
- Selected Riverpod, Drift, UUID, path-provider, and logging foundations; later native feature packages remain phase-scoped and must be revalidated when added.
- Phase 1 verification at completion: formatting clean, analysis clean, and 11 tests passed. Windows build verification was completed during Phase 2 after the toolchain became available.

---

# Phase 2 — Project Foundation

**Status:** Complete (2026-08-15)

## Scope

- [x] Flutter project generated
- [x] Windows target works
- [x] App shell
- [x] Navigation
- [x] Light/Dark/System themes
- [x] Logging
- [x] Configuration
- [x] SQLite initialization
- [x] Migration runner
- [x] Shared UI patterns

## Acceptance

- [x] Windows app launches
- [x] app survives restart
- [x] theme selection works
- [x] database initializes
- [x] tests run

## Phase 2 implementation notes

- Added application bootstrap that resolves platform application-support storage, starts bounded local logging, opens Drift's background production connection, runs migrations, verifies foreign keys, and injects dependencies through Riverpod.
- Implemented the full 20-table normalized Version 1 schema, constraints, partial unique indexes, lookup indexes, UTC text timestamps, transaction adapter, generated typed access code, and `drift_schemas/schema_v1.json`.
- Implemented Drift-backed appearance persistence with System, Light, and Dark modes; tests close and reopen a real SQLite file to verify persistence.
- Replaced widget-owned navigation state with Riverpod-selected destinations and typed entity route intent.
- Added a responsive Material 3 Windows shell, shared page/empty-state patterns, a first-run Dashboard state, and working appearance settings without hard-coded inventory statistics.
- Added tests for configuration safety, bounded log rotation, database creation/constraints/defaults/rollback, production bootstrap, settings persistence, Riverpod controllers, navigation, and Light/Dark UI behavior.
- Formatting is clean, `flutter analyze` reports no issues, and all 28 tests pass from a normal-ACL snapshot. The Windows Release build succeeds, and the built executable passed two launch checks.

---

# Phase 3 — Icon System

**Status:** Complete (2026-08-15)

## Scope

- [x] Built-in Icon Registry
- [x] Default Battery icon
- [x] Default Set icon
- [x] Default Device icon
- [x] Icon selector
- [x] Categories/search
- [x] Icon colors
- [x] Custom PNG import
- [x] Custom SVG import
- [x] Custom icon categories
- [x] Safe custom icon deletion/replacement
- [x] Missing/deprecated icon handling
- [x] Persistence

## Acceptance

- [x] icon-only Battery works
- [x] icon-only Set works
- [x] icon-only Device works
- [x] icon color persists after restart
- [x] custom icon persists after restart
- [x] in-use custom icon cannot be silently deleted
- [x] Light/Dark display is usable

## Phase 3 implementation notes

- Added a centralized registry with 54 packaged SVG assets, searchable categories and keywords, owner-scoped defaults, deprecation redirects, and deterministic missing-reference fallback.
- Added immutable validated icon colors with the required preset palette and custom `#RRGGBB` values; owner selections persist source, logical key/UUID, and color without changing permanent entity identity.
- Added Drift repositories for custom categories, custom-icon metadata, bounded recent selections, owner usage counts, activity records, and transactional replacement across Batteries, Battery Sets, Devices, and Battery Types.
- Added application-managed PNG/SVG imports with content/size validation, unsafe SVG rejection, UUID-based relative paths, compensating cleanup, source replacement, duplication, deactivation, and in-use deletion safeguards.
- Added a reusable responsive icon chooser and Settings Icon Library for search/filter, preview, color selection, import, edit, category creation, source replacement, duplication, and explicit replacement/default deletion.
- Added native file dialogs behind `FileSelectionService`; feature/domain code remains independent of plugin and Windows APIs.
- Icon-specific verification covers 45 tests, including restart persistence, transaction rollback, missing-file fallback, Light/Dark rendering, and full library workflows. Final repository/build verification is recorded in the environment notes.

---

# Phase 4 — Battery Types

**Status:** Not started

## Scope

- [ ] List
- [ ] Add
- [ ] Edit
- [ ] Delete/deactivate rules
- [ ] Validation
- [ ] Suggested icon
- [ ] Suggested icon color
- [ ] Default voltage/capacity/chemistry

## Acceptance

- [ ] CRUD persists
- [ ] invalid records are rejected
- [ ] suggested icon/color can be overridden

---

# Phase 5 — Battery Inventory

**Status:** Not started

## Scope

- [ ] Battery model
- [ ] Permanent UUID
- [ ] User Battery ID
- [ ] sequential ID suggestion
- [ ] specifications
- [ ] purchase information
- [ ] status
- [ ] condition
- [ ] notes
- [ ] table view
- [ ] card view
- [ ] search
- [ ] filters
- [ ] sorting
- [ ] detail screen

## Acceptance

- [ ] Battery data persists after restart
- [ ] UUID never changes during edits
- [ ] user-facing ID may change
- [ ] search/filter works
- [ ] no photo required

---

# Phase 6 — Optional Photographs

**Status:** Not started

## Scope

- [ ] Application-managed image storage
- [ ] Add Photograph
- [ ] Drag/drop where practical
- [ ] Webcam capture where practical
- [ ] Primary/additional photos
- [ ] Icon Primary / Photo Primary choice
- [ ] Missing-photo fallback

## Acceptance

- [ ] adding a photo does not automatically replace Icon Primary
- [ ] switching primary visual works
- [ ] removing photo leaves icon intact
- [ ] missing file falls back to icon

---

# Phase 7 — Battery Sets

**Status:** Not started

## Scope

- [ ] Set record
- [ ] permanent UUID
- [ ] sequential Set ID
- [ ] membership
- [ ] membership history
- [ ] compatibility warnings
- [ ] detail screen
- [ ] set icon/photo
- [ ] Mark Entire Set Charged
- [ ] Set assignment

## Acceptance

Use all Battery Set scenarios in the master prompt.

---

# Phase 8 — Devices

**Status:** Not started

## Scope

- [ ] Device record
- [ ] permanent UUID
- [ ] category
- [ ] manufacturer/model/serial
- [ ] location
- [ ] icon/color
- [ ] optional photos
- [ ] battery requirements
- [ ] detail screen
- [ ] search

## Acceptance

- [ ] Device persists
- [ ] icon-only workflow works
- [ ] requirements guide but do not block override

---

# Phase 9 — Assignments

**Status:** Not started

## Scope

- [ ] Battery → Device
- [ ] multiple Batteries → Device
- [ ] Set → Device
- [ ] removal
- [ ] compatibility warnings
- [ ] assignment history
- [ ] transaction safety

## Acceptance

- [ ] history is never overwritten
- [ ] Set assignment is atomic
- [ ] removal preserves dates/history

---

# Phase 10 — Charge Tracking

**Status:** Not started

## Scope

- [ ] Mark Charged
- [ ] Recorded Charges
- [ ] Last Charged
- [ ] optional start/end percentage
- [ ] charger
- [ ] notes
- [ ] Set charge
- [ ] selected-battery bulk charge

## Acceptance

- [ ] "Recorded Charges" terminology used
- [ ] Set charging creates individual records atomically
- [ ] bulk charge is atomic

---

# Phase 11 — Bulk Battery Creation

**Status:** Not started

## Scope

- [ ] shared fields
- [ ] quantity
- [ ] prefix
- [ ] separator
- [ ] starting number
- [ ] padding
- [ ] generated preview
- [ ] duplicate detection
- [ ] next available IDs
- [ ] per-row edits
- [ ] shared icon/color
- [ ] Batch ID
- [ ] optional Set creation
- [ ] transactional save
- [ ] completion summary

## Acceptance

Use all Bulk Creation scenarios in the master prompt.

---

# Phase 12 — Bulk Edit

**Status:** Not started

## Scope

- [ ] Type
- [ ] Status
- [ ] Condition
- [ ] Icon
- [ ] Icon Color
- [ ] Set membership
- [ ] Shared note
- [ ] Purchase information
- [ ] Retirement
- [ ] Charge action
- [ ] Preview/confirmation

## Acceptance

- [ ] user sees affected-record count
- [ ] dangerous changes require confirmation
- [ ] no silent destructive changes

---

# Phase 13 — QR Labels

**Status:** Not started

## Scope

- [ ] UUID URI format
- [ ] Battery QR
- [ ] Set QR
- [ ] Device QR
- [ ] Label designer
- [ ] templates
- [ ] live preview
- [ ] icon rendering
- [ ] custom icon rendering
- [ ] optional photo rendering
- [ ] individual print
- [ ] batch print
- [ ] sheet layout
- [ ] starting label position
- [ ] PDF export
- [ ] QR lookup

## Acceptance

Use all QR Label scenarios in the master prompt.

---

# Phase 14 — Dashboard

**Status:** Not started

## Scope

- [ ] summary cards
- [ ] recent activity
- [ ] batteries needing attention

## Acceptance

- [ ] all values come from real persisted data
- [ ] no hard-coded counts

---

# Phase 15 — History

**Status:** Not started

## Scope

- [ ] assignment history
- [ ] Set membership history
- [ ] charge history
- [ ] status changes
- [ ] additions
- [ ] QR events
- [ ] retirement
- [ ] bulk operations
- [ ] filters

## Acceptance

- [ ] history survives restarts
- [ ] filters work
- [ ] destructive actions do not erase required history

---

# Phase 16 — Backup, Restore, Import, Export

**Status:** Not started

## Backup

- [ ] database
- [ ] photos
- [ ] custom icons
- [ ] label templates
- [ ] settings
- [ ] validation
- [ ] restore confirmation
- [ ] restore verification

## CSV

- [ ] Battery export
- [ ] Set export
- [ ] Battery import template
- [ ] field mapping
- [ ] preview
- [ ] duplicate detection
- [ ] validation
- [ ] import summary

## Acceptance

- [ ] restored application remains usable
- [ ] custom icons/photos survive
- [ ] invalid backup is rejected
- [ ] CSV import does not write until confirmed

---

# Phase 17 — Testing and Cleanup

**Status:** Not started

## Required checks

- [ ] Unit tests
- [ ] Database tests
- [ ] Repository tests
- [ ] Migration tests
- [ ] Assignment transaction tests
- [ ] Set tests
- [ ] Icon tests
- [ ] Custom icon tests
- [ ] Photo fallback tests
- [ ] Bulk creation tests
- [ ] QR tests
- [ ] Backup/restore tests
- [ ] Import/export tests
- [ ] UI smoke tests
- [ ] Light Mode
- [ ] Dark Mode
- [ ] empty database
- [ ] large inventory behavior
- [ ] Windows release build

## Final commands

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows
```

---

# Architecture decisions

Record decisions below as they are made.

| Date | Decision | Rationale | Consequences |
|---|---|---|---|
| 2026-08-15 | Riverpod for state/DI | Testable async state and explicit dependency overrides without tying services to widgets. | Providers coordinate workflows; SQLite remains authoritative. |
| 2026-08-15 | Drift/SQLite with numbered migrations | Typed queries, transactions, schema tooling, and supported Windows/mobile/macOS paths. | Generated schema code and migration snapshots enter Phase 2. |
| 2026-08-15 | UUID v4 permanent identity | Stable cross-platform identity independent of editable labels. | QR, history, import, and restore preserve UUIDs. |
| 2026-08-15 | Application-support root plus logical relative paths | Avoid machine-specific database values and keep complete backup portability. | Platform adapters resolve/contain paths; domain models never hold absolute paths. |
| 2026-08-15 | Typed photo-owner join tables | Preserves SQLite foreign-key integrity while sharing media metadata. | Three small join tables instead of an unenforced polymorphic owner reference. |
| 2026-08-15 | Set assignment creates Set and member rows | Supports fast current Battery queries while preserving the Set action's historical meaning. | Rows share an operation UUID and are inserted/closed atomically. |
| 2026-08-15 | PDF is the label/print interchange | Keeps label layout platform-neutral and supports preview/export/host printing. | Printer adapters consume PDF bytes rather than label-domain objects. |
| 2026-08-15 | Manifested ZIP backup with staging restore | Enables validation, checksums, traversal protection, and recovery before overwrite. | Restore never extracts directly over active data. |
| 2026-08-15 | Central immutable built-in icon catalog plus UUID custom records | Gives every owner a stable icon-first identity while allowing safe user extension. | Built-ins use logical keys; custom icons use permanent UUIDs and managed relative paths. |
| 2026-08-15 | `flutter_svg` plus validated managed SVG/PNG storage | Supports packaged and user-imported cross-platform icons without storing bytes in SQLite. | SVG imports reject scripts/external content; missing files render owner defaults. |
| 2026-08-15 | `file_selector` only behind `FileSelectionService` | Uses maintained native dialogs without leaking plugin values into features or domain models. | Windows, Android, iOS, and macOS adapters remain replaceable at the service boundary. |

---

# Known defects / blockers

| ID | Issue | Severity | Status | Notes |
|---|---|---|---|---|
| ENV-001 | Visual Studio C++ desktop toolchain missing during initial inspection | Blocking Windows build | Resolved | Flutter now detects Visual Studio Professional 2026 18.9.0 with Windows SDK 10.0.26100.0; the Release build succeeds. |
| ENV-002 | OneDrive workspace denies directory deletion | Blocks repeated Flutter generation in-place | Open | Use a normal local checkout or temporary verification snapshot; do not weaken project architecture or disable SwiftPM. |
| ENV-003 | Flutter/Dart not on `PATH` | Low | Mitigated | Shared PowerShell discovery now finds `C:\Users\jay15\Develop\flutter`; `BATTERY_TRACKER_FLUTTER_ROOT` supports custom locations. |
| ENV-004 | Android SDK missing | Blocks future Android verification | Deferred | Install before the first Android build milestone. |

---

# Current next action

1. Begin Phase 4 with the Battery Type repository and validation rules.
2. Reuse the Phase 3 icon chooser for suggested Battery Type icon/color without coupling Battery Types to presentation widgets.
3. Preserve permanent UUIDs, deactivation semantics, and real restart persistence in Battery Type CRUD.

## Tooling maintenance

- 2026-08-15: `bootstrap_windows.ps1` and `check.ps1` now share automatic Flutter/Dart SDK discovery. Windows PowerShell 5.1 tests cover override, `PATH`, per-user fallback, incomplete SDK rejection, and matched Dart resolution.
