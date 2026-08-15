# Battery Tracker — Implementation Plan

## Status

**Project stage:** Phase 1 complete; Phase 2 not started  
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
- [ ] Visual Studio C++ desktop workload available
- [x] `flutter pub get` succeeds
- [ ] starter app runs on Windows
- [x] `flutter analyze` succeeds
- [x] `flutter test` succeeds
- [ ] `flutter build windows` succeeds

### Environment notes

- Inspected 2026-08-15 on Windows 11 Home Insider Preview 25H2, build 26220.
- Flutter 3.47.0 stable and Dart 3.13.0 are installed at `C:\Users\jay15\Develop\flutter`.
- Flutter and Dart are not currently on `PATH`; commands used the SDK's full path.
- Windows desktop support is enabled and a Windows device is detected.
- Visual Studio is not installed. `flutter doctor -v` requires Visual Studio with the Desktop development with C++ workload.
- Android SDK is not installed. This does not block the initial Windows-first phase, but it blocks future Android builds.
- The Codex OneDrive workspace inherits an `Everyone: Deny DeleteSubdirectoriesAndFiles` ACL. Flutter cannot refresh ignored `build/` and Apple `ephemeral/` directories there.
- A fresh temporary snapshot with normal ACLs completed `flutter pub get`, formatting, analysis, and all 11 tests. This verifies the same source/lockfile without changing product configuration or disabling Swift Package Manager.
- `flutter build windows --no-pub` was attempted in that snapshot and stopped with `Unable to find suitable Visual Studio toolchain.`

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
- Phase 1 verification: formatting clean, analysis clean, 11 tests passed. Windows build is environment-blocked by the missing Visual Studio toolchain.

---

# Phase 2 — Project Foundation

**Status:** Not started

## Scope

- [ ] Flutter project generated
- [ ] Windows target works
- [ ] App shell
- [ ] Navigation
- [ ] Light/Dark/System themes
- [ ] Logging
- [ ] Configuration
- [ ] SQLite initialization
- [ ] Migration runner
- [ ] Shared UI patterns

## Acceptance

- [ ] Windows app launches
- [ ] app survives restart
- [ ] theme selection works
- [ ] database initializes
- [ ] tests run

---

# Phase 3 — Icon System

**Status:** Not started

## Scope

- [ ] Built-in Icon Registry
- [ ] Default Battery icon
- [ ] Default Set icon
- [ ] Default Device icon
- [ ] Icon selector
- [ ] Categories/search
- [ ] Icon colors
- [ ] Custom PNG import
- [ ] Custom SVG import
- [ ] Custom icon categories
- [ ] Safe custom icon deletion/replacement
- [ ] Missing/deprecated icon handling
- [ ] Persistence

## Acceptance

- [ ] icon-only Battery works
- [ ] icon-only Set works
- [ ] icon-only Device works
- [ ] icon color persists after restart
- [ ] custom icon persists after restart
- [ ] in-use custom icon cannot be silently deleted
- [ ] Light/Dark display is usable

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

---

# Known defects / blockers

| ID | Issue | Severity | Status | Notes |
|---|---|---|---|---|
| ENV-001 | Visual Studio C++ desktop toolchain missing | Blocking Windows build | Open | Install Visual Studio 2022/Build Tools with Desktop development with C++ and its default components. |
| ENV-002 | OneDrive workspace denies directory deletion | Blocks repeated Flutter generation in-place | Open | Use a normal local checkout or temporary verification snapshot; do not weaken project architecture or disable SwiftPM. |
| ENV-003 | Flutter/Dart not on `PATH` | Low | Open | Add `C:\Users\jay15\Develop\flutter\bin` to the user `PATH` or continue using the full SDK path. |
| ENV-004 | Android SDK missing | Blocks future Android verification | Deferred | Install before the first Android build milestone. |

---

# Current next action

1. Install Visual Studio with the Desktop development with C++ workload, then rerun `flutter doctor -v` and `flutter build windows`.
2. Begin Phase 2 with Riverpod application setup, logging/configuration, and the executable Drift version 1 migration.
3. Keep the application runnable and update this plan after each verified Phase 2 slice.
