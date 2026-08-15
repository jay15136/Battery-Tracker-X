# Project Manifest

The authored starter files were reconciled in place with Flutter 3.47.0 generated projects on 2026-08-15.

## Preserved project-control files

- `AGENTS.md`
- `CODEX_INSTRUCTIONS.md`
- `CODEX_START_HERE.md`
- `Battery_Tracker_Master_Codex_Prompt.md`
- `agent.md`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/ARCHITECTURE.md`
- `docs/DATABASE_PLAN.md`

Hash checks performed immediately after `flutter create` confirmed the control documents, starter `README.md`, `pubspec.yaml`, `lib/main.dart`, and authored smoke test were not overwritten.

## Flutter-generated projects

- `android/`
- `ios/`
- `macos/`
- `windows/`
- `.metadata`

Generated files should be updated through Flutter tooling and reviewed as normal source changes. Project-control documents must not be removed when regenerating platform projects.

## Authored application areas

- `lib/app/` — application shell, typed destinations, and navigation
- `lib/core/` — identity, database contracts, storage values, theme, logging, and utilities
- `lib/features/` — feature-first modules for all Version 1 capabilities
- `assets/icons/builtin/` — immutable packaged SVG catalog used by the centralized icon registry
- `lib/services/` — platform and cross-cutting service contracts/adapters
- `drift_schemas/` — immutable Drift schema snapshots used for migration review and tests
- `test/` — unit, repository, migration, and widget tests
- `scripts/` — repeatable bootstrap and verification commands
- `docs/superpowers/specs/` and `docs/superpowers/plans/` — reviewed feature designs and executable implementation records

Build output, local databases, logs, photographs, imported custom icons, and user backups are not source artifacts and must remain ignored.

## Completed Phase 4 module

- `lib/features/battery_types/` — Battery Type domain draft/record/repository interface, Drift repository, Riverpod catalog controller, responsive management page, form dialog, and Battery-scope icon rendering/fallback.

Phase 4 adds no dependency, migration, or schema version. `lib/core/database/app_database.g.dart` and `drift_schemas/schema_v1.json` remain generated/schema-controlled artifacts; their Phase 4 final SHA-256 values are recorded in `docs/IMPLEMENTATION_PLAN.md`.
