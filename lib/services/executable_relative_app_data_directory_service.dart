import 'dart:io';

import 'app_data_directory_service.dart';

/// Resolves application-managed storage to a fixed-name folder next to the
/// running executable, instead of the platform's per-user profile.
///
/// This supports a portable Windows deployment: the executable and its
/// data travel together, for example on a USB drive. The folder resolves
/// correctly regardless of which drive letter Windows assigns the media on
/// a given machine, because the root is computed from
/// [Platform.resolvedExecutable] at each launch rather than a stored path.
final class ExecutableRelativeAppDataDirectoryService
    implements AppDataDirectoryService {
  const ExecutableRelativeAppDataDirectoryService(
      {this.folderName = 'My Battery Data'});

  /// The sibling folder created next to the executable.
  final String folderName;

  @override
  Future<Uri> getApplicationSupportRoot() async {
    final executableDirectory = File(Platform.resolvedExecutable).parent;
    final root = Directory(
      '${executableDirectory.path}${Platform.pathSeparator}$folderName',
    );
    await root.create(recursive: true);
    return root.uri;
  }
}
