import '../../icons/domain/icon_selection.dart';

enum BatteryTypeField {
  typeName,
  defaultVoltage,
  defaultCapacity,
  capacityUnit,
}

final class BatteryTypeValidationException implements Exception {
  const BatteryTypeValidationException(this.errors);

  final Map<BatteryTypeField, String> errors;

  @override
  String toString() =>
      'Battery Type validation failed: ${errors.values.join(' ')}';
}

final class BatteryTypeDraft {
  const BatteryTypeDraft({
    required this.typeName,
    required this.description,
    required this.chemistry,
    required this.defaultVoltage,
    required this.defaultCapacity,
    required this.capacityUnit,
    required this.physicalSize,
    required this.notes,
    required this.suggestedIcon,
  });

  final String typeName;
  final String? description;
  final String? chemistry;
  final double? defaultVoltage;
  final double? defaultCapacity;
  final String? capacityUnit;
  final String? physicalSize;
  final String? notes;
  final IconSelection suggestedIcon;

  BatteryTypeDraft validated() {
    final name = typeName.trim();
    final unit = _optional(capacityUnit);
    final errors = <BatteryTypeField, String>{};
    if (name.isEmpty) {
      errors[BatteryTypeField.typeName] = 'Enter a Battery Type name.';
    }
    if (defaultVoltage != null &&
        (!defaultVoltage!.isFinite || defaultVoltage! <= 0)) {
      errors[BatteryTypeField.defaultVoltage] =
          'Voltage must be greater than zero.';
    }
    if (defaultCapacity != null &&
        (!defaultCapacity!.isFinite || defaultCapacity! <= 0)) {
      errors[BatteryTypeField.defaultCapacity] =
          'Capacity must be greater than zero.';
    }
    if (defaultCapacity != null && unit == null) {
      errors[BatteryTypeField.capacityUnit] =
          'Choose or enter a capacity unit.';
    }
    if (defaultCapacity == null && unit != null) {
      errors[BatteryTypeField.defaultCapacity] =
          'Enter a capacity for this unit.';
    }
    if (errors.isNotEmpty) {
      throw BatteryTypeValidationException(Map.unmodifiable(errors));
    }
    return BatteryTypeDraft(
      typeName: name,
      description: _optional(description),
      chemistry: _optional(chemistry),
      defaultVoltage: defaultVoltage,
      defaultCapacity: defaultCapacity,
      capacityUnit: unit,
      physicalSize: _optional(physicalSize),
      notes: _optional(notes),
      suggestedIcon: suggestedIcon,
    );
  }
}

String? _optional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
