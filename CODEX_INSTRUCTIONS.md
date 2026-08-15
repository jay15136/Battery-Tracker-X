# Battery Tracker — Codex Project Instructions

## Purpose

This file tells ChatGPT Codex how to use the Battery Tracker specification and how to execute the project safely and systematically.

The product requirements are defined in:

`Battery_Tracker_Master_Codex_Prompt.md`

The repository-level working rules are defined in:

`AGENTS.md`

For Codex, `AGENTS.md` is the authoritative repository instruction file. Read both files before beginning implementation.

---

# 1. Source of Truth

Use this precedence order when deciding what to build:

1. The user's newest explicit instruction.
2. `Battery_Tracker_Master_Codex_Prompt.md`
3. `AGENTS.md`
4. Existing project documentation and implementation decisions that do not conflict with items 1–3.
5. Existing code behavior.

Do not silently weaken, remove, or reinterpret a Version 1 requirement.

If two requirements appear to conflict:

1. Identify the conflict.
2. Prefer the more specific requirement.
3. Prefer the newer requirement when dates or revisions are clear.
4. Record the decision in the project documentation.
5. Continue with the safest implementation that preserves data and existing functionality.

Do not stop solely because a minor implementation detail is unspecified. Choose a reasonable, cross-platform design and document the decision.

---

# 2. Product Goal

Build **Battery Tracker**, a polished offline-first rechargeable-battery inventory application.

Initial target:

- Windows 11 desktop

Required architecture direction:

- Flutter
- Dart
- SQLite
- Cross-platform service boundaries
- Future portability to Android, iPhone/iPad, and macOS

Core Version 1 capabilities include:

- Battery inventory
- Battery Types
- Battery Sets
- Devices
- Battery/device assignments
- Charge history
- Status and condition tracking
- Icon-first, photo-optional visuals
- Built-in generic icons
- Icon colors
- User-imported PNG/SVG icons
- Optional photographs
- Bulk battery creation
- Batch IDs
- Bulk editing
- Bulk charging
- QR-code labels
- Label designer
- Sheet printing
- PDF label export
- CSV import/export
- Backup and restore
- Unified history/activity log

Do not move required Version 1 features into a future roadmap.

---

# 3. Core Product Rule

The visual rule for the entire application is:

**Icons identify inventory. Photographs add detail.**

The application is:

**ICON-FIRST, PHOTO-OPTIONAL**

This means:

- Every Battery, Battery Set, and Device always has a usable icon.
- A photograph is never required.
- The default primary visual is the icon.
- Adding a photograph does not automatically make the photograph primary.
- Users can explicitly switch between Icon Primary and Photo Primary.
- The selected icon remains associated with the record as a fallback.
- Missing photograph files must fall back to the icon instead of producing broken-image UI.

Treat this as a product invariant.

---

# 4. First Codex Session

When starting from an empty or new repository:

1. Read `AGENTS.md` completely.
2. Read `Battery_Tracker_Master_Codex_Prompt.md` completely.
3. Inspect the current repository.
4. Inspect the local development environment.
5. Confirm Flutter and Windows desktop requirements.
6. Create an implementation plan.
7. Create the Flutter project if one does not already exist.
8. Establish the project structure.
9. Establish the database/migration architecture.
10. Select dependencies deliberately.
11. Build the smallest working application shell.
12. Run it.
13. Continue into the next implementation phase.

Do not stop after producing an architecture report.

The first session should leave the repository in a runnable state whenever the local environment permits it.

---

# 5. Recommended Initial Prompt to Codex

Use this prompt from the repository root:

> Read `AGENTS.md` and `Battery_Tracker_Master_Codex_Prompt.md` completely before changing files. Inspect the repository and development environment. Create or update the implementation plan, then begin implementing Battery Tracker in the required phase order. Do not stop at planning or scaffolding. Build, analyze, test, and fix each completed phase before moving on. Preserve all Version 1 requirements and keep the project runnable.

For an existing implementation, use:

> Read `AGENTS.md`, `Battery_Tracker_Master_Codex_Prompt.md`, the current implementation plan, and the relevant code. Determine the first incomplete Version 1 requirement. Implement it end-to-end, add or update tests, run the applicable checks, fix failures, and update documentation. Do not replace working behavior with placeholders.

---

# 6. Execution Plan

Battery Tracker is a large multi-phase project. Maintain a living implementation plan.

Recommended file:

`docs/IMPLEMENTATION_PLAN.md`

The plan should contain:

- Current project status
- Architecture decisions
- Major dependencies
- Database schema status
- Completed phases
- Current phase
- Remaining Version 1 work
- Known defects
- Test status
- Important design decisions
- Migration notes
- Cross-platform concerns

For each major phase include:

- Goal
- Requirements being implemented
- Files/modules affected
- Database changes
- Tests required
- Acceptance criteria
- Status

Update the plan as work progresses.

Do not use the plan as a substitute for implementation.

---

# 7. Required Implementation Order

Use this order unless the existing codebase makes a small dependency-driven adjustment necessary.

## Phase 1 — Architecture

Define:

- project structure
- database schema
- migrations
- models
- repositories
- services
- state-management approach
- navigation
- storage locations
- platform abstraction boundaries

## Phase 2 — Project Foundation

Implement:

- Flutter project
- Windows desktop support
- dependencies
- navigation shell
- light/dark themes
- logging
- configuration
- SQLite initialization
- migrations
- shared UI patterns

## Phase 3 — Icon System

Implement before photographs:

- built-in icon registry
- default icons
- icon selector
- icon colors
- custom PNG/SVG import
- custom icon categories
- custom icon management
- icon persistence
- missing/deprecated icon handling

## Phase 4 — Battery Types

Implement full CRUD and validation.

## Phase 5 — Battery Inventory

Implement:

- battery records
- table view
- card view
- add/edit/details
- search
- filters
- sorting
- status
- condition
- UUIDs
- sequential user IDs

## Phase 6 — Optional Photographs

Implement:

- application-managed storage
- primary/additional photos
- drag/drop where appropriate
- file selection
- webcam capture where practical
- photo/icon primary preference
- icon fallback

## Phase 7 — Battery Sets

Implement:

- set records
- sequential Set IDs
- membership
- membership history
- compatibility warnings
- set charging
- set assignment
- set detail screen

## Phase 8 — Devices

Implement full device management and optional battery requirements.

## Phase 9 — Assignments

Implement:

- individual battery assignments
- multiple batteries
- whole-set assignments
- removal
- history
- validation/warnings
- transaction safety

## Phase 10 — Charge Tracking

Implement:

- Mark Charged
- Recorded Charges
- Last Charged
- optional estimated percentage
- set charging
- selected-battery bulk charging

## Phase 11 — Bulk Battery Creation

Implement:

- shared fields
- sequential ID generation
- duplicate detection
- next-available IDs
- preview
- per-row overrides
- optional Batch ID
- optional Battery Set creation
- transaction-safe creation
- completion summary

## Phase 12 — Bulk Edit

Implement supported mass operations with preview and confirmation.

## Phase 13 — QR Labels

Implement:

- UUID-based QR values
- battery/set/device labels
- label templates
- live label designer
- built-in/custom icon rendering
- optional photos
- individual printing
- batch printing
- sheet printing
- starting-label position
- PDF export
- QR lookup

## Phase 14 — Dashboard

Use real database queries. No hard-coded statistics.

## Phase 15 — History

Implement complete activity and history views.

## Phase 16 — Backup, Restore, Import, Export

Implement and verify:

- complete backups
- validation
- restore
- custom icons
- photographs
- templates
- settings
- CSV import
- CSV export

## Phase 17 — Testing and Cleanup

Run the complete quality pass and close Version 1 gaps.

---

# 8. Architecture Rules

Use clear layers. Do not put business logic directly in UI widgets.

Recommended organization:

```text
lib/
  app/
  core/
    database/
    logging/
    routing/
    theme/
    utilities/
  features/
    batteries/
    battery_types/
    battery_sets/
    devices/
    assignments/
    charging/
    bulk_operations/
    icons/
    photos/
    qr_labels/
    history/
    backup/
    import_export/
    settings/
  services/
```

The exact structure may vary, but responsibilities must remain separated.

Use isolated services/interfaces for platform-sensitive work, including:

- DatabaseService
- IconService / IconRegistry
- ImageService
- CameraService
- BatterySetService
- AssignmentService
- ChargeService
- QrCodeService
- LabelService
- PrintService
- BackupService
- ImportService
- ExportService

Do not let Windows-only APIs leak into core domain models.

---

# 9. Database Rules

SQLite is the Version 1 local database.

Requirements:

- Permanent UUIDs for Batteries, Battery Sets, Devices, and custom icons
- Foreign keys
- Appropriate indexes
- Created/modified timestamps
- Migration/version support
- Parameterized queries
- Transactions for multi-record operations
- Meaningful historical records
- Soft deletion where appropriate

Never use editable IDs such as `AA-001` as permanent record identity.

Treat the UUID as immutable.

Do not directly overwrite history when:

- moving batteries between sets
- assigning/removing batteries
- assigning/removing sets
- recording charges
- retiring records

Use history rows/events.

---

# 10. Transaction Boundaries

Use transactions for operations that must be all-or-nothing.

Examples:

- Bulk battery creation
- Creating batteries plus set memberships
- Assigning an entire Battery Set to a Device
- Removing an entire Set assignment
- Marking an entire Set charged
- Marking multiple selected Batteries charged
- Restoring a backup where transactional database replacement is used

A failed operation must not leave unexplained partial state.

---

# 11. Data Safety

Do not silently destroy user data.

Before destructive operations:

- identify dependent records
- explain the impact
- require confirmation
- preserve history where required

Examples:

- Deleting a Battery that is assigned
- Deleting a Battery in a Set
- Deleting a Set
- Deleting a custom icon that is in use
- Restoring a backup over current data
- Bulk retirement/deletion

Prefer deactivation, retirement, or soft deletion when it preserves meaning.

---

# 12. Dependency Policy

Before adding a production dependency:

1. Confirm it supports the required Windows behavior.
2. Check whether it supports or has a reasonable path for Android/iOS/macOS.
3. Prefer maintained packages with clear licenses.
4. Avoid packages that force cloud services.
5. Avoid unnecessary dependency overlap.
6. Document why the package was selected.

If two packages provide the same core capability, choose one unless there is a clear reason to keep both.

Keep package choices centralized in project documentation.

---

# 13. Cross-Platform Rules

Windows is the first shipping target, but architecture must not trap the project on Windows.

Do not:

- store Windows absolute file paths as permanent logical identifiers
- depend on Windows-only system icons for inventory identity
- mix platform-specific camera/printing code into domain models
- encode platform-specific paths into QR records
- use Windows-only values for icon colors

Use logical identifiers and application-managed relative paths.

---

# 14. UI Rules

The app should feel like a polished inventory program.

Requirements:

- modern Windows desktop layout
- left navigation
- resizable windows
- keyboard/mouse support
- standard scaling
- light mode
- dark mode
- clear empty states
- responsive operations
- clear destructive-action confirmations

Avoid:

- unfinished placeholder screens
- raw debug controls in production UI
- hard-coded demo data in production
- broken-image boxes
- cryptic exception text

---

# 15. Battery ID Rules

A Battery has:

- Permanent UUID
- Editable user-facing Battery ID

Support sequential IDs such as:

- AA-001
- AAA-001
- 18650-001
- TOOL-001

Bulk creation must support:

- prefix
- separator
- starting number
- padding
- quantity
- duplicate detection
- next available IDs
- preview
- row-level overrides

Never silently change generated IDs after preview.

---

# 16. Batch vs Set

Keep these concepts distinct.

**Batch**
Batteries purchased or entered together.

**Battery Set**
Batteries intentionally kept, charged, or used together.

A battery may belong to a Batch and a Set at the same time.

Batch membership is not a replacement for Set membership.

---

# 17. QR Rules

QR codes must resolve through permanent UUIDs.

Use a stable logical format such as:

- `batterytracker://battery/{UUID}`
- `batterytracker://set/{UUID}`
- `batterytracker://device/{UUID}`

Changing `AA-001` to another user-facing ID must not invalidate the QR code.

QR label rendering must support:

- built-in icons
- custom icons
- icon colors
- optional photograph
- selected text fields
- custom text

---

# 18. Backup Rules

A backup must preserve the complete usable application state.

Include:

- SQLite database
- photographs
- custom icon files
- custom icon metadata
- QR label templates
- settings
- icon selections
- icon colors

Built-in packaged icon assets do not need to be duplicated.

Before restore:

- validate archive
- confirm with user
- protect against partial restore

After restore, verify:

- database opens
- icon references resolve
- custom icons load
- photographs load or gracefully fall back
- QR templates exist
- core counts are consistent

---

# 19. Testing Policy

A feature is not complete because it compiles.

For each feature:

1. Add/update automated tests where practical.
2. Run targeted tests.
3. Run static analysis.
4. Run formatting checks.
5. Exercise the core UI workflow where practical.
6. Fix failures before claiming completion.

At major milestones also run:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows
```

If a command cannot run because the environment lacks a required component, document the exact blocker and continue with every check that can run.

Do not claim successful execution for commands that were not run.

---

# 20. Required Regression Areas

Always consider regression risk in:

- SQLite migrations
- assignment history
- set membership history
- UUID stability
- custom icon references
- photograph fallback
- bulk transactions
- QR resolution
- backup/restore
- CSV import validation
- label rendering
- dark/light mode

---

# 21. Error Handling

Normal users must not see raw stack traces.

Use actionable messages.

Technical details should go to logs.

Examples:

- Battery could not be saved.
- Some generated Battery IDs already exist.
- The selected custom icon could not be imported.
- The selected photograph is unavailable.
- Backup validation failed.
- Restore was cancelled because the backup is not valid.

---

# 22. Documentation

Keep these documents current as the project evolves:

- `README.md`
- `docs/IMPLEMENTATION_PLAN.md`
- database/schema documentation
- migration notes
- architecture decisions when important

README must eventually include:

- description
- features
- technology stack
- setup
- Windows prerequisites
- run commands
- build commands
- release/installer instructions
- database location
- image location
- custom icon location
- backup location
- testing
- limitations
- roadmap

---

# 23. Completion Standard

Do not mark a feature complete unless:

- required behavior exists
- persistence works
- validation exists
- error handling exists
- relevant history is preserved
- relevant tests pass
- static analysis is acceptable
- documentation is updated when behavior/setup changed

Do not use placeholder functions for required Version 1 behavior.

Do not leave a feature looking complete in the UI while its persistence or business logic is fake.

---

# 24. Progress Reporting

When working interactively, report progress in concrete terms.

Good:

- "Implemented battery UUID persistence and sequential IDs; database tests pass."
- "Set assignment now runs in one transaction; mismatch warning still needs UI coverage."

Avoid vague statements such as:

- "Made good progress."
- "Mostly done."
- "Should work."

State blockers precisely.

---

# 25. Change Discipline

Before editing:

1. Read relevant files.
2. Understand existing architecture.
3. Identify tests.
4. Make the smallest coherent change.

After editing:

1. Format.
2. Analyze.
3. Run targeted tests.
4. Run broader tests when appropriate.
5. Review the diff.
6. Update documentation.

Do not rewrite unrelated working code simply to match a preference.

---

# 26. Version Control Guidance

Keep changes reviewable.

Prefer logical commits such as:

- `feat: add battery type persistence`
- `feat: add icon registry and color support`
- `feat: add battery set membership history`
- `feat: add bulk battery creation`
- `feat: add uuid-based qr labels`
- `test: cover set assignment transactions`
- `docs: update Windows build instructions`

Do not commit secrets, build artifacts, local databases, user photos, or machine-specific paths.

Maintain an appropriate `.gitignore`.

---

# 27. Version 1 Acceptance Checklist

Before calling Version 1 complete, verify all major categories:

- [ ] Windows application builds and runs
- [ ] SQLite data persists across restart
- [ ] Battery Types work
- [ ] Batteries work
- [ ] Battery Sets work
- [ ] Devices work
- [ ] Assignments work
- [ ] Charge history works
- [ ] Built-in icons work
- [ ] Icon colors persist
- [ ] Custom PNG/SVG icons work
- [ ] Photo-optional workflow works
- [ ] Icon fallback works
- [ ] Bulk battery creation works
- [ ] Batch IDs work
- [ ] Bulk edit works
- [ ] Bulk charging works
- [ ] UUID QR labels work
- [ ] Label designer works
- [ ] Sheet printing works
- [ ] PDF label export works
- [ ] QR lookup works
- [ ] Dashboard uses real data
- [ ] History is preserved
- [ ] CSV import works
- [ ] CSV export works
- [ ] Backup works
- [ ] Restore works
- [ ] Custom icons/photos survive backup and restore
- [ ] Light Mode works
- [ ] Dark Mode works
- [ ] Tests pass
- [ ] `flutter analyze` is acceptable
- [ ] README is complete

Use the detailed test scenarios in `Battery_Tracker_Master_Codex_Prompt.md` as the definitive acceptance suite.

---

# 28. Final Rule

Do not stop at code generation.

For every implementation task:

**Read → Plan → Implement → Build → Test → Fix → Document → Continue**

The goal is a working Battery Tracker application, not a collection of code snippets.
