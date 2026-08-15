import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../domain/battery_type.dart';
import '../domain/battery_type_draft.dart';
import '../domain/battery_type_repository.dart';

enum BatteryTypeStatusFilter { active, inactive, all }

final class BatteryTypeCatalogRefreshWarning implements Exception {
  const BatteryTypeCatalogRefreshWarning({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;
}

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
    return _commitMutation(() => _repository.create(draft));
  }

  Future<BatteryTypeRecord> updateBatteryType(
    PermanentId id,
    BatteryTypeDraft draft,
  ) async {
    return _commitMutation(() => _repository.update(id, draft));
  }

  Future<BatteryTypeRecord> deactivate(PermanentId id) async {
    return _commitMutation(
      () => _repository.deactivate(id),
      invalidateUsageFor: id,
    );
  }

  Future<BatteryTypeRecord> reactivate(PermanentId id) async {
    return _commitMutation(
      () => _repository.reactivate(id),
      invalidateUsageFor: id,
    );
  }

  BatteryTypeRepository get _repository =>
      ref.read(batteryTypeRepositoryProvider);

  Future<BatteryTypeRecord> _commitMutation(
    Future<BatteryTypeRecord> Function() mutation, {
    PermanentId? invalidateUsageFor,
  }) async {
    late final BatteryTypeRecord persisted;
    try {
      persisted = await mutation();
    } on Object catch (error, stackTrace) {
      if (!_isExpectedConflict(error)) {
        rethrow;
      }
      await _bestEffortConflictRefresh();
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (invalidateUsageFor != null) {
      ref.invalidate(batteryTypeUsageProvider(invalidateUsageFor));
    }
    _reconcilePersistedRecord(persisted);
    try {
      await refresh();
    } on Object catch (error, stackTrace) {
      throw BatteryTypeCatalogRefreshWarning(
        error: error,
        stackTrace: stackTrace,
      );
    }
    return persisted;
  }

  bool _isExpectedConflict(Object error) =>
      error is BatteryTypeNameConflictException ||
      error is BatteryTypeReactivationConflictException ||
      error is BatteryTypeStateConflictException ||
      error is BatteryTypeNotFoundException;

  Future<void> _bestEffortConflictRefresh() async {
    try {
      await refresh();
    } on Object {
      // Preserve the original typed conflict for presentation.
    }
  }

  void _reconcilePersistedRecord(BatteryTypeRecord persisted) {
    _records = [
      for (final record in _records)
        if (record.id != persisted.id) record,
      persisted,
    ]..sort(_compareCatalogRecords);
    _selectedId = persisted.id;
    _emit();
  }

  int _compareCatalogRecords(
    BatteryTypeRecord left,
    BatteryTypeRecord right,
  ) {
    if (left.isActive != right.isActive) {
      return left.isActive ? -1 : 1;
    }
    final byName =
        left.typeName.toLowerCase().compareTo(right.typeName.toLowerCase());
    return byName != 0 ? byName : left.id.value.compareTo(right.id.value);
  }

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
