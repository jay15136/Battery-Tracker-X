import 'dart:io';

import 'package:battery_tracker/app/app_bootstrap.dart';
import 'package:battery_tracker/core/configuration/app_configuration.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
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

  test('injects a Battery Type repository that persists across restart',
      () async {
    const configuration = AppConfiguration(
      maxLogFileBytes: 4096,
      retainedLogFileCount: 2,
    );
    final directoryService = _FixedAppDataDirectoryService(temporaryRoot.uri);
    final first = await AppBootstrap.start(
      configuration: configuration,
      appDataDirectoryService: directoryService,
    );
    final created = await first.batteryTypeRepository.create(
      const BatteryTypeDraft(
        typeName: '18650 Li-ion',
        description: 'High-output cells',
        chemistry: 'Li-ion',
        defaultVoltage: 3.7,
        defaultCapacity: 3000,
        capacityUnit: 'mAh',
        physicalSize: '18650',
        notes: null,
        suggestedIcon: IconSelection(
          source: IconSource.builtin,
          key: 'battery_18650',
          color: IconColor.orange,
        ),
      ),
    );
    await first.close();

    final reopened = await AppBootstrap.start(
      configuration: configuration,
      appDataDirectoryService: directoryService,
    );
    addTearDown(reopened.close);
    final loaded = await reopened.batteryTypeRepository.get(created.id);

    expect(loaded.id, created.id);
    expect(loaded.typeName, '18650 Li-ion');
  });
}

final class _FixedAppDataDirectoryService implements AppDataDirectoryService {
  const _FixedAppDataDirectoryService(this.root);

  final Uri root;

  @override
  Future<Uri> getApplicationSupportRoot() async => root;
}
