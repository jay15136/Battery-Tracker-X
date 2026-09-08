import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/bulk_operations/data/drift_bulk_creation_repository.dart';
import 'package:battery_tracker/features/bulk_operations/domain/bulk_creation.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftBulkCreationRepository repo;
  late DriftIconRepository icons;
  void bind(AppDatabase database) {
    db = database;
    icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    repo =
        DriftBulkCreationRepository(db: db, batteries: batteries, sets: sets);
  }

  setUp(() => bind(AppDatabase.forTesting(NativeDatabase.memory())));
  tearDown(() => db.close());
  List<BulkRow> rows(int count,
          {BatteryDraft shared =
              const BatteryDraft(userBatteryId: 'shared')}) =>
      BulkIds.generate(
              prefix: 'AA',
              separator: '-',
              start: 1,
              padding: 3,
              quantity: count)
          .map((id) => BulkRow(bulkCopy(shared, id: id)))
          .toList();
  for (final count in [4, 20]) {
    test('create $count Batteries with unique UUIDs and individual history',
        () async {
      final result = await repo.save(BulkRequest(rows: rows(count)));
      expect(result.batteries.toSet(), hasLength(count));
      final all = await batteries.list();
      expect(all, hasLength(count));
      expect(all.first.values.userBatteryId, 'AA-001');
      expect(all.last.values.userBatteryId,
          'AA-' + count.toString().padLeft(3, '0'));
      for (final b in all) {
        expect(await batteries.history(b.id), isNotEmpty);
        expect(b.values.icon.key, 'battery_generic');
        expect(b.currentSets, isEmpty);
      }
    });
  }
  test('custom prefix start separator and padding generate exact preview', () {
    expect(
        BulkIds.generate(
            prefix: 'CELL', separator: '', start: 21, padding: 4, quantity: 2),
        ['CELL0021', 'CELL0022']);
    expect(
        BulkIds.generate(
            prefix: 'AA', separator: '-', start: 21, padding: 3, quantity: 2),
        ['AA-021', 'AA-022']);
    expect(
        BulkIds.generate(
            prefix: 'X', separator: '/', start: 0, padding: 0, quantity: 1),
        ['X/0']);
  });
  test('next available finds gaps without changing requested count', () {
    expect(
        BulkIds.generate(
            prefix: 'AA',
            separator: '-',
            start: 1,
            padding: 3,
            quantity: 4,
            nextAvailable: true,
            existing: {'aa-001', 'AA-002', 'AA-003', 'AA-004'}),
        ['AA-005', 'AA-006', 'AA-007', 'AA-008']);
  });
  test('invalid generation bounds fail before allocation', () {
    for (final n in [0, -1, 1001]) {
      expect(
          () => BulkIds.generate(
              prefix: 'A', separator: '-', start: 1, padding: 3, quantity: n),
          throwsA(isA<BulkValidationException>()));
    }
  });
  test('edited preview ID saved exactly and duplicates reject atomically',
      () async {
    final preview = rows(4);
    preview[1] = BulkRow(bulkCopy(preview[1].battery, id: 'My custom ID'));
    await repo.save(BulkRequest(rows: preview));
    expect(
        (await batteries.list())
            .any((b) => b.values.userBatteryId == 'My custom ID'),
        isTrue);
    await expectLater(repo.save(BulkRequest(rows: rows(4))),
        throwsA(isA<BulkValidationException>()));
    expect(await batteries.list(), hasLength(4));
    await expectLater(
        repo.save(BulkRequest(rows: [
          const BulkRow(BatteryDraft(userBatteryId: 'Case')),
          const BulkRow(BatteryDraft(userBatteryId: ' case '))
        ])),
        throwsA(isA<BulkValidationException>()));
  });
  test('stale preview collision never renumbers or partially saves', () async {
    final preview = rows(4);
    await batteries.save(const BatteryDraft(userBatteryId: 'AA-004'));
    await expectLater(repo.save(BulkRequest(rows: preview)),
        throwsA(isA<BulkValidationException>()));
    expect(await batteries.list(), hasLength(1));
  });
  test('shared purchase Batch tags built-in icon and individual color persist',
      () async {
    final shared = BatteryDraft(
        userBatteryId: 'shared',
        manufacturer: 'Acme',
        model: 'M',
        chemistry: 'NiMH',
        nominalVoltage: 1.2,
        capacity: 2500,
        capacityUnit: 'mAh',
        purchaseDate: DateTime.utc(2026, 8, 1),
        purchaseLocation: 'Store',
        purchasePrice: 20,
        totalPackagePrice: 20,
        perBatteryPrice: 5,
        warrantyExpiration: DateTime.utc(2028),
        batchCode: 'BATCH-1',
        notes: 'Spare',
        icon: const IconSelection(
            source: IconSource.builtin,
            key: 'battery_aa',
            color: IconColor.green));
    final preview = rows(4, shared: shared);
    preview[0] = const BulkRow(BatteryDraft(
        userBatteryId: 'AA-001',
        batchCode: 'BATCH-1',
        icon: IconSelection(
            source: IconSource.builtin,
            key: 'battery_aa',
            color: IconColor.blue)));
    final result = await repo
        .save(BulkRequest(rows: preview, tags: [' Work ', 'work', 'Spare']));
    final saved = await batteries.get(result.batteries[1]);
    expect(saved.values.manufacturer, 'Acme');
    expect(saved.values.purchaseDate, shared.purchaseDate);
    expect(saved.values.perBatteryPrice, 5);
    expect(saved.values.totalPackagePrice, 20);
    expect(saved.values.icon.color, IconColor.green);
    expect((await batteries.get(result.batteries[0])).values.icon.color,
        IconColor.blue);
    expect(await db.select(db.batteryBatches).get(), hasLength(1));
    expect(await db.select(db.tags).get(), hasLength(2));
    expect(await db.select(db.batteryTags).get(), hasLength(8));
  });
  test('custom icon selection copied to every Battery', () async {
    const ids = UuidV4PermanentIdGenerator();
    final cat = await icons.createCategory(
        id: ids.next(), name: 'Custom batteries', scope: IconScope.battery);
    final icon = await icons.createCustomIcon(
        id: ids.next(),
        name: 'Custom',
        categoryId: cat.id,
        relativePath: ManagedRelativePath.parse('custom_icons/test.svg'),
        fileType: IconFileType.svg,
        supportsColor: true);
    await repo.save(BulkRequest(
        rows: rows(4,
            shared: BatteryDraft(
                userBatteryId: 'shared',
                icon: IconSelection(
                    source: IconSource.custom,
                    key: icon.id.value,
                    color: IconColor.blue)))));
    expect(
        (await batteries.list()).every((b) =>
            b.values.icon.key == icon.id.value &&
            b.values.icon.color == IconColor.blue),
        isTrue);
  });
  test('eight Batteries split into two new Sets with one independent Batch',
      () async {
    final preview = rows(8,
        shared:
            const BatteryDraft(userBatteryId: 'shared', batchCode: 'Batch'));
    final result = await repo.save(BulkRequest(rows: [
      for (var i = 0; i < 8; i++)
        BulkRow(preview[i].battery, newSet: i < 4 ? 'first' : 'second')
    ], newSets: {
      'first': const SetDraft(userSetId: 'SET-001', name: 'First'),
      'second': const SetDraft(userSetId: 'SET-002', name: 'Second')
    }));
    expect(result.sets.toSet(), hasLength(2));
    for (final id in result.sets) {
      expect((await sets.get(id)).members, hasLength(4));
    }
    expect(await db.select(db.batterySetMemberships).get(), hasLength(8));
    expect(await db.select(db.batteryBatches).get(), hasLength(1));
  });
  test(
      'existing Set membership and compatibility acknowledgment are transactional',
      () async {
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Existing'));
    final b = await batteries.save(const BatteryDraft(
        userBatteryId: 'Old', capacity: 1000, capacityUnit: 'mAh'));
    await sets.addMember(s.id, b.id);
    final request = BulkRequest(rows: [
      BulkRow(
          const BatteryDraft(
              userBatteryId: 'New', capacity: 2000, capacityUnit: 'mAh'),
          existingSet: s.id)
    ]);
    Set<String> warnings = {};
    try {
      await repo.save(request);
      fail('Expected warning');
    } on SetWarnings catch (e) {
      warnings = e.messages;
    }
    expect(await batteries.list(), hasLength(1));
    await repo.save(request, acceptedWarnings: warnings);
    expect((await sets.get(s.id)).members, hasLength(2));
  });
  test(
      'injected failure rolls back Batteries Batch Sets tags membership and history',
      () async {
    await db.customStatement(
        "CREATE TRIGGER reject_second BEFORE INSERT ON batteries WHEN (SELECT COUNT(*) FROM batteries)=1 BEGIN SELECT RAISE(ABORT,'injected'); END");
    await expectLater(
        repo.save(BulkRequest(
            rows: rows(4,
                    shared: const BatteryDraft(
                        userBatteryId: 'shared', batchCode: 'Batch'))
                .map((r) => BulkRow(r.battery, newSet: 's'))
                .toList(),
            newSets: {'s': const SetDraft(userSetId: 'S', name: 'Set')},
            tags: ['Test'])),
        throwsA(isA<Exception>()));
    for (final table in [
      'batteries',
      'battery_batches',
      'battery_sets',
      'battery_set_memberships',
      'tags',
      'battery_tags',
      'activity_log'
    ]) {
      expect(
          (await db
                  .customSelect('SELECT COUNT(*) AS n FROM ' + table)
                  .getSingle())
              .read<int>('n'),
          0,
          reason: table);
    }
  });
  test('membership failure rolls back already created Batteries and Set',
      () async {
    await db.customStatement(
        "CREATE TRIGGER reject_members BEFORE INSERT ON battery_set_memberships BEGIN SELECT RAISE(ABORT,'injected'); END");
    await expectLater(
        repo.save(BulkRequest(
            rows: [BulkRow(rows(1).single.battery, newSet: 's')],
            newSets: {'s': const SetDraft(userSetId: 'S', name: 'Set')})),
        throwsA(isA<Exception>()));
    expect(await batteries.list(), isEmpty);
    expect(await sets.list(), isEmpty);
  });
  test('bulk UUIDs Batch Sets and values survive SQLite restart', () async {
    await db.close();
    final root = await Directory.systemTemp.createTemp('bulk-restart-');
    final file = File(root.path + '/data.sqlite');
    try {
      bind(AppDatabase.forTesting(NativeDatabase(file)));
      final result = await repo.save(BulkRequest(
          rows: rows(4,
                  shared: const BatteryDraft(
                      userBatteryId: 'shared', batchCode: 'Batch'))
              .map((r) => BulkRow(r.battery, newSet: 's'))
              .toList(),
          newSets: {'s': const SetDraft(userSetId: 'S', name: 'Set')}));
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase(file)));
      expect((await batteries.list()).map((b) => b.id).toSet(),
          result.batteries.toSet());
      expect((await sets.get(result.sets.single)).members, hasLength(4));
      expect(
          (await batteries.list()).every((b) => b.values.batchCode == 'Batch'),
          isTrue);
    } finally {
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase.memory()));
      await root.delete(recursive: true);
    }
  });
}
