import '../../../core/identity/permanent_id.dart';

final class AssignmentValidationException implements Exception {
  const AssignmentValidationException(this.message);
  final String message;
}

final class AssignmentWarnings implements Exception {
  const AssignmentWarnings(this.messages);
  final Set<String> messages;
}

final class AssignmentRecord {
  const AssignmentRecord(
      {required this.id,
      required this.deviceId,
      required this.deviceName,
      required this.label,
      required this.batteryId,
      required this.setId,
      required this.parentId,
      required this.assignedAt,
      required this.removedAt,
      required this.notes,
      required this.overrideReason,
      required this.memberIds,
      this.removalNotes});
  final PermanentId id, deviceId;
  final PermanentId? batteryId, setId, parentId;
  final String deviceName, label;
  final DateTime assignedAt;
  final DateTime? removedAt;
  final String? notes, overrideReason, removalNotes;
  final List<PermanentId> memberIds;
  Duration durationAt(DateTime now) =>
      (removedAt ?? now).difference(assignedAt);
}

abstract interface class AssignmentRepository {
  Future<List<AssignmentRecord>> list();
  Future<void> assign(
      {required PermanentId deviceId,
      List<PermanentId> batteryIds = const [],
      PermanentId? setId,
      DateTime? assignedAt,
      String? notes,
      Set<String> acceptedWarnings = const {}});
  Future<void> remove(List<PermanentId> assignmentIds,
      {DateTime? removedAt, String? notes});
}
