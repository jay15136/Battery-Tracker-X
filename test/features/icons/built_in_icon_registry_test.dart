import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const requiredKeys = {
    'battery_aa',
    'battery_aaa',
    'battery_c',
    'battery_d',
    'battery_9v',
    'battery_coin_cell',
    'battery_button_cell',
    'battery_cr123',
    'battery_18650',
    'battery_21700',
    'battery_cylindrical',
    'battery_rectangular',
    'battery_camera',
    'battery_tool',
    'battery_radio',
    'battery_drone',
    'battery_gaming_pack',
    'battery_laptop',
    'battery_rechargeable_pack',
    'battery_generic',
    'battery_other',
    'device_controller',
    'device_vr_controller',
    'device_flashlight',
    'device_radio',
    'device_camera',
    'device_video_camera',
    'device_drone',
    'device_cordless_drill',
    'device_power_tool',
    'device_remote_control',
    'device_mouse',
    'device_keyboard',
    'device_microphone',
    'device_headphones',
    'device_speaker',
    'device_phone',
    'device_tablet',
    'device_laptop',
    'device_gps',
    'device_toy',
    'device_medical',
    'device_test_equipment',
    'device_smart_home',
    'device_security',
    'device_generic',
    'device_other',
    'battery_set_pair',
    'battery_set_four',
    'battery_set_group',
    'battery_set_case',
    'battery_set_holder',
    'battery_set_pack',
    'battery_set_generic',
  };

  test('contains every required uniquely keyed packaged icon', () {
    final definitions = BuiltInIconRegistry.definitions;
    final keys = definitions.map((definition) => definition.key).toList();

    expect(definitions, hasLength(54));
    expect(keys.toSet(), hasLength(keys.length));
    expect(keys.toSet(), requiredKeys);
    expect(
      definitions.every(
        (definition) =>
            definition.source == IconSource.builtin &&
            definition.location.startsWith('assets/icons/builtin/') &&
            definition.location.endsWith('.svg'),
      ),
      isTrue,
    );
  });

  test('supplies distinct defaults for Battery, Set, and Device', () {
    final registry = IconRegistry(
      builtIns: BuiltInIconRegistry.definitions,
    );

    expect(registry.defaultFor(IconScope.battery).key, 'battery_generic');
    expect(
      registry.defaultFor(IconScope.batterySet).key,
      'battery_set_generic',
    );
    expect(registry.defaultFor(IconScope.device).key, 'device_generic');
  });

  test('searches names, keys, categories, and keywords within a scope', () {
    final registry = IconRegistry(
      builtIns: BuiltInIconRegistry.definitions,
    );

    expect(
      registry
          .search(scope: IconScope.battery, query: 'standard cells')
          .map((definition) => definition.key),
      contains('battery_aa'),
    );
    expect(
      registry
          .search(scope: IconScope.device, query: 'law enforcement')
          .map((definition) => definition.key),
      contains('device_radio'),
    );
    expect(
      registry
          .search(scope: IconScope.batterySet, query: 'holder')
          .map((definition) => definition.key),
      contains('battery_set_holder'),
    );
    expect(
      registry.search(scope: IconScope.device, query: 'AA Battery'),
      isEmpty,
    );
  });

  test('falls back by owner scope when a custom icon is unavailable', () {
    final registry = IconRegistry(
      builtIns: BuiltInIconRegistry.definitions,
    );

    final result = registry.resolve(
      scope: IconScope.device,
      selection: IconSelection(
        source: IconSource.custom,
        key: '11111111-1111-4111-8111-111111111111',
        color: IconColor.parse('#F44336'),
      ),
    );

    expect(result.definition.key, 'device_generic');
    expect(result.usedFallback, isTrue);
    expect(result.fallbackReason, IconFallbackReason.missing);
    expect(result.color.value, '#F44336');
  });

  test('resolves deprecated built-ins to their declared replacement', () {
    final registry = IconRegistry(
      builtIns: [
        IconDefinition.builtIn(
          key: 'battery_old',
          displayName: 'Old Battery',
          scope: IconScope.battery,
          category: 'Other',
          location: 'assets/icons/builtin/battery_old.svg',
          defaultColor: IconColor.parse('#607D8B'),
          deprecatedReplacementKey: 'battery_generic',
        ),
        IconDefinition.builtIn(
          key: 'battery_generic',
          displayName: 'Generic Battery',
          scope: IconScope.battery,
          category: 'Other',
          location: 'assets/icons/builtin/battery_generic.svg',
          defaultColor: IconColor.parse('#607D8B'),
        ),
      ],
    );

    final result = registry.resolve(
      scope: IconScope.battery,
      selection: IconSelection(
        source: IconSource.builtin,
        key: 'battery_old',
        color: IconColor.parse('#2196F3'),
      ),
    );

    expect(result.definition.key, 'battery_generic');
    expect(result.usedFallback, isTrue);
    expect(result.fallbackReason, IconFallbackReason.deprecated);
    expect(result.color.value, '#2196F3');
  });
}
