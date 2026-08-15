import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_bootstrap.dart';
import 'app_providers.dart';
import 'battery_tracker_app.dart';

class BatteryTrackerRoot extends StatefulWidget {
  const BatteryTrackerRoot({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<BatteryTrackerRoot> createState() => _BatteryTrackerRootState();
}

class _BatteryTrackerRootState extends State<BatteryTrackerRoot> {
  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return ProviderScope(
      overrides: [
        appConfigurationProvider.overrideWithValue(
          dependencies.configuration,
        ),
        databaseServiceProvider.overrideWithValue(
          dependencies.databaseService,
        ),
        appLogServiceProvider.overrideWithValue(dependencies.logService),
        appSettingsRepositoryProvider.overrideWithValue(
          dependencies.settingsRepository,
        ),
        applicationSupportRootProvider.overrideWithValue(
          dependencies.applicationSupportRoot,
        ),
        iconRepositoryProvider.overrideWithValue(
          dependencies.iconRepository,
        ),
        batteryTypeRepositoryProvider.overrideWithValue(
          dependencies.batteryTypeRepository,
        ),
        iconLibraryServiceProvider.overrideWithValue(
          dependencies.iconLibraryService,
        ),
        fileSelectionServiceProvider.overrideWithValue(
          dependencies.fileSelectionService,
        ),
      ],
      child: const BatteryTrackerApp(),
    );
  }

  @override
  void dispose() {
    unawaited(widget.dependencies.close());
    super.dispose();
  }
}
