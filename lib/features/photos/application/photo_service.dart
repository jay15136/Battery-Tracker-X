import 'package:logging/logging.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../domain/photo.dart';

/// Coordinates database transactions and compensating file cleanup.
final class PhotoService {
  const PhotoService(
      {required this.repository,
      required this.storage,
      required this.logger,
      this.ids = const UuidV4PermanentIdGenerator()});
  final PhotoRepository repository;
  final PhotoStorage storage;
  final Logger logger;
  final PermanentIdGenerator ids;
  Future<PermanentId> add(PhotoOwner owner, Uri source) async {
    final id = ids.next();
    final file = await storage.import(source, id);
    try {
      await repository.add(owner, id, file);
    } on Object {
      await _cleanup(file.path);
      rethrow;
    }
    return id;
  }

  Future<void> replace(PhotoOwner owner, PermanentId photo, Uri source) async {
    final file = await storage.import(source, ids.next());
    ManagedRelativePath? old;
    try {
      old = await repository.replace(owner, photo, file);
    } on Object {
      await _cleanup(file.path);
      rethrow;
    }
    if (old != null) await _cleanup(old);
  }

  Future<void> remove(PhotoOwner owner, PermanentId photo) async {
    final old = await repository.remove(owner, photo);
    if (old != null) await _cleanup(old);
  }

  Future<void> usePhoto(PhotoOwner owner, PhotoRecord photo) async {
    if (!await storage.exists(photo.file.path))
      throw const PhotoException(
          'This photograph is missing. Replace it or choose another photograph.');
    await repository.choosePrimary(owner, photo.id, preferPhoto: true);
  }

  Future<void> _cleanup(ManagedRelativePath path) async {
    try {
      await storage.delete(path);
    } on Object catch (e, s) {
      logger.warning(
          'Unreferenced photograph cleanup failed: ${path.value}', e, s);
    }
  }
}
