import 'package:flutter/material.dart';
import '../../../core/identity/permanent_id.dart';
import '../../battery_types/domain/battery_type.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/presentation/inventory_icon.dart';
import '../../icons/presentation/icon_picker_dialog.dart';
import '../domain/device.dart';

class DeviceFormDialog extends StatefulWidget {
  const DeviceFormDialog(
      {required this.types,
      required this.categories,
      required this.save,
      this.record,
      super.key});
  final List<BatteryTypeRecord> types;
  final List<String> categories;
  final Future<void> Function(DeviceDraft) save;
  final DeviceRecord? record;
  @override
  State<DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends State<DeviceFormDialog> {
  final _fields = <String, TextEditingController>{};
  late IconSelection _icon;
  PermanentId? _type;
  bool _busy = false;
  String? _error;
  static const _labels = [
    'Name',
    'Category',
    'Manufacturer',
    'Model',
    'Serial number',
    'Location',
    'Description',
    'Notes',
    'Required quantity',
    'Required voltage',
    'Requirement notes'
  ];
  static const _suggestions = {
    'Gaming': 'device_controller',
    'Cameras': 'device_camera',
    'Communications': 'device_radio',
    'Other': 'device_generic'
  };
  @override
  void initState() {
    super.initState();
    final v = widget.record?.values ?? const DeviceDraft(name: '');
    final values = [
      v.name,
      v.category,
      v.manufacturer,
      v.model,
      v.serialNumber,
      v.location,
      v.description,
      v.notes,
      v.quantity?.toString(),
      v.voltage?.toString(),
      v.requirementNotes
    ];
    for (var n = 0; n < _labels.length; n++) {
      _fields[_labels[n]] = TextEditingController(text: values[n] ?? '');
    }
    _icon = v.icon;
    _type = v.requiredTypeId;
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  String text(String key) => _fields[key]!.text;
  Widget field(String label, {int lines = 1}) => TextField(
      key: ValueKey('device-$label'),
      controller: _fields[label],
      enabled: !_busy,
      maxLines: lines,
      onChanged: label == 'Category' ? (_) => setState(() {}) : null,
      decoration: InputDecoration(labelText: label));
  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final quantity = text('Required quantity').trim(),
          voltage = text('Required voltage').trim();
      if (quantity.isNotEmpty && int.tryParse(quantity) == null)
        throw const DeviceValidationException(
            'Enter a whole number for Required quantity.');
      if (voltage.isNotEmpty && double.tryParse(voltage) == null)
        throw const DeviceValidationException(
            'Enter a number for Required voltage.');
      final draft = DeviceDraft(
          name: text('Name'),
          category: text('Category'),
          manufacturer: text('Manufacturer'),
          model: text('Model'),
          serialNumber: text('Serial number'),
          location: text('Location'),
          description: text('Description'),
          notes: text('Notes'),
          requiredTypeId: _type,
          quantity: int.tryParse(quantity),
          voltage: double.tryParse(voltage),
          requirementNotes: text('Requirement notes'),
          icon: _icon);
      draft.validate();
      await widget.save(draft);
      if (mounted) Navigator.pop(context, true);
    } on DeviceValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted)
        setState(
            () => _error = 'The Device could not be saved. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
          title: Text(widget.record == null ? 'Add Device' : 'Edit Device'),
          content: SizedBox(
              width: 640,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    InventoryIcon(
                        selection: _icon, scope: IconScope.device, size: 64),
                    TextButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                final chosen = await IconPickerDialog.show(
                                    context,
                                    scope: IconScope.device,
                                    initialSelection: _icon);
                                if (mounted && chosen != null)
                                  setState(() => _icon = chosen);
                              },
                        child: const Text('Choose icon and color')),
                    field('Name'),
                    field('Category'),
                    Wrap(spacing: 8, children: [
                      for (final category in {
                        ..._suggestions.keys,
                        ...widget.categories
                      })
                        ActionChip(
                            label: Text(category),
                            onPressed: _busy
                                ? null
                                : () => setState(
                                    () => _fields['Category']!.text = category))
                    ]),
                    if (_suggestions.containsKey(text('Category')))
                      TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() => _icon = IconSelection(
                                  source: IconSource.builtin,
                                  key: _suggestions[text('Category')]!,
                                  color: IconColor.defaultColor)),
                          child: const Text(
                              'Use suggested category icon and color')),
                    for (final key in [
                      'Manufacturer',
                      'Model',
                      'Serial number',
                      'Location'
                    ])
                      field(key),
                    field('Description', lines: 2),
                    field('Notes', lines: 3),
                    const SizedBox(height: 16),
                    Text('Optional battery requirements',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Text(
                        'Requirements guide assignments. Mismatches can be acknowledged and overridden.'),
                    DropdownButtonFormField<PermanentId>(
                        key: ValueKey(_type),
                        initialValue: _type,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Required Battery Type'),
                        items: [
                          for (final t in widget.types
                              .where((t) => t.isActive || t.id == _type))
                            DropdownMenuItem(
                                value: t.id,
                                child: Text(
                                    '${t.typeName}${t.isActive ? '' : ' (inactive)'}'))
                        ],
                        onChanged:
                            _busy ? null : (v) => setState(() => _type = v)),
                    if (_type != null)
                      TextButton(
                          onPressed:
                              _busy ? null : () => setState(() => _type = null),
                          child: const Text('Clear required Battery Type')),
                    field('Required quantity'),
                    field('Required voltage'),
                    field('Requirement notes', lines: 2)
                  ]))),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(_busy ? 'Saving…' : 'Save Device'))
          ]));
}
