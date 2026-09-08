import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:battery_tracker/features/import_export/data/drift_import_export_repository.dart';
import 'package:battery_tracker/features/import_export/domain/import_export.dart';
import 'package:csv/csv.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftBatteryTypeRepository types;
  late DriftImportExportRepository repo;
  final now = DateTime.utc(2026, 9, 8, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    types = DriftBatteryTypeRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        iconRepository: icons);
    repo = DriftImportExportRepository(
        db: db,
        batteries: batteries,
        batterySets: sets,
        batteryTypes: types,
        now: () => now);
  });
  tearDown(() => db.close());

  BatteryTypeDraft typeDraft(String name) => BatteryTypeDraft(
      typeName: name,
      description: null,
      chemistry: null,
      defaultVoltage: null,
      defaultCapacity: null,
      capacityUnit: null,
      physicalSize: null,
      notes: null,
      suggestedIcon: const IconSelection(
          source: IconSource.builtin,
          key: 'battery_generic',
          color: IconColor.defaultColor));

  List<List<String>> parse(String csv) =>
      const CsvToListConverter(shouldParseNumbers: false)
          .convert(csv)
          .map((row) => row.map((c) => c.toString()).toList())
          .toList();

  test('batteryCsvTemplate is a header-only CSV of the canonical fields', () {
    final rows = parse(repo.batteryCsvTemplate());
    expect(rows, [batteryCsvFields]);
  });

  test('exportBatteriesCsv includes Type, Set, Device, and charge columns',
      () async {
    final type = await types.create(typeDraft('AA NiMH'));
    final battery = await batteries.save(BatteryDraft(
        userBatteryId: 'AA-001',
        name: 'Radio, spare',
        batteryTypeId: type.id,
        manufacturer: 'Acme',
        nominalVoltage: 1.2,
        capacity: 2000,
        capacityUnit: 'mAh'));
    final set = await sets.save(const SetDraft(userSetId: 'S-1', name: 'Set'));
    await sets.addMember(set.id, battery.id);

    final csv = await repo.exportBatteriesCsv();
    final rows = parse(csv);
    expect(rows.first, [...batteryCsvFields, ...batteryExportOnlyFields]);
    final row = rows[1];
    final header = rows.first;
    String cell(String field) => row[header.indexOf(field)];
    expect(cell('Battery ID'), 'AA-001');
    expect(cell('Name'), 'Radio, spare');
    expect(cell('Type'), 'AA NiMH');
    expect(cell('Manufacturer'), 'Acme');
    expect(cell('Voltage'), '1.2');
    expect(cell('Capacity'), '2000.0');
    expect(cell('Capacity Unit'), 'mAh');
    expect(cell('Battery Set'), contains('S-1'));
  });

  test('exportBatterySetsCsv reports member count and active state', () async {
    final battery =
        await batteries.save(const BatteryDraft(userBatteryId: 'AA-001'));
    final set = await sets.save(const SetDraft(userSetId: 'S-1', name: 'Kit'));
    await sets.addMember(set.id, battery.id);

    final rows = parse(await repo.exportBatterySetsCsv());
    expect(rows.first, batterySetCsvFields);
    final header = rows.first;
    final row = rows[1];
    String cell(String field) => row[header.indexOf(field)];
    expect(cell('Set ID'), 'S-1');
    expect(cell('Member Count'), '1');
    expect(cell('Active'), 'Yes');
  });

  String csvOf(List<List<String>> rows) =>
      const ListToCsvConverter().convert(rows);

  test('previewBatteryImport flags a blank Battery ID as an error', () async {
    final csv = csvOf([
      batteryCsvFields,
      ['', 'No id', ...List.filled(batteryCsvFields.length - 2, '')],
    ]);
    final preview = await repo.previewBatteryImport(csv);
    expect(preview.rows.single.isValid, isFalse);
    expect(preview.rows.single.errors, contains('Enter a Battery ID.'));
  });

  test('previewBatteryImport warns but still imports an unrecognized Type',
      () async {
    final csv = csvOf([
      batteryCsvFields,
      [
        'AA-001',
        '',
        'Unknown Type',
        ...List.filled(batteryCsvFields.length - 3, '')
      ],
    ]);
    final preview = await repo.previewBatteryImport(csv);
    final row = preview.rows.single;
    expect(row.isValid, isTrue);
    expect(row.draft!.batteryTypeId, isNull);
    expect(row.warnings.single, contains('Unknown Type'));
  });

  test('previewBatteryImport resolves a known Type by name case-insensitively',
      () async {
    final type = await types.create(typeDraft('AA NiMH'));
    final csv = csvOf([
      batteryCsvFields,
      [
        'AA-001',
        '',
        'aa nimh',
        ...List.filled(batteryCsvFields.length - 3, '')
      ],
    ]);
    final preview = await repo.previewBatteryImport(csv);
    expect(preview.rows.single.draft!.batteryTypeId, type.id);
    expect(preview.rows.single.warnings, isEmpty);
  });

  test(
      'previewBatteryImport rejects unparsable numbers and mismatched capacity',
      () async {
    const header = batteryCsvFields;
    int idx(String f) => header.indexOf(f);
    List<String> row(Map<String, String> values) {
      final cells = List.filled(header.length, '');
      values.forEach((k, v) => cells[idx(k)] = v);
      return cells;
    }

    final csv = csvOf([
      header,
      row({'Battery ID': 'AA-001', 'Voltage': 'not-a-number'}),
      row({'Battery ID': 'AA-002', 'Capacity': '2000'}),
    ]);
    final preview = await repo.previewBatteryImport(csv);
    expect(preview.rows[0].errors, contains('Voltage must be a number.'));
    expect(preview.rows[1].errors,
        contains('Enter both Capacity and Capacity Unit, or neither.'));
  });

  test('previewBatteryImport rejects an unrecognized Status or Condition',
      () async {
    const header = batteryCsvFields;
    List<String> row(String id, String status, String condition) {
      final cells = List.filled(header.length, '');
      cells[header.indexOf('Battery ID')] = id;
      cells[header.indexOf('Status')] = status;
      cells[header.indexOf('Condition')] = condition;
      return cells;
    }

    final csv = csvOf([header, row('AA-001', 'Sparkling', 'Mint')]);
    final preview = await repo.previewBatteryImport(csv);
    expect(preview.rows.single.errors,
        contains('Status "Sparkling" is not recognized.'));
    expect(preview.rows.single.errors,
        contains('Condition "Mint" is not recognized.'));
  });

  test(
      'previewBatteryImport marks the second occurrence of a repeated ID as a duplicate',
      () async {
    final csv = csvOf([
      batteryCsvFields,
      ['AA-001', ...List.filled(batteryCsvFields.length - 1, '')],
      ['AA-001', ...List.filled(batteryCsvFields.length - 1, '')],
    ]);
    final preview = await repo.previewBatteryImport(csv);
    expect(preview.rows[0].duplicateOf, isNull);
    expect(preview.rows[0].willImport, isTrue);
    expect(preview.rows[1].duplicateOf, 'AA-001');
    expect(preview.rows[1].willImport, isFalse);
  });

  test('previewBatteryImport marks a row duplicate against an existing Battery',
      () async {
    await batteries.save(const BatteryDraft(userBatteryId: 'AA-001'));
    final csv = csvOf([
      batteryCsvFields,
      ['AA-001', ...List.filled(batteryCsvFields.length - 1, '')],
    ]);
    final preview = await repo.previewBatteryImport(csv);
    expect(preview.rows.single.duplicateOf, 'AA-001');
  });

  test(
      'commitBatteryImport creates only valid, non-duplicate rows and logs one event',
      () async {
    await batteries.save(const BatteryDraft(userBatteryId: 'EXISTING'));
    const header = batteryCsvFields;
    List<String> row(Map<String, String> values) {
      final cells = List.filled(header.length, '');
      values.forEach((k, v) => cells[header.indexOf(k)] = v);
      return cells;
    }

    final csv = csvOf([
      header,
      row({'Battery ID': 'NEW-1'}),
      row({'Battery ID': 'NEW-2'}),
      row({'Battery ID': 'EXISTING'}), // duplicate of existing
      row({'Battery ID': '', 'Name': 'invalid, no id'}), // invalid
    ]);
    final preview = await repo.previewBatteryImport(csv);
    expect(preview.willImportCount, 2);
    expect(preview.duplicateCount, 1);
    expect(preview.errorCount, 1);

    final summary = await repo.commitBatteryImport(preview);
    expect(summary.created, 2);
    expect(summary.skippedDuplicates, 1);
    expect(summary.skippedInvalid, 1);

    final all = await batteries.list();
    expect(all.map((b) => b.values.userBatteryId).toSet(),
        {'EXISTING', 'NEW-1', 'NEW-2'});

    final activity = await (db.select(db.activityLog)).get();
    final imported =
        activity.where((a) => a.eventType == 'csv_batteries_imported');
    expect(imported.length, 1);
    expect(imported.single.summary, contains('Imported 2 Batteries'));
  });
}
