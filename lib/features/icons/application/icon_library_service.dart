import 'package:logging/logging.dart';

import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../domain/custom_icon_storage.dart';
import '../domain/icon_definition.dart';
import '../domain/icon_repository.dart';
import '../domain/icon_selection.dart';

final class IconLibraryService {
  IconLibraryService({
    required this.repository,
    required this.storage,
    required this.idGenerator,
    Logger? logger,
  }) : _logger = logger ?? Logger('battery_tracker.icons');

  final IconRepository repository;
  final CustomIconStorage storage;
  final PermanentIdGenerator idGenerator;
  final Logger _logger;

  Future<void> ensureDefaultCategories() async {
    final existing = await repository.listCategories();
    const defaults = [
      (scope: IconScope.battery, name: 'Batteries'),
      (scope: IconScope.batterySet, name: 'Battery Sets'),
      (scope: IconScope.device, name: 'Devices'),
      (scope: IconScope.general, name: 'General'),
    ];
    for (final category in defaults) {
      final present = existing.any(
        (candidate) =>
            candidate.scope == category.scope &&
            candidate.name.toLowerCase() == category.name.toLowerCase(),
      );
      if (!present) {
        await repository.createCategory(
          id: idGenerator.next(),
          name: category.name,
          scope: category.scope,
        );
      }
    }
  }

  Future<IconCategoryRecord> createCategory({
    required String name,
    required IconScope scope,
  }) {
    return repository.createCategory(
      id: idGenerator.next(),
      name: name,
      scope: scope,
    );
  }

  Future<CustomIconRecord> importCustomIcon({
    required Uri source,
    required String name,
    required PermanentId categoryId,
    required bool supportsColor,
  }) async {
    final iconId = idGenerator.next();
    final revisionId = idGenerator.next();
    final inspection = await storage.inspect(source);
    final managed = await storage.copySource(
      source: source,
      ownerId: iconId,
      revisionId: revisionId,
    );
    try {
      return await repository.createCustomIcon(
        id: iconId,
        name: name,
        categoryId: categoryId,
        relativePath: managed,
        fileType: inspection.fileType,
        supportsColor: supportsColor,
      );
    } on Object catch (error, stackTrace) {
      await _removeAfterFailure(managed, error, stackTrace);
      rethrow;
    }
  }

  Future<CustomIconRecord> replaceSource({
    required PermanentId id,
    required Uri source,
  }) async {
    final existing = await repository.getCustomIcon(id);
    final revisionId = idGenerator.next();
    final inspection = await storage.inspect(source);
    final managed = await storage.copySource(
      source: source,
      ownerId: id,
      revisionId: revisionId,
    );
    try {
      await repository.updateCustomIconSource(
        id: id,
        relativePath: managed,
        fileType: inspection.fileType,
      );
    } on Object catch (error, stackTrace) {
      await _removeAfterFailure(managed, error, stackTrace);
      rethrow;
    }
    await _removeSuperseded(existing.relativePath);
    return repository.getCustomIcon(id);
  }

  Future<CustomIconRecord> duplicate(PermanentId id) async {
    final existing = await repository.getCustomIcon(id);
    final duplicateId = idGenerator.next();
    final revisionId = idGenerator.next();
    final managed = await storage.copyManaged(
      source: existing.relativePath,
      ownerId: duplicateId,
      revisionId: revisionId,
    );
    try {
      return await repository.createCustomIcon(
        id: duplicateId,
        name: '${existing.name} Copy',
        categoryId: existing.category.id,
        relativePath: managed,
        fileType: existing.fileType,
        supportsColor: existing.supportsColor,
      );
    } on Object catch (error, stackTrace) {
      await _removeAfterFailure(managed, error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateMetadata({
    required PermanentId id,
    required String name,
    required PermanentId categoryId,
    required bool supportsColor,
  }) {
    return repository.updateCustomIconMetadata(
      id: id,
      name: name,
      categoryId: categoryId,
      supportsColor: supportsColor,
    );
  }

  Future<void> delete(
    PermanentId id, {
    IconSelection? replacement,
    bool replaceWithDefaults = false,
  }) async {
    final managed = await repository.deactivateCustomIcon(
      id: id,
      replacement: replacement,
      replaceWithDefaults: replaceWithDefaults,
    );
    try {
      await storage.delete(managed);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'An inactive custom icon file could not be removed.',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _removeAfterFailure(
    ManagedRelativePath managed,
    Object cause,
    StackTrace stackTrace,
  ) async {
    try {
      await storage.delete(managed);
    } on Object catch (cleanupError, cleanupStackTrace) {
      _logger.severe(
        'Custom icon import failed and its staged file could not be removed.',
        cleanupError,
        cleanupStackTrace,
      );
      _logger.fine('Original import failure.', cause, stackTrace);
    }
  }

  Future<void> _removeSuperseded(ManagedRelativePath managed) async {
    try {
      await storage.delete(managed);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'A superseded custom icon file could not be removed.',
        error,
        stackTrace,
      );
    }
  }
}
