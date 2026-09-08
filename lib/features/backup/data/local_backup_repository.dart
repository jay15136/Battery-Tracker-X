import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';

import '../../../core/configuration/app_configuration.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/drift_database_service.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../domain/backup.dart';

/// Creates, validates, and restores single-archive Battery Tracker backups.
///
/// A backup contains a `manifest.json`, a consistent SQLite snapshot taken
/// with `VACUUM INTO`, and the application-managed `photos/` and
/// `custom_icons/` directories. Built-in icons, QR label templates,
/// settings, and icon selections/colors already live in SQLite and travel
/// with the database file; nothing else needs to be copied.
final class LocalBackupRepository implements BackupRepository {
  LocalBackupRepository({
    required this.db,
    required this.applicationSupportRoot,
    required this.configuration,
    this.idGenerator = const UuidV4PermanentIdGenerator(),
    DateTime Function()? now,
  }) : now = now ?? DateTime.now {
    // Validation and restore briefly open a second, independent AppDatabase
    // (a throwaway probe, or a short-lived post-restore verification
    // connection) alongside whatever connection the rest of the app holds.
    // They never share a QueryExecutor, so Drift's cross-instance race
    // warning does not apply here.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  final AppDatabase db;
  final Uri applicationSupportRoot;
  final AppConfiguration configuration;
  final PermanentIdGenerator idGenerator;
  final DateTime Function() now;

  static const _photosDir = 'photos';
  static const _customIconsDir = 'custom_icons';
  static const _appVersion = '0.1.0';

  File _resolve(String relative) =>
      File.fromUri(applicationSupportRoot.resolve(relative));
  Directory _resolveDir(String relative) =>
      Directory.fromUri(applicationSupportRoot.resolve(relative));

  @override
  Future<BackupSummary> createBackup(Uri destination) async {
    final staging = await Directory.systemTemp
        .createTemp('battery_tracker_backup_${idGenerator.next().value}_');
    try {
      final databasePath =
          ManagedRelativePath.parse(configuration.databaseRelativePath);
      final stagedDatabase = File(
          '${staging.path}/${databasePath.value.replaceAll('/', Platform.pathSeparator)}');
      await stagedDatabase.parent.create(recursive: true);
      await _snapshotDatabase(stagedDatabase);

      final entries = <BackupManifestEntry>[];
      final archive = Archive();
      await _addFile(archive, entries, databasePath.value, stagedDatabase);
      await _addDirectory(archive, entries, _photosDir);
      await _addDirectory(archive, entries, _customIconsDir);

      final manifest = BackupManifest(
        formatVersion: BackupManifest.currentFormatVersion,
        appVersion: _appVersion,
        schemaVersion: db.schemaVersion,
        createdAt: now().toUtc(),
        entries: entries,
      );
      archive.add(ArchiveFile.bytes(
          'manifest.json', utf8.encode(jsonEncode(_manifestToJson(manifest)))));

      final zipBytes = ZipEncoder().encodeBytes(archive);
      final tempArchive = File('${staging.path}/output.zip');
      await tempArchive.writeAsBytes(zipBytes, flush: true);

      // Validate before replacing anything at the destination.
      final reopened =
          ZipDecoder().decodeBytes(await tempArchive.readAsBytes());
      if (reopened.findFile('manifest.json') == null) {
        throw const BackupValidationException(
            'The backup archive could not be verified after creation.');
      }

      final destinationFile = File.fromUri(destination);
      await destinationFile.parent.create(recursive: true);
      await tempArchive.copy(destinationFile.path);
      return BackupSummary(location: destination, manifest: manifest);
    } finally {
      await staging.delete(recursive: true);
    }
  }

  Future<void> _snapshotDatabase(File destination) async {
    final escaped = destination.path.replaceAll("'", "''");
    await db.customStatement("VACUUM INTO '$escaped'");
  }

  Future<void> _addFile(Archive archive, List<BackupManifestEntry> entries,
      String logicalPath, File file) async {
    if (!await file.exists()) return;
    final bytes = await file.readAsBytes();
    archive.add(ArchiveFile.bytes(logicalPath, bytes));
    entries.add(BackupManifestEntry(
        logicalPath: logicalPath,
        size: bytes.length,
        sha256: sha256.convert(bytes).toString()));
  }

  Future<void> _addDirectory(Archive archive, List<BackupManifestEntry> entries,
      String relativeRoot) async {
    final dir = _resolveDir(relativeRoot);
    if (!await dir.exists()) return;
    final prefixLength = dir.path.length;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final suffix = entity.path
          .substring(prefixLength)
          .replaceAll('\\', '/')
          .replaceFirst(RegExp(r'^/'), '');
      await _addFile(archive, entries, '$relativeRoot/$suffix', entity);
    }
  }

  Map<String, Object?> _manifestToJson(BackupManifest manifest) => {
        'formatVersion': manifest.formatVersion,
        'appVersion': manifest.appVersion,
        'schemaVersion': manifest.schemaVersion,
        'createdAt': manifest.createdAt.toIso8601String(),
        'files': [
          for (final e in manifest.entries)
            {'path': e.logicalPath, 'size': e.size, 'sha256': e.sha256}
        ],
      };

  BackupManifest? _manifestFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final formatVersion = json['formatVersion'];
    final schemaVersion = json['schemaVersion'];
    final appVersion = json['appVersion'];
    final createdAt = json['createdAt'];
    final files = json['files'];
    if (formatVersion is! int ||
        schemaVersion is! int ||
        appVersion is! String ||
        createdAt is! String ||
        files is! List) {
      return null;
    }
    final entries = <BackupManifestEntry>[];
    for (final entry in files) {
      if (entry is! Map<String, dynamic>) return null;
      final path = entry['path'];
      final size = entry['size'];
      final digest = entry['sha256'];
      if (path is! String || size is! int || digest is! String) return null;
      entries.add(
          BackupManifestEntry(logicalPath: path, size: size, sha256: digest));
    }
    DateTime created;
    try {
      created = DateTime.parse(createdAt).toUtc();
    } on FormatException {
      return null;
    }
    return BackupManifest(
        formatVersion: formatVersion,
        appVersion: appVersion,
        schemaVersion: schemaVersion,
        createdAt: created,
        entries: entries);
  }

  /// Decodes and checks [source] without writing anything. Returns the
  /// decoded archive alongside the validation result so [restoreBackup] can
  /// reuse the already-decoded bytes instead of reading the file twice.
  Future<(Archive?, BackupValidationResult)> _decodeAndValidate(
      Uri source) async {
    final file = File.fromUri(source);
    if (!await file.exists()) {
      return (
        null,
        const BackupValidationResult.invalid('The backup file was not found.')
      );
    }
    final Uint8List bytes;
    Archive archive;
    try {
      bytes = await file.readAsBytes();
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      return (
        null,
        const BackupValidationResult.invalid(
            'This file is not a readable ZIP archive.')
      );
    }
    for (final entry in archive) {
      if (_isUnsafeEntryName(entry.name)) {
        return (
          null,
          const BackupValidationResult.invalid(
              'The archive contains an unsafe file path and was rejected.')
        );
      }
    }
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) {
      return (
        null,
        const BackupValidationResult.invalid(
            'The archive is missing manifest.json and is not a valid backup.')
      );
    }
    Object? manifestJson;
    try {
      manifestJson = jsonDecode(utf8.decode(manifestFile.content));
    } on Object {
      return (
        null,
        const BackupValidationResult.invalid('manifest.json is not valid JSON.')
      );
    }
    final manifest = _manifestFromJson(manifestJson);
    if (manifest == null) {
      return (
        null,
        const BackupValidationResult.invalid(
            'manifest.json is missing required fields.')
      );
    }
    if (manifest.formatVersion > BackupManifest.currentFormatVersion) {
      return (
        null,
        const BackupValidationResult.invalid(
            'This backup was created by a newer version of Battery Tracker '
            'and cannot be restored here.')
      );
    }
    for (final expected in manifest.entries) {
      final actual = archive.findFile(expected.logicalPath);
      if (actual == null) {
        return (
          null,
          BackupValidationResult.invalid(
              'The archive is missing ${expected.logicalPath}.')
        );
      }
      final content = actual.content;
      if (content.length != expected.size) {
        return (
          null,
          BackupValidationResult.invalid(
              '${expected.logicalPath} size does not match the manifest.')
        );
      }
      if (sha256.convert(content).toString() != expected.sha256) {
        return (
          null,
          BackupValidationResult.invalid(
              '${expected.logicalPath} failed checksum verification.')
        );
      }
    }
    final databasePath =
        ManagedRelativePath.parse(configuration.databaseRelativePath).value;
    final databaseEntry = archive.findFile(databasePath);
    if (databaseEntry == null) {
      return (
        null,
        const BackupValidationResult.invalid(
            'The archive does not contain a database file.')
      );
    }
    final probe = await Directory.systemTemp.createTemp(
        'battery_tracker_backup_probe_${idGenerator.next().value}_');
    try {
      final probeFile = File('${probe.path}/probe.sqlite');
      await probeFile.writeAsBytes(databaseEntry.content);
      final probeDb = AppDatabase.forTesting(NativeDatabase(probeFile));
      try {
        await probeDb
            .customSelect('SELECT count(*) FROM sqlite_master')
            .getSingle();
      } on Object {
        return (
          null,
          const BackupValidationResult.invalid(
              'The database inside this archive could not be opened.')
        );
      } finally {
        await probeDb.close();
      }
    } finally {
      await probe.delete(recursive: true);
    }
    return (archive, BackupValidationResult.valid(manifest));
  }

  bool _isUnsafeEntryName(String name) {
    final normalized = name.replaceAll('\\', '/');
    if (normalized.startsWith('/') ||
        RegExp(r'^[a-zA-Z]:').hasMatch(normalized)) {
      return true;
    }
    return normalized.split('/').contains('..');
  }

  @override
  Future<BackupValidationResult> validateBackup(Uri source) async {
    final (_, result) = await _decodeAndValidate(source);
    return result;
  }

  @override
  Future<void> restoreBackup(Uri source) async {
    final (archive, result) = await _decodeAndValidate(source);
    if (!result.valid || archive == null) {
      throw BackupRestoreException(
          result.reason ?? 'This backup could not be validated.');
    }

    final stagingId = idGenerator.next().value;
    final staging = _resolveDir('backups/restore-staging-$stagingId');
    final recovery = _resolveDir('backups/recovery-$stagingId');
    await staging.create(recursive: true);
    try {
      final databasePath =
          ManagedRelativePath.parse(configuration.databaseRelativePath).value;
      for (final entry in archive) {
        if (!entry.isFile || entry.name == 'manifest.json') continue;
        final target = File(
            '${staging.path}/${entry.name.replaceAll('/', Platform.pathSeparator)}');
        await target.parent.create(recursive: true);
        await target.writeAsBytes(entry.content);
      }

      await db.close();

      await recovery.create(recursive: true);
      await _moveIfExists(_resolve(databasePath), recovery, databasePath);
      await _moveDirIfExists(_resolveDir(_photosDir), recovery, _photosDir);
      await _moveDirIfExists(
          _resolveDir(_customIconsDir), recovery, _customIconsDir);

      await _restoreInto(staging, databasePath, _photosDir, _customIconsDir);

      final restoredDatabaseFile = _resolve(databasePath);
      final verifyDb = AppDatabase(NativeDatabase(restoredDatabaseFile));
      try {
        await DriftDatabaseService(verifyDb).initialize();
      } finally {
        await verifyDb.close();
      }

      await recovery.delete(recursive: true);
    } on Object catch (error) {
      await _rollback(recovery,
          databasePath: configuration.databaseRelativePath);
      throw BackupRestoreException(
          'Restore failed and the previous data was restored: $error');
    } finally {
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  Future<void> _restoreInto(Directory staging, String databasePath,
      String photosDir, String customIconsDir) async {
    final stagedDatabase = File(
        '${staging.path}/${databasePath.replaceAll('/', Platform.pathSeparator)}');
    if (await stagedDatabase.exists()) {
      final liveDatabase = _resolve(databasePath);
      await liveDatabase.parent.create(recursive: true);
      await stagedDatabase.copy(liveDatabase.path);
    }
    for (final dirName in [photosDir, customIconsDir]) {
      final stagedDir = Directory('${staging.path}/$dirName');
      if (!await stagedDir.exists()) continue;
      final liveDir = _resolveDir(dirName);
      await liveDir.create(recursive: true);
      await for (final entity
          in stagedDir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final relative = entity.path.substring(stagedDir.path.length);
        final target = File('${liveDir.path}$relative');
        await target.parent.create(recursive: true);
        await entity.copy(target.path);
      }
    }
  }

  Future<void> _moveIfExists(
      File source, Directory recovery, String logicalPath) async {
    if (!await source.exists()) return;
    final target = File(
        '${recovery.path}/${logicalPath.replaceAll('/', Platform.pathSeparator)}');
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }

  Future<void> _moveDirIfExists(
      Directory source, Directory recovery, String logicalName) async {
    if (!await source.exists()) return;
    final target = Directory('${recovery.path}/$logicalName');
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }

  Future<void> _rollback(Directory recovery,
      {required String databasePath}) async {
    if (!await recovery.exists()) return;
    try {
      final recoveredDatabase = File(
          '${recovery.path}/${databasePath.replaceAll('/', Platform.pathSeparator)}');
      if (await recoveredDatabase.exists()) {
        final liveDatabase = _resolve(databasePath);
        if (await liveDatabase.exists()) await liveDatabase.delete();
        await liveDatabase.parent.create(recursive: true);
        await recoveredDatabase.rename(liveDatabase.path);
      }
      for (final dirName in [_photosDir, _customIconsDir]) {
        final recoveredDir = Directory('${recovery.path}/$dirName');
        if (!await recoveredDir.exists()) continue;
        final liveDir = _resolveDir(dirName);
        if (await liveDir.exists()) await liveDir.delete(recursive: true);
        await recoveredDir.rename(liveDir.path);
      }
    } on Object {
      // The recovery copy is preserved on disk under backups/ for manual
      // recovery even when the automatic rollback itself cannot complete.
    }
  }
}
