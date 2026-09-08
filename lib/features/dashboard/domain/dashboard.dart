import '../../../core/identity/permanent_id.dart';
import '../../icons/domain/icon_selection.dart';

class AttentionPolicy {
  const AttentionPolicy(
      {this.daysWithoutCharge = 90,
      this.recordedChargeThreshold = 500,
      this.setChargeDifference = 50});
  final int daysWithoutCharge, recordedChargeThreshold, setChargeDifference;
  void validate() {
    if (daysWithoutCharge < 0 ||
        daysWithoutCharge > 36500 ||
        recordedChargeThreshold < 0 ||
        recordedChargeThreshold > 1000000 ||
        setChargeDifference < 0 ||
        setChargeDifference > 1000000) {
      throw const FormatException(
          'Enter whole numbers from 0–36,500 days and 0–1,000,000 Recorded Charges. Zero disables that reminder.');
    }
  }

  Map<String, int> toJson() => {
        'days': daysWithoutCharge,
        'charges': recordedChargeThreshold,
        'difference': setChargeDifference
      };
  factory AttentionPolicy.fromJson(Map<String, dynamic> j) {
    final result = AttentionPolicy(
        daysWithoutCharge: j['days'] as int,
        recordedChargeThreshold: j['charges'] as int,
        setChargeDifference: j['difference'] as int);
    result.validate();
    return result;
  }
}

class AttentionBattery {
  AttentionBattery(
      {required this.id,
      required this.label,
      required this.icon,
      required List<String> reasons})
      : reasons = List.unmodifiable(reasons);
  final PermanentId id;
  final String label;
  final IconSelection icon;
  final List<String> reasons;
}

class DashboardActivity {
  const DashboardActivity(
      {required this.summary,
      required this.at,
      required this.entityType,
      required this.entityId,
      this.entityLabel,
      required this.available});
  final String? entityLabel;
  final String summary, entityType;
  final DateTime at;
  final PermanentId? entityId;
  final bool available;
}

class DashboardSnapshot {
  DashboardSnapshot(
      {required Map<String, int> counts,
      required List<AttentionBattery> attention,
      required List<DashboardActivity> activity,
      required this.policy,
      required this.at})
      : counts = Map.unmodifiable(counts),
        attention = List.unmodifiable(attention),
        activity = List.unmodifiable(activity);
  final Map<String, int> counts;
  final List<AttentionBattery> attention;
  final List<DashboardActivity> activity;
  final AttentionPolicy policy;
  final DateTime at;
}

abstract interface class DashboardRepository {
  Future<DashboardSnapshot> load();
  Stream<DashboardSnapshot> watch();
  Future<void> savePolicy(AttentionPolicy policy);
}
