import '../domain/icon_color.dart';
import '../domain/icon_definition.dart';

abstract final class BuiltInIconRegistry {
  static final definitions = <IconDefinition>[
    _battery('battery_aa', 'AA Battery', 'Standard Cells', ['double a']),
    _battery('battery_aaa', 'AAA Battery', 'Standard Cells', ['triple a']),
    _battery('battery_c', 'C Battery', 'Standard Cells'),
    _battery('battery_d', 'D Battery', 'Standard Cells'),
    _battery('battery_9v', '9V Battery', 'Standard Cells', ['nine volt']),
    _battery('battery_coin_cell', 'Coin Cell', 'Lithium Cells'),
    _battery('battery_button_cell', 'Button Cell', 'Lithium Cells'),
    _battery('battery_cr123', 'CR123 Battery', 'Lithium Cells'),
    _battery('battery_18650', '18650 Cell', 'Lithium Cells'),
    _battery('battery_21700', '21700 Cell', 'Lithium Cells'),
    _battery('battery_cylindrical', 'Cylindrical Battery', 'Standard Cells'),
    _battery(
        'battery_rectangular', 'Rectangular Battery', 'Specialty Batteries'),
    _battery('battery_camera', 'Camera Battery', 'Specialty Batteries'),
    _battery('battery_tool', 'Power Tool Battery', 'Battery Packs', ['tools']),
    _battery('battery_radio', 'Radio Battery', 'Specialty Batteries'),
    _battery('battery_drone', 'Drone Battery', 'Battery Packs'),
    _battery('battery_gaming_pack', 'Gaming Battery Pack', 'Battery Packs'),
    _battery('battery_laptop', 'Laptop Battery', 'Battery Packs'),
    _battery(
      'battery_rechargeable_pack',
      'Rechargeable Battery Pack',
      'Battery Packs',
    ),
    _battery('battery_generic', 'Generic Battery', 'Other'),
    _battery('battery_other', 'Other Battery', 'Other'),
    _device('device_controller', 'Game Controller', 'Gaming'),
    _device('device_vr_controller', 'VR Controller', 'Gaming'),
    _device('device_flashlight', 'Flashlight', 'Lighting'),
    _device(
      'device_radio',
      'Portable Radio',
      'Radios',
      ['law enforcement', 'police equipment'],
    ),
    _device('device_camera', 'Camera', 'Cameras'),
    _device('device_video_camera', 'Video Camera', 'Cameras'),
    _device('device_drone', 'Drone', 'Electronics'),
    _device('device_cordless_drill', 'Cordless Drill', 'Tools'),
    _device('device_power_tool', 'Power Tool', 'Tools'),
    _device('device_remote_control', 'Remote Control', 'Electronics'),
    _device('device_mouse', 'Computer Mouse', 'Computer Equipment'),
    _device('device_keyboard', 'Keyboard', 'Computer Equipment'),
    _device('device_microphone', 'Wireless Microphone', 'Electronics'),
    _device('device_headphones', 'Headphones', 'Electronics'),
    _device('device_speaker', 'Speaker', 'Electronics'),
    _device('device_phone', 'Phone', 'Electronics'),
    _device('device_tablet', 'Tablet', 'Computer Equipment'),
    _device('device_laptop', 'Laptop', 'Computer Equipment'),
    _device('device_gps', 'GPS', 'Electronics'),
    _device('device_toy', 'Toy', 'Other'),
    _device('device_medical', 'Medical Device', 'Other'),
    _device('device_test_equipment', 'Test Equipment', 'Electronics'),
    _device('device_smart_home', 'Smart Home Device', 'Smart Home'),
    _device('device_security', 'Security Device', 'Smart Home'),
    _device('device_generic', 'Generic Electronic Device', 'Other'),
    _device('device_other', 'Other Device', 'Other'),
    _set('battery_set_pair', 'Battery Pair', 'Groups'),
    _set('battery_set_four', 'Four-Battery Set', 'Groups'),
    _set('battery_set_group', 'Battery Group', 'Groups'),
    _set('battery_set_case', 'Battery Case', 'Cases'),
    _set('battery_set_holder', 'Battery Holder', 'Holders'),
    _set('battery_set_pack', 'Battery Pack', 'Packs'),
    _set('battery_set_generic', 'Generic Battery Set', 'Groups'),
  ];

  static const _assetRoot = 'assets/icons/builtin';

  static IconDefinition _battery(
    String key,
    String name,
    String category, [
    List<String> keywords = const [],
  ]) =>
      IconDefinition.builtIn(
        key: key,
        displayName: name,
        scope: IconScope.battery,
        category: category,
        location: '$_assetRoot/$key.svg',
        defaultColor: IconColor.defaultColor,
        keywords: keywords,
      );

  static IconDefinition _device(
    String key,
    String name,
    String category, [
    List<String> keywords = const [],
  ]) =>
      IconDefinition.builtIn(
        key: key,
        displayName: name,
        scope: IconScope.device,
        category: category,
        location: '$_assetRoot/$key.svg',
        defaultColor: IconColor.defaultColor,
        keywords: keywords,
      );

  static IconDefinition _set(
    String key,
    String name,
    String category, [
    List<String> keywords = const [],
  ]) =>
      IconDefinition.builtIn(
        key: key,
        displayName: name,
        scope: IconScope.batterySet,
        category: category,
        location: '$_assetRoot/$key.svg',
        defaultColor: IconColor.defaultColor,
        keywords: keywords,
      );
}
