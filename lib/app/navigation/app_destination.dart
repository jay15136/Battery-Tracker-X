import 'package:flutter/material.dart';

enum AppDestination {
  dashboard('Dashboard', Icons.dashboard_outlined),
  batteries('Batteries', Icons.battery_charging_full_outlined),
  batterySets('Battery Sets', Icons.inventory_2_outlined),
  devices('Devices', Icons.devices_other_outlined),
  assignments('Assignments', Icons.swap_horiz_outlined),
  batteryTypes('Battery Types', Icons.category_outlined),
  qrLabels('QR Labels', Icons.qr_code_2_outlined),
  history('History', Icons.history_outlined),
  settings('Settings', Icons.settings_outlined);

  const AppDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}
