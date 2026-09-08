# History

The History section is a unified, filterable read of the shared `activity_log`
table that every other feature already writes to (Battery/Set/Device
lifecycle, assignments, Set membership, charging, retirement, QR label
output, icon/photo changes, and bulk/CSV operations). History never writes
activity itself; it only filters, paginates, and resolves current record
labels. No migration or new dependency is needed.

## Filters

- **Date** — optional From/To bounds compared against the stored UTC
  `occurred_at` text, inclusive on both ends.
- **Activity Type** — a curated `HistoryCategory` grouping of the catalogued
  `event_type` values (Additions, Status Changes, Assignment History, Battery
  Set Membership History, Charge History, Retirement, QR Label Activity, Bulk
  Operations, Icons and Photographs). An event type the app has not
  catalogued yet is grouped under **Other Activity** instead of being
  hidden, so newly introduced event types remain visible without a code
  change here.
- **Battery / Battery Set / Device** — one optional entity selection. Entity
  kinds are mutually exclusive per activity row (`entity_type` is single
  valued), so this is one dropdown pair (kind, then a searchable record
  picker) rather than three simultaneous filters that could never all match
  the same row.

Filters compose with AND. Clearing a filter control removes only that
condition.

## Pagination and live updates

Results page 25 at a time with **Show more events**; the header shows
`Showing N of Total`. `DriftHistoryRepository.watch` subscribes to Drift
table-update notifications on `activity_log`, `batteries`, `battery_sets`,
and `devices`, so History reflects new activity and record deletions while
the page stays open, the same reactive pattern the Dashboard uses.

## Entity resolution

Each row resolves its `entity_uuid` against the corresponding live table to
show the current label and whether the record is still available. Deleted
records keep their historical summary text but are no longer clickable,
matching the Dashboard's recent-activity behavior. Rows whose `entity_type`
is not one of `battery`/`battery_set`/`device` (for example
`battery_type`, `custom_icon`, or `bulk_operation`) still display with their
recorded summary; they simply have no navigation target.

## Testing

`DriftHistoryRepository` tests cover date-range bounds, each catalogued
category plus the "other" fallback, entity filtering, pagination/total
counts, retained text for deleted records, and live updates. `HistoryPage`
widget tests cover the empty state, a populated filtered list, entity
navigation, and Light/Dark narrow layouts.
