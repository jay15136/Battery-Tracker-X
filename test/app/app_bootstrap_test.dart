import 'dart:io';

import 'package:battery_tracker/app/app_bootstrap.dart';
import 'package:battery_tracker/core/configuration/app_configuration.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/services/app_data_directory_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temporaryRoot;

  setUp(() async {
    temporaryRoot = await Directory.systemTemp.createTemp(
      'battery-tracker-bootstrap-test-',
    );
  });

  tearDown(() async {
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  test('initializes persistent database and logs under application support',
      () async {
    final dependencies = await AppBootstrap.start(
      configuration: const AppConfiguration(
        maxLogFileBytes: 4096,
        retainedLogFileCount: 2,
      ),
      appDataDirectoryService: _FixedAppDataDirectoryService(
        temporaryRoot.uri,
      ),
    );

    expect(
      File.fromUri(
        temporaryRoot.uri.resolve('database/battery_tracker.sqlite'),
      ).existsSync(),
      isTrue,
    );
    expect(dependencies.databaseService.migrations.currentVersion, 1);
    final iconCategories = await dependencies.iconRepository.listCategories();
    expect(iconCategories, hasLength(4));
    expect(
      iconCategories.map((category) => category.scope).toSet(),
      containsAll(IconScope.values),
    );
    dependencies.logService.logger('bootstrap_test').info('Ready.');

    await dependencies.close();

    final logContents = await File.fromUri(
      temporaryRoot.uri.resolve('logs/battery_tracker.log'),
    ).readAsString();
    expect(logContents, contains('Battery Tracker initialized.'));
    expect(logContents, contains('Ready.'));
  });
}

final class _FixedAppDataDirectoryService implements AppDataDirectoryService {
  const _FixedAppDataDirectoryService(this.root);

  final Uri root;

  @override
  Future<Uri> getApplicationSupportRoot() async => root;
}
