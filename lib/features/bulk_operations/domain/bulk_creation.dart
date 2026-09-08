import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../battery_sets/domain/battery_set.dart';

final class BulkValidationException implements Exception {
  const BulkValidationException(this.message);
  final String message;
}

final class BulkRow {
  const BulkRow(this.battery, {this.existingSet, this.newSet});
  final BatteryDraft battery;
  final PermanentId? existingSet;
  final String? newSet;
}

final class BulkRequest {
  BulkRequest(
      {required List<BulkRow> rows,
      Map<String, SetDraft> newSets = const {},
      List<String> tags = const []})
      : rows = List.unmodifiable(rows),
        newSets = Map.unmodifiable(newSets),
        tags = List.unmodifiable(tags);
  final List<BulkRow> rows;
  final Map<String, SetDraft> newSets;
  final List<String> tags;
}

final class BulkResult {
  const BulkResult(this.batteries, this.sets);
  final List<PermanentId> batteries, sets;
}

abstract interface class BulkCreationRepository {
  Future<Set<String>> existingIds();
  Future<BulkResult> save(BulkRequest request,
      {Set<String> acceptedWarnings = const {}});
}

final class BulkIds {
  static List<String> generate(
      {required String prefix,
      required String separator,
      required int start,
      required int padding,
      required int quantity,
      Set<String> existing = const {},
      bool nextAvailable = false}) {
    if (quantity < 1 ||
        quantity > 1000 ||
        start < 0 ||
        padding < 0 ||
        padding > 12 ||
        start > 999999999999 - quantity) {
      throw const BulkValidationException(
          'Use quantity 1–1000, a nonnegative starting number up to 999999998999, and padding 0–12.');
    }
    final reserved = existing.map((s) => s.trim().toLowerCase()).toSet();
    final result = <String>[];
    var number = start;
    while (result.length < quantity) {
      if (number > 999999999999)
        throw const BulkValidationException(
            'No IDs remain in the supported numeric range.');
      final id =
          prefix.trim() + separator + number.toString().padLeft(padding, '0');
      number++;
      if (!nextAvailable || !reserved.contains(id.toLowerCase()))
        result.add(id);
    }
    return result;
  }

  static Set<String> duplicates(List<BulkRow> rows, Set<String> existing) {
    final seen = existing.map((s) => s.trim().toLowerCase()).toSet(),
        bad = <String>{};
    for (final row in rows) {
      final id = row.battery.userBatteryId.trim();
      if (!seen.add(id.toLowerCase())) bad.add(id);
    }
    return bad;
  }
}

BatteryDraft bulkCopy(BatteryDraft v,
        {String? id, double? total, double? per}) =>
    BatteryDraft(
        userBatteryId: id ?? v.userBatteryId,
        name: v.name,
        batteryTypeId: v.batteryTypeId,
        batchCode: v.batchCode,
        manufacturer: v.manufacturer,
        model: v.model,
        serialNumber: v.serialNumber,
        customLabel: v.customLabel,
        chemistry: v.chemistry,
        nominalVoltage: v.nominalVoltage,
        capacity: v.capacity,
        capacityUnit: v.capacityUnit,
        rechargeable: v.rechargeable,
        purchaseDate: v.purchaseDate,
        purchaseLocation: v.purchaseLocation,
        purchasePrice: v.purchasePrice,
        totalPackagePrice: total ?? v.totalPackagePrice,
        perBatteryPrice: per ?? v.perBatteryPrice,
        warrantyExpiration: v.warrantyExpiration,
        status: v.status,
        condition: v.condition,
        conditionNote: v.conditionNote,
        notes: v.notes,
        icon: v.icon);
