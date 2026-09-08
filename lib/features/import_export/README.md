# Import Export

CSV export for Batteries and Battery Sets, and preview-before-commit CSV
import for Batteries. Built entirely on the existing `BatteryRepository`,
`BatterySetRepository`, and `BatteryTypeRepository`, so import/export share
exactly the same validation and persistence rules as manual entry. The
`csv` package is the one new dependency, matching the Phase 1 architecture
decision; there is no migration or schema change.

## Export

`exportBatteriesCsv` writes the canonical Battery fields (Battery ID
through Notes) plus read-only columns — Battery Set, Assigned Device,
Batch ID, Recorded Charges, and Last Charged — computed from each
Battery's current relationships. `exportBatterySetsCsv` writes Set ID,
Name, Battery Type, Description, Member Count, Assigned Device, Recorded
Charges, Last Charged, Active, and Notes. `batteryCsvTemplate` is a
header-only CSV of the editable import fields for users starting from
scratch. All three go through `ListToCsvConverter`, so values containing
commas or quotes are escaped correctly.

## Import

`previewBatteryImport` parses CSV text with `CsvToListConverter`
(`shouldParseNumbers: false`, so a Battery ID or Serial Number that looks
numeric is never silently converted to a number and loses formatting),
maps header columns onto the canonical fields by case-insensitive name
match, and validates every row without writing anything:

- A blank Battery ID is a row error.
- An unrecognized Battery Type name is a warning, not an error — the row
  still imports without a Type.
- Voltage, Capacity, and Purchase Price must parse as numbers when present;
  Capacity and Capacity Unit must be given together or not at all.
- Status and Condition must match the same recognized values manual entry
  uses.
- Purchase Date must parse as a date.
- A repeated Battery ID — within the file or against an existing Battery —
  is flagged as a duplicate rather than an error. The first valid
  occurrence in the file is the one that will import; later repeats, and
  any ID that already exists, are marked as duplicates and skipped.

`commitBatteryImport` takes a previously returned `CsvImportPreview` and
creates only the rows that are both valid and not a duplicate, inside one
transaction. Duplicate and invalid rows are counted, not written. One
`csv_batteries_imported` activity log entry records the created Battery
UUIDs and the final created/duplicate/invalid counts.

## UI

`DataManagementPage` (under Settings → Data Management) surfaces backup,
restore, CSV export, and CSV import behind native file dialogs
(`FileSelectionService`). The import flow always shows a preview dialog —
listing every row's outcome and reason — before a separate confirmation
commits anything, matching "do not import until the user confirms
preview."

## Testing

`DriftImportExportRepository` tests cover the template, an export round
trip with Type/Set columns and a comma-containing Name, every validation
rule, within-file and existing-record duplicate detection, and a commit
that creates only the valid, non-duplicate rows while logging one activity
entry with the correct summary. `DataManagementPage` widget tests cover
the export/import buttons end to end, including a real preview-then-commit
CSV import.
