import '../../../core/identity/permanent_id.dart';
import 'battery_type.dart';
import 'battery_type_draft.dart';

final class BatteryTypeNotFoundException implements Exception {
  const BatteryTypeNotFoundException(this.id);

  final PermanentId id;
}

final class BatteryTypeNameConflictException implements Exception {
  const BatteryTypeNameConflictException(this.name);

  final String name;
}

final class BatteryTypeReactivationConflictException implements Exception {
  const BatteryTypeReactivationConflictException(
      {required this.id, required this.name});

  final PermanentId id;
  final String name;
}

final class BatteryTypeStateConflictException implements Exception {
  const BatteryTypeStateConflictException(this.id, this.message);

  final PermanentId id;
  final String message;
}

abstract interface class BatteryTypeRepository {
  Future<List<BatteryTypeRecord>> list({bool includeInactive = false});
  Future<BatteryTypeRecord> get(PermanentId id);
  Future<BatteryTypeRecord> create(BatteryTypeDraft draft);
  Future<BatteryTypeRecord> update(PermanentId id, BatteryTypeDraft draft);
  Future<BatteryTypeUsage> usage(PermanentId id);
  Future<BatteryTypeRecord> deactivate(PermanentId id);
  Future<BatteryTypeRecord> reactivate(PermanentId id);
}
