# Phase 4 Battery Types Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver complete offline Battery Type creation, editing, deactivation,
reactivation, validation, icon defaults, persistence, and responsive management
UI for Phase 4.

**Architecture:** Immutable feature-domain values and a defensive validator feed
a Drift repository that owns UUID, uniqueness, usage, lifecycle, activity, and
transaction behavior. A Riverpod catalog controller drives a responsive
Material 3 page and focused form dialog; the Phase 3 icon chooser remains the
single icon/color selection UI.

**Tech Stack:** Flutter 3.47, Dart 3.13, Riverpod, Drift/SQLite, existing Phase
3 icon registry/repository/widgets, Material 3, Flutter test.

**Spec:** `docs/superpowers/specs/2026-08-15-battery-types-design.md`

**PowerShell command prelude:** At the start of every new PowerShell process,
resolve the installed SDK through the repository helper before running any
command below:

```powershell
. (Join-Path (Get-Location) 'scripts\flutter_sdk.ps1')
$flutterSdk = Resolve-FlutterSdk
```

## Global Constraints

- Permanent Battery Type UUIDs are created once and never change.
- There is no hard-delete workflow; deactivation preserves every foreign-key
  reference and activity record.
- Inactive types are excluded from normal future selection lists and remain
  accessible through Inactive and All filters.
- Chemistry and capacity units offer editable suggestions and accept custom
  text.
- Supplied voltage and capacity must be greater than zero; capacity and unit
  must be supplied together.
- Suggested icon and color use the centralized Phase 3 Battery-scope rules and
  remain overridable defaults.
- Create, update, deactivate, and reactivate write one activity event in the
  same database transaction as the record change.
- Schema version 1 and `drift_schemas/schema_v1.json` must not change.
- No production dependency, network service, cloud account, or Windows-only
  domain assumption is added.
- Existing Phase 1–3 behavior and project-control documents remain intact.

---

### Task 1: Battery Type domain values and validation

**Files:**
- Create: `lib/features/battery_types/domain/battery_type.dart`
- Create: `lib/features/battery_types/domain/battery_type_draft.dart`
- Create: `lib/features/battery_types/domain/battery_type_repository.dart`
- Test: `test/features/battery_types/battery_type_draft_test.dart`

**Interfaces:**
- Consumes: `PermanentId`, `IconSelection`, and `IconColor` from existing core
  and icon-domain modules.
- Produces: `BatteryTypeRecord`, `BatteryTypeDraft`, `BatteryTypeUsage`,
  `BatteryTypeField`, `BatteryTypeValidationException`,
  `BatteryTypeRepository`, and typed repository exceptions.

- [ ] **Step 1: Write failing validation tests**

Create tests with a valid default draft and direct assertions for trimming,
custom values, numeric rules, and capacity/unit dependency:

```dart
BatteryTypeDraft validDraft({
  String typeName = ' AA NiMH ',
  double? voltage = 1.2,
  double? capacity = 2500,
  String? unit = ' mAh ',
}) => BatteryTypeDraft(
  typeName: typeName,
  description: ' Rechargeable AA ',
  chemistry: ' Custom NiMH Blend ',
  defaultVoltage: voltage,
  defaultCapacity: capacity,
  capacityUnit: unit,
  physicalSize: ' AA ',
  notes: ' Fleet stock ',
  suggestedIcon: const IconSelection(
    source: IconSource.builtin,
    key: 'battery_aa',
    color: IconColor.green,
  ),
);

test('normalizes text while retaining custom chemistry and unit', () {
  final normalized = validDraft(unit: 'cells').validated();
  expect(normalized.typeName, 'AA NiMH');
  expect(normalized.chemistry, 'Custom NiMH Blend');
  expect(normalized.capacityUnit, 'cells');
});

test('rejects non-positive voltage and capacity', () {
  expect(
    () => validDraft(voltage: 0, capacity: -1).validated(),
    throwsA(
      isA<BatteryTypeValidationException>()
        .having((error) => error.errors.keys, 'fields', containsAll([
          BatteryTypeField.defaultVoltage,
          BatteryTypeField.defaultCapacity,
        ])),
    ),
  );
});

test('requires capacity and unit together', () {
  expect(
    () => validDraft(unit: null).validated(),
    throwsA(isA<BatteryTypeValidationException>()),
  );
  expect(
    () => validDraft(capacity: null, unit: 'mAh').validated(),
    throwsA(isA<BatteryTypeValidationException>()),
  );
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```powershell
& $flutterSdk.Flutter test test/features/battery_types/battery_type_draft_test.dart
```

Expected: compilation fails because the Battery Type domain files and types do
not exist.

- [ ] **Step 3: Implement immutable domain values and defensive validation**

Use these exact shapes:

```dart
enum BatteryTypeField {
  typeName,
  defaultVoltage,
  defaultCapacity,
  capacityUnit,
}

final class BatteryTypeValidationException implements Exception {
  const BatteryTypeValidationException(this.errors);
  final Map<BatteryTypeField, String> errors;
}

final class BatteryTypeDraft {
  const BatteryTypeDraft({
    required this.typeName,
    required this.description,
    required this.chemistry,
    required this.defaultVoltage,
    required this.defaultCapacity,
    required this.capacityUnit,
    required this.physicalSize,
    required this.notes,
    required this.suggestedIcon,
  });

  final String typeName;
  final String? description;
  final String? chemistry;
  final double? defaultVoltage;
  final double? defaultCapacity;
  final String? capacityUnit;
  final String? physicalSize;
  final String? notes;
  final IconSelection suggestedIcon;

  BatteryTypeDraft validated() {
    final name = typeName.trim();
    final unit = _optional(capacityUnit);
    final errors = <BatteryTypeField, String>{};
    if (name.isEmpty) {
      errors[BatteryTypeField.typeName] = 'Enter a Battery Type name.';
    }
    if (defaultVoltage != null &&
        (!defaultVoltage!.isFinite || defaultVoltage! <= 0)) {
      errors[BatteryTypeField.defaultVoltage] =
          'Voltage must be greater than zero.';
    }
    if (defaultCapacity != null &&
        (!defaultCapacity!.isFinite || defaultCapacity! <= 0)) {
      errors[BatteryTypeField.defaultCapacity] =
          'Capacity must be greater than zero.';
    }
    if (defaultCapacity != null && unit == null) {
      errors[BatteryTypeField.capacityUnit] =
          'Choose or enter a capacity unit.';
    }
    if (defaultCapacity == null && unit != null) {
      errors[BatteryTypeField.defaultCapacity] =
          'Enter a capacity for this unit.';
    }
    if (errors.isNotEmpty) {
      throw BatteryTypeValidationException(Map.unmodifiable(errors));
    }
    return BatteryTypeDraft(
      typeName: name,
      description: _optional(description),
      chemistry: _optional(chemistry),
      defaultVoltage: defaultVoltage,
      defaultCapacity: defaultCapacity,
      capacityUnit: unit,
      physicalSize: _optional(physicalSize),
      notes: _optional(notes),
      suggestedIcon: suggestedIcon,
    );
  }
}
```

Define `BatteryTypeRecord` with every schema field, `createdAt`, `modifiedAt`,
`deactivatedAt`, and `isActive`. Define `BatteryTypeUsage` with `batteries`,
`batterySets`, `devices`, and `total`. Define repository methods exactly as:

```dart
abstract interface class BatteryTypeRepository {
  Future<List<BatteryTypeRecord>> list({bool includeInactive = false});
  Future<BatteryTypeRecord> get(PermanentId id);
  Future<BatteryTypeRecord> create(BatteryTypeDraft draft);
  Future<BatteryTypeRecord> update(PermanentId id, BatteryTypeDraft draft);
  Future<BatteryTypeUsage> usage(PermanentId id);
  Future<BatteryTypeRecord> deactivate(PermanentId id);
  Future<BatteryTypeRecord> reactivate(PermanentId id);
}
```

Add `BatteryTypeNotFoundException`, `BatteryTypeNameConflictException`,
`BatteryTypeReactivationConflictException`, and
`BatteryTypeStateConflictException`, each carrying the permanent ID or name
needed for presentation messages.

Add explicit tests for `double.nan`, positive infinity, and negative infinity;
none is a valid stored voltage or capacity even though some compare differently
from ordinary non-positive numbers.

- [ ] **Step 4: Run domain tests and verify GREEN**

Run:

```powershell
& $flutterSdk.Dart format lib/features/battery_types/domain test/features/battery_types/battery_type_draft_test.dart
& $flutterSdk.Flutter test test/features/battery_types/battery_type_draft_test.dart
```

Expected: all Battery Type draft tests pass with no warnings.

- [ ] **Step 5: Commit the domain slice**

```powershell
git add lib/features/battery_types/domain test/features/battery_types/battery_type_draft_test.dart
git commit -m "Add Battery Type domain validation"
```

---

### Task 2: Icon validation boundary and Drift CRUD repository

**Files:**
- Modify: `lib/features/icons/domain/icon_repository.dart`
- Modify: `lib/features/icons/data/drift_icon_repository.dart`
- Modify: `test/features/icons/drift_icon_repository_test.dart`
- Create: `lib/features/battery_types/data/drift_battery_type_repository.dart`
- Create: `test/features/battery_types/drift_battery_type_repository_test.dart`

**Interfaces:**
- Consumes: Task 1 domain contract, `AppDatabase`, `PermanentIdGenerator`, and
  the existing `IconRepository` rules.
- Produces: public `IconRepository.validateSelection` and
  `DriftBatteryTypeRepository` implementing all Task 1 methods.

- [ ] **Step 1: Write a failing public icon-validation test**

Add a test that calls the new contract directly:

```dart
test('validates Battery Type icon scope through the public boundary', () async {
  await repository.validateSelection(
    scopes: const {IconScope.battery},
    selection: const IconSelection(
      source: IconSource.builtin,
      key: 'battery_aa',
      color: IconColor.green,
    ),
  );
  await expectLater(
    repository.validateSelection(
      scopes: const {IconScope.battery},
      selection: const IconSelection(
        source: IconSource.builtin,
        key: 'device_radio',
        color: IconColor.blue,
      ),
    ),
    throwsA(isA<InvalidIconSelectionException>()),
  );
});
```

- [ ] **Step 2: Run the icon repository test and verify RED**

Run:

```powershell
& $flutterSdk.Flutter test test/features/icons/drift_icon_repository_test.dart
```

Expected: compilation fails because `validateSelection` is not public.

- [ ] **Step 3: Expose the existing centralized validation rule**

Add this method to `IconRepository`:

```dart
Future<void> validateSelection({
  required Set<IconScope> scopes,
  required IconSelection selection,
});
```

Rename `DriftIconRepository._validateSelection` to `validateSelection`, add
`@override`, and update its existing internal calls. Do not create a second
validation implementation.

- [ ] **Step 4: Run the icon test and verify GREEN**

Run:

```powershell
& $flutterSdk.Flutter test test/features/icons/drift_icon_repository_test.dart
```

Expected: all existing icon repository tests plus the new public-boundary test
pass.

- [ ] **Step 5: Write failing Battery Type CRUD repository tests**

Use `AppDatabase.forTesting(NativeDatabase.memory())`, the real
`DriftIconRepository`, and deterministic UUID generators. Cover create, get,
sorted active list, update, defensive validation, custom icon/color storage,
and duplicate active names:

```dart
test('creates and updates a type without changing its UUID', () async {
  final created = await repository.create(validDraft());
  final updated = await repository.update(
    created.id,
    validDraft(typeName: 'AA High Capacity'),
  );
  expect(updated.id, created.id);
  expect(updated.typeName, 'AA High Capacity');
  expect(updated.modifiedAt, isNot(created.modifiedAt));
});

test('rejects case-insensitive duplicate active names', () async {
  await repository.create(validDraft(typeName: 'AA NiMH'));
  await expectLater(
    repository.create(validDraft(typeName: ' aa nimh ')),
    throwsA(isA<BatteryTypeNameConflictException>()),
  );
});
```

- [ ] **Step 6: Run the CRUD test and verify RED**

Run:

```powershell
& $flutterSdk.Flutter test test/features/battery_types/drift_battery_type_repository_test.dart
```

Expected: compilation fails because `DriftBatteryTypeRepository` does not
exist.

- [ ] **Step 7: Implement the minimal typed Drift adapter**

Use this constructor and transaction pattern:

```dart
final class DriftBatteryTypeRepository implements BatteryTypeRepository {
  DriftBatteryTypeRepository({
    required this.database,
    required this.idGenerator,
    required this.iconRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final AppDatabase database;
  final PermanentIdGenerator idGenerator;
  final IconRepository iconRepository;
  final DateTime Function() _clock;

  @override
  Future<BatteryTypeRecord> create(BatteryTypeDraft draft) {
    return database.transaction(() async {
      final values = draft.validated();
      await iconRepository.validateSelection(
        scopes: const {IconScope.battery},
        selection: values.suggestedIcon,
      );
      await _ensureActiveNameAvailable(values.typeName);
      final id = idGenerator.next();
      final now = _clock();
      await database.into(database.batteryTypes).insert(
        BatteryTypesCompanion.insert(
          uuid: id.value,
          typeName: values.typeName,
          description: Value(values.description),
          chemistry: Value(values.chemistry),
          defaultVoltage: Value(values.defaultVoltage),
          defaultCapacity: Value(values.defaultCapacity),
          capacityUnit: Value(values.capacityUnit),
          physicalSize: Value(values.physicalSize),
          suggestedIconSource:
              Value(values.suggestedIcon.source.storageValue),
          suggestedIconKey: Value(values.suggestedIcon.key),
          suggestedIconColor: Value(values.suggestedIcon.color.value),
          notes: Value(values.notes),
          createdAt: Value(now),
          modifiedAt: Value(now),
        ),
      );
      await _recordActivity('battery_type_created', id);
      return get(id);
    });
  }
}
```

Implement update with the same validation/icon/activity transaction and set
`modified_at` from `_clock`. Enforce active-name uniqueness when the record
being edited is active. An inactive record may retain or adopt a name used by
an active record; reactivation is the operation that rejects that conflict.
Map `BatteryType` rows into the Task 1 domain type; never expose Drift row IDs.
Catch only expected uniqueness violations and map them to
`BatteryTypeNameConflictException`; rethrow unrelated database failures.

- [ ] **Step 8: Run CRUD and icon tests and verify GREEN**

Run:

```powershell
& $flutterSdk.Dart format lib/features/icons lib/features/battery_types/data test/features/icons test/features/battery_types
& $flutterSdk.Flutter test test/features/icons/drift_icon_repository_test.dart test/features/battery_types/drift_battery_type_repository_test.dart
```

Expected: both suites pass and schema generation is unchanged.

- [ ] **Step 9: Commit the repository slice**

```powershell
git add lib/features/icons/domain/icon_repository.dart lib/features/icons/data/drift_icon_repository.dart test/features/icons/drift_icon_repository_test.dart lib/features/battery_types/data/drift_battery_type_repository.dart test/features/battery_types/drift_battery_type_repository_test.dart
git commit -m "Add Drift Battery Type CRUD"
```

---

### Task 3: Lifecycle, usage, activity, rollback, and restart persistence

**Files:**
- Modify: `lib/features/battery_types/data/drift_battery_type_repository.dart`
- Modify: `test/features/battery_types/drift_battery_type_repository_test.dart`

**Interfaces:**
- Consumes: Task 2 repository adapter and schema version 1 foreign keys.
- Produces: exact usage counts, reference-preserving deactivate/reactivate,
  lifecycle activity, stale-state errors, and restart-safe storage.

- [ ] **Step 1: Add failing lifecycle and usage tests**

Seed one Battery, one Battery Set, and one Device that reference the created
type. Assert exact counts and preservation:

```dart
test('deactivation preserves all references and reports exact usage', () async {
  final type = await repository.create(validDraft());
  await seedBatterySetAndDeviceReferences(type.id);
  expect(
    await repository.usage(type.id),
    const BatteryTypeUsage(batteries: 1, batterySets: 1, devices: 1),
  );
  final inactive = await repository.deactivate(type.id);
  expect(inactive.isActive, isFalse);
  expect(await referencedBatteryTypeRowIds(), everyElement(isNotNull));
  expect(await repository.list(), isEmpty);
  expect(await repository.list(includeInactive: true), hasLength(1));
});
```

Add tests for name reuse after deactivation, reactivation conflict, successful
reactivation, edit while inactive, repeated deactivate/reactivate stale-state
errors, and missing UUID errors.

- [ ] **Step 2: Add failing transaction and activity tests**

Create a SQLite trigger that aborts `battery_type_deactivated` activity inserts,
then assert `deactivated_at` remains null. Check successful event names,
entity UUIDs, and deactivation usage-count metadata.

```dart
await database.customStatement('''
  CREATE TRIGGER fail_battery_type_activity
  BEFORE INSERT ON activity_log
  WHEN NEW.event_type = 'battery_type_deactivated'
  BEGIN
    SELECT RAISE(ABORT, 'simulated activity failure');
  END;
''');
await expectLater(repository.deactivate(type.id), throwsA(isA<Object>()));
expect((await repository.get(type.id)).isActive, isTrue);
```

- [ ] **Step 3: Add a failing real-file restart test**

Create a temporary SQLite file, create and update a Battery Type with a custom
chemistry/unit and icon color, close the database, reopen it, and assert every
field and UUID matches.

- [ ] **Step 4: Run the focused repository suite and verify RED**

Run:

```powershell
& $flutterSdk.Flutter test test/features/battery_types/drift_battery_type_repository_test.dart
```

Expected: lifecycle methods, usage counts, activity metadata, or restart
expectations fail because Task 2 implemented CRUD only.

- [ ] **Step 5: Implement lifecycle methods inside transactions**

Use direct parameterized count queries for the three foreign-key consumers.
For deactivation:

```dart
return database.transaction(() async {
  final current = await get(id);
  if (!current.isActive) {
    throw BatteryTypeStateConflictException(id);
  }
  final counts = await usage(id);
  await _setDeactivatedAt(id, _clock());
  await _recordActivity(
    'battery_type_deactivated',
    id,
    metadata: {
      'batteries': counts.batteries,
      'battery_sets': counts.batterySets,
      'devices': counts.devices,
    },
  );
  return get(id);
});
```

Reactivation checks for another active case-insensitive name before clearing
`deactivated_at`. Neither method updates any foreign-key consumer row.

- [ ] **Step 6: Run focused repository and database tests and verify GREEN**

Run:

```powershell
& $flutterSdk.Flutter test test/features/battery_types/drift_battery_type_repository_test.dart test/core/database
```

Expected: lifecycle, rollback, restart, and existing schema tests pass.

- [ ] **Step 7: Commit the lifecycle slice**

```powershell
git add lib/features/battery_types/data/drift_battery_type_repository.dart test/features/battery_types/drift_battery_type_repository_test.dart
git commit -m "Add Battery Type lifecycle safety"
```

---

### Task 4: Riverpod catalog controller and production dependency wiring

**Files:**
- Create: `lib/features/battery_types/application/battery_type_catalog_controller.dart`
- Modify: `lib/app/app_providers.dart`
- Modify: `lib/app/app_bootstrap.dart`
- Modify: `lib/app/battery_tracker_root.dart`
- Modify: `test/app/app_bootstrap_test.dart`
- Create: `test/features/battery_types/battery_type_catalog_controller_test.dart`

**Interfaces:**
- Consumes: `BatteryTypeRepository` from Task 1 and Drift adapter from Tasks
  2–3.
- Produces: `batteryTypeCatalogProvider`, `batteryTypeUsageProvider`,
  `BatteryTypeCatalogSnapshot`, `BatteryTypeStatusFilter`, and a production
  repository override.

- [ ] **Step 1: Write failing controller tests with the real repository**

Use a Riverpod `ProviderContainer` overriding `batteryTypeRepositoryProvider`.
Seed active and inactive records, then prove search and status behavior:

```dart
test('filters by status and searchable specification text', () async {
  final initial = await container.read(batteryTypeCatalogProvider.future);
  expect(initial.visible.map((item) => item.typeName), contains('AA NiMH'));

  container
      .read(batteryTypeCatalogProvider.notifier)
      .setQuery('lifepo4');
  expect(
    container.read(batteryTypeCatalogProvider).requireValue.visible.single
        .chemistry,
    'LiFePO4',
  );

  container
      .read(batteryTypeCatalogProvider.notifier)
      .setStatus(BatteryTypeStatusFilter.inactive);
  expect(
    container.read(batteryTypeCatalogProvider).requireValue.visible,
    everyElement(isA<BatteryTypeRecord>().having(
      (record) => record.isActive,
      'isActive',
      isFalse,
    )),
  );
});
```

Add tests for selection retention, create/update refresh, deactivate/reactivate,
and keeping the last persisted snapshot visible after a failed repository
write.

- [ ] **Step 2: Run controller tests and verify RED**

Run:

```powershell
& $flutterSdk.Flutter test test/features/battery_types/battery_type_catalog_controller_test.dart
```

Expected: compilation fails because the provider/controller types do not
exist.

- [ ] **Step 3: Implement snapshot, derived filters, and controller methods**

Use these exact public values:

```dart
enum BatteryTypeStatusFilter { active, inactive, all }

final class BatteryTypeCatalogSnapshot {
  const BatteryTypeCatalogSnapshot({
    required this.records,
    required this.visible,
    required this.status,
    required this.query,
    required this.selectedId,
  });
  final List<BatteryTypeRecord> records;
  final List<BatteryTypeRecord> visible;
  final BatteryTypeStatusFilter status;
  final String query;
  final PermanentId? selectedId;
}
```

Search case-insensitively over name, chemistry, physical size, and description.
Load the backing catalog with `list(includeInactive: true)` and default the
derived view to Active. `create`, `update`, `deactivate`, and `reactivate` await
the repository and then reload; state enters `AsyncLoading` only for the
initial load so routine saves do not erase the current page on failure.

Add a family provider:

```dart
final batteryTypeUsageProvider =
    FutureProvider.family<BatteryTypeUsage, PermanentId>(
  (ref, id) => ref.watch(batteryTypeRepositoryProvider).usage(id),
);
```

Invalidate the affected usage provider after lifecycle changes.

- [ ] **Step 4: Wire the production repository**

Add `batteryTypeRepositoryProvider` to `app_providers.dart`. Construct
`DriftBatteryTypeRepository` in `AppBootstrap.start` after the icon repository,
store it on `AppDependencies`, and override it in `BatteryTrackerRoot`.
Extend `app_bootstrap_test.dart` to create a Battery Type through the injected
repository, close dependencies, restart, and verify the same UUID loads.

- [ ] **Step 5: Run controller and bootstrap tests and verify GREEN**

Run:

```powershell
& $flutterSdk.Dart format lib/features/battery_types/application lib/app test/features/battery_types test/app/app_bootstrap_test.dart
& $flutterSdk.Flutter test test/features/battery_types/battery_type_catalog_controller_test.dart test/app/app_bootstrap_test.dart
```

Expected: controller and production bootstrap persistence tests pass.

- [ ] **Step 6: Commit the application slice**

```powershell
git add lib/features/battery_types/application lib/app test/features/battery_types/battery_type_catalog_controller_test.dart test/app/app_bootstrap_test.dart
git commit -m "Wire Battery Type application state"
```

---

### Task 5: Battery Type create/edit dialog

**Files:**
- Create: `lib/features/battery_types/presentation/battery_type_form_dialog.dart`
- Create: `test/features/battery_types/battery_type_form_dialog_test.dart`

**Interfaces:**
- Consumes: Task 1 draft/record values, Phase 3 `IconPickerDialog`,
  `IconVisual`, and `applicationSupportRootProvider`.
- Produces: `BatteryTypeFormDialog.show`, returning a validated
  `BatteryTypeDraft` only after confirmation.

- [ ] **Step 1: Write failing form widget tests**

Pump the dialog inside a `ProviderScope` with real icon repository and support
root overrides. Test add and edit modes, field keys, numeric parsing, custom
suggestions, capacity/unit dependency, cancel, and icon/color override.

Use stable keys:

```dart
const ValueKey('battery-type-name-field');
const ValueKey('battery-type-chemistry-field');
const ValueKey('battery-type-voltage-field');
const ValueKey('battery-type-capacity-field');
const ValueKey('battery-type-capacity-unit-field');
const ValueKey('battery-type-physical-size-field');
const ValueKey('battery-type-description-field');
const ValueKey('battery-type-notes-field');
const ValueKey('battery-type-choose-icon');
```

One test must enter `Custom Zinc Hybrid` and `cells`, save, and assert those
exact values in the returned draft. Another enters zero and nonnumeric values
and asserts localized field errors without a returned draft.

- [ ] **Step 2: Run form tests and verify RED**

Run:

```powershell
& $flutterSdk.Flutter test test/features/battery_types/battery_type_form_dialog_test.dart
```

Expected: compilation fails because the form dialog does not exist.

- [ ] **Step 3: Implement the focused form**

Use a stateful dialog with controllers initialized from an optional
`BatteryTypeRecord`. Group controls under Identity, Defaults, Visual Default,
and Notes headings. Use editable `Autocomplete<String>` fields with these
constants:

```dart
const chemistrySuggestions = [
  'NiMH',
  'NiCd',
  'Li-ion',
  'LiPo',
  'LiFePO4',
  'Lead Acid',
  'Proprietary',
  'Other',
];
const capacityUnitSuggestions = ['mAh', 'Ah', 'Wh'];
```

Parse numeric text with `double.tryParse`, map parse and Task 1 validation
errors back to the exact fields, and keep the dialog open. The icon action
calls:

```dart
final selection = await IconPickerDialog.show(
  context,
  scope: IconScope.battery,
  initialSelection: _suggestedIcon,
);
```

Render the returned choice and color in the Visual Default preview. Save pops
the validated draft; Cancel pops null.

- [ ] **Step 4: Run form and icon chooser tests and verify GREEN**

Run:

```powershell
& $flutterSdk.Dart format lib/features/battery_types/presentation/battery_type_form_dialog.dart test/features/battery_types/battery_type_form_dialog_test.dart
& $flutterSdk.Flutter test test/features/battery_types/battery_type_form_dialog_test.dart test/features/icons/icon_picker_dialog_test.dart
```

Expected: form and existing chooser tests pass in Light and Dark test themes.

- [ ] **Step 5: Commit the form slice**

```powershell
git add lib/features/battery_types/presentation/battery_type_form_dialog.dart test/features/battery_types/battery_type_form_dialog_test.dart
git commit -m "Add Battery Type form workflow"
```

---

### Task 6: Responsive Battery Types management page and navigation

**Files:**
- Create: `lib/features/battery_types/presentation/battery_type_icon.dart`
- Create: `lib/features/battery_types/presentation/battery_types_page.dart`
- Modify: `lib/app/navigation/app_shell.dart`
- Modify: `test/app/app_smoke_test.dart`
- Create: `test/features/battery_types/battery_type_icon_test.dart`
- Create: `test/features/battery_types/battery_types_page_test.dart`

**Interfaces:**
- Consumes: Tasks 4–5 providers/controller/form and Phase 3 icon rendering.
- Produces: the complete Battery Types destination, list/details workflow,
  deactivation usage confirmation, and reactivation UI.

- [ ] **Step 1: Write failing navigation and page widget tests**

Use a real in-memory Drift repository inside provider overrides. Cover:

- the navigation destination renders `BatteryTypesPage`;
- database-empty and no-search-results states differ;
- add creates and displays a record;
- edit preserves UUID and updates displayed fields;
- search covers chemistry and physical size;
- Active, Inactive, and All filters;
- selected details display full defaults and usage counts;
- deactivation confirmation reports exact Battery/Set/Device counts;
- deactivation preserves references and moves the row to Inactive;
- reactivation restores it to Active;
- a reactivation name conflict displays a concise message;
- Light, Dark, keyboard semantics, and a 640-pixel-wide surface produce no
  overflow exceptions.

Add focused icon tests proving a built-in selection, an active custom icon,
an inactive custom icon still referenced by a type, and a missing custom file
all render without a broken-image box. The last two cases must fall back to the
generic Battery icon while retaining the stored logical selection.

Assert stable page keys and copy:

```dart
expect(find.byKey(const ValueKey('battery-types-page')), findsOneWidget);
expect(find.byKey(const ValueKey('battery-types-search')), findsOneWidget);
expect(find.text('No Battery Types yet.'), findsOneWidget);
expect(find.text('No Battery Types match these filters.'), findsOneWidget);
expect(find.text('Used by 1 Battery, 1 Battery Set, and 1 Device.'),
    findsOneWidget);
```

- [ ] **Step 2: Run page tests and verify RED**

Run:

```powershell
& $flutterSdk.Flutter test test/features/battery_types/battery_types_page_test.dart test/app/app_smoke_test.dart
```

Expected: navigation still renders the generic empty state and the page class
does not exist.

- [ ] **Step 3: Implement a Battery Type icon resolver widget**

`BatteryTypeIcon` accepts an `IconSelection`, size, and optional semantics
label. Resolve built-ins from `BuiltInIconRegistry`; resolve custom logical
UUIDs through `IconRepository.getCustomIcon`. Convert an active, file-backed
custom record with `toDefinition()`. For missing, inactive, invalid, or
unresolvable custom references, supply the Battery-scope default definition to
`IconVisual`. Keep file paths and database access out of the Battery Type
domain model.

- [ ] **Step 4: Implement the responsive management page**

Create a `ConsumerWidget`/focused private widgets for toolbar, record list,
row/card, details, and confirmation dialog. Use the existing
`AppPageScaffold`, an icon-led industrial inventory layout, and
`LayoutBuilder`:

```dart
final compact = constraints.maxWidth < 820;
return compact
    ? Column(children: [Expanded(child: list), details])
    : Row(children: [Expanded(child: list), const VerticalDivider(), details]);
```

Keep filters in a `SingleChildScrollView(scrollDirection: Axis.horizontal)` at
narrow widths. Use `BatteryTypeIcon` for every row and details header.
The Add and Edit actions await `BatteryTypeFormDialog.show` then call the
controller.

Before deactivation, await `batteryTypeUsageProvider(id).future` and render all
three counts. Only a clearly labeled Deactivate confirmation calls the
controller. Reactivation has its own confirmation and maps a name conflict to
`A different active Battery Type already uses this name.`

Log unexpected errors with:

```dart
ref.read(appLogServiceProvider).logger('battery_types.ui').severe(
  'Battery Type operation failed.',
  error,
  stackTrace,
);
```

Show operation-specific SnackBars without exception strings or stack traces.

- [ ] **Step 5: Replace the AppShell empty-state branch**

Import the page and add this switch arm before the generic branch:

```dart
AppDestination.batteryTypes => const BatteryTypesPage(),
```

Keep every other destination unchanged.

- [ ] **Step 6: Run page, app, controller, and icon tests and verify GREEN**

Run:

```powershell
& $flutterSdk.Dart format lib/features/battery_types/presentation lib/app/navigation/app_shell.dart test/features/battery_types test/app/app_smoke_test.dart
& $flutterSdk.Flutter test test/features/battery_types test/app/app_smoke_test.dart test/features/icons
```

Expected: all Phase 4 workflows and Phase 3 reuse regressions pass without
overflow, semantic, or raw-error failures.

- [ ] **Step 7: Commit the management UI slice**

```powershell
git add lib/features/battery_types/presentation lib/app/navigation/app_shell.dart test/features/battery_types test/app/app_smoke_test.dart
git commit -m "Complete Battery Type management UI"
```

---

### Task 7: Documentation, acceptance, and full Windows verification

**Files:**
- Modify: `README.md`
- Modify: `MANIFEST.md`
- Modify: `docs/ARCHITECTURE.md`
- Modify: `docs/DATABASE_PLAN.md`
- Modify: `docs/IMPLEMENTATION_PLAN.md`
- Modify: `lib/features/battery_types/README.md`

**Interfaces:**
- Consumes: all completed Phase 4 behavior and fresh verification evidence.
- Produces: current Phase 4 user guidance, architecture/lifecycle decisions,
  completion status, and Phase 5 next action.

- [ ] **Step 1: Update feature and project documentation**

Document fields, editable suggestions, validation rules, UUID stability,
icon-default behavior, usage-count confirmation, reference-preserving
deactivation, reactivation conflict handling, activity events, and unchanged
schema version 1. Mark Phase 4 complete only after the following verification
steps pass; set Phase 5 Battery Inventory as the next action.

- [ ] **Step 2: Run formatting verification in the workspace**

Run:

```powershell
. (Join-Path (Get-Location) 'scripts\flutter_sdk.ps1')
$flutterSdk = Resolve-FlutterSdk
& $flutterSdk.Dart format .
& $flutterSdk.Dart format --output=none --set-exit-if-changed .
```

Expected: the second command exits zero and reports zero changed files.

- [ ] **Step 3: Create and verify an exact normal-ACL source snapshot**

Create a unique directory under `$env:TEMP` with `New-Item`, resolve both the
workspace and snapshot paths, and assert the snapshot is inside that unique
temporary directory. Copy the source with `robocopy`, excluding `.git`,
`.dart_tool`, `build`, platform `ephemeral` directories, and local runtime
data. Treat robocopy exit codes 0 through 7 as success. Run all remaining
commands from that snapshot so Flutter can refresh generated directories
without the OneDrive delete-deny ACL.

- [ ] **Step 4: Resolve dependencies and regenerate Drift artifacts**

Run in the normal-ACL verification snapshot:

```powershell
& $flutterSdk.Flutter pub get
& $flutterSdk.Dart run build_runner build
```

Expected: both commands exit zero. Compare
`lib/core/database/app_database.g.dart` and
`drift_schemas/schema_v1.json` with the workspace; both hashes must remain
unchanged because Phase 4 uses the existing schema.

- [ ] **Step 5: Run clean static analysis**

```powershell
& $flutterSdk.Flutter analyze --no-pub
```

Expected: `No issues found!` and exit zero.

- [ ] **Step 6: Run the complete test suite**

```powershell
& $flutterSdk.Flutter test --no-pub
```

Expected: every test passes with no failure, warning, or uncaught exception.

- [ ] **Step 7: Build and launch-check Windows Release**

```powershell
& $flutterSdk.Flutter build windows --release --no-pub
```

Expected: `battery_tracker.exe` is created under
`build\windows\x64\runner\Release`. Start it twice with hidden windows, verify
each process remains alive for five seconds, and stop only those exact process
IDs.

- [ ] **Step 8: Audit the completed phase**

Run `git diff --check`, review status and the complete diff, scan Phase 4 source
and tests for unfinished markers, confirm all five project-control documents
still exist, confirm the schema and generated plugin files match the verified
snapshot, and reconcile every Phase 4 scope/acceptance checkbox against direct
tests or build evidence.

- [ ] **Step 9: Commit documentation and verified status**

```powershell
git add README.md MANIFEST.md docs/ARCHITECTURE.md docs/DATABASE_PLAN.md docs/IMPLEMENTATION_PLAN.md lib/features/battery_types/README.md
git commit -m "Document completed Phase 4 battery types"
```
