final class FileTypeFilter {
  const FileTypeFilter({required this.label, required this.extensions});

  final String label;
  final List<String> extensions;
}

/// Native file-dialog boundary shared by desktop and mobile adapters.
abstract interface class FileSelectionService {
  Future<Uri?> chooseOpenFile({required List<FileTypeFilter> acceptedTypes});

  Future<Uri?> chooseSaveLocation({required String suggestedFileName});
}
