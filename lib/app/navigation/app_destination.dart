import 'package:flutter/material.dart';

enum AppDestination {
  dashboard(
    'Dashboard',
    Icons.dashboard_outlined,
    'A clear starting point for local battery inventory.',
    'Your inventory is ready.',
    'Add Battery Types and Batteries to begin tracking equipment.',
  ),
  batteries(
    'Batteries',
    Icons.battery_charging_full_outlined,
    'Individual rechargeable batteries and battery packs.',
    'Battery inventory is empty.',
    'No batteries have been added yet.',
  ),
  batterySets(
    'Battery Sets',
    Icons.inventory_2_outlined,
    'Batteries intentionally kept, charged, or used together.',
    'No Battery Sets yet.',
    'Create a Set after batteries are available.',
  ),
  devices(
    'Devices',
    Icons.devices_other_outlined,
    'Equipment that uses individual Batteries or Battery Sets.',
    'No devices yet.',
    'Device records will appear here after they are added.',
  ),
  assignments(
    'Assignments',
    Icons.swap_horiz_outlined,
    'Current placement with complete historical context.',
    'Nothing is assigned.',
    'Battery and Set assignments will appear here.',
  ),
  charging(
      'Charge Tracking',
      Icons.battery_charging_full,
      'Charge events and manual estimates.',
      'No Recorded Charges yet.',
      'Record a charge to begin.'),
  batteryTypes(
    'Battery Types',
    Icons.category_outlined,
    'Reusable specifications for standard and custom batteries.',
    'No Battery Types yet.',
    'Create a Battery Type before entering inventory.',
  ),
  qrLabels(
    'QR Labels',
    Icons.qr_code_2_outlined,
    'Stable UUID labels for Batteries, Sets, and Devices.',
    'No labels have been prepared.',
    'Label templates and queued labels will appear here.',
  ),
  history(
    'History',
    Icons.history_outlined,
    'Recorded Charges, assignments, membership, and activity.',
    'No activity yet.',
    'Historical events will appear as inventory changes.',
  ),
  settings(
    'Settings',
    Icons.settings_outlined,
    'Appearance and local application preferences.',
    '',
    '',
  );

  const AppDestination(
    this.label,
    this.icon,
    this.description,
    this.emptyTitle,
    this.emptyMessage,
  );

  final String label;
  final IconData icon;
  final String description;
  final String emptyTitle;
  final String emptyMessage;
}
