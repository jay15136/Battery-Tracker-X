import '../storage/managed_relative_path.dart';

/// Immutable runtime configuration shared by production and tests.
final class AppConfiguration {
  const AppConfiguration({
    this.appName = 'Battery Tracker',
    this.version = '0.1.0',
    this.databaseRelativePath = 'database/battery_tracker.sqlite',
    this.logDirectoryRelativePath = 'logs',
    this.maxLogFileBytes = 2 * 1024 * 1024,
    this.retainedLogFileCount = 5,
  });

  static const production = AppConfiguration();

  final String appName;
  final String version;
  final String databaseRelativePath;
  final String logDirectoryRelativePath;
  final int maxLogFileBytes;
  final int retainedLogFileCount;

  /// Rejects configuration that could escape managed storage or disable
  /// bounded log retention.
  void validate() {
    ManagedRelativePath.parse(databaseRelativePath);
    ManagedRelativePath.parse(logDirectoryRelativePath);

    if (maxLogFileBytes <= 0) {
      throw StateError('Maximum log file size must be greater than zero.');
    }
    if (retainedLogFileCount <= 0) {
      throw StateError('At least one log file must be retained.');
    }
  }
}
