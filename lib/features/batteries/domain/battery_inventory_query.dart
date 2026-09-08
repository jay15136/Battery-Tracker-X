import '../../battery_types/domain/battery_type.dart';
import 'battery.dart';

/// Inventory search and ordering shared independently of widgets.
abstract final class BatteryInventoryQuery {
  static String typeName(BatteryDraft v, List<BatteryTypeRecord> types) {
    for (final type in types) {
      if (type.id == v.batteryTypeId) return type.typeName;
    }
    return 'No Battery Type';
  }

  static Map<String, List<String>> attributes(
      BatteryRecord record, List<BatteryTypeRecord> types) {
    final v = record.values;
    return {
      'Battery Type': [typeName(v, types)],
      'Manufacturer': [v.manufacturer ?? 'Not specified'],
      'Chemistry': [v.chemistry ?? 'Not specified'],
      'Status': [v.status],
      'Condition': [v.condition],
      'Batch ID': [v.batchCode ?? 'No Batch'],
      'Battery Set':
          record.currentSets.isEmpty ? ['No Set'] : record.currentSets,
      'Device Assignment': record.currentDevices.isEmpty
          ? ['Unassigned']
          : record.currentDevices,
    };
  }

  static List<BatteryRecord> apply(
    List<BatteryRecord> records,
    List<BatteryTypeRecord> types, {
    String search = '',
    Map<String, String?> filters = const {},
    String sort = 'Battery ID',
    bool descending = false,
  }) {
    final query = search.trim().toLowerCase();
    final visible = records.where((r) {
      final v = r.values;
      final a = attributes(r, types);
      return filters.entries.every((e) =>
              e.value == null || (a[e.key]?.contains(e.value) ?? false)) &&
          [
            v.userBatteryId,
            v.name,
            v.manufacturer,
            v.model,
            v.serialNumber,
            v.customLabel,
            v.notes,
            v.batchCode,
            r.id.value,
            ...a.values.expand((v) => v)
          ].any((s) => s?.toLowerCase().contains(query) ?? false);
    }).toList();
    String value(BatteryRecord r) => switch (sort) {
          'Name' => r.values.name ?? '',
          'Status' => r.values.status,
          'Condition' => r.values.condition,
          'Created' => r.createdAt.toIso8601String(),
          _ => r.values.userBatteryId
        };
    visible.sort((a, b) {
      final c = value(a).toLowerCase().compareTo(value(b).toLowerCase());
      return (descending ? -1 : 1) *
          (c == 0 ? a.id.value.compareTo(b.id.value) : c);
    });
    return visible;
  }
}
