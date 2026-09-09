import 'dart:io';

import 'package:flutter/material.dart';

import 'app/app_bootstrap.dart';
import 'app/battery_tracker_root.dart';
import 'core/configuration/app_configuration.dart';
import 'core/theme/app_theme.dart';
import 'services/app_data_directory_service.dart';
import 'services/executable_relative_app_data_directory_service.dart';
import 'services/path_provider_app_data_directory_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Windows runs as a portable deployment: the executable and its data
  // ("My Battery Data") travel together, for example on a USB drive. Other
  // platforms keep the per-user application-support location, since a
  // writable folder next to the binary is not a meaningful concept inside
  // an Android/iOS/macOS app bundle.
  final AppDataDirectoryService appDataDirectoryService = Platform.isWindows
      ? const ExecutableRelativeAppDataDirectoryService()
      : const PathProviderAppDataDirectoryService();

  Future<AppDependencies> bootstrap() => AppBootstrap.start(
        configuration: AppConfiguration.production,
        appDataDirectoryService: appDataDirectoryService,
      );

  try {
    final dependencies = await bootstrap();
    runApp(
        BatteryTrackerRoot(dependencies: dependencies, bootstrap: bootstrap));
  } on Object catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'battery_tracker/bootstrap',
      ),
    );
    runApp(const _BootstrapFailureApp());
  }
}

class _BootstrapFailureApp extends StatelessWidget {
  const _BootstrapFailureApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 52),
                SizedBox(height: 16),
                Text(
                  'Battery Tracker could not start.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Close the application and try again. Technical details '
                  'were recorded for troubleshooting.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
