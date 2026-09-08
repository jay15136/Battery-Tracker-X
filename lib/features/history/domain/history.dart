import '../../../core/identity/permanent_id.dart';

/// Human-facing grouping of `activity_log.event_type` values for the History
/// filter and legend. An event type the app has not catalogued yet is
/// grouped under [other] instead of being hidden, so newly added event types
/// remain visible in History without a code change here.
enum HistoryCategory {
  additions('Additions'),
  statusChanges('Status Changes'),
  assignments('Assignment History'),
  setMembership('Battery Set Membership History'),
  charging('Charge History'),
  retirement('Retirement'),
  qrLabels('QR Label Activity'),
  bulkOperations('Bulk Operations'),
  iconsAndPhotos('Icons and Photographs'),
  other('Other Activity');

  const HistoryCategory(this.label);
  final String label;
}

/// Catalogued `event_type` values grouped by [HistoryCategory]. Values not
/// present here fall back to [HistoryCategory.other].
const Map<HistoryCategory, Set<String>> historyCategoryEventTypes = {
  HistoryCategory.additions: {
    'battery_created',
    'device_created',
    'set_created',
    'battery_type_created',
    'custom_icon_created',
  },
  HistoryCategory.statusChanges: {
    'battery_updated',
    'device_updated',
    'set_updated',
    'battery_type_updated',
    'battery_status_changed',
    'device_deactivated',
    'battery_type_deactivated',
    'set_deactivated',
    'device_deleted',
    'set_deleted',
  },
  HistoryCategory.assignments: {
    'battery_assigned',
    'set_assigned',
    'inventory_assigned',
    'battery_removed_from_device',
    'set_removed_from_device',
    'inventory_removed',
    'assignment_removed',
  },
  HistoryCategory.setMembership: {
    'set_membership_added',
    'set_member_added',
    'set_membership_removed',
    'set_member_removed',
  },
  HistoryCategory.charging: {
    'battery_charged',
    'set_charged',
    'charge_estimate_updated',
  },
  HistoryCategory.retirement: {
    'battery_retired',
  },
  HistoryCategory.qrLabels: {
    'qr_labels_printed',
    'qr_labels_exported',
  },
  HistoryCategory.bulkOperations: {
    'bulk_batteries_created',
    'battery_batch_created',
    'battery_bulk_updated',
    'bulk_set_assignment',
    'bulk_charge_applied',
    'bulk_retirement_applied',
    'csv_batteries_imported',
  },
  HistoryCategory.iconsAndPhotos: {
    'photo_added',
    'photo_removed',
    'photo_replaced',
    'primary_photo_changed',
    'custom_icon_updated',
    'custom_icon_source_replaced',
    'custom_icon_deleted',
    'icon_selection_changed',
  },
};

final Map<String, HistoryCategory> _eventTypeCategory = {
  for (final entry in historyCategoryEventTypes.entries)
    for (final type in entry.value) type: entry.key,
};

HistoryCategory categoryForEventType(String eventType) =>
    _eventTypeCategory[eventType] ?? HistoryCategory.other;

/// A readable fallback label built from a snake_case event type, used when
/// no catalogued category applies.
String labelForEventType(String eventType) => eventType
    .split('_')
    .where((word) => word.isNotEmpty)
    .map((word) => word[0].toUpperCase() + word.substring(1))
    .join(' ');

/// The three entity kinds History can be filtered by, matching the storage
/// values `activity_log.entity_type` uses for inventory records.
enum HistoryEntityType {
  battery('battery', 'Battery'),
  batterySet('battery_set', 'Battery Set'),
  device('device', 'Device');

  const HistoryEntityType(this.storage, this.label);
  final String storage;
  final String label;

  static HistoryEntityType? fromStorage(String value) {
    for (final type in values) {
      if (type.storage == value) return type;
    }
    return null;
  }
}

/// One selectable entity offered by a History entity picker.
final class HistoryEntityOption {
  const HistoryEntityOption({required this.id, required this.label});
  final PermanentId id;
  final String label;
}

/// Restricts History to activity belonging to exactly one Battery, Battery
/// Set, or Device. Entity kinds are mutually exclusive per activity row, so
/// this is a single selection rather than three independent filters.
final class HistoryEntityFilter {
  const HistoryEntityFilter(
      {required this.type, required this.id, required this.label});
  final HistoryEntityType type;
  final PermanentId id;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntityFilter &&
          type == other.type &&
          id == other.id &&
          label == other.label;

  @override
  int get hashCode => Object.hash(type, id, label);
}

/// Combined History query filters: Date, Activity Type, and one optional
/// Battery/Battery Set/Device selection.
final class HistoryFilter {
  const HistoryFilter({this.from, this.to, this.category, this.entity});

  final DateTime? from;
  final DateTime? to;
  final HistoryCategory? category;
  final HistoryEntityFilter? entity;

  bool get isEmpty =>
      from == null && to == null && category == null && entity == null;

  HistoryFilter copyWith({
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
    HistoryCategory? category,
    bool clearCategory = false,
    HistoryEntityFilter? entity,
    bool clearEntity = false,
  }) =>
      HistoryFilter(
        from: clearFrom ? null : (from ?? this.from),
        to: clearTo ? null : (to ?? this.to),
        category: clearCategory ? null : (category ?? this.category),
        entity: clearEntity ? null : (entity ?? this.entity),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryFilter &&
          from == other.from &&
          to == other.to &&
          category == other.category &&
          entity == other.entity;

  @override
  int get hashCode => Object.hash(from, to, category, entity);
}

/// One recorded historical event, resolved against current inventory so the
/// UI can show whether the related record still exists.
final class HistoryEntry {
  const HistoryEntry({
    required this.uuid,
    required this.eventType,
    required this.entityType,
    required this.entityUuid,
    required this.summary,
    required this.occurredAt,
    required this.available,
    this.entityLabel,
    this.operationUuid,
  });

  final String uuid;
  final String eventType;
  final String entityType;
  final String entityUuid;
  final String summary;
  final DateTime occurredAt;
  final bool available;
  final String? entityLabel;
  final String? operationUuid;

  HistoryCategory get category => categoryForEventType(eventType);

  HistoryEntityType? get resolvedEntityType =>
      HistoryEntityType.fromStorage(entityType);

  PermanentId? get entityId {
    try {
      return PermanentId.parse(entityUuid);
    } on FormatException {
      return null;
    }
  }
}

/// A page of matching History entries plus the total matching-row count so
/// the UI can show "N of M" and offer to load more.
final class HistoryResult {
  const HistoryResult(
      {required List<HistoryEntry> entries, required this.totalCount})
      : entries = entries;
  final List<HistoryEntry> entries;
  final int totalCount;
}

abstract interface class HistoryRepository {
  Future<HistoryResult> query(HistoryFilter filter,
      {required int limit, required int offset});

  Stream<HistoryResult> watch(HistoryFilter filter,
      {required int limit, required int offset});

  Future<List<HistoryEntityOption>> entityOptions(HistoryEntityType type);
}
