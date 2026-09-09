import 'dart:io';

import 'package:battery_tracker/services/executable_relative_app_data_directory_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Uses a unique throwaway folder name (rather than the real default,
  // "My Battery Data") so the test cannot collide with a real portable
  // deployment's data and always cleans up after itself, regardless of
  // where the test binary itself happens to be running from.
  test('resolves and creates a sibling folder next to the running executable',
      () async {
    final folderName =
        'battery_tracker_test_${DateTime.now().microsecondsSinceEpoch}';
    final service =
        ExecutableRelativeAppDataDirectoryService(folderName: folderName);
    final executableDirectory = File(Platform.resolvedExecutable).parent;
    final expected = Directory(
        '${executableDirectory.path}${Platform.pathSeparator}$folderName');
    addTearDown(() async {
      if (await expected.exists()) await expected.delete(recursive: true);
    });

    final root = await service.getApplicationSupportRoot();

    // Directory.uri appends a trailing separator; compare with it stripped
    // so this only asserts on the meaningful path, not that formatting.
    final resolvedPath = Directory.fromUri(root).path;
    expect(
        resolvedPath.endsWith(Platform.pathSeparator)
            ? resolvedPath.substring(0, resolvedPath.length - 1)
            : resolvedPath,
        expected.path);
    expect(await Directory.fromUri(root).exists(), isTrue);
  });

  test('is safe to call repeatedly without failing on an existing folder',
      () async {
    final folderName =
        'battery_tracker_test_${DateTime.now().microsecondsSinceEpoch}';
    final service =
        ExecutableRelativeAppDataDirectoryService(folderName: folderName);
    addTearDown(() async {
      final executableDirectory = File(Platform.resolvedExecutable).parent;
      final dir = Directory(
          '${executableDirectory.path}${Platform.pathSeparator}$folderName');
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    final first = await service.getApplicationSupportRoot();
    final second = await service.getApplicationSupportRoot();

    expect(second, first);
  });

  test('defaults to a folder named "My Battery Data"', () {
    const service = ExecutableRelativeAppDataDirectoryService();
    expect(service.folderName, 'My Battery Data');
  });
}
