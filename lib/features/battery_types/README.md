# Battery Types Feature

Phase 4 provides persisted, user-managed Battery Type definitions and suggested Battery icon/color defaults. It does not add a migration: it uses the existing `battery_types` table in schema version 1.

## Behavior

Each record stores a permanent UUID, type name, optional description, chemistry, default voltage, default capacity/unit, physical size, notes, suggested icon/color, timestamps, and optional deactivation time. The UUID is created once and never changes during edits, deactivate/reactivate lifecycle changes, or restart persistence.

The form requires a trimmed type name. Default voltage and capacity must be finite numbers greater than zero. Capacity and capacity unit are required together. Chemistry suggestions (NiMH, NiCd, Li-ion, LiPo, LiFePO4, Lead Acid, Proprietary, Other) and capacity-unit suggestions (mAh, Ah, Wh) are editable; custom text is retained. Active names are unique without regard to case.

The suggested visual starts as the Battery-scope Generic Battery icon/color and is selected through the reusable icon picker. It is a default suggestion for a future Battery, never a forced replacement for a record's own icon-first visual. If its custom icon cannot resolve, the presentation falls back to Generic Battery instead of showing a broken visual.

## Lifecycle and history

The page has searchable Active, Inactive, and All views; search considers type name, chemistry, physical size, and description. It shows specifications, a permanent UUID, and exact live usage counts for Batteries, Battery Sets, and Devices.

Deactivation is a confirmed soft lifecycle action. The confirmation says `Used by {Batteries} Batteries, {Battery Sets} Battery Sets, and {Devices} Devices.` and states that existing references stay connected while new records will not use the type by default. No Battery, Set, or Device reference is rewritten. Reactivation is confirmed and fails safely if a different active record has the same name.

The Drift repository executes create, update, deactivate, and reactivate in individual SQLite transactions. Each operation emits `battery_type_created`, `battery_type_updated`, `battery_type_deactivated`, or `battery_type_reactivated` to `activity_log`; deactivation metadata includes the three exact usage counts. Controller writes refresh the catalog only after repository success and preserve the last good snapshot/selection if a refresh fails.

## Verification

Tests cover validation, UUID stability and restart persistence, active-name collisions, reference-preserving deactivation, reactivation conflicts, activity metadata, transaction rollback, editable suggestions/form errors, controller recovery, icon fallback, and responsive UI workflows. Phase 4 final verification completed the full 131-test suite, analysis, code generation/hash comparison, Windows Release build, and two five-second executable launch checks.
