import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../configuration/app_configuration.dart';
import '../storage/managed_relative_path.dart';

Future<QueryExecutor> createProductionDatabaseExecutor({
  required Uri applicationSupportRoot,
  required AppConfiguration configuration,
}) async {
  final relativePath = ManagedRelativePath.parse(
    configuration.databaseRelativePath,
  );
  final databaseFile = File.fromUri(
    applicationSupportRoot.resolve(relativePath.value),
  );
  await databaseFile.parent.create(recursive: true);
  final temporaryDirectory = Directory.fromUri(
    databaseFile.parent.uri.resolve('tmp/'),
  );
  await temporaryDirectory.create(recursive: true);

  return driftDatabase(
    name: 'battery_tracker',
    native: DriftNativeOptions(
      databasePath: () async => databaseFile.path,
      tempDirectoryPath: () async => temporaryDirectory.path,
    ),
  );
}
