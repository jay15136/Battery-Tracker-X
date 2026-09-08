# Dashboard

The Dashboard is the application's opening screen. Nine summary cards, recent activity, and attention reminders come from a consistent SQLite read transaction. No inventory totals are stored separately or hard-coded. No migration or new dependency is needed.

## Counts

- Total Batteries, Battery Sets, and Total Devices exclude soft-deleted records. Inactive Sets/Devices remain in the totals; retired Batteries remain in inventory.
- Available Batteries have Available status, no current Device assignment or Set membership, and no retirement flag.
- Batteries Assigned to Devices counts distinct Batteries with current assignment rows. Batteries in Sets counts distinct Batteries with current membership rows. These counts overlap when a Set is installed in a Device; they are not additive totals.
- Batteries Charging uses Charging status and excludes retirement flags.
- Retired Batteries includes Retired status/condition or a recorded retirement date.
- Batteries Needing Attention counts each matching Battery once even when it has multiple reasons.

Closed assignments/memberships never count as current relationships. Links to deleted Sets/Devices are ignored. SQL aggregates charge history before joining it to Batteries, avoiding duplicated counts.

## Attention rules

Open **Attention rules** to change and save three reminder thresholds. These are organizational reminders, not electrochemical health estimates or true cycle counts.

| Rule | Initial value | Behavior |
|---|---:|---|
| Days without a recorded charge | 90 | Uses the latest charge date, or creation date when no charge exists; fires at or above the threshold in whole elapsed days. |
| Recorded Charges threshold | 500 | Uses the actual number of individual charge records; fires at or above the threshold. |
| Set Recorded Charges difference | 50 | Compares highest and lowest counts among current members of each active Set. Each eligible member receives an explanation when the difference reaches the threshold. Removed members are excluded. |

Zero disables the respective numeric reminder. Charge reminders apply only to rechargeable, non-retired Batteries. Poor condition, Damaged status/condition, Needs Attention status, and retirement flags always appear. The UI shows every applicable reason; searching and hiding retired Batteries filter the list without changing the summary count or persisted records. Lists initially show 25 matches, with **Show more Batteries** for further matches.

Rules persist as JSON in the existing `settings` table under `dashboard_attention_policy`. Validation rejects negative/non-integer/out-of-range values before writing. Invalid stored configuration produces a concise error; **Attention rules** allows explicitly saving valid replacement rules. Unrelated settings and inventory are preserved.

## Activity and navigation

Recent Activity shows the latest 20 persisted activity rows, ordered by event time and then row ID. Deleted and non-inventory entities retain their history text; only available Battery, Set, and Device records are clickable. Attention rows open the exact Battery details using permanent UUIDs. The navigation shell now consumes entity route intents and recreates the relevant page when its target changes.

Shortcuts open Batteries, Sets, Devices, charge tracking, and QR labels. The complete searchable history interface remains Phase 15; this phase displays the recent activity feed required by the dashboard specification.

## Refresh and verification

Drift table notifications refresh the snapshot after inventory, Set, Device, assignment, membership, charge, activity, or settings changes. An auto-disposed one-minute timer reevaluates elapsed-time reminders while the dashboard is displayed. Returning to the dashboard and the manual Refresh button also reload it. Loading and error states remain distinct from empty inventory; technical failures go to the application log.

Tests cover empty/mixed counts, current versus closed relationships, attention boundaries, Set differences, disabled rules, deleted records, bounded activity, live updates without count changes, persisted settings after reopening SQLite, input validation, record navigation, and light/dark desktop layouts. Optional test-only `DASHBOARD_TEST_FONT` and `DASHBOARD_ARTIFACT` environment variables generate a readable local UI screenshot without committing a machine-specific font or path.
