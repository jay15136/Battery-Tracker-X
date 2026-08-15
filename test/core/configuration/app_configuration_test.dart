import 'package:battery_tracker/core/configuration/app_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfiguration', () {
    test('production configuration uses portable managed paths', () {
      const configuration = AppConfiguration.production;

      expect(configuration.databaseRelativePath,
          'database/battery_tracker.sqlite');
      expect(configuration.logDirectoryRelativePath, 'logs');
      expect(configuration.validate, returnsNormally);
    });

    test('rejects paths that could escape application-managed storage', () {
      const absoluteDatabase = AppConfiguration(
        databaseRelativePath: r'C:\data\battery_tracker.sqlite',
      );
      const traversalLogs = AppConfiguration(
        logDirectoryRelativePath: '../logs',
      );

      expect(absoluteDatabase.validate, throwsFormatException);
      expect(traversalLogs.validate, throwsFormatException);
    });

    test('rejects non-positive bounded logging limits', () {
      const zeroFileSize = AppConfiguration(maxLogFileBytes: 0);
      const zeroRetainedFiles = AppConfiguration(retainedLogFileCount: 0);

      expect(zeroFileSize.validate, throwsStateError);
      expect(zeroRetainedFiles.validate, throwsStateError);
    });
  });
}
