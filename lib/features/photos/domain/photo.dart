import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';

enum PhotoOwnerKind { battery, batterySet, device }

final class PhotoOwner {
  const PhotoOwner(this.kind, this.id);
  final PhotoOwnerKind kind;
  final PermanentId id;
  @override
  bool operator ==(Object other) =>
      other is PhotoOwner && kind == other.kind && id == other.id;
  @override
  int get hashCode => Object.hash(kind, id);
}

final class PhotoException implements Exception {
  const PhotoException(this.message);
  final String message;
}

final class StoredPhoto {
  const StoredPhoto(
      {required this.path,
      required this.filename,
      required this.mimeType,
      required this.byteSize,
      required this.width,
      required this.height,
      required this.checksum});
  final ManagedRelativePath path;
  final String filename, mimeType, checksum;
  final int byteSize, width, height;
}

final class PhotoRecord {
  const PhotoRecord(
      {required this.id, required this.file, required this.isPrimary});
  final PermanentId id;
  final StoredPhoto file;
  final bool isPrimary;
}

final class PhotoGallery {
  const PhotoGallery({required this.photos, required this.preferPhoto});
  final List<PhotoRecord> photos;
  final bool preferPhoto;
  PhotoRecord? get primary {
    for (final photo in photos) {
      if (photo.isPrimary) return photo;
    }
    return null;
  }
}

abstract interface class PhotoStorage {
  Future<StoredPhoto> import(Uri source, PermanentId revisionId);
  Future<bool> exists(ManagedRelativePath path);
  Future<void> delete(ManagedRelativePath path);
}

abstract interface class PhotoRepository {
  Future<PhotoGallery> gallery(PhotoOwner owner);
  Future<void> add(PhotoOwner owner, PermanentId id, StoredPhoto file);
  Future<void> preferIcon(PhotoOwner owner);
  Future<void> choosePrimary(PhotoOwner owner, PermanentId id,
      {required bool preferPhoto});
  Future<ManagedRelativePath?> remove(PhotoOwner owner, PermanentId id);
  Future<ManagedRelativePath?> replace(
      PhotoOwner owner, PermanentId id, StoredPhoto file);
}
