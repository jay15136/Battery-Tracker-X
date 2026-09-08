import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/devices/data/drift_device_repository.dart';
import 'package:battery_tracker/features/devices/domain/device.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/qr_labels/data/drift_label_repository.dart';
import 'package:battery_tracker/features/qr_labels/domain/labels.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/photos/data/drift_photo_repository.dart';
import 'package:battery_tracker/features/photos/domain/photo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftDeviceRepository devices;
  late DriftLabelRepository repo;
  void bind(AppDatabase database) {
    db = database;
    final icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    devices = DriftDeviceRepository(db: db, batteries: batteries, icons: icons);
    repo = DriftLabelRepository(
        db: db, batteries: batteries, sets: sets, devices: devices);
  }

  setUp(() => bind(AppDatabase.forTesting(NativeDatabase.memory())));
  tearDown(() => db.close());
  test(
      'label can opt into a photograph without changing icon-first inventory preference',
      () async {
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'Photo'));
    final owner = PhotoOwner(PhotoOwnerKind.battery, b.id);
    final photos = DriftPhotoRepository(db);
    final path = ManagedRelativePath.parse('photos/test.png');
    await photos.add(
        owner,
        const UuidV4PermanentIdGenerator().next(),
        StoredPhoto(
            path: path,
            filename: 'test.png',
            mimeType: 'image/png',
            byteSize: 10,
            width: 10,
            height: 10,
            checksum: 'test'));
    expect((await photos.gallery(owner)).preferPhoto, isFalse);
    expect((await repo.resolve(LabelRef(LabelKind.battery, b.id))).photo, path);
    expect((await photos.gallery(owner)).preferPhoto, isFalse);
  });
  test('whole-Set labels use current membership and exclude removed members',
      () async {
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Kit'));
    final a = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'B'));
    await sets.addMember(s.id, a.id);
    await sets.addMember(s.id, b.id);
    await sets.removeMember(s.id, a.id);
    expect(await repo.setMembers(s.id), [LabelRef(LabelKind.battery, b.id)]);
    expect(
        (await repo.resolve(LabelRef(LabelKind.set, s.id))).fields['members'],
        '1 Batteries');
  });
  test('Battery rename preserves QR lookup and exposes current fields',
      () async {
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'AA-001'));
    final ref = LabelRef(LabelKind.battery, b.id),
        uri = LabelRef(LabelKind.battery, b.id).uri;
    await batteries.save(
        const BatteryDraft(userBatteryId: 'Renamed', manufacturer: 'Acme'),
        id: b.id);
    final found = await repo.resolve(LabelRef.parse(uri.toString()));
    expect(found.ref, ref);
    expect(found.title, 'Renamed');
    expect(found.fields['manufacturer'], 'Acme');
  });
  test('Set and Device lookup preserve their independent permanent identities',
      () async {
    final s = await sets.save(const SetDraft(userSetId: 'SET-1', name: 'Kit'));
    final d = await devices.save(const DeviceDraft(name: 'Radio'));
    final sr = LabelRef(LabelKind.set, s.id),
        dr = LabelRef(LabelKind.device, d.id);
    await sets.save(const SetDraft(userSetId: 'SET-2', name: 'Updated'),
        id: s.id);
    await devices.save(const DeviceDraft(name: 'New radio'), id: d.id);
    expect((await repo.resolve(sr)).title, 'SET-2');
    expect((await repo.resolve(dr)).title, 'New radio');
    expect((await repo.inventory()).map((t) => t.ref).toSet(), {sr, dr});
  });
  test('unknown UUID gives an actionable missing-record result', () async {
    for (final kind in LabelKind.values) {
      await expectLater(
          repo.resolve(
              LabelRef(kind, const UuidV4PermanentIdGenerator().next())),
          throwsA(isA<LabelValidationException>()));
    }
  });
  test('templates and saved selections survive SQLite restart and retain UUIDs',
      () async {
    final root = await Directory.systemTemp.createTemp('labels-restart-');
    try {
      await db.close();
      bind(AppDatabase.forTesting(
          NativeDatabase(File('${root.path}/labels.sqlite'))));
      final b =
          await batteries.save(const BatteryDraft(userBatteryId: 'Persistent'));
      final refs = [LabelRef(LabelKind.battery, b.id)];
      await repo.saveTemplate(
          'Address',
          LabelKind.battery,
          LabelLayout.presets['Address Label Sheet']!,
          const LabelSheet(enabled: true, start: 8));
      final template = (await repo.templates()).single;
      final created =
          (await db.select(db.qrLabelTemplates).get()).single.createdAt;
      await repo.saveTemplate('Updated', LabelKind.battery,
          LabelLayout(customText: 'Test'), const LabelSheet(),
          id: template.id);
      expect((await db.select(db.qrLabelTemplates).get()).single.createdAt,
          created);
      await repo.saveJob('Later', refs, template.layout, template.sheet);
      await db.close();
      bind(AppDatabase.forTesting(
          NativeDatabase(File('${root.path}/labels.sqlite'))));
      final restored = (await repo.templates()).single;
      expect(restored.id, template.id);
      expect(restored.name, 'Updated');
      expect(restored.layout.customText, 'Test');
      final job = (await repo.jobs()).single;
      expect(job.refs, refs);
      expect(job.sheet.start, 8);
      expect((await repo.resolve(job.refs.single)).title, 'Persistent');
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase.memory()));
    } finally {
      await root.delete(recursive: true);
    }
  });
  test(
      'duplicate names and invalid layouts leave templates unchanged; deletion is soft',
      () async {
    await repo.saveTemplate(
        'Label', LabelKind.battery, LabelLayout(), const LabelSheet());
    await expectLater(
        repo.saveTemplate(
            ' label ', LabelKind.device, LabelLayout(), const LabelSheet()),
        throwsA(isA<LabelValidationException>()));
    await expectLater(
        repo.saveTemplate('Broken', LabelKind.device, LabelLayout(qrSize: 1),
            const LabelSheet()),
        throwsA(isA<LabelValidationException>()));
    final saved = (await repo.templates()).single;
    await repo.deactivateTemplate(saved.id);
    expect(await repo.templates(), isEmpty);
    expect((await db.select(db.qrLabelTemplates).get()).single.deactivatedAt,
        isNotNull);
  });
  test('output history keeps each UUID with one shared operation', () async {
    final a = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'B'));
    await repo.recordOutput('qr_labels_exported',
        [LabelRef(LabelKind.battery, a.id), LabelRef(LabelKind.battery, b.id)]);
    final rows = (await db.select(db.activityLog).get())
        .where((r) => r.eventType == 'qr_labels_exported')
        .toList();
    expect(rows.length, 2);
    expect(rows.map((r) => r.operationUuid).toSet().length, 1);
    expect(rows.map((r) => r.entityUuid).toSet(), {a.id.value, b.id.value});
    await expectLater(repo.recordOutput('wrong', []),
        throwsA(isA<LabelValidationException>()));
  });
}
