# Battery Tracker — Version 1 Database Plan

**Decision status:** Phase 3 executable schema version 1; icon tables operational
**Engine/access:** SQLite through Drift  
**Initial schema version:** 1

## Database rules

- Enable `PRAGMA foreign_keys = ON` for every connection.
- Store timestamps as UTC ISO-8601 text; presentation converts to local time.
- Use integer surrogate keys for local joins and immutable lowercase UUID text for durable identity/export/QR references.
- Use parameterized Drift queries and explicit transactions.
- Keep assignment, membership, charge, retirement, and activity history.
- Prefer `deactivated_at`/`retired_at`/`deleted_at` markers to destructive deletion.
- Store only application-managed relative asset paths.

Every table has the smallest useful set of constraints in schema version 1. Drift table definitions, executable migration/index creation, generated typed access code, and `drift_schemas/schema_v1.json` are implemented and committed together.

## Identity and shared columns

Durable/exported entities use:

- `id INTEGER PRIMARY KEY AUTOINCREMENT`
- `uuid TEXT NOT NULL UNIQUE`
- `created_at TEXT NOT NULL`
- `modified_at TEXT NOT NULL` where edits are supported

`uuid` values are `PermanentId` values. User-facing IDs have separate columns and may be edited without changing UUIDs or QR codes.

## Finalized tables

### `battery_types`

Reusable type definitions: `uuid`, `type_name`, description, chemistry, default voltage/capacity/unit, physical size, suggested icon source/key/color, notes, timestamps, and `deactivated_at`.

Constraints/indexes:

- case-insensitive unique active `type_name`
- non-negative default voltage/capacity
- icon source limited to `builtin` or `custom`

### `battery_batches`

Optional purchase/entry grouping: `uuid`, unique `batch_code`, description, purchase date/location, total purchase price, notes, and timestamps. A Batch never implies Set membership.

### `batteries`

Stores `uuid`, unique editable `user_battery_id`, name, type/batch foreign keys, manufacturer/model/serial/custom label, chemistry, voltage, capacity/unit, rechargeable flag, purchase fields, warranty, status, condition/note, notes, icon source/key/color, preferred primary visual, estimated charge percent, retirement date/reason, timestamps, and `deleted_at`.

Constraints/indexes:

- active `user_battery_id` is case-insensitively unique
- `estimated_charge_percent` is null or 0–100
- voltage/capacity/prices are null or non-negative
- preferred visual is `icon` or `photo`; default `icon`
- icon fields are always non-null and default to Generic Battery
- indexes on type, batch, status, condition, manufacturer, model, and serial number

Status values begin with Available, Assigned, In Set, Charging, Storage, Needs Attention, Damaged, and Retired. They are validated in application code in Version 1 so a later migration can add customizable lookup records without rewriting historical text.

### `battery_sets`

Stores `uuid`, unique editable `user_set_id`, name, optional type foreign key, description, notes, icon source/key/color, preferred primary visual, timestamps, `deactivated_at`, and `deleted_at`.

Icon fields are non-null and default to Generic Battery Set. Active Set IDs are case-insensitively unique.

### `battery_set_memberships`

Append-only temporal membership: `uuid`, battery foreign key, Set foreign key, `added_at`, nullable `removed_at`, notes, and shared `operation_uuid`.

- Check `removed_at` is null or not before `added_at`.
- Index battery/Set and active-row lookups.
- Do not add a database uniqueness constraint limiting a Battery to one active Set because Version 1 explicitly permits an acknowledged override. The application warns by default and records the override.
- Removing/moving closes active rows and inserts new rows; it never rewrites prior membership meaning.

### `devices`

Stores `uuid`, name, category, manufacturer/model/serial, location, description, notes, optional required type/quantity/voltage/notes, icon source/key/color, preferred primary visual, timestamps, `deactivated_at`, and `deleted_at`.

Icon fields are non-null and default to Generic Device. Requirement values guide assignment and do not prevent an acknowledged override.

### `assignments`

Append-only temporal assignments: `uuid`, `subject_type`, nullable battery foreign key, nullable Set foreign key, device foreign key, nullable `source_set_assignment_id`, shared `operation_uuid`, `assigned_at`, nullable `removed_at`, notes, and `override_reason`.

Constraints:

- `subject_type` is `battery` or `battery_set`.
- Exactly one of battery/Set foreign keys is non-null and agrees with `subject_type`.
- `removed_at` is null or not before `assigned_at`.

Assigning a Set creates one Set assignment plus one Battery assignment for each current member. Battery rows point to the Set assignment through `source_set_assignment_id`, and every row shares one operation UUID. Assignment/removal runs atomically. This preserves simple current-Battery queries and the original Set-level history.

Indexes cover device, battery, Set, source Set assignment, operation UUID, and active rows.

### `set_charge_records`

One row for each Mark Entire Set Charged action: `uuid`, Set foreign key, `charged_at`, notes, created timestamp, and operation UUID.

### `charge_records`

One append-only Recorded Charge per Battery: `uuid`, battery foreign key, charged time, optional starting/ending percentage, charger, notes, optional source Set charge foreign key, optional bulk operation UUID, and created timestamp.

Percentages are null or 0–100. Mark Entire Set Charged inserts one Set row and one Battery row per current member in one transaction.

### `media_assets`

Application-managed files: `uuid`, relative path, original filename, MIME type, byte size, checksum, width/height where known, timestamps, and `missing_at`.

The relative path is unique. File bytes are not stored in SQLite.

### `battery_photos`, `battery_set_photos`, `device_photos`

Typed join tables reference the owner and `media_assets`, with `is_primary`, display order, caption, and timestamps. Typed tables were chosen over a polymorphic owner column so SQLite foreign keys can enforce ownership.

At most one active primary photo per owner is enforced with a partial unique index. Records still retain their icon and default preferred visual `icon`.

### `icon_categories`

Custom/reusable categories: `uuid`, name, scope (`battery`, `battery_set`, `device`, `general`), timestamps, and `deactivated_at`. Active names are unique within scope.

Phase 3 bootstraps idempotent Batteries, Battery Sets, Devices, and General categories through the repository during application startup.

### `custom_icons`

Stores permanent `uuid`, name, category foreign key, managed relative path, file type (`png` or `svg` initially), `supports_color`, timestamps, and `deactivated_at`.

Before deactivation/deletion, repositories count Battery, Battery Set, Device, and Battery Type references. A replacement transaction validates the replacement, updates every reference and activity history, and then deactivates the icon; any failure rolls the entire database operation back. Source-file replacement retains the same UUID and swaps only its managed relative path after validation.

### `tags`, `battery_tags`

Tags use UUID/name/timestamps; the join table links Batteries to tags. This supports the Version 1 bulk-create/bulk-edit tag requirement without comma-separated data.

### `qr_label_templates`

Stores `uuid`, unique template name, target type, dimensions in PDF points (1/72 inch), layout JSON, timestamps, and `deactivated_at`. Layout JSON has an application-level version and validation before use.

### `activity_log`

Append-only events: `uuid`, event type, entity type/UUID, optional related entity type/UUID, operation UUID, summary, versioned metadata JSON, and `occurred_at`.

Indexes cover time, event type, entity UUID, related UUID, and operation UUID.

### `settings`

Disciplined key/value settings: unique key, value, value type, and modified timestamp. Only registered settings keys are accepted. Domain records never live here.

## Search strategy

Version 1 uses indexed case-insensitive prefix/contains queries across user IDs, names, type, manufacturer, model, serial, Batch, Set, Device, and notes. If large-inventory testing shows unacceptable contains-search performance, add an FTS5 migration; do not denormalize schema version 1 prematurely.

## Initial indexes

In addition to unique UUID and display-ID indexes:

- Batteries: type, Batch, status, condition, manufacturer/model/serial
- Memberships: Battery + active state, Set + active state, operation UUID
- Assignments: Device/Battery/Set + active state, source Set assignment, operation UUID
- Charges: Battery + charged time, source Set charge, bulk operation UUID
- Photos: owner + display order and owner primary partial uniqueness
- Activity: occurred time, event type, entity/related UUID, operation UUID
- Custom icons: category and active state

## Transaction boundaries

The following operations must be all-or-nothing:

1. Bulk Batteries + optional Batch + optional Set records + membership + activity.
2. Multi-row Set membership changes.
3. Set assignment/removal + all member assignment rows + activity.
4. Mark Entire Set Charged + all individual Recorded Charges + activity.
5. Mark Selected Charged + activity.
6. Multi-record bulk edit/retirement + history/activity.
7. Confirmed CSV import.
8. Custom-icon replacement for all references.

File workflows use a staging directory plus database transaction. Finalization failures clean only newly staged data and never remove pre-existing user assets.

## Migration policy

- Migration numbers start at 1 and are contiguous.
- Never edit a released migration; add the next version.
- Store Drift schema snapshots in version control.
- Schema version 1 is recorded in `drift_schemas/schema_v1.json`.
- Back up or checkpoint before a destructive transform.
- Do not use drop-and-recreate for user upgrades.
- Tests open version 1 from empty and upgrade every retained prior snapshot.
- Tests verify UUIDs, membership/assignment history, Recorded Charges, settings, and relative asset references survive.

## Backup consistency

Backups use SQLite's online backup/export mechanism or an exclusive checkpointed copy supplied by the Drift adapter; copying a live WAL database file by itself is forbidden. The backup manifest records schema version and checksums. Restore validates in staging before replacing active state.
