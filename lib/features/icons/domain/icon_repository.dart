import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import 'icon_definition.dart';
import 'icon_selection.dart';

final class IconCategoryRecord {
  const IconCategoryRecord({
    required this.id,
    required this.name,
    required this.scope,
    required this.createdAt,
    required this.modifiedAt,
    required this.deactivatedAt,
  });

  final PermanentId id;
  final String name;
  final IconScope scope;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;

  bool get isActive => deactivatedAt == null;
}

final class CustomIconRecord {
  const CustomIconRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.relativePath,
    required this.fileType,
    required this.supportsColor,
    required this.createdAt,
    required this.modifiedAt,
    required this.deactivatedAt,
  });

  final PermanentId id;
  final String name;
  final IconCategoryRecord category;
  final ManagedRelativePath relativePath;
  final IconFileType fileType;
  final bool supportsColor;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;

  IconScope get scope => category.scope;
  bool get isActive => deactivatedAt == null;

  IconDefinition toDefinition() => IconDefinition.custom(
        key: id.value,
        displayName: name,
        scope: scope,
        category: category.name,
        location: relativePath.value,
        fileType: fileType,
        supportsColor: supportsColor,
      );
}

enum IconOwnerType {
  battery('battery', IconScope.battery),
  batterySet('battery_set', IconScope.batterySet),
  device('device', IconScope.device),
  batteryType('battery_type', IconScope.battery);

  const IconOwnerType(this.storageValue, this.scope);

  final String storageValue;
  final IconScope scope;
}

final class IconOwnerReference {
  const IconOwnerReference({required this.type, required this.id});

  final IconOwnerType type;
  final PermanentId id;
}

final class IconUsage {
  const IconUsage({
    required this.batteries,
    required this.batterySets,
    required this.devices,
    required this.batteryTypes,
  });

  final int batteries;
  final int batterySets;
  final int devices;
  final int batteryTypes;

  int get total => batteries + batterySets + devices + batteryTypes;

  Set<IconScope> get scopes => {
        if (batteries > 0 || batteryTypes > 0) IconScope.battery,
        if (batterySets > 0) IconScope.batterySet,
        if (devices > 0) IconScope.device,
      };
}

final class IconInUseException implements Exception {
  const IconInUseException(this.usage);

  final IconUsage usage;

  @override
  String toString() => 'Custom icon is used by ${usage.total} records.';
}

final class CustomIconNotFoundException implements Exception {
  const CustomIconNotFoundException(this.id);

  final PermanentId id;
}

final class IconOwnerNotFoundException implements Exception {
  const IconOwnerNotFoundException(this.owner);

  final IconOwnerReference owner;
}

final class InvalidIconSelectionException implements Exception {
  const InvalidIconSelectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class IconRepository {
  Future<List<IconCategoryRecord>> listCategories({
    IconScope? scope,
    bool includeInactive = false,
  });

  Future<IconCategoryRecord> createCategory({
    required PermanentId id,
    required String name,
    required IconScope scope,
  });

  Future<void> renameCategory(PermanentId id, String name);

  Future<List<CustomIconRecord>> listCustomIcons({
    IconScope? scope,
    bool includeInactive = false,
  });

  Future<CustomIconRecord> getCustomIcon(PermanentId id);

  Future<CustomIconRecord> createCustomIcon({
    required PermanentId id,
    required String name,
    required PermanentId categoryId,
    required ManagedRelativePath relativePath,
    required IconFileType fileType,
    required bool supportsColor,
  });

  Future<void> updateCustomIconMetadata({
    required PermanentId id,
    required String name,
    required PermanentId categoryId,
    required bool supportsColor,
  });

  Future<void> updateCustomIconSource({
    required PermanentId id,
    required ManagedRelativePath relativePath,
    required IconFileType fileType,
  });

  Future<IconUsage> usageCount(PermanentId id);

  Future<void> saveOwnerSelection({
    required IconOwnerReference owner,
    required IconSelection selection,
  });

  Future<List<IconSelection>> recentSelections(IconScope scope);

  Future<ManagedRelativePath> deactivateCustomIcon({
    required PermanentId id,
    IconSelection? replacement,
    bool replaceWithDefaults = false,
  });
}
