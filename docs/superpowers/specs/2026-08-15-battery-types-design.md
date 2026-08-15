# Phase 4 Battery Types Design

## Purpose

Phase 4 implements complete local Battery Type management. Battery Types are
reusable specification defaults for later Battery, Battery Set, Device,
bulk-create, compatibility, and import workflows. They are suggestions rather
than immutable templates: a future Battery may copy a type's defaults and then
override them without changing the Battery Type or other Batteries.

## Scope

Phase 4 includes:

- active and inactive Battery Type lists;
- create, edit, deactivate, and reactivate workflows;
- field and database validation;
- exact Battery, Battery Set, and Device usage counts;
- suggested Battery icon and color selection through the Phase 3 chooser;
- search, filtering, empty states, error handling, and responsive Windows UI;
- real Drift persistence, activity history, and restart tests.

Individual Battery creation, applying defaults to new Batteries, compatibility
warnings, bulk operations, CSV, and photograph behavior remain in their
scheduled phases. Phase 4 must expose clean repository values for those later
features and must not implement partial versions of them now.

## Existing database contract

Schema version 1 already contains every required column:

- immutable UUID and local row ID;
- type name, description, chemistry, default voltage, default capacity,
  capacity unit, physical size, and notes;
- suggested icon source, logical key or custom-icon UUID, and color;
- created, modified, and deactivated timestamps.

It also has non-negative numeric constraints, an icon-source constraint,
case-insensitive active-name uniqueness, indexes, and restrictive foreign keys
from Batteries, Battery Sets, and Devices. Phase 4 therefore adds no migration
and must leave `drift_schemas/schema_v1.json` unchanged.

## Domain model

`BatteryTypeRecord` is an immutable feature-domain value with:

- `PermanentId id`;
- all editable specification fields;
- `IconSelection suggestedIcon`;
- created/modified timestamps and optional deactivated timestamp;
- an `isActive` convenience property.

`BatteryTypeDraft` contains the corresponding editable values. Creation assigns
a UUID through `PermanentIdGenerator`; update, deactivation, and reactivation
always retain the existing UUID.

`BatteryTypeUsage` reports separate Battery, Battery Set, and Device counts plus
a total. `BatteryTypeNameConflictException`,
`BatteryTypeReactivationConflictException`, and
`BatteryTypeNotFoundException` let presentation map expected failures to
concise messages without exposing SQLite or stack traces.

## Validation

Feature-domain validation applies both before presentation submits and again at
the repository boundary:

- trim every text value;
- require a non-empty type name;
- treat blank optional values as null;
- permit custom chemistry and capacity-unit text;
- require voltage to be greater than zero when supplied;
- require capacity to be greater than zero when supplied;
- require a non-empty capacity unit whenever capacity is supplied;
- reject a capacity unit without a capacity;
- require a valid Battery-scope built-in or active custom icon selection;
- normalize icon color through `IconColor`.

The form offers editable suggestions rather than enums. Chemistry suggestions
include NiMH, NiCd, Li-ion, LiPo, LiFePO4, Lead Acid, Proprietary, and Other.
Capacity-unit suggestions include mAh, Ah, and Wh. Users may type values not in
either list.

Active type names are unique after trimming and case folding. An inactive type
may share a name with an active type. Reactivation is rejected when another
active type currently has the same name.

## Repository and transaction behavior

`BatteryTypeRepository` exposes:

- list and get;
- create and update;
- usage count;
- deactivate and reactivate.

The Drift adapter uses parameterized typed queries and orders types by active
state then name. The Riverpod controller applies the small in-memory search and
status filters so one authoritative snapshot drives the list and details
panel.

The Phase 3 icon repository gains a public Battery-scope selection validation
operation backed by its existing centralized rules. Battery Type create/update
runs icon validation, the row write, and one activity event inside the same
outer Drift transaction. This avoids partially created types and prevents
invalid or inactive custom-icon references.

Create records `battery_type_created`; update records `battery_type_updated`.
Deactivation records `battery_type_deactivated` with the three usage counts;
reactivation records `battery_type_reactivated`. Activity entity identity is
always the permanent UUID.

## Deactivation and reactivation

There is no hard-delete workflow. Deactivation is allowed even when the type is
referenced, but the UI first presents the exact Battery, Battery Set, and Device
counts and requires confirmation. The repository changes only
`deactivated_at` and `modified_at`; all foreign-key references remain intact so
existing inventory, requirements, and history retain their meaning.

Inactive types:

- are excluded from normal future selection lists;
- remain visible through Inactive or All filters;
- remain editable;
- can be reactivated unless their name conflicts with an active type.

Deactivating or reactivating an already matching state is rejected as a stale
operation and refreshes the controller rather than silently reporting success.

## Application state

`BatteryTypeCatalogController` is an asynchronous Riverpod controller holding:

- the complete repository snapshot;
- Active, Inactive, or All status filter;
- normalized search text;
- selected UUID where available;
- derived visible records and selected record.

The controller owns create, update, deactivate, reactivate, refresh, search,
filter, and selection coordination. It updates visible state only after
persistence succeeds. Widgets contain no uniqueness, lifecycle, or usage-count
business rules.

## Presentation

The Battery Types navigation destination replaces its current empty state with a real
`BatteryTypesPage`. The page follows the existing restrained industrial
Material 3 design and uses icons as the primary visual identifier.

The toolbar contains search, Active/Inactive/All filters, and a prominent Add
Battery Type action. Desktop widths use an icon-led compact list/table beside a
selected-record details panel. Narrow widths use stacked cards and keep search,
filters, and actions usable without horizontal overflow.

Rows show suggested icon/color, type name, chemistry, voltage, capacity/unit,
physical size, and active state. The details panel shows the complete record,
per-owner usage counts, timestamps, Edit, Deactivate, or Reactivate. A database
empty state differs from a no-search-results state.

The create/edit dialog groups fields into Identity, Defaults, Visual Default,
and Notes. It provides editable chemistry and unit suggestions, localized field
errors, a current icon/color preview, and a Choose Icon action that opens the
Phase 3 `IconPickerDialog` with Battery scope. Suggested icon/color changes are
defaults only and never force later inventory choices.

Deactivation confirmation states the exact usage impact. Reactivation uses a
simple confirmation because it does not rewrite references. Keyboard focus,
tab order, semantic labels, Light/Dark themes, and mouse-sized targets are part
of acceptance.

## Error handling

Expected validation, duplicate-name, stale-state, and reactivation-conflict
errors map to direct user messages. Unexpected exceptions and stack traces go
to `appLogServiceProvider.logger('battery_types.ui')`; users receive a concise
operation-specific message and the existing persisted state remains visible.

The controller reloads after a persistence conflict so two open dialogs cannot
leave the page claiming an operation succeeded when it did not.

## Testing

Development follows strict red-green-refactor cycles.

Domain tests cover trimming, optional values, positive numeric defaults,
capacity/unit dependency, custom suggestions, and invalid drafts.

Drift repository tests use real SQLite and cover:

- CRUD and sorted active/inactive lists;
- case-insensitive active-name conflicts;
- UUID stability through update, deactivation, and reactivation;
- name reuse after deactivation and conflict on reactivation;
- exact usage counts across Batteries, Battery Sets, and Devices;
- reference preservation after deactivation;
- suggested built-in/custom icon and color validation;
- activity events and forced transaction rollback;
- close/reopen persistence using a real database file.

Controller tests cover search, filters, selection retention, successful
refresh, and state preservation on failed writes.

Widget tests cover create, edit, validation, custom chemistry/unit entry,
icon/color override, search, status filters, deactivation usage confirmation,
reactivation, empty states, Light/Dark rendering, keyboard semantics, and a
narrow window.

## Verification

Completion requires:

1. clean `dart format --output=none --set-exit-if-changed .`;
2. successful dependency resolution and Drift generation consistency;
3. `flutter analyze` with no issues;
4. the complete Flutter test suite with no failures;
5. unchanged schema version 1 generated artifacts;
6. a Windows Release build from a normal-ACL verification snapshot;
7. two executable launch checks;
8. diff, unfinished-marker, generated-file, and project-control-document audits.

No cloud, account, network, new production dependency, or Windows-only domain
assumption is introduced.
