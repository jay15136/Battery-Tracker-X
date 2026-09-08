# Battery Sets

Battery Sets are persisted inventory records with permanent UUIDs and editable, case-insensitive unique display IDs. The default visual is a generic Set icon; icon/color selection and the shared optional photograph gallery support custom assets and missing-photo fallback.

## Workflow

Open Battery Sets, choose Add Set, enter a name and either a manual ID or Suggest Set ID. Suggestions use a configurable prefix and starting number with three-digit minimum padding. Saving never substitutes a different ID after preview.

Select a Set to edit details, manage photographs, inspect current members, and expand membership, assignment, and activity history. Search and Active/Inactive/All filters operate on persisted records.

Add / Move Battery supports retaining existing memberships after acknowledgment or closing them and opening a new one. Type, chemistry, voltage, and capacity differences require acknowledgment. The repository recalculates warnings within each transaction, including on retry.

Mark Entire Set Charged creates one Set charge event plus one individual charge record per current member. Each member keeps its own Recorded Charges total. Empty Sets and Sets containing retired/deleted/non-rechargeable members cannot record a charge.

Assign Set to Device creates a Set assignment and linked individual assignments atomically. Matching configured requirements are indicated; quantity, type, voltage, and existing occupancy mismatches require acknowledgment. Already-assigned members must be removed from their existing Device first. The Create Device shortcut delegates to the same repository as the full Device editor.

Remove Set from Device closes only that Set's parent assignment and linked member assignments, retaining original dates, notes, UUIDs, and unrelated Device occupants. Remove an assigned Set from its Device before changing membership, deactivating, or deleting it.

Deactivation retains membership links/history but removes the Set from active inventory. Reactivation restores active status. Deletion is soft: it closes current memberships, retains history and photos, and never deletes member Batteries. Available/Assigned/In Set status follows active relationships; other user-selected statuses are retained except when explicit assignment makes a Battery Assigned or charging ends Charging status.

## Architecture and persistence

- `domain/battery_set.dart`: drafts, records, warnings, and repository contract.
- `data/drift_battery_set_repository.dart`: validation, transactional membership/assignment/charge operations, UUID identity, and activity events.
- `presentation/`: management screen and editable Set form. Widgets do not write SQL.
- Existing schema v1 tables are used without migrations or additional production dependencies.
- InventoryIcon centralizes scoped icon resolution for Batteries, Battery Types, and Sets.
- Photo metadata uses the existing typed Set photo links and application-managed relative storage paths.

Create QR Labels opens a label for the Set; Create member QR Labels selects its current Batteries. Full Device, assignment, and charge management are available. Set assignment/removal now delegates to the shared assignment repository and supports explicit dates.

## Verification

Repository tests cover the master four-member scenario, restart persistence, identity, compatibility acknowledgment, membership history, unequal charge counts, lifecycle operations, and injected transaction failures during move, charge, assignment, and removal. Widget tests exercise actual SQLite-backed create/edit, dark validation, warning cancel/accept, member removal, charging, assignment match, and unassignment. The application shell test verifies navigation into the Set screen. Shared photo/icon tests cover Set storage and fallback rendering.
