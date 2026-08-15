import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../icons/data/built_in_icon_registry.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_registry.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/presentation/icon_picker_dialog.dart';
import '../../icons/presentation/icon_visual.dart';
import '../domain/battery_type.dart';
import '../domain/battery_type_draft.dart';

const chemistrySuggestions = [
  'NiMH',
  'NiCd',
  'Li-ion',
  'LiPo',
  'LiFePO4',
  'Lead Acid',
  'Proprietary',
  'Other',
];

const capacityUnitSuggestions = ['mAh', 'Ah', 'Wh'];

class BatteryTypeFormDialog extends ConsumerStatefulWidget {
  const BatteryTypeFormDialog({this.record, super.key});

  final BatteryTypeRecord? record;

  static Future<BatteryTypeDraft?> show(
    BuildContext context, {
    BatteryTypeRecord? record,
  }) {
    return showDialog<BatteryTypeDraft>(
      context: context,
      builder: (_) => BatteryTypeFormDialog(record: record),
    );
  }

  @override
  ConsumerState<BatteryTypeFormDialog> createState() =>
      _BatteryTypeFormDialogState();
}

class _BatteryTypeFormDialogState extends ConsumerState<BatteryTypeFormDialog> {
  final _typeNameController = TextEditingController();
  final _voltageController = TextEditingController();
  final _capacityController = TextEditingController();
  final _physicalSizeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _errors = <BatteryTypeField, String>{};

  late String _chemistry;
  late String _capacityUnit;
  late IconSelection _suggestedIcon;
  late IconDefinition _visualDefinition;

  IconRegistry get _builtInRegistry => IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      );

  IconDefinition get _fallbackIcon =>
      _builtInRegistry.defaultFor(IconScope.battery);

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _typeNameController.text = record?.typeName ?? '';
    _voltageController.text = _numericText(record?.defaultVoltage);
    _capacityController.text = _numericText(record?.defaultCapacity);
    _physicalSizeController.text = record?.physicalSize ?? '';
    _descriptionController.text = record?.description ?? '';
    _notesController.text = record?.notes ?? '';
    _chemistry = record?.chemistry ?? '';
    _capacityUnit = record?.capacityUnit ?? '';
    _suggestedIcon = record?.suggestedIcon ??
        IconSelection(
          source: _fallbackIcon.source,
          key: _fallbackIcon.key,
          color: _fallbackIcon.defaultColor,
        );
    _visualDefinition = _fallbackIcon;
    Future<void>.microtask(() => _resolveVisualDefinition(_suggestedIcon));
  }

  @override
  void dispose() {
    _typeNameController.dispose();
    _voltageController.dispose();
    _capacityController.dispose();
    _physicalSizeController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 780),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Edit Battery Type' : 'Add Battery Type',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set reusable specifications and visual defaults.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: 'Identity',
                      child: Column(
                        children: [
                          _textField(
                            key: const ValueKey('battery-type-name-field'),
                            controller: _typeNameController,
                            label: 'Type name',
                            error: _errors[BatteryTypeField.typeName],
                            onChanged: (_) =>
                                _clearError(BatteryTypeField.typeName),
                            autofocus: true,
                          ),
                          const SizedBox(height: 16),
                          _suggestionField(
                            key: const ValueKey('battery-type-chemistry-field'),
                            label: 'Chemistry',
                            initialValue: _chemistry,
                            suggestions: chemistrySuggestions,
                            onChanged: (value) => _chemistry = value,
                          ),
                          const SizedBox(height: 16),
                          _textField(
                            key: const ValueKey(
                              'battery-type-physical-size-field',
                            ),
                            controller: _physicalSizeController,
                            label: 'Physical size',
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 16),
                          _textField(
                            key: const ValueKey(
                              'battery-type-description-field',
                            ),
                            controller: _descriptionController,
                            label: 'Description',
                            onChanged: (_) {},
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Defaults',
                      child: Column(
                        children: [
                          _textField(
                            key: const ValueKey('battery-type-voltage-field'),
                            controller: _voltageController,
                            label: 'Default voltage',
                            suffixText: 'V',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            error: _errors[BatteryTypeField.defaultVoltage],
                            onChanged: (_) =>
                                _clearError(BatteryTypeField.defaultVoltage),
                          ),
                          const SizedBox(height: 16),
                          _textField(
                            key: const ValueKey('battery-type-capacity-field'),
                            controller: _capacityController,
                            label: 'Default capacity',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            error: _errors[BatteryTypeField.defaultCapacity],
                            onChanged: (_) {
                              _clearError(BatteryTypeField.defaultCapacity);
                              _clearError(BatteryTypeField.capacityUnit);
                            },
                          ),
                          const SizedBox(height: 16),
                          _suggestionField(
                            key: const ValueKey(
                              'battery-type-capacity-unit-field',
                            ),
                            label: 'Capacity unit',
                            initialValue: _capacityUnit,
                            suggestions: capacityUnitSuggestions,
                            error: _errors[BatteryTypeField.capacityUnit],
                            onChanged: (value) {
                              _capacityUnit = value;
                              _clearError(BatteryTypeField.capacityUnit);
                              _clearError(BatteryTypeField.defaultCapacity);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Visual Default',
                      child: _VisualDefault(
                        definition: _visualDefinition,
                        selection: _suggestedIcon,
                        fallbackDefinition: _fallbackIcon,
                        applicationSupportRoot:
                            ref.watch(applicationSupportRootProvider),
                        onChooseIcon: _chooseIcon,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Notes',
                      child: _textField(
                        key: const ValueKey('battery-type-notes-field'),
                        controller: _notesController,
                        label: 'Notes',
                        onChanged: (_) {},
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: _save,
                    child: Text(_isEditing ? 'Save changes' : 'Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    String? error,
    String? suffixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool autofocus = false,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        suffixText: suffixText,
      ),
      onChanged: onChanged,
    );
  }

  Widget _suggestionField({
    required Key key,
    required String label,
    required String initialValue,
    required List<String> suggestions,
    required ValueChanged<String> onChanged,
    String? error,
  }) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initialValue),
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        return suggestions.where(
          (suggestion) =>
              query.isEmpty || suggestion.toLowerCase().contains(query),
        );
      },
      onSelected: onChanged,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          key: key,
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(labelText: label, errorText: error),
          onChanged: onChanged,
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }

  Future<void> _chooseIcon() async {
    final selection = await IconPickerDialog.show(
      context,
      scope: IconScope.battery,
      initialSelection: _suggestedIcon,
    );
    if (selection == null || !mounted) {
      return;
    }
    setState(() => _suggestedIcon = selection);
    await _resolveVisualDefinition(selection);
  }

  Future<void> _resolveVisualDefinition(IconSelection selection) async {
    final customIcons = await ref
        .read(iconRepositoryProvider)
        .listCustomIcons(scope: IconScope.battery);
    final resolved = IconRegistry(
      builtIns: BuiltInIconRegistry.definitions,
      customIcons: customIcons.map((icon) => icon.toDefinition()),
    ).resolve(scope: IconScope.battery, selection: selection);
    if (!mounted || selection != _suggestedIcon) {
      return;
    }
    setState(() => _visualDefinition = resolved.definition);
  }

  void _save() {
    final errors = <BatteryTypeField, String>{};
    final voltage = _parseNumber(
      _voltageController.text,
      field: BatteryTypeField.defaultVoltage,
      label: 'voltage',
      errors: errors,
    );
    final capacity = _parseNumber(
      _capacityController.text,
      field: BatteryTypeField.defaultCapacity,
      label: 'capacity',
      errors: errors,
    );
    final draft = BatteryTypeDraft(
      typeName: _typeNameController.text,
      description: _descriptionController.text,
      chemistry: _chemistry,
      defaultVoltage: voltage,
      defaultCapacity: capacity,
      capacityUnit: _capacityUnit,
      physicalSize: _physicalSizeController.text,
      notes: _notesController.text,
      suggestedIcon: _suggestedIcon,
    );
    try {
      final validated = draft.validated();
      if (errors.isEmpty) {
        Navigator.of(context).pop(validated);
        return;
      }
    } on BatteryTypeValidationException catch (error) {
      for (final entry in error.errors.entries) {
        errors.putIfAbsent(entry.key, () => entry.value);
      }
    }
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
  }

  double? _parseNumber(
    String value, {
    required BatteryTypeField field,
    required String label,
    required Map<BatteryTypeField, String> errors,
  }) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(text);
    if (parsed == null) {
      errors[field] = 'Enter a valid $label.';
    }
    return parsed;
  }

  void _clearError(BatteryTypeField field) {
    if (!_errors.containsKey(field)) {
      return;
    }
    setState(() => _errors.remove(field));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _VisualDefault extends StatelessWidget {
  const _VisualDefault({
    required this.definition,
    required this.selection,
    required this.fallbackDefinition,
    required this.applicationSupportRoot,
    required this.onChooseIcon,
  });

  final IconDefinition definition;
  final IconSelection selection;
  final IconDefinition fallbackDefinition;
  final Uri applicationSupportRoot;
  final VoidCallback onChooseIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconVisual(
              definition: definition,
              color: selection.color,
              fallbackDefinition: fallbackDefinition,
              applicationSupportRoot: applicationSupportRoot,
              size: 52,
            ),
          ),
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(definition.displayName,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Suggested icon and color for new batteries of this type.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const ValueKey('battery-type-choose-icon'),
                  onPressed: onChooseIcon,
                  icon: const Icon(Icons.palette_outlined),
                  label: const Text('Choose icon and color'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _numericText(double? value) => value == null ? '' : value.toString();
