import 'dart:collection';

final class DatabaseMigration {
  const DatabaseMigration({required this.version, required this.name});

  final int version;
  final String name;
}

/// Ordered migration metadata shared by production and migration tests.
final class MigrationRegistry {
  MigrationRegistry(Iterable<DatabaseMigration> migrations)
      : _migrations = List<DatabaseMigration>.unmodifiable(migrations) {
    for (var index = 0; index < _migrations.length; index++) {
      final expectedVersion = index + 1;
      final migration = _migrations[index];
      if (migration.version != expectedVersion ||
          migration.name.trim().isEmpty) {
        throw StateError(
          'Migration $expectedVersion must exist and have a non-empty name.',
        );
      }
    }
  }

  final List<DatabaseMigration> _migrations;

  UnmodifiableListView<DatabaseMigration> get migrations =>
      UnmodifiableListView(_migrations);

  int get currentVersion => _migrations.isEmpty ? 0 : _migrations.last.version;
}
