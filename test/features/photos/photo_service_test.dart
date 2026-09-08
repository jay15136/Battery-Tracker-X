import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/photos/domain/photo.dart';
import 'package:battery_tracker/features/photos/data/drift_photo_repository.dart';
import 'package:battery_tracker/features/photos/data/local_photo_storage.dart';
import 'package:battery_tracker/features/photos/application/photo_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late AppDatabase db;
  late DriftPhotoRepository repository;
  late LocalPhotoStorage storage;
  late PhotoService service;
  late Uri source;
  late PhotoOwner owner;
  const ids = UuidV4PermanentIdGenerator();
  setUp(() async {
    root = await Directory.systemTemp.createTemp('battery-photos-test-');
    db = AppDatabase.forTesting(
        NativeDatabase(File('${root.path}/test.sqlite')));
    repository = DriftPhotoRepository(db);
    storage = LocalPhotoStorage(root.uri);
    service = PhotoService(
        repository: repository,
        storage: storage,
        logger: Logger('test.photos'));
    source = (await File('android/app/src/main/res/mipmap-mdpi/ic_launcher.png')
            .copy('${root.path}/original.png'))
        .uri;
    owner = PhotoOwner(PhotoOwnerKind.battery, ids.next());
    await db.into(db.batteries).insert(BatteriesCompanion.insert(
        uuid: owner.id.value,
        userBatteryId: 'AA-001',
        iconColor: const Value('#F44336')));
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });
  test(
      'import copies decoded bytes and survives original deletion and DB restart',
      () async {
    await service.add(owner, source);
    final photo = (await repository.gallery(owner)).photos.single;
    expect(photo.file.path.value, startsWith('photos/'));
    expect(photo.file.width, greaterThan(0));
    expect(photo.file.checksum.length, 64);
    await File.fromUri(source).delete();
    await db.close();
    db = AppDatabase.forTesting(
        NativeDatabase(File('${root.path}/test.sqlite')));
    repository = DriftPhotoRepository(db);
    final restored = await repository.gallery(owner);
    expect(restored.preferPhoto, isFalse);
    expect(restored.photos.single.id, photo.id);
    expect(await storage.exists(photo.file.path), isTrue);
  });
  test(
      'explicit photo primary changes retain icon and adding another preserves preference',
      () async {
    await service.add(owner, source);
    var gallery = await repository.gallery(owner);
    expect(gallery.preferPhoto, isFalse);
    expect(gallery.primary, isNotNull);
    await service.usePhoto(owner, gallery.photos.single);
    await service.add(owner, source);
    gallery = await repository.gallery(owner);
    expect(gallery.preferPhoto, isTrue);
    expect(gallery.photos.where((p) => p.isPrimary).length, 1);
    await repository.choosePrimary(owner, gallery.photos.last.id,
        preferPhoto: true);
    final row = (await db.select(db.batteries).get()).single;
    expect(row.iconKey, 'battery_generic');
    expect(row.iconColor, '#F44336');
    expect(row.uuid, owner.id.value);
    await repository.preferIcon(owner);
    expect((await repository.gallery(owner)).preferPhoto, isFalse);
  });
  test('removing primary returns to icon while additional photos remain',
      () async {
    await service.add(owner, source);
    await service.add(owner, source);
    final gallery = await repository.gallery(owner);
    await service.usePhoto(owner, gallery.photos.first);
    await service.remove(owner, gallery.photos.first.id);
    final next = await repository.gallery(owner);
    expect(next.preferPhoto, isFalse);
    expect(next.photos.length, 1);
    expect(await storage.exists(gallery.photos.first.file.path), isFalse);
    expect((await db.select(db.batteries).get()).single.iconColor, '#F44336');
  });
  test('event failure rolls back metadata and cleans copied photo', () async {
    await db.customStatement(
        "CREATE TRIGGER reject_photo BEFORE INSERT ON activity_log BEGIN SELECT RAISE(ABORT,'injected history failure'); END");
    await expectLater(service.add(owner, source), throwsA(isA<Exception>()));
    expect((await repository.gallery(owner)).photos, isEmpty);
    expect(await db.select(db.mediaAssets).get(), isEmpty);
    expect(await Directory.fromUri(root.uri.resolve('photos/')).list().toList(),
        isEmpty);
  });
  test('replace missing photo preserves preference and cleans old metadata',
      () async {
    await service.add(owner, source);
    final old = (await repository.gallery(owner)).photos.single;
    await service.usePhoto(owner, old);
    await storage.delete(old.file.path);
    await expectLater(
        service.usePhoto(owner, old), throwsA(isA<PhotoException>()));
    await service.replace(owner, old.id, source);
    final next = await repository.gallery(owner);
    expect(next.preferPhoto, isTrue);
    expect(next.primary, isNotNull);
    expect(await storage.exists(next.primary!.file.path), isTrue);
    expect((await db.select(db.mediaAssets).get()).length, 1);
  });
  test('cross-owner photo actions are rejected without altering either owner',
      () async {
    final other = PhotoOwner(PhotoOwnerKind.device, ids.next());
    await db
        .into(db.devices)
        .insert(DevicesCompanion.insert(uuid: other.id.value, name: 'Radio'));
    await service.add(owner, source);
    final photo = (await repository.gallery(owner)).photos.single;
    await expectLater(
        repository.remove(other, photo.id), throwsA(isA<PhotoException>()));
    expect((await repository.gallery(owner)).photos.length, 1);
    expect((await repository.gallery(other)).photos, isEmpty);
  });
  for (final kind in [PhotoOwnerKind.batterySet, PhotoOwnerKind.device]) {
    test('${kind.name} supports persisted photo selection and removal',
        () async {
      final target = PhotoOwner(kind, ids.next());
      if (kind == PhotoOwnerKind.batterySet) {
        await db.into(db.batterySets).insert(BatterySetsCompanion.insert(
            uuid: target.id.value, userSetId: 'SET-001', name: 'Pair'));
      } else {
        await db.into(db.devices).insert(
            DevicesCompanion.insert(uuid: target.id.value, name: 'Radio'));
      }
      await service.add(target, source);
      final photo = (await repository.gallery(target)).photos.single;
      await service.usePhoto(target, photo);
      expect((await repository.gallery(target)).preferPhoto, isTrue);
      await service.remove(target, photo.id);
      expect((await repository.gallery(target)).preferPhoto, isFalse);
    });
  }
  test('invalid and truncated files are rejected before persistence', () async {
    final bad = File('${root.path}/bad.png');
    await bad.writeAsString('not an image');
    await expectLater(
        service.add(owner, bad.uri), throwsA(isA<PhotoException>()));
    await bad.writeAsBytes([137, 80, 78, 71, 13, 10, 26, 10]);
    await expectLater(
        service.add(owner, bad.uri), throwsA(isA<PhotoException>()));
    expect((await repository.gallery(owner)).photos, isEmpty);
  });
  test('storage refuses unrelated managed files', () async {
    await expectLater(
        storage.delete(ManagedRelativePath.parse('database/test.sqlite')),
        throwsA(isA<PhotoException>()));
    expect(await File('${root.path}/test.sqlite').exists(), isTrue);
  });
}
