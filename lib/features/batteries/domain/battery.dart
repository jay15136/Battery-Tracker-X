import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';

const batteryStatuses = [
  'Available',
  'Assigned',
  'In Set',
  'Charging',
  'Storage',
  'Needs Attention',
  'Damaged',
  'Retired'
];
const batteryConditions = [
  'New',
  'Excellent',
  'Good',
  'Fair',
  'Poor',
  'Damaged',
  'Retired'
];

final class BatteryValidationException implements Exception {
  const BatteryValidationException(this.message);
  final String message;
}

/// Editable inventory values; permanent identity never belongs to a draft.
final class BatteryDraft {
  const BatteryDraft({
    required this.userBatteryId,
    this.name,
    this.batteryTypeId,
    this.batchCode,
    this.manufacturer,
    this.model,
    this.serialNumber,
    this.customLabel,
    this.chemistry,
    this.nominalVoltage,
    this.capacity,
    this.capacityUnit,
    this.rechargeable = true,
    this.purchaseDate,
    this.purchaseLocation,
    this.purchasePrice,
    this.totalPackagePrice,
    this.perBatteryPrice,
    this.warrantyExpiration,
    this.status = 'Available',
    this.condition = 'New',
    this.conditionNote,
    this.notes,
    this.icon = const IconSelection(
        source: IconSource.builtin,
        key: 'battery_generic',
        color: IconColor.defaultColor),
  });
  final String userBatteryId;
  final PermanentId? batteryTypeId;
  final String? name,
      batchCode,
      manufacturer,
      model,
      serialNumber,
      customLabel,
      chemistry,
      capacityUnit,
      purchaseLocation,
      conditionNote,
      notes;
  final double? nominalVoltage,
      capacity,
      purchasePrice,
      totalPackagePrice,
      perBatteryPrice;
  final bool rechargeable;
  final DateTime? purchaseDate, warrantyExpiration;
  final String status, condition;
  final IconSelection icon;

  void validate() {
    if (userBatteryId.trim().isEmpty) {
      throw const BatteryValidationException('Enter a Battery ID.');
    }
    for (final entry
        in {'Voltage': nominalVoltage, 'Capacity': capacity}.entries) {
      if (entry.value != null &&
          (!entry.value!.isFinite || entry.value! <= 0)) {
        throw BatteryValidationException(
            '${entry.key} must be greater than zero.');
      }
    }
    if ((capacity != null) != ((capacityUnit?.trim().isNotEmpty) ?? false)) {
      throw const BatteryValidationException(
          'Enter both capacity and its unit.');
    }
    for (final price in [purchasePrice, totalPackagePrice, perBatteryPrice]) {
      if (price != null && (!price.isFinite || price < 0)) {
        throw const BatteryValidationException(
            'Prices must be zero or greater.');
      }
    }
    if (!batteryStatuses.contains(status) ||
        !batteryConditions.contains(condition)) {
      throw const BatteryValidationException(
          'Choose a valid status and condition.');
    }
  }
}

final class BatteryRecord {
  const BatteryRecord(
      {required this.id,
      required this.values,
      required this.createdAt,
      required this.modifiedAt,
      this.currentSets = const [],
      this.currentDevices = const [],
      this.recordedCharges = 0,
      this.estimatedChargePercent,
      this.lastCharged,
      this.retiredAt,
      this.retirementReason,
      this.primaryPhotoPath});
  final PermanentId id;
  final BatteryDraft values;
  final DateTime createdAt, modifiedAt;
  final List<String> currentSets, currentDevices;
  final int recordedCharges;
  final int? estimatedChargePercent;
  final DateTime? lastCharged, retiredAt;
  final String? retirementReason;
  final ManagedRelativePath? primaryPhotoPath;
}

abstract interface class BatteryRepository {
  Future<List<BatteryRecord>> list();
  Future<BatteryRecord> get(PermanentId id);
  Future<BatteryRecord> save(BatteryDraft draft, {PermanentId? id});
  Future<String> suggestId(
      {String prefix = 'BAT',
      String separator = '-',
      int start = 1,
      int padding = 3});
  Future<List<String>> history(PermanentId id);
}
