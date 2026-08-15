import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import 'icon_definition.dart';

final class CustomIconInspection {
  const CustomIconInspection({
    required this.fileType,
    required this.byteSize,
  });

  final IconFileType fileType;
  final int byteSize;
}

final class InvalidCustomIconFileException implements Exception {
  const InvalidCustomIconFileException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class CustomIconStorage {
  Future<CustomIconInspection> inspect(Uri source);

  Future<ManagedRelativePath> copySource({
    required Uri source,
    required PermanentId ownerId,
    required PermanentId revisionId,
  });

  Future<ManagedRelativePath> copyManaged({
    required ManagedRelativePath source,
    required PermanentId ownerId,
    required PermanentId revisionId,
  });

  Future<bool> exists(ManagedRelativePath reference);

  Future<void> delete(ManagedRelativePath reference);
}
