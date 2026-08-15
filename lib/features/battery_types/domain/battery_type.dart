import '../../../core/identity/permanent_id.dart';
import '../../icons/domain/icon_selection.dart';

final class BatteryTypeRecord {
  const BatteryTypeRecord({
    required this.id,
    required this.typeName,
    required this.description,
    required this.chemistry,
    required this.defaultVoltage,
    required this.defaultCapacity,
    required this.capacityUnit,
    required this.physicalSize,
    required this.suggestedIcon,
    required this.notes,
    required this.createdAt,
    required this.modifiedAt,
    required this.deactivatedAt,
  });

  final PermanentId id;
  final String typeName;
  final String? description;
  final String? chemistry;
  final double? defaultVoltage;
  final double? defaultCapacity;
  final String? capacityUnit;
  final String? physicalSize;
  final IconSelection suggestedIcon;
  final String? notes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;

  bool get isActive => deactivatedAt == null;
}

final class BatteryTypeUsage {
  const BatteryTypeUsage({
    required this.batteries,
    required this.batterySets,
    required this.devices,
  });

  final int batteries;
  final int batterySets;
  final int devices;

  int get total => batteries + batterySets + devices;
}
