import 'package:file_selector/file_selector.dart';

import 'file_selection_service.dart';

/// Native file-dialog adapter kept outside feature and domain code.
final class FileSelectorFileSelectionService implements FileSelectionService {
  const FileSelectorFileSelectionService();

  @override
  Future<Uri?> chooseOpenFile({
    required List<FileTypeFilter> acceptedTypes,
  }) async {
    final file = await openFile(
      acceptedTypeGroups: acceptedTypes
          .map(
            (filter) => XTypeGroup(
              label: filter.label,
              extensions: filter.extensions,
            ),
          )
          .toList(growable: false),
    );
    return file == null ? null : Uri.file(file.path);
  }

  @override
  Future<Uri?> chooseSaveLocation({
    required String suggestedFileName,
  }) async {
    final location = await getSaveLocation(suggestedName: suggestedFileName);
    return location == null ? null : Uri.file(location.path);
  }
}
