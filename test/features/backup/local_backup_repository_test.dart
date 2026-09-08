import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:battery_tracker/core/configuration/app_configuration.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/backup/data/local_backup_repository.dart';
import 'package:battery_tracker/features/backup/domain/backup.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late AppDatabase db;
  late LocalBackupRepository repo;
  const configuration = AppConfiguration.production;
  const ids = UuidV4PermanentIdGenerator();

  File databaseFile() =>
      File('${root.path}/${configuration.databaseRelativePath}');

  Future<void> addBattery(AppDatabase database, String id) =>
      database.into(database.batteries).insert(
          BatteriesCompanion.insert(uuid: ids.next().value, userBatteryId: id));

  setUp(() async {
    root = await Directory.systemTemp.createTemp('battery-backup-test-');
    await databaseFile().parent.create(recursive: true);
    db = AppDatabase.forTesting(NativeDatabase(databaseFile()));
    repo = LocalBackupRepository(
        db: db, applicationSupportRoot: root.uri, configuration: configuration);
  });
  tearDown(() async {
    // A successful restoreBackup already closes db; closing an
    // already-closed connection again is expected to be harmless.
    try {
      await db.close();
    } on Object {
      // Ignore: already closed by a completed restore in this test.
    }
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('createBackup includes the database, photos, and custom icons',
      () async {
    await addBattery(db, 'AA-001');
    await File('${root.path}/photos/pic.png').create(recursive: true);
    await File('${root.path}/photos/pic.png').writeAsBytes([1, 2, 3]);
    await File('${root.path}/custom_icons/owner1/source-rev1.svg')
        .create(recursive: true);
    await File('${root.path}/custom_icons/owner1/source-rev1.svg')
        .writeAsString('<svg></svg>');

    final destination = Uri.file('${root.path}/out/backup.zip');
    final summary = await repo.createBackup(destination);

    expect(File.fromUri(destination).existsSync(), isTrue);
    final paths = summary.manifest.entries.map((e) => e.logicalPath).toSet();
    expect(paths, contains(configuration.databaseRelativePath));
    expect(paths, contains('photos/pic.png'));
    expect(paths, contains('custom_icons/owner1/source-rev1.svg'));
    expect(summary.manifest.schemaVersion, db.schemaVersion);
  });

  test('createBackup succeeds with no photos or custom icons yet', () async {
    final destination = Uri.file('${root.path}/out/backup.zip');
    final summary = await repo.createBackup(destination);
    expect(summary.manifest.entries.map((e) => e.logicalPath),
        [configuration.databaseRelativePath]);
  });

  test('validateBackup accepts a backup this repository created', () async {
    final destination = Uri.file('${root.path}/out/backup.zip');
    await repo.createBackup(destination);
    final result = await repo.validateBackup(destination);
    expect(result.valid, isTrue);
    expect(result.manifest, isNotNull);
  });

  test('validateBackup rejects a missing file', () async {
    final result =
        await repo.validateBackup(Uri.file('${root.path}/nothing.zip'));
    expect(result.valid, isFalse);
    expect(result.reason, contains('not found'));
  });

  test('validateBackup rejects a file that is not a valid archive', () async {
    final bogus = File('${root.path}/bogus.zip');
    await bogus.writeAsString('not a zip file');
    final result = await repo.validateBackup(bogus.uri);
    expect(result.valid, isFalse);
  });

  test('validateBackup rejects an archive missing manifest.json', () async {
    final archive = Archive()
      ..add(ArchiveFile.bytes('database/battery_tracker.sqlite', [1, 2, 3]));
    final bytes = ZipEncoder().encodeBytes(archive);
    final file = File('${root.path}/no-manifest.zip');
    await file.writeAsBytes(bytes);
    final result = await repo.validateBackup(file.uri);
    expect(result.valid, isFalse);
    expect(result.reason, contains('manifest.json'));
  });

  test(
      'validateBackup rejects a tampered file whose checksum no longer matches',
      () async {
    final destination = Uri.file('${root.path}/out/backup.zip');
    await repo.createBackup(destination);
    final original = File.fromUri(destination);
    final archive = ZipDecoder().decodeBytes(await original.readAsBytes());
    final tampered = Archive();
    for (final entry in archive) {
      if (entry.name == configuration.databaseRelativePath) {
        // Same length as the original so this exercises the checksum
        // comparison specifically, not the earlier size comparison.
        final reversed = entry.content.reversed.toList();
        tampered.add(ArchiveFile.bytes(entry.name, reversed));
      } else {
        tampered.add(ArchiveFile.bytes(entry.name, entry.content));
      }
    }
    await original.writeAsBytes(ZipEncoder().encodeBytes(tampered));
    final result = await repo.validateBackup(destination);
    expect(result.valid, isFalse);
    expect(result.reason, contains('checksum'));
  });

  test('validateBackup rejects a path-traversal entry name', () async {
    final archive = Archive()
      ..add(ArchiveFile.bytes(
          'manifest.json',
          utf8.encode(jsonEncode({
            'formatVersion': 1,
            'appVersion': '0.1.0',
            'schemaVersion': db.schemaVersion,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
            'files': []
          }))))
      ..add(ArchiveFile.bytes('../../evil.txt', [1]));
    final file = File('${root.path}/evil.zip');
    await file.writeAsBytes(ZipEncoder().encodeBytes(archive));
    final result = await repo.validateBackup(file.uri);
    expect(result.valid, isFalse);
    expect(result.reason, contains('unsafe'));
  });

  test('restoreBackup replaces the current database and preserves photographs',
      () async {
    await addBattery(db, 'ORIGINAL');
    await File('${root.path}/photos/keep.png').create(recursive: true);
    await File('${root.path}/photos/keep.png').writeAsBytes([9, 9, 9]);
    final destination = Uri.file('${root.path}/out/backup.zip');
    await repo.createBackup(destination);

    await addBattery(db, 'ADDED-AFTER-BACKUP');
    await File('${root.path}/photos/keep.png').delete();

    await repo.restoreBackup(destination);

    final reopened = AppDatabase.forTesting(NativeDatabase(databaseFile()));
    try {
      final ids = await (reopened.select(reopened.batteries)).get();
      expect(ids.map((b) => b.userBatteryId), ['ORIGINAL']);
    } finally {
      await reopened.close();
    }
    expect(await File('${root.path}/photos/keep.png').exists(), isTrue);
    expect(await File('${root.path}/photos/keep.png').readAsBytes(), [9, 9, 9]);
    final recoveryDirs = await Directory('${root.path}/backups')
        .list()
        .where((e) => e.path.contains('recovery-'))
        .toList();
    expect(recoveryDirs, isEmpty,
        reason: 'the recovery copy is deleted after a verified restore');
  });

  test(
      'restoreBackup throws and leaves live data untouched for an invalid backup',
      () async {
    await addBattery(db, 'STAYS');
    final bogus = File('${root.path}/bogus.zip');
    await bogus.writeAsString('not a zip');
    await expectLater(
        repo.restoreBackup(bogus.uri), throwsA(isA<BackupRestoreException>()));
    final ids = await (db.select(db.batteries)).get();
    expect(ids.map((b) => b.userBatteryId), ['STAYS']);
  });
}
