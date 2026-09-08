# Assignments

The Assignments destination manages individual Batteries, multiple Batteries, and whole Battery Sets through one transactional repository. Battery details open a Battery-scoped manager; Device details open a Device-scoped manager. Existing Set assignment/removal shortcuts delegate to the same repository.

## Workflow

Choose New assignment, select a Device and Batteries or a Set, choose an assignment date/time, add installation notes, and confirm. The default Battery list includes unassigned Available/In Set inventory. Show all exposes other statuses; already assigned and retired Batteries remain unavailable. Individually assigning a Set member requires acknowledgment and leaves membership unchanged.

Device type/quantity/voltage mismatches and unusual statuses produce reviewable warnings. Quantity guidance includes inventory already installed in the Device. Existing occupants remain installed. Warning acknowledgment is revalidated in the write transaction, so a stale warning cannot authorize newly changed requirements.

Select current root assignments for Remove selected, or use a row's Remove action. Review the exact inventory, select a removal date/time, and add removal notes. Set removal closes its parent and every linked member in one transaction. A linked member cannot be removed alone, preserving the Set/member relationship. Unrelated assignments remain open.

Include history shows closed assignments, original installation notes, separate removal notes, acknowledged warnings, and elapsed duration. Dates persist in UTC and display in local time. Duration is computed from installation to removal, or to the current view time for open assignments.

## Date and history rules

- Backdated installation/removal is supported; future dates are rejected.
- A Battery has at most one current assignment. Remove it before installing it again.
- Installation cannot precede its last recorded removal. This prevents overlapping history; filling arbitrary earlier gaps is not supported.
- Removal cannot precede any selected installation.
- Backdated Set installation records the current member snapshot at entry; the parent/child assignment links preserve that snapshot even after future membership changes.
- UUIDs, installation dates/notes, and operation relationships are never rewritten during removal. Removal notes use assignment-specific activity entries, without replacing installation notes.

## Architecture

- Domain: repository contract and assignment history records with computed duration.
- Data: DriftAssignmentRepository validates and atomically creates/closes records, updates Battery status, and writes Battery/Set/Device/assignment activity.
- Presentation: shared date/time field, multi-select assignment dialog, scoped manager, and history page.
- Existing Set repository methods are compatibility wrappers over the common transaction implementation; no duplicate assignment business logic remains.
- Assignments, Batteries, Sets, and Devices invalidate their relevant catalog views after changes.
- Existing schema v1 is used; no migration or production dependency is added. Database foreign keys and original assignment links remain intact.

## Verification

Repository tests cover multi-record rollback on second assignment/removal, UUID/note/date preservation, duration, future/overlapping date rejection, stale warning acknowledgment, retired/duplicate/current-assignment rejection, mixed Set/individual removal, explicit Set dates, membership preservation, unrelated occupants, and SQLite restart.

Widget tests cover multi-select/backdated assignment, available/all filtering, warning cancellation/override, Set selection, root-only removal, confirmation cancellation, history display, date controls, dark mode, and inactive Device validation. App smoke tests cover navigation and the Battery/Device detail entry points. Existing Set and Device tests continue to exercise the shared transaction implementation.
