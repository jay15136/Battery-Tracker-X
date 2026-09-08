import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';

enum BulkEditAction {
  type('Battery Type'),
  status('Status'),
  condition('Condition'),
  icon('Icon'),
  color('Icon Color'),
  addSet('Add to Battery Set'),
  removeSet('Remove from Battery Set'),
  tag('Add Tag'),
  note('Add Shared Note'),
  purchaseDate('Purchase Date'),
  purchaseLocation('Purchase Location'),
  purchasePrice('Purchase Price'),
  totalPackagePrice('Total Package Price'),
  perBatteryPrice('Per-Battery Price'),
  warrantyExpiration('Warranty Expiration'),
  retire('Retire Selected Batteries');

  const BulkEditAction(this.label);
  final String label;
}

const retirementReasons = [
  'Capacity loss',
  'Damaged',
  'Age',
  'Replaced',
  'Lost',
  'Other'
];

final class BulkEditRequest {
  BulkEditRequest(
      {required List<PermanentId> ids,
      required this.action,
      this.value,
      this.retirementDate,
      this.reason})
      : ids = List.unmodifiable(ids);
  final List<PermanentId> ids;
  final BulkEditAction action;
  final Object? value;
  final DateTime? retirementDate;
  final String? reason;
}

final class BulkEditRow {
  const BulkEditRow(
      {required this.battery,
      required this.before,
      required this.after,
      required this.signature});
  final BatteryRecord battery;
  final String before, after, signature;
}

final class BulkEditPreview {
  BulkEditPreview(this.request, List<BulkEditRow> rows)
      : rows = List.unmodifiable(rows);
  final BulkEditRequest request;
  final List<BulkEditRow> rows;
}

abstract interface class BulkEditRepository {
  Future<BulkEditPreview> preview(BulkEditRequest request);
  Future<void> apply(BulkEditPreview preview,
      {Set<String> acceptedWarnings = const {}});
}
