import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'app_data_directory_service.dart';

final class PathProviderAppDataDirectoryService
    implements AppDataDirectoryService {
  const PathProviderAppDataDirectoryService();

  @override
  Future<Uri> getApplicationSupportRoot() async {
    final platformSupport = await getApplicationSupportDirectory();
    final root = Directory.fromUri(
      platformSupport.uri.resolve('BatteryTracker/'),
    );
    await root.create(recursive: true);
    return root.uri;
  }
}
