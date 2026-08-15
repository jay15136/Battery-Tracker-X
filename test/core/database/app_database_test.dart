import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/database/drift_database_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftDatabaseService service;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    service = DriftDatabaseService(database);
    await service.initialize();
  });

  tearDown(() => service.close());

  test('initializes the complete version 1 schema with foreign keys enabled',
      () async {
    final versionRow =
        await database.customSelect('PRAGMA user_version').getSingle();
    final foreignKeyRow =
        await database.customSelect('PRAGMA foreign_keys').getSingle();
    final tableRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .get();

    expect(versionRow.read<int>('user_version'), 1);
    expect(foreignKeyRow.read<int>('foreign_keys'), 1);
    expect(
      tableRows.map((row) => row.read<String>('name')).toSet(),
      {
        'activity_log',
        'assignments',
        'batteries',
        'battery_batches',
        'battery_photos',
        'battery_set_memberships',
        'battery_set_photos',
        'battery_sets',
        'battery_tags',
        'battery_types',
        'charge_records',
        'custom_icons',
        'device_photos',
        'devices',
        'icon_categories',
        'media_assets',
        'qr_label_templates',
        'set_charge_records',
        'settings',
        'tags',
      },
    );
  });

  test('enforces foreign keys and case-insensitive active Battery IDs',
      () async {
    await expectLater(
      database.into(database.batteries).insert(
            BatteriesCompanion.insert(
              uuid: '11111111-1111-4111-8111-111111111111',
              userBatteryId: 'AA-001',
              batteryTypeId: const Value(999),
            ),
          ),
      throwsA(isA<Exception>()),
    );

    await database.into(database.batteries).insert(
          BatteriesCompanion.insert(
            uuid: '22222222-2222-4222-8222-222222222222',
            userBatteryId: 'AA-001',
          ),
        );

    await expectLater(
      database.into(database.batteries).insert(
            BatteriesCompanion.insert(
              uuid: '33333333-3333-4333-8333-333333333333',
              userBatteryId: 'aa-001',
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('stores UTC timestamps as text and supplies icon-first defaults',
      () async {
    final rowId = await database.into(database.batteries).insert(
          BatteriesCompanion.insert(
            uuid: '44444444-4444-4444-8444-444444444444',
            userBatteryId: 'AA-002',
          ),
        );
    final battery = await (database.select(database.batteries)
          ..where((table) => table.id.equals(rowId)))
        .getSingle();
    final storageRow = await database.customSelect(
      'SELECT typeof(created_at) AS storage_type FROM batteries WHERE id = ?',
      variables: [Variable<int>(rowId)],
    ).getSingle();

    expect(storageRow.read<String>('storage_type'), 'text');
    expect(battery.createdAt.isUtc, isTrue);
    expect(battery.iconSource, 'builtin');
    expect(battery.iconKey, 'battery_generic');
    expect(battery.preferredPrimaryVisual, 'icon');
  });

  test('rolls back all writes when transaction work fails', () async {
    await expectLater(
      service.transaction<void>((transaction) async {
        final driftTransaction = transaction as DriftDatabaseTransaction;
        await driftTransaction.database.into(database.settings).insert(
              SettingsCompanion.insert(
                key: 'appearance.theme_mode',
                value: 'dark',
                valueType: 'string',
              ),
            );
        throw StateError('Simulated failure');
      }),
      throwsStateError,
    );

    expect(await database.select(database.settings).get(), isEmpty);
  });
}
