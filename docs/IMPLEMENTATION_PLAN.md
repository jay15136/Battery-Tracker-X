# Battery Tracker — Implementation Plan

## Status

**Project stage:** Phase 14 Dashboard complete; Phase 15 History next
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
- Phase 4 final verification ran in the linked normal-ACL TEMP worktree, verified outside the OneDrive checkout. It restored the built-in icon asset declaration in `pubspec.yaml` before generation, then completed `flutter pub get`, `dart run build_runner build`, formatting/check, `flutter analyze --no-pub`, all 151 tests, and `flutter build windows --release --no-pub`. The generated Drift source SHA-256 remained `50FC69A828D9175E9697C62AA810D28BB37F5EA0FB4B55B660E37AC040631CB1` and schema v1 remained `525A1F93C1DE420CE3A9C3C58AB286FDC7D0E5A016ED7D0AB8AFBF9A75448ACF`. The Release executable stayed alive for five seconds on both checked launches. MSBuild emitted only its expected TEMP-output warning.

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

**Status:** Complete (2026-08-15)

## Scope

- [x] List with searchable Active, Inactive, and All views
- [x] Add and edit with persisted selection
- [x] Confirmed, reference-preserving deactivation and explicit reactivation
- [x] Domain/form validation and case-insensitive active-name uniqueness
- [x] Suggested Battery-scope icon with safe fallback
- [x] Suggested icon color
- [x] Default voltage/capacity/chemistry, physical size, description, and notes

## Acceptance

- [x] CRUD/lifecycle persists through real Drift/SQLite and restart tests
- [x] Invalid records are rejected with field-level messages
- [x] Suggested icon/color can be selected or overridden and never forces a Battery visual
- [x] UUID remains stable; deactivation preserves all Battery, Set, and Device references
- [x] Lifecycle writes are transactional and append activity events with deactivation usage metadata

## Phase 4 implementation and acceptance evidence

- `BatteryTypeDraft` trims optional values, requires a name, rejects non-finite/non-positive defaults, and requires capacity/unit together. The chemistry/unit suggestion controls are editable and preserve custom values.
- `DriftBatteryTypeRepository` enforces active case-insensitive names, validates Battery-scope icon selections, generates an immutable UUID once, soft-deactivates without mutating references, blocks conflicting reactivation, and records typed lifecycle activity in the same transaction.
- The management page uses a responsive list/detail layout, concise logged failures, field-level validation, exact usage-count confirmation, and Generic Battery fallback for missing custom suggestions.
- Final fresh evidence: `flutter pub get` exit 0; `dart run build_runner build` exit 0 with 0 outputs; format check exit 0 with 0 changed files; analysis exit 0 with `No issues found!`; `flutter test --no-pub` exit 0 with 151 passing tests; Windows Release build exit 0. Artifact hashes are recorded in Environment notes above. The Release executable was `build\windows\x64\runner\Release\battery_tracker.exe`; PIDs 8680 and 11284 each remained alive after five seconds and were stopped by exact PID.

---

# Phase 5 — Battery Inventory

**Status:** Complete (2026-09-08)

## Scope

- [x] Battery model
- [x] Permanent UUID
- [x] User Battery ID
- [x] sequential ID suggestion
- [x] specifications
- [x] purchase information
- [x] status
- [x] condition
- [x] notes
- [x] table view
- [x] card view
- [x] search
- [x] filters
- [x] sorting
- [x] detail screen

## Acceptance

- [x] Battery data persists after restart
- [x] UUID never changes during edits
- [x] user-facing ID may change
- [x] search/filter works
- [x] no photo required

---

### Phase 5 implementation notes

- Added the Battery domain model, repository, and Riverpod wiring using schema v1 without new dependencies.
- Saves preserve UUID/creation time and existing relational rows; Battery, Batch, and activity/status writes are atomic.
- Battery Type defaults require an explicit action and remain editable; inactive types are retained only on existing references.
- Added table/card inventory, eight combined filters, search, sorting, full add/edit fields, duplicate-ID feedback, and detail/status history.
- ID suggestions are previews. Saving never substitutes another ID if a collision occurs.
- Repository and UI checks cover persistence/restart, UUID stability, rollback, type overrides, existing relationships, Light/Dark workflows, search, and ordering.
- Verification runs from a fresh local TEMP snapshot because in-place tests hit ENV-002 (`build/unit_test_assets` deletion denied). Final results: dependency restore exit 0; formatting checked 95 files with zero changes; analysis found no issues; all 161 tests passed; Windows Release build exited 0. MSBuild emitted the expected TEMP-output warning. All Dart source/test files matched the snapshot.

- The verified Release folder was copied to ignored `build/phase5-release`; its executable SHA-256 is 400CC60D7E696B555A58F1C8A604D4C39D20F2C126BB271CC3F8B4E747772ADE. PID 15704 remained alive after five seconds and was stopped by exact PID. This is a launch check; UI behavior is covered by widget tests.

---

# Phase 6 — Optional Photographs

**Status:** Complete (2026-09-08)

## Scope

- [x] Application-managed image storage
- [x] Add Photograph
- [x] Drag/drop where practical
- [x] Webcam capture where practical
- [x] Primary/additional photos
- [x] Icon Primary / Photo Primary choice
- [x] Missing-photo fallback

## Acceptance

- [x] adding a photo does not automatically replace Icon Primary
- [x] switching primary visual works
- [x] removing photo leaves icon intact
- [x] missing file falls back to icon

---

## Phase 6 implementation and verification

- Added shared PhotoOwner/PhotoRepository/PhotoStorage contracts, transaction-backed SQLite media/link operations for Batteries, Sets, and Devices, and compensating file cleanup. Schema remains v1.
- Added PNG/JPEG/WebP signature and decode validation, 25 MB/40-megapixel bounds, UUID relative paths, dimensions, and SHA-256 metadata. Sources remain untouched.
- Battery details expose the gallery; table/card/detail visuals honor the explicit preference. Icons are shown during loading and on missing/corrupt photos. Replace/remove controls remain usable when an original file is gone.
- Added file import, desktop drag/drop, primary/additional selection, explicit Keep Icon as Primary default, confirmed removal, and optional webcam preview/capture through platform adapters. Photo writes preserve inventory UUID and icon fields.
- Reviewed and added camera/camera_windows and desktop_drop for native Windows support; crypto was already transitive and is now direct for checksums. The photo module README records package sources, limitations, storage semantics, and future platform adapters.
- Verification: snapshot `flutter pub get` exit 0; formatting checked 106 files with zero changes; `flutter analyze --no-pub` found no issues; the complete suite passed all 176 tests; Windows Release build exited 0. MSBuild emitted its expected TEMP-output warning.
- In-place `flutter pub get` restored packages but exited 1 when OneDrive denied deletion of `windows/flutter/ephemeral/.plugin_symlinks`; ENV-002 remains open. Verification used a fresh normal-ACL local snapshot. All Dart source and tests were hash-matched to that snapshot.
- Copied the runnable release to ignored `build/phase6-release`. Executable SHA-256: `76FBB2F7815056BB2A2E1E700390D2981E47CBDC4123AE50BA308CEF6F6D2A95`. PID 27660 remained alive for five seconds; the startup log recorded successful initialization. The process was then stopped by exact PID.
- Validation limit: no physical webcam capture or OS-level drag gesture was performed. Automated checks cover gallery integration, drop callback, no-camera/cancellation states, persistence, primary preference, rollback cleanup, cross-owner rejection, replacement/removal, and missing/corrupt fallback. MacOS camera capture needs a future adapter; Windows camera support is built and registered.

---
# Phase 7 — Battery Sets

**Status:** Complete (2026-09-08)

## Scope

- [x] Set record
- [x] permanent UUID
- [x] sequential Set ID
- [x] membership
- [x] membership history
- [x] compatibility warnings
- [x] detail screen
- [x] set icon/photo
- [x] Mark Entire Set Charged
- [x] Set assignment

## Acceptance

Use all Battery Set scenarios in the master prompt.

## Implementation decisions

- Added a transactional BatterySetRepository over the existing schema v1: stable UUIDs, sequential suggestions without silent ID changes, full record editing, soft deletion/deactivation, and scoped icons/photos.
- Add/move/remove preserves membership rows and original notes. Type, chemistry, voltage, capacity, and existing membership warnings are recalculated inside the write transaction. Move closes source memberships and records source/target activity together.
- Entire-Set charging creates a Set record and one charge record for every current member; individual lifetime totals remain independent. Empty, inactive, or retired/non-rechargeable membership is rejected before writes.
- Set assignment creates a parent plus linked member rows with one operation UUID. Removal closes only those linked rows, preserving original assignment notes and unrelated Device occupants. Both operations update statuses/history atomically.
- Membership changes, deactivation, and deletion require first removing the Set from its Device. Deactivation retains links but removes the Set from active status calculations; deletion closes memberships and retains Batteries/history/media.
- Advanced the minimal Device creation dependency needed to make Set assignments usable. Full Device CRUD remains Phase 8. General assignment/charging screens remain Phases 9/10. The already-planned Phase 13 adds QR display/label actions to Set details.
- Shared InventoryIcon now supplies scope-specific fallback; the BatteryTypeIcon API remains a compatibility wrapper. Set details show member manufacturer, capacity, condition, status, Recorded Charges, last charge, and icon/photo.
- Added repository and widget coverage, including all four-member master scenarios, restart persistence, compatibility cancel/accept, unequal charge counts, and injected rollback failures during move, charge, assignment, and removal.

## Verification

- Snapshot `flutter pub get` exited 0. `dart format --output=none --set-exit-if-changed .` checked 113 files with zero changes. `flutter analyze --no-pub` found no issues. The complete `flutter test --no-pub` suite passed all 197 tests. `git diff --check` passed.
- `flutter build windows --release --no-pub` exited 0 (86.0 seconds). MSBuild emitted the expected MSB8029 warning for TEMP output paths.
- All 113 Dart source/test files hash-match the verified snapshot. The runnable output was copied to ignored `build/phase7-release`; executable SHA-256: `C71B4926FA3BFBF855728476BE4B358DCC8BD1E76B38B99A824F062E485E11B6`.
- The copied executable remained alive for five seconds (PID 24128); the application log recorded initialization at `2026-09-08T13:33:02.575288Z`. The test process was stopped by exact PID after verification.
- ENV-002 remains open: in-place `flutter analyze` triggered package generation that failed while deleting `ios/Flutter/ephemeral/Packages/.packages`. Verification used a normal-ACL temporary snapshot without changing workspace permissions.
- UI workflow verification is automated using the real SQLite repository. The native release received a startup smoke check; Phase 6 physical webcam/OS drag-gesture limitations remain unchanged.

---

# Phase 8 — Devices

**Status:** Complete (2026-09-08)

## Scope

- [x] Device record
- [x] permanent UUID
- [x] category
- [x] manufacturer/model/serial
- [x] location
- [x] icon/color
- [x] optional photos
- [x] battery requirements
- [x] detail screen
- [x] search

## Acceptance

- [x] Device persists
- [x] icon-only workflow works
- [x] requirements guide but do not block override

## Implementation decisions

- Added full Device domain/repository/form/page modules using existing schema v1. No migration or production dependency was added.
- Custom categories are free text with reusable category chips. Built-in category suggestions apply icon/color only on explicit request; default remains Generic Device. Shared InventoryIcon and photo gallery preserve fallback and explicit primary preference.
- Added name/category/location/manufacturer/model/serial/description/notes fields, optional type/quantity/voltage requirements and notes, current inventory, assignment/activity history, search, and active/category filters.
- Device creation from Set assignment now delegates to the full Device repository. Existing UUIDs, creation dates, photo preference, and assignment relationships survive edits.
- Active Device names are case-insensitively unique. Inactive type references remain editable when unchanged; new required types must be active. Reactivation checks name conflicts without discarding inactive records.
- Deactivation/deletion require zero open assignments and run in the same transaction as activity writes. Soft deletion retains inventory, historical references, and managed media.
- Whole-Set assignment and removal are available from Device details using existing transactional warning/override behavior. Device/Set catalog invalidation is coordinated. Individual assignment workflows remain Phase 9; QR actions remain Phase 13.
- Tests cover actual repository-backed UI, narrow dark layout, photo fallback, restart persistence, lifecycle confirmation, and injected rollback failures.

## Verification

- Snapshot `flutter pub get` exited 0. `dart format --output=none --set-exit-if-changed .` checked 120 files with no changes. `flutter analyze --no-pub` found no issues. The full `flutter test --no-pub` suite passed all 213 tests. `git diff --check` passed.
- The targeted Device/navigation run passed all 22 tests. The real-file photo widget fixture uses `tester.runAsync` for file/decode work outside Flutter's simulated test clock; the corrected missing-photo/gallery test passes.
- `flutter build windows --release --no-pub` exited 0 in 103.2 seconds. The expected MSB8029 TEMP-output warning remains environmental.
- All 120 Dart source/test files hash-match the verified snapshot. The runnable release is copied to ignored `build/phase8-release`; executable SHA-256: `6F08AF63BF1B9F988C006FE64B8B6833FF5B02AA449F7550381183CE22B5EBD7`.
- The copied executable remained alive for five seconds (PID 1884); the application log recorded initialization at `2026-09-08T14:15:17.962976Z`. The verification process was then stopped by exact PID.
- ENV-002 remains open; verification used a normal-ACL temporary snapshot without modifying workspace permissions. Native startup is verified; detailed workflows are covered by automated SQLite-backed widget tests. Physical webcam and OS drag gestures retain the Phase 6 manual-verification limitation.

---

# Phase 9 — Assignments

**Status:** Complete (2026-09-08)

## Scope

- [x] Battery → Device
- [x] multiple Batteries → Device
- [x] Set → Device
- [x] removal
- [x] compatibility warnings
- [x] assignment history
- [x] transaction safety

## Acceptance

- [x] history is never overwritten
- [x] Set assignment is atomic
- [x] removal preserves dates/history

## Implementation decisions

- Added a shared DriftAssignmentRepository for individual, multi-Battery, and whole-Set assignment/removal. Existing Set methods delegate and translate validation/warning types for compatibility. Schema remains v1 with no dependency changes.
- The Assignments destination and scoped Battery/Device managers expose Device selection, available/all inventory, multi-selection, dates/times, installation notes, confirmation, warning acknowledgment, removal notes, and duration/history.
- Type/quantity/voltage and status warnings are recomputed inside the transaction. Quantity guidance includes existing Device occupants. Assigned and retired Batteries are rejected; individually assigning a current Set member warns without altering membership.
- Root Set removal closes every linked child atomically. Direct removal of a linked member is blocked; the UI provides the parent action. Mixed direct/Set removals preserve unrelated rows and all original installation dates/notes/UUIDs.
- Dates are stored in UTC, shown locally, and can be backdated. Future dates, removals before installation, and installations before the last recorded removal are rejected. Backdated Set entries snapshot current members; their assignment links remain historical even after membership changes.
- Removal notes are assignment-specific activity metadata, leaving installation notes untouched. Shared status handling retains intentional nonrelationship statuses on removal.
- Catalog invalidation connects Set/Device shortcuts and the new assignment manager. Existing Set/Device shortcuts now accept explicit assignment/removal dates.

## Verification

- Snapshot `flutter pub get` exited 0. Formatting checked all 128 Dart files with zero changes. `flutter analyze --no-pub` found no issues. The full `flutter test --no-pub` suite passed all 231 tests. `git diff --check` passed.
- Targeted runs passed 46 repository/Set/Device checks and 24 assignment/navigation checks before the final detail-entry smoke test was added. The final full suite includes both Battery and Device entry paths.
- `flutter build windows --release --no-pub` exited 0 in 83.5 seconds. MSBuild emitted the expected MSB8029 warning for TEMP output paths.
- All 128 Dart source/test files hash-match the verification snapshot. The runnable release is copied to ignored `build/phase9-release`; executable SHA-256: `06FC4A0E6AC2199BA11FB7113513A6ABD892362B045E7CC9C440940DDC433ADA`.
- The copied executable remained alive for five seconds (PID 27816), and the startup log recorded initialization at `2026-09-08T14:35:21.866492Z`. The verification process was then stopped by exact PID.
- ENV-002 remains open; verification used a normal-ACL snapshot without changing workspace permissions. Detailed workflows were exercised by automated SQLite-backed widget tests; the native release received a startup check.

---

# Phase 10 — Charge Tracking

**Status:** Complete (2026-09-08)

## Scope

- [x] Mark Charged
- [x] Recorded Charges
- [x] Last Charged
- [x] optional start/end percentage
- [x] charger
- [x] notes
- [x] Set charge
- [x] selected-battery bulk charge

## Acceptance

- [x] "Recorded Charges" terminology used
- [x] Set charging creates individual records atomically
- [x] bulk charge is atomic

---

Implementation: shared transactional charge repository; individual, selected, and Set dialogs; charge history; default ending percentage 100; separate manual current estimates. Backdated entries preserve latest charge date and do not clear a more recently modified Charging status. Schema v1, no dependencies added.

Verification: 247 tests passed, 135 Dart files formatted without changes, analysis clean. Windows Release build passed (84.3 seconds); five-second startup check passed with a fresh initialization log. Source/test hashes match the normal-ACL verification snapshot (ENV-002 workaround). Runnable copy: `build/phase10-release`.

# Phase 11 — Bulk Battery Creation

**Status:** Complete (2026-09-08)

## Scope

- [x] shared fields
- [x] quantity
- [x] prefix
- [x] separator
- [x] starting number
- [x] padding
- [x] generated preview
- [x] duplicate detection
- [x] next available IDs
- [x] per-row edits
- [x] shared icon/color
- [x] Batch ID
- [x] optional Set creation
- [x] transactional save
- [x] completion summary

## Acceptance

Implemented Phase 11 scenarios: 4/20 Batteries, ID format controls, duplicate/skip/next-available handling, editable preview, shared and per-row icons/colors, purchase data, Batch, tags, existing/new Sets and two-Set splits, unique UUIDs, restart persistence, and all-or-nothing rollback. Cross-phase scenarios remain explicitly tracked: bulk edit/retirement/Set changes in Phase 12, QR/PDF in Phase 13, backup/restore in Phase 16. Existing selected charging is Phase 10.

---

Implementation: common draft editor reused without persistence; one outer transaction composes existing Battery and Set repositories. Quantity 1–1000 per operation; no schema migration or dependency additions. Price allocation occurs only during preview generation and remains explicit after row edits/skips.

Verification: 268 tests passed, including the previously visited Sets-screen refresh regression. Formatting: 140 Dart files, no changes. Analysis clean. Final Windows Release build passed (40.0 seconds) and five-second startup check passed with a fresh initialization log. Source/test hashes match the normal-ACL verification snapshot (ENV-002 workaround). Runnable copy: `build/phase11-release`.

# Phase 12 — Bulk Edit

**Status:** Complete (2026-09-08)

## Scope

- [x] Type
- [x] Status
- [x] Condition
- [x] Icon
- [x] Icon Color
- [x] Set membership
- [x] Shared note
- [x] Purchase information
- [x] Retirement
- [x] Charge action
- [x] Preview/confirmation

## Acceptance

- [x] user sees affected-record count
- [x] dangerous changes require confirmation
- [x] no silent destructive changes

---

Implementation: explicit table/card selection; per-action old/new previews; transaction-safe Type/Status/Condition/icon/color/purchase edits, appended notes/tags, Set additions/removals, retirement date/reason, and selected charging. Stale previews fail without partial changes. Device assignments must be removed before retirement; Set memberships remain. Schema v1; no production dependencies added.

Verification: 293 tests passed, including ordinary-edit retirement metadata preservation/restoration. Formatting: 145 Dart files, no changes. Analysis clean. Final Windows Release build passed (37.0 seconds); five-second startup check passed with a fresh initialization log. Source/test hashes match the normal-ACL verification snapshot (ENV-002 workaround). Runnable copy: `build/phase12-release`.

# Phase 13 — QR Labels

**Status:** Complete (2026-09-08)

## Scope

- [x] UUID URI format
- [x] Battery QR
- [x] Set QR
- [x] Device QR
- [x] Label designer
- [x] templates
- [x] live preview
- [x] icon rendering
- [x] custom icon rendering
- [x] optional photo rendering
- [x] individual print
- [x] batch print
- [x] sheet layout
- [x] starting label position
- [x] PDF export
- [x] QR lookup

## Acceptance

Use all QR Label scenarios in the master prompt.

---

Implementation: permanent-UUID QR generation and lookup for Batteries, Sets, and Devices; a visual label designer with presets, fields, dimensions, orientation, alignment, icons/colors and optional photographs; reusable SQLite templates; saved selections; shared live/page/PDF rendering; native printing; custom sheets and starting positions. Inventory details and bulk creation open scoped label selections. Icon-first inventory preferences remain unchanged when a label explicitly uses a photo.

Verification: 326 tests passed (33 new QR/domain/repository/rendering/UI cases). All 156 Dart files are format-clean; analysis is clean. Independent PDF inspection verified Letter and portrait page sizes, three-sheet distribution of 1/30/1 labels, and positions starting at slot 30. Rendered QR images decode successfully, including small/portrait labels and custom PNG/SVG icons. Templates/jobs survive SQLite restart; canceled printing/export creates no output history. Full-source/test hashes match the verification snapshot.

Final Windows Release build passed (104.6 seconds), followed by a five-second startup check with a fresh initialization log at 2026-09-08T16:26:37.137191Z. Runnable copy: `build/phase13-release`; SHA256: `A5BF9BBCD3E33604AB8F558A5776D24CF2F90569636E6D405EFBD0DA98CB7609`. The complete release includes the printing plugin and PDFium. ENV-002 still requires a normal-ACL verification snapshot; the build emitted only the known temporary-output warning.

Hardware acceptance remaining: check physical label alignment and live webcam capture on the target workstation. Print submission/cancellation and image decoding are tested; physical paper output and camera hardware were not exercised. Mobile/Apple builds remain unverified. Schema v1 is unchanged; dependency decisions and usage are documented in `lib/features/qr_labels/README.md`.

# Phase 14 — Dashboard

**Status:** Complete (2026-09-08)

## Scope

- [x] summary cards
- [x] recent activity
- [x] batteries needing attention

## Acceptance

- [x] all values come from real persisted data
- [x] no hard-coded counts

---

Implementation: nine live inventory cards; latest 20 activity events with current record labels; distinct current-assignment and Set-membership counts; attention reasons for explicit flags, retirement, age since recording a charge, Recorded Charges totals, and current Set usage differences. Configurable rules persist in schema v1 settings. Search, retired filtering, pagination, direct UUID record navigation, and operational shortcuts are available. Table notifications and a one-minute refresh keep the view current. No migration or production dependency was added.

Verification: 343 tests passed, including 17 new dashboard repository/UI cases. All 160 Dart files are format-clean; analysis and diff checks are clean. Tests cover threshold boundaries, disabled rules, closed relationships, deleted entities, live updates without count changes, settings restart persistence, navigation, error handling, and light/dark layouts. A populated dashboard screenshot was visually reviewed. Source/test hashes match the normal-ACL verification snapshot.

Final Windows Release build passed (91.9 seconds); five-second startup check passed with no new severe log entries and initialization at 2026-09-08T16:57:52.979877Z. Runnable copy: `build/phase14-release`; SHA256: `9CB09EF7D93659617C459FC4B9A088EF96F6ECE261315D3590E99D2A056E725F`. ENV-002 remains the reason for building outside the OneDrive checkout; the known temporary-output warning is unchanged.

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
| 2026-09-08 | Dashboard snapshots use read transactions and table-update notifications | Keeps relationship counts, attention rules, and recent events consistent and current without cached totals. | Existing schema v1 settings persist configurable reminders; entity route intents open records by UUID. |
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
| 2026-08-15 | Battery Types are soft-deactivated reusable definitions | Existing inventory references must retain their historical/current meaning; an active-name collision must not be silently resolved. | Usage is counted before confirmation, existing foreign keys remain untouched, and reactivation performs the active-name check. |

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

1. Begin Phase 15 History using the retained activity, assignment, membership, and charge records.
2. Implement history views and filters for additions, assignments, membership, charging, status changes, retirement, QR actions, and bulk operations.
3. Verify history filtering, chronological ordering, retained meaning after edits/deletions, and restart persistence.
## Tooling maintenance

- 2026-08-15: `bootstrap_windows.ps1` and `check.ps1` now share automatic Flutter/Dart SDK discovery. Windows PowerShell 5.1 tests cover override, `PATH`, per-user fallback, incomplete SDK rejection, and matched Dart resolution.
