import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../icons/data/built_in_icon_registry.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_registry.dart';
import '../../icons/domain/icon_repository.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/presentation/icon_visual.dart';

class BatteryTypeIcon extends ConsumerStatefulWidget {
  const BatteryTypeIcon({
    required this.selection,
    this.size = 48,
    this.semanticsLabel,
    super.key,
  });

  final IconSelection selection;
  final double size;
  final String? semanticsLabel;

  @override
  ConsumerState<BatteryTypeIcon> createState() => _BatteryTypeIconState();
}

class _BatteryTypeIconState extends ConsumerState<BatteryTypeIcon> {
  late Future<IconDefinition> _definition;

  IconRegistry get _builtIns => IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      );

  @override
  void initState() {
    super.initState();
    _definition = _resolve(widget.selection);
  }

  @override
  void didUpdateWidget(covariant BatteryTypeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selection != widget.selection) {
      _definition = _resolve(widget.selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallback = _builtIns.defaultFor(IconScope.battery);
    return FutureBuilder<IconDefinition>(
      future: _definition,
      initialData: widget.selection.source == IconSource.builtin
          ? _builtIns
              .resolve(
                scope: IconScope.battery,
                selection: widget.selection,
              )
              .definition
          : fallback,
      builder: (context, snapshot) {
        final visual = IconVisual(
          definition: snapshot.data ?? fallback,
          color: widget.selection.color,
          fallbackDefinition: fallback,
          applicationSupportRoot: ref.watch(applicationSupportRootProvider),
          size: widget.size,
        );
        final label = widget.semanticsLabel;
        if (label == null) {
          return visual;
        }
        return Semantics(
          label: label,
          image: true,
          excludeSemantics: true,
          child: visual,
        );
      },
    );
  }

  Future<IconDefinition> _resolve(IconSelection selection) async {
    final fallback = _builtIns.defaultFor(IconScope.battery);
    if (selection.source == IconSource.builtin) {
      return _builtIns
          .resolve(scope: IconScope.battery, selection: selection)
          .definition;
    }

    try {
      final id = PermanentId.parse(selection.key);
      final custom = await ref.read(iconRepositoryProvider).getCustomIcon(id);
      if (!custom.isActive) {
        return fallback;
      }
      return IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
        customIcons: [custom.toDefinition()],
      ).resolve(scope: IconScope.battery, selection: selection).definition;
    } on FormatException {
      return fallback;
    } on CustomIconNotFoundException {
      return fallback;
    } on Object catch (error, stackTrace) {
      ref.read(appLogServiceProvider).logger('battery_types.ui').severe(
            'Battery Type operation failed.',
            error,
            stackTrace,
          );
      return fallback;
    }
  }
}
