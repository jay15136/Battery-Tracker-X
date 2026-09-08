# Bulk Operations

Phase 11 implements **Batteries → Add Multiple Batteries**. Phase 12 adds selected-record Bulk Edit, retirement, and inventory access to selected charging.

## Workflow

1. Configure prefix, separator (including blank), starting number, padding, and quantity.
2. Edit shared Battery fields, type, icon/color, purchase information, optional Batch ID, and notes using the existing Battery editor. This editor returns a draft; it does not save inventory.
3. Optionally enter comma-separated tags and choose an existing unassigned active Set or define new Sets by ID/name.
4. Generate the preview. Use Next Available IDs explicitly skips occupied IDs while maintaining quantity. Skip Existing IDs removes colliding/duplicate preview rows and reduces the count.
5. Edit individual rows, including IDs, names, icons/colors, notes, and specifications. Each row can select its own Set, allowing eight Batteries to be split across two four-member Sets. Apply Set to all preview rows explicitly changes every row's destination.
6. Confirm the exact preview. The completion summary lists the created Battery IDs and Battery/Set counts.

Changing shared fields or generation controls does not modify an existing preview. Regeneration requires confirmation because it replaces row edits. New preview Sets are only persisted when referenced by a saved row. Canceling saves no Battery, Batch, or Set.

## Prices

Purchase Price can mean per-Battery price (default) or total purchase price. Total mode preserves the original total and calculates approximate per-Battery cost when the preview is generated. The preview displays both amounts. Per-row edits and skipping rows retain the reviewed amounts; regenerate or edit costs when a different allocation is intended. No costs are silently recalculated during save.

## Persistence and validation

- One outer SQLite transaction wraps Battery creation, Batch lookup/creation, new Sets, memberships, tags, and activity. Existing repositories supply UUID generation, icon/type validation, and membership compatibility checks.
- Every Battery has its own permanent UUID and individual creation/status history. The operation also records a summary with created UUIDs and tags.
- IDs are checked case-insensitively against active inventory and within the preview, then checked again at save. A stale preview fails without renumbering or partial writes.
- Set warnings roll back the attempt. Accepting the displayed warning retries the same preview with explicit acknowledgment; new warnings still require acknowledgment.
- Tags are trimmed, deduplicated case-insensitively, stored in lowercase, and associated through the existing tag join table. Ordinary Battery edits preserve these associations.
- Quantity is bounded to 1–1000 per operation and padding to 0–12. Larger inventories can be entered in multiple batches.
- Schema v1 already supports this feature. No migration or production dependency was added.

## Acceptance coverage and later-phase dependencies

Phase 11 tests cover sequential/custom IDs, duplicate/skip/next-available behavior, edited IDs, built-in/custom icons and colors, purchase data, Batch IDs, existing/new Sets, two-Set splits, distinct UUIDs, restart persistence, stale previews, and injected failures.

The master prompt also lists cross-phase bulk scenarios. Bulk edit, add/remove Set membership, and retirement are implemented in Phase 12. Phase 13 adds Create QR Labels after successful bulk creation, with all new UUIDs selected, subset selection, PDF export, printing, and saved selections. Backup/restore remains required Phase 16 work. Existing Phase 10 charging operates on the same persisted Battery records.
## Phase 12: Bulk Edit

Select Batteries with table/card checkboxes or Select filtered. Filtering does not erase an existing selection; Clear selection resets it. Bulk Edit shows the total selected count and a before/after preview for every selected Battery. One action applies per confirmed operation, so only the chosen field or relationship changes. Blank optional purchase fields and Battery Type can explicitly clear those values. Shared notes append, and tags are added without removing earlier tags.

Supported actions: Type, Status, Condition, icon selection, color only, add/remove Set membership, tags, shared notes, purchase date/location/prices, warranty date, retirement, and Mark Selected Charged. Color-only edits preserve each Battery's existing icon key/source. Type changes preserve specifications and request compatibility acknowledgment when existing Sets or Devices are linked. The icon picker supports the existing built-in/custom library and colors.

Previewing does not write. Confirmation rechecks the selected records and relationship state; changes since preview require a fresh preview. A transaction includes all selected edits, membership changes, and activity. Every Battery keeps its UUID, unrelated fields, photos, and prior history. Each edit event records its old/new values and a shared operation UUID. Set compatibility warnings roll back the attempt before asking for acknowledgment.

### Retirement and restoration

Retire Selected Batteries requires a reason and date/time, stored per Battery and shown in details. Reasons: Capacity loss, Damaged, Age, Replaced, Lost, Other. Future dates and already-retired selections are rejected. Remove active Device assignments first; retirement never closes assignments silently. Set memberships remain, and the preview explicitly says they are retained. Restoring a non-retired status clears current retirement fields while historical retirement events retain the earlier reason/date. Ordinary edits to a still-retired Battery preserve its retirement metadata.

Status choices must respect existing Assigned/In Set/Available relationships. Set membership changes require an unassigned target Set; additions require an active Set. Removal preserves closed membership rows. Mark Selected Charged uses the existing charge dialog/repository, with per-Battery records and one transaction.

### Implementation and verification

Bulk Edit uses schema v1; no migration or dependency was added. The repository builds and validates previews separately from applying them. SQL field names come from a fixed action mapping; values use parameters. Quantity is limited to 1–1000 selected Batteries per operation.

Tests cover preservation of unrelated data/UUIDs, type clearing and compatibility acknowledgment, notes/tags, distinct icons and colors, purchase field clearing, Set addition/removal history, retirement metadata, assignment safety, stale previews, rollback on the second edit/membership/retirement, restart persistence, filtered selection, selected charging, light/dark layouts, and explicit confirmation.
