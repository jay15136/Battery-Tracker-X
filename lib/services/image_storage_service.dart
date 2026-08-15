import '../core/identity/permanent_id.dart';
import '../core/storage/managed_relative_path.dart';

enum ImageOwnerType { battery, batterySet, device, customIcon }

/// Imports optional images into application-managed storage.
abstract interface class ImageStorageService {
  Future<ManagedRelativePath> importImage({
    required Uri source,
    required ImageOwnerType ownerType,
    required PermanentId ownerId,
  });

  Future<bool> exists(ManagedRelativePath reference);
}
