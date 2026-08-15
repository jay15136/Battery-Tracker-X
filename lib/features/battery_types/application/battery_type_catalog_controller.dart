import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../domain/battery_type.dart';
import '../domain/battery_type_draft.dart';
import '../domain/battery_type_repository.dart';

enum BatteryTypeStatusFilter { active, inactive, all }

final class BatteryTypeCatalogSnapshot {
  const BatteryTypeCatalogSnapshot({
    required this.records,
    required this.visible,
    required this.status,
    required this.query,
    required this.selectedId,
  });

  final List<BatteryTypeRecord> records;
  final List<BatteryTypeRecord> visible;
  final BatteryTypeStatusFilter status;
  final String query;
  final PermanentId? selectedId;
}

final batteryTypeCatalogProvider = AsyncNotifierProvider<
    BatteryTypeCatalogController, BatteryTypeCatalogSnapshot>(
  BatteryTypeCatalogController.new,
);

final batteryTypeUsageProvider =
    FutureProvider.family<BatteryTypeUsage, PermanentId>(
  (ref, id) => ref.watch(batteryTypeRepositoryProvider).usage(id),
);

final class BatteryTypeCatalogController
    extends AsyncNotifier<BatteryTypeCatalogSnapshot> {
  List<BatteryTypeRecord> _records = const [];
  BatteryTypeStatusFilter _status = BatteryTypeStatusFilter.active;
  String _query = '';
  PermanentId? _selectedId;

  @override
  Future<BatteryTypeCatalogSnapshot> build() async {
    _records = await _repository.list(includeInactive: true);
    _reconcileSelection();
    return _snapshot();
  }

  void setQuery(String query) {
    _query = query.trim();
    _emit();
  }

  void setStatus(BatteryTypeStatusFilter status) {
    _status = status;
    _emit();
  }

  void select(PermanentId? id) {
    _selectedId = id;
    _reconcileSelection();
    _emit();
  }

  Future<void> refresh() async {
    final records = await _repository.list(includeInactive: true);
    _records = records;
    _reconcileSelection();
    _emit();
  }

  Future<BatteryTypeRecord> create(BatteryTypeDraft draft) async {
    final created = await _repository.create(draft);
    await refresh();
    _selectedId = created.id;
    _emit();
    return created;
  }

  Future<BatteryTypeRecord> updateBatteryType(
    PermanentId id,
    BatteryTypeDraft draft,
  ) async {
    final updated = await _repository.update(id, draft);
    await refresh();
    _selectedId = updated.id;
    _emit();
    return updated;
  }

  Future<BatteryTypeRecord> deactivate(PermanentId id) async {
    final deactivated = await _repository.deactivate(id);
    ref.invalidate(batteryTypeUsageProvider(id));
    await refresh();
    return deactivated;
  }

  Future<BatteryTypeRecord> reactivate(PermanentId id) async {
    final reactivated = await _repository.reactivate(id);
    ref.invalidate(batteryTypeUsageProvider(id));
    await refresh();
    return reactivated;
  }

  BatteryTypeRepository get _repository =>
      ref.read(batteryTypeRepositoryProvider);

  BatteryTypeCatalogSnapshot _snapshot() {
    final normalizedQuery = _query.toLowerCase();
    final visible = _records.where((record) {
      final matchesStatus = switch (_status) {
        BatteryTypeStatusFilter.active => record.isActive,
        BatteryTypeStatusFilter.inactive => !record.isActive,
        BatteryTypeStatusFilter.all => true,
      };
      return matchesStatus && _matchesQuery(record, normalizedQuery);
    }).toList(growable: false);
    return BatteryTypeCatalogSnapshot(
      records: List.unmodifiable(_records),
      visible: List.unmodifiable(visible),
      status: _status,
      query: _query,
      selectedId: _selectedId,
    );
  }

  bool _matchesQuery(BatteryTypeRecord record, String normalizedQuery) {
    if (normalizedQuery.isEmpty) {
      return true;
    }
    return [
      record.typeName,
      record.chemistry,
      record.physicalSize,
      record.description,
    ].any(
      (value) => value?.toLowerCase().contains(normalizedQuery) ?? false,
    );
  }

  void _reconcileSelection() {
    if (_selectedId != null &&
        !_records.any((record) => record.id == _selectedId)) {
      _selectedId = null;
    }
  }

  void _emit() {
    if (state.hasValue) {
      state = AsyncData(_snapshot());
    }
  }
}
