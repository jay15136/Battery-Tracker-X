import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../../batteries/domain/battery.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_selection.dart';

final class SetValidationException implements Exception {
  const SetValidationException(this.message);
  final String message;
}

final class SetWarnings implements Exception {
  const SetWarnings(this.messages);
  final Set<String> messages;
}

enum MembershipAction { add, move }

final class SetDraft {
  const SetDraft(
      {required this.userSetId,
      required this.name,
      this.typeId,
      this.description,
      this.notes,
      this.icon = const IconSelection(
          source: IconSource.builtin,
          key: 'battery_set_generic',
          color: IconColor.defaultColor)});
  final String userSetId, name;
  final PermanentId? typeId;
  final String? description, notes;
  final IconSelection icon;
  void validate() {
    if (userSetId.trim().isEmpty || name.trim().isEmpty)
      throw const SetValidationException('Enter a Set ID and name.');
  }
}

final class SetMembership {
  const SetMembership(
      {required this.batteryId,
      required this.batteryLabel,
      required this.addedAt,
      required this.removedAt,
      required this.notes});
  final PermanentId batteryId;
  final String batteryLabel;
  final DateTime addedAt;
  final DateTime? removedAt;
  final String? notes;
}

final class SetAssignment {
  const SetAssignment(
      {required this.deviceName,
      required this.assignedAt,
      required this.removedAt,
      required this.notes});
  final String deviceName;
  final DateTime assignedAt;
  final DateTime? removedAt;
  final String? notes;
}

final class SetRecord {
  const SetRecord(
      {required this.id,
      required this.values,
      required this.createdAt,
      required this.active,
      required this.members,
      required this.membershipHistory,
      required this.assignments,
      required this.recordedCharges,
      required this.lastCharged,
      this.typeName,
      this.activityHistory = const [],
      this.primaryPhotoPath});
  final List<String> activityHistory;
  final String? typeName;
  final PermanentId id;
  final SetDraft values;
  final DateTime createdAt;
  final bool active;
  final List<BatteryRecord> members;
  final List<SetMembership> membershipHistory;
  final List<SetAssignment> assignments;
  final int recordedCharges;
  final DateTime? lastCharged;
  final ManagedRelativePath? primaryPhotoPath;
  SetAssignment? get currentAssignment {
    for (final a in assignments) {
      if (a.removedAt == null) return a;
    }
    return null;
  }
}

final class SetDevice {
  const SetDevice(
      {required this.id,
      required this.name,
      this.requiredTypeId,
      this.quantity,
      this.voltage});
  final PermanentId id;
  final String name;
  final PermanentId? requiredTypeId;
  final int? quantity;
  final double? voltage;
}

abstract interface class BatterySetRepository {
  Future<List<SetRecord>> list();
  Future<SetRecord> get(PermanentId id);
  Future<SetRecord> save(SetDraft draft, {PermanentId? id});
  Future<String> suggestId({String prefix = 'SET', int start = 1});
  Future<void> setActive(PermanentId id, bool active);
  Future<void> delete(PermanentId id);
  Future<void> addMember(PermanentId setId, PermanentId batteryId,
      {MembershipAction action = MembershipAction.add,
      String? notes,
      Set<String> acceptedWarnings = const {}});
  Future<void> removeMember(PermanentId setId, PermanentId batteryId,
      {String? notes});
  Future<void> markCharged(PermanentId id, {String? notes});
  Future<List<SetDevice>> devices();
  Future<SetDevice> createDevice(String name,
      {PermanentId? requiredTypeId, int? quantity, double? voltage});
  Future<void> assign(PermanentId id, PermanentId deviceId,
      {DateTime? assignedAt,
      String? notes,
      Set<String> acceptedWarnings = const {}});
  Future<void> unassign(PermanentId id, {DateTime? removedAt, String? notes});
}
