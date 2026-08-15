import 'package:flutter_test/flutter_test.dart';

import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';

BatteryTypeDraft validDraft({
  String typeName = ' AA NiMH ',
  double? voltage = 1.2,
  double? capacity = 2500,
  String? unit = ' mAh ',
}) =>
    BatteryTypeDraft(
      typeName: typeName,
      description: ' Rechargeable AA ',
      chemistry: ' Custom NiMH Blend ',
      defaultVoltage: voltage,
      defaultCapacity: capacity,
      capacityUnit: unit,
      physicalSize: ' AA ',
      notes: ' Fleet stock ',
      suggestedIcon: const IconSelection(
        source: IconSource.builtin,
        key: 'battery_aa',
        color: IconColor.green,
      ),
    );

void main() {
  test('normalizes text while retaining custom chemistry and unit', () {
    final normalized = validDraft(unit: 'cells').validated();

    expect(normalized.typeName, 'AA NiMH');
    expect(normalized.description, 'Rechargeable AA');
    expect(normalized.chemistry, 'Custom NiMH Blend');
    expect(normalized.capacityUnit, 'cells');
    expect(normalized.physicalSize, 'AA');
    expect(normalized.notes, 'Fleet stock');
  });

  test('rejects non-positive voltage and capacity', () {
    expect(
      () => validDraft(voltage: 0, capacity: -1).validated(),
      throwsA(
        isA<BatteryTypeValidationException>().having(
          (error) => error.errors.keys,
          'fields',
          containsAll([
            BatteryTypeField.defaultVoltage,
            BatteryTypeField.defaultCapacity,
          ]),
        ),
      ),
    );
  });

  test('requires capacity and unit together', () {
    expect(
      () => validDraft(unit: null).validated(),
      throwsA(isA<BatteryTypeValidationException>()),
    );
    expect(
      () => validDraft(capacity: null, unit: 'mAh').validated(),
      throwsA(isA<BatteryTypeValidationException>()),
    );
  });

  test('rejects non-finite voltage and capacity values', () {
    for (final value in [
      double.nan,
      double.infinity,
      double.negativeInfinity
    ]) {
      expect(
        () => validDraft(voltage: value).validated(),
        throwsA(
          isA<BatteryTypeValidationException>().having(
            (error) => error.errors,
            'errors',
            containsPair(
              BatteryTypeField.defaultVoltage,
              'Voltage must be greater than zero.',
            ),
          ),
        ),
      );
      expect(
        () => validDraft(capacity: value).validated(),
        throwsA(
          isA<BatteryTypeValidationException>().having(
            (error) => error.errors,
            'errors',
            containsPair(
              BatteryTypeField.defaultCapacity,
              'Capacity must be greater than zero.',
            ),
          ),
        ),
      );
    }
  });
}
