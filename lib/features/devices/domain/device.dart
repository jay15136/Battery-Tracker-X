import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../../batteries/domain/battery.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_selection.dart';

final class DeviceValidationException implements Exception {
  const DeviceValidationException(this.message);
  final String message;
}

final class DeviceDraft {
  const DeviceDraft(
      {required this.name,
      this.category,
      this.manufacturer,
      this.model,
      this.serialNumber,
      this.location,
      this.description,
      this.notes,
      this.requiredTypeId,
      this.quantity,
      this.voltage,
      this.requirementNotes,
      this.icon = const IconSelection(
          source: IconSource.builtin,
          key: 'device_generic',
          color: IconColor.defaultColor)});
  final String name;
  final String? category,
      manufacturer,
      model,
      serialNumber,
      location,
      description,
      notes,
      requirementNotes;
  final PermanentId? requiredTypeId;
  final int? quantity;
  final double? voltage;
  final IconSelection icon;
  void validate() {
    if (name.trim().isEmpty)
      throw const DeviceValidationException('Enter a Device name.');
    if (quantity != null && quantity! <= 0)
      throw const DeviceValidationException(
          'Required quantity must be greater than zero.');
    if (voltage != null && (!voltage!.isFinite || voltage! <= 0))
      throw const DeviceValidationException(
          'Required voltage must be greater than zero.');
  }

  bool get hasRequirements =>
      requiredTypeId != null || quantity != null || voltage != null;
  List<String> assess(Iterable<BatteryRecord> batteries) {
    final members = batteries.toList();
    final warnings = <String>[];
    if (quantity != null && quantity != members.length)
      warnings.add(
          'Requires $quantity Batteries; ${members.length} currently assigned.');
    for (final b in members) {
      if (requiredTypeId != null && b.values.batteryTypeId != requiredTypeId)
        warnings.add(
            '${b.values.userBatteryId} differs from the required Battery Type.');
      if (voltage != null && b.values.nominalVoltage != voltage)
        warnings.add(
            '${b.values.userBatteryId} differs from the required voltage.');
    }
    return warnings;
  }
}

final class DeviceAssignment {
  const DeviceAssignment(
      {required this.id,
      required this.subjectId,
      required this.label,
      required this.isSet,
      required this.fromSet,
      required this.assignedAt,
      required this.removedAt,
      required this.notes});
  final PermanentId id, subjectId;
  final String label;
  final bool isSet, fromSet;
  final DateTime assignedAt;
  final DateTime? removedAt;
  final String? notes;
}

final class DeviceRecord {
  const DeviceRecord(
      {required this.id,
      required this.values,
      required this.createdAt,
      required this.active,
      required this.assignments,
      required this.batteries,
      required this.activity,
      this.typeName,
      this.photoPath});
  final PermanentId id;
  final DeviceDraft values;
  final DateTime createdAt;
  final bool active;
  final String? typeName;
  final ManagedRelativePath? photoPath;
  final List<DeviceAssignment> assignments;
  final List<BatteryRecord> batteries;
  final List<String> activity;
  List<DeviceAssignment> get currentSets =>
      assignments.where((a) => a.isSet && a.removedAt == null).toList();
  bool get isAssigned => assignments.any((a) => a.removedAt == null);
}

abstract interface class DeviceRepository {
  Future<List<DeviceRecord>> list();
  Future<DeviceRecord> get(PermanentId id);
  Future<DeviceRecord> save(DeviceDraft draft, {PermanentId? id});
  Future<void> setActive(PermanentId id, bool active);
  Future<void> delete(PermanentId id);
}
