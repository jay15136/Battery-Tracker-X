# Batteries Feature

Phase 5 provides persisted individual Battery inventory, table/card views, search,
combined filters, sorting, add/edit forms, and an icon-first detail view.

- `domain/battery.dart` separates editable values from permanent UUID identity.
- `domain/battery_inventory_query.dart` applies search, filters, and ordering independently of widgets.
- `data/drift_battery_repository.dart` uses the existing version 1 schema and writes inventory, optional Batch creation, and activity/status history in one transaction.
- `presentation/` uses Riverpod repository injection and the existing Battery-scope icon renderer and chooser.

Battery Types can supply specifications and icon/color through an explicit Apply
Defaults action. Later type changes never overwrite Battery values. An inactive
type can remain on an existing Battery but cannot be newly assigned.

ID suggestions skip occupied IDs and never reserve or silently change them. Save
checks case-insensitive uniqueness again; conflicts leave the entered form open.
Batch codes identify purchases/entry groups independently of Battery Sets.

Read-only current Set, Device, and Recorded Charges summaries use existing relational
tables. Their write workflows remain in the separately planned Set, Assignment,
and Charging phases. Photograph workflows are provided by the shared Phase 6 photo manager. No database migration
or additional production dependency was required.

Tests cover real SQLite restart persistence, stable UUIDs across ID changes, duplicate
IDs, transaction rollback, type overrides, relationship preservation, and inventory
UI workflows in Light/Dark themes.
