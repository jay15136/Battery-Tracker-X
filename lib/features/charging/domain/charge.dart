import '../../../core/identity/permanent_id.dart';

final class ChargeValidationException implements Exception {
  const ChargeValidationException(this.message);
  final String message;
}

final class ChargeDraft {
  const ChargeDraft(
      {required this.chargedAt,
      this.startPercent,
      this.endPercent = 100,
      this.charger,
      this.notes,
      this.updateCurrentEstimate = false});
  final DateTime chargedAt;
  final int? startPercent, endPercent;
  final String? charger, notes;
  final bool updateCurrentEstimate;
  void validate() {
    for (final p in [startPercent, endPercent]) {
      if (p != null && (p < 0 || p > 100))
        throw const ChargeValidationException(
            'Percentages must be whole numbers from 0 to 100.');
    }
    if (startPercent != null &&
        endPercent != null &&
        endPercent! < startPercent!)
      throw const ChargeValidationException(
          'Ending percentage cannot be below starting percentage.');
    if (updateCurrentEstimate && endPercent == null)
      throw const ChargeValidationException(
          'Enter an ending percentage to update the current estimate.');
  }
}

final class RecordedCharge {
  const RecordedCharge(
      {required this.id,
      required this.batteryId,
      required this.batteryLabel,
      required this.chargedAt,
      required this.startPercent,
      required this.endPercent,
      required this.charger,
      required this.notes,
      required this.setId,
      required this.setLabel,
      required this.operationId});
  final PermanentId id, batteryId;
  final PermanentId? setId;
  final String batteryLabel;
  final String? setLabel, charger, notes, operationId;
  final DateTime chargedAt;
  final int? startPercent, endPercent;
}

abstract interface class ChargeRepository {
  Future<List<RecordedCharge>> list(
      {PermanentId? batteryId, PermanentId? setId});
  Future<void> record(ChargeDraft draft,
      {List<PermanentId> batteryIds = const [], PermanentId? setId});
  Future<void> setEstimate(PermanentId batteryId, int? percent);
}
