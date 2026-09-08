# Charge Tracking

Phase 10 provides individual, selected-Battery, and entire-Set charge recording through one SQLite repository. Open Charge Tracking from navigation, Battery details, or Set charge history.

- Each saved event has a permanent UUID, charge date/time, optional starting and ending percentages, charger, and notes. Ending percentage defaults to 100; clearing it records unknown.
- Percentages must be whole numbers from 0 to 100. When both are supplied, ending percentage cannot be below starting percentage. Future charge dates are rejected.
- Recorded Charges counts logged events, not measured electrochemical cycles. Last Charged is the latest charge date, including when older history is entered later.
- Current manual charge estimates are separate. Recording history preserves them unless the user explicitly checks the estimate-update option. Editing or clearing an estimate creates activity, not a charge.
- Selected-Battery and Set operations validate every Battery, then save records, optional estimates, status changes, and activity in one transaction. Any failure rolls everything back.
- Set charging snapshots current membership and keeps a parent Set event. Later membership changes do not alter earlier charge history or individual totals.
- Empty, duplicate, unavailable, retired, and non-rechargeable selections are rejected.
- A current charge completes a Charging status and restores Assigned, In Set, or Available based on live relationships. An older charge does not clear a more recently modified Charging status.
- Historical rows are retained; Battery UUIDs remain authoritative. Ordinary Battery edits preserve the manual estimate.
- Schema v1 already contains the required fields; no migration or production dependency was added.

Tests cover individual metadata, optional percentages, counts and dates, manual estimates, invalid selections, Set membership changes, injected transaction failures, SQLite restart persistence, real UI saves/cancel/validation, dark mode, and navigation.
