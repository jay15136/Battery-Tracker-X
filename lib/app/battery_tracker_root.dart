import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'app_bootstrap.dart';
import 'app_providers.dart';
import 'battery_tracker_app.dart';

/// Rebuilds the entire application dependency graph in place, without
/// restarting the process. Used after a backup restore replaces the live
/// database, photos, and custom icons on disk.
abstract interface class AppLifecycle {
  Future<void> reload();
}

final appLifecycleProvider = Provider<AppLifecycle>(
    (ref) => throw StateError('AppLifecycle was not configured at startup.'));

class BatteryTrackerRoot extends StatefulWidget {
  const BatteryTrackerRoot({
    required this.dependencies,
    required this.bootstrap,
    super.key,
  });

  final AppDependencies dependencies;

  /// Rebuilds a fresh [AppDependencies] graph pointed at the same
  /// application-managed storage location used at startup.
  final Future<AppDependencies> Function() bootstrap;

  @override
  State<BatteryTrackerRoot> createState() => _BatteryTrackerRootState();
}

class _BatteryTrackerRootState extends State<BatteryTrackerRoot>
    implements AppLifecycle {
  late AppDependencies _dependencies = widget.dependencies;

  @override
  Future<void> reload() async {
    // Close the current state before rebuilding a new one. The production
    // database connection is registered under a fixed name through
    // dart:isolate's IsolateNameServer (see drift_flutter); leaving the
    // prior connection open while opening a new one under that same name
    // can hang or reconnect to the wrong database, so the old state must be
    // fully torn down first.
    try {
      await _dependencies.close();
    } on Object catch (error, stack) {
      // The previous database connection may already be closed by the
      // operation that triggered this reload (for example, a completed
      // restore). Closing it again is expected to be harmless; log and
      // continue rather than surfacing a spurious failure.
      Logger('battery_tracker.lifecycle').warning(
          'Prior application state could not be closed cleanly.', error, stack);
    }
    final next = await widget.bootstrap();
    if (!mounted) {
      await next.close();
      return;
    }
    setState(() => _dependencies = next);
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = _dependencies;
    return ProviderScope(
      overrides: [
        appLifecycleProvider.overrideWithValue(this),
        dashboardRepositoryProvider
            .overrideWithValue(dependencies.dashboardRepository),
        historyRepositoryProvider
            .overrideWithValue(dependencies.historyRepository),
        backupRepositoryProvider
            .overrideWithValue(dependencies.backupRepository),
        importExportRepositoryProvider
            .overrideWithValue(dependencies.importExportRepository),
        labelRepositoryProvider.overrideWithValue(dependencies.labelRepository),
        bulkEditRepositoryProvider
            .overrideWithValue(dependencies.bulkEditRepository),
        bulkCreationRepositoryProvider
            .overrideWithValue(dependencies.bulkCreationRepository),
        chargeRepositoryProvider
            .overrideWithValue(dependencies.chargeRepository),
        assignmentRepositoryProvider
            .overrideWithValue(dependencies.assignmentRepository),
        deviceRepositoryProvider
            .overrideWithValue(dependencies.deviceRepository),
        batterySetRepositoryProvider
            .overrideWithValue(dependencies.batterySetRepository),
        photoServiceProvider.overrideWithValue(dependencies.photoService),
        batteryRepositoryProvider
            .overrideWithValue(dependencies.batteryRepository),
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
      // The key forces the widget subtree (and every provider it created)
      // to be torn down and rebuilt fresh after a reload, so no widget can
      // keep holding a reference into the closed prior database.
      child: BatteryTrackerApp(key: ValueKey(dependencies)),
    );
  }

  @override
  void dispose() {
    unawaited(_dependencies.close());
    super.dispose();
  }
}
