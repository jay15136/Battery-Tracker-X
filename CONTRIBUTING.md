# Contributing to Battery Tracker X

Thanks for your interest in contributing. This is a Windows-first, offline
Flutter desktop app, and it's held to a fairly strict standard of test
coverage and documentation — please read this before opening a PR.

## Before you start

For anything beyond a small fix, open an issue first to discuss the change.
For the full picture of how the app is built and why, read:

- [`README.md`](./README.md) — what the app is and how it's organized
- [`OLD-README.md`](./OLD-README.md) — detailed build/run instructions and
  per-feature notes
- [`docs/IMPLEMENTATION_PLAN.md`](./docs/IMPLEMENTATION_PLAN.md) — the
  authoritative, phase-by-phase build log: every architecture decision,
  every defect found and how it was fixed, and current verification status
- [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) /
  [`docs/DATABASE_PLAN.md`](./docs/DATABASE_PLAN.md) — system design and
  schema
- [`Battery_Tracker_Master_Codex_Prompt.md`](./Battery_Tracker_Master_Codex_Prompt.md)
  — the original product/requirements specification the app was built
  against

## Development setup

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   (stable channel) and enable Windows desktop support:
   ```powershell
   flutter config --enable-windows-desktop
   ```
2. Install the Visual Studio C++ desktop workload (required for the Windows
   build toolchain).
3. Clone the repo and fetch dependencies:
   ```powershell
   flutter pub get
   ```
4. Run the app:
   ```powershell
   flutter run -d windows
   ```

See `OLD-README.md` for the full prerequisites list and troubleshooting
notes.

## Code style and architecture

- Feature-first structure: each feature under `lib/features/<feature>/` is
  split into `domain/` (models, validation, repository interfaces),
  `data/` (Drift-backed repository implementations), `application/`
  (Riverpod controllers/providers), and `presentation/` (widgets).
- State management is Riverpod; persistence is SQLite via Drift. Domain code
  must not depend on Flutter widgets or plugin classes — platform-specific
  behavior stays behind an interface in `lib/services/`.
- Entities that need a stable identity (Batteries, Battery Sets, Devices,
  Battery Types, custom icons) use a permanent UUID (`PermanentId`) that
  never changes, separate from any user-editable display ID.
- Multi-record writes use a single Drift transaction; historical records
  (assignments, membership, charges, activity log) are append-only or
  soft-closed, never overwritten or deleted.
- Run formatting before committing:
  ```powershell
  dart format .
  ```

Read `docs/ARCHITECTURE.md` before introducing a new dependency or crossing
a layer boundary (e.g., a domain model importing a plugin type) — several of
those boundaries are deliberate and documented with the reasoning behind
them.

## Testing

This project treats test coverage as non-negotiable for anything that
touches persistence, transactions, or a workflow a user depends on. Before
opening a PR, run:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows
```

- New repository/domain logic needs a test using a real in-memory or
  temp-file SQLite database (see any `test/features/*/drift_*_test.dart`
  for the pattern) — not a mock.
- New UI needs at least an empty-state and a populated-state widget test,
  and should be checked in both Light and Dark mode where practical.
- If you touch anything involving real file I/O in a widget test, be aware
  that `tester.pumpAndSettle()` does not mix well with real `dart:io` work
  running inside Flutter's synthetic test clock — see the Phase 16 notes in
  `docs/IMPLEMENTATION_PLAN.md` for the pattern (`tester.runAsync`) and the
  reasoning.

If you find and fix a bug while working on something else, fix it in the
same PR (with its own test) rather than filing a separate issue — this
project's own history in `docs/IMPLEMENTATION_PLAN.md` follows that rule
throughout and it keeps defects from lingering.

## Commit messages and PRs

- Keep commits focused; explain *why*, not just *what*, in the body when the
  reasoning isn't obvious from the diff.
- Update `docs/IMPLEMENTATION_PLAN.md` and the relevant feature `README.md`
  (each feature folder under `lib/features/` has one) when you change
  behavior — this repo relies on those staying accurate.
- Open your PR against `main`.

## Reporting bugs and requesting features

Please use the issue templates (bug report / feature request) so we get the
information needed to reproduce or scope the work. For security
vulnerabilities, see [`SECURITY.md`](./SECURITY.md) instead of opening a
public issue.

## Code of Conduct

This project follows the [Contributor Covenant](./CODE_OF_CONDUCT.md).
Participation implies agreement to abide by it.
