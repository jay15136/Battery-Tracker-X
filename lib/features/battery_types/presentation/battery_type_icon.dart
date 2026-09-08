import 'package:flutter/material.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/presentation/inventory_icon.dart';

/// Compatibility wrapper for Battery and Battery Type visuals.
class BatteryTypeIcon extends StatelessWidget {
  const BatteryTypeIcon(
      {required this.selection,
      this.size = 48,
      this.semanticsLabel,
      super.key});
  final IconSelection selection;
  final double size;
  final String? semanticsLabel;
  @override
  Widget build(BuildContext context) => InventoryIcon(
      selection: selection, size: size, semanticsLabel: semanticsLabel);
}
