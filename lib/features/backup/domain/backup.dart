/// A backup archive could not be created, is not a valid Battery Tracker
/// archive, or failed validation before restore was attempted.
final class BackupValidationException implements Exception {
  const BackupValidationException(this.message);
  final String message;
}

/// A validated backup could not be safely restored. The live application
/// state is left untouched or has already been rolled back to its recovery
/// copy by the time this is thrown.
final class BackupRestoreException implements Exception {
  const BackupRestoreException(this.message);
  final String message;
}

/// One file recorded in a backup archive's manifest.
final class BackupManifestEntry {
  const BackupManifestEntry(
      {required this.logicalPath, required this.size, required this.sha256});
  final String logicalPath;
  final int size;
  final String sha256;
}

/// `manifest.json` inside a Battery Tracker backup archive.
final class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.entries,
  });

  /// The current, and only presently understood, archive format version.
  static const currentFormatVersion = 1;

  final int formatVersion;
  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final List<BackupManifestEntry> entries;

  int get totalBytes => entries.fold(0, (sum, e) => sum + e.size);
}

/// Outcome of creating a backup archive.
final class BackupSummary {
  const BackupSummary({required this.location, required this.manifest});
  final Uri location;
  final BackupManifest manifest;
}

/// Outcome of validating a backup archive before restore.
final class BackupValidationResult {
  const BackupValidationResult.valid(BackupManifest manifest)
      : valid = true,
        manifest = manifest,
        reason = null;
  const BackupValidationResult.invalid(String reason)
      : valid = false,
        manifest = null,
        reason = reason;

  final bool valid;
  final BackupManifest? manifest;
  final String? reason;
}

/// Creates, validates, and restores complete application backup archives.
///
/// A backup contains a consistent SQLite database snapshot, Battery/Battery
/// Set/Device photographs, and custom icon files. QR label templates,
/// application settings, icon selections, and icon colors already live
/// inside the database and travel with it automatically. Built-in icons ship
/// with the application and are never copied.
abstract interface class BackupRepository {
  /// Writes a new backup archive to [destination]. Returns before any file
  /// at [destination] is replaced; a partially written archive never
  /// replaces an existing file at that location.
  Future<BackupSummary> createBackup(Uri destination);

  /// Reads and checks [source] without changing any application data.
  Future<BackupValidationResult> validateBackup(Uri source);

  /// Validates [source], then closes the live database, replaces the
  /// current database/photos/custom icons with the archive's contents, and
  /// verifies the result opens cleanly. A recovery copy of the prior state
  /// is kept until the new state is verified, and restored automatically if
  /// any step after validation fails.
  ///
  /// The live database connection this repository was built with is closed
  /// by a successful or failed restore attempt past validation; callers
  /// must rebuild the application's dependency graph afterward rather than
  /// reusing this repository instance.
  Future<void> restoreBackup(Uri source);
}
