import 'dart:io';

import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryRoot;

  setUp(() async {
    temporaryRoot = await Directory.systemTemp.createTemp(
      'battery-tracker-log-test-',
    );
  });

  tearDown(() async {
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  test('writes scoped technical records to managed local storage', () async {
    final service = LocalFileLogService(
      applicationSupportRoot: temporaryRoot.uri,
      logDirectory: ManagedRelativePath.parse('logs'),
      maxFileBytes: 4096,
      retainedFileCount: 2,
    );
    await service.initialize();

    service.logger('database').info('Database opened.');
    await service.close();

    final logFile = File.fromUri(temporaryRoot.uri.resolve(
      'logs/battery_tracker.log',
    ));
    final contents = await logFile.readAsString();
    expect(contents, contains('INFO'));
    expect(contents, contains('battery_tracker.database'));
    expect(contents, contains('Database opened.'));
  });

  test('rotates logs without exceeding the configured retained file count',
      () async {
    final service = LocalFileLogService(
      applicationSupportRoot: temporaryRoot.uri,
      logDirectory: ManagedRelativePath.parse('logs'),
      maxFileBytes: 100,
      retainedFileCount: 2,
    );
    await service.initialize();

    for (var index = 0; index < 8; index++) {
      service.logger('rotation').warning(
            'Rotation record $index with enough content to fill the file.',
          );
    }
    await service.close();

    final logDirectory = Directory.fromUri(
      temporaryRoot.uri.resolve('logs/'),
    );
    final logFiles = await logDirectory
        .list()
        .where((entry) => entry is File && entry.path.endsWith('.log'))
        .toList();

    expect(logFiles, hasLength(2));
  });
}
