import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../battery_types/domain/battery_type.dart';
import '../../battery_types/presentation/battery_type_icon.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/presentation/icon_picker_dialog.dart';
import '../domain/battery.dart';

class BatteryFormDialog extends ConsumerStatefulWidget {
  const BatteryFormDialog(
      {required this.types,
      this.record,
      this.initialDraft,
      this.draftOnly = false,
      super.key});
  final List<BatteryTypeRecord> types;
  final BatteryRecord? record;
  final BatteryDraft? initialDraft;
  final bool draftOnly;
  @override
  ConsumerState<BatteryFormDialog> createState() => _BatteryFormDialogState();
}

class _BatteryFormDialogState extends ConsumerState<BatteryFormDialog> {
  final _form = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};
  late IconSelection _icon;
  PermanentId? _type;
  late String _status, _condition;
  late bool _rechargeable;
  bool _saving = false;
  String? _error;
  static const labels = {
    'userBatteryId': 'Battery ID',
    'name': 'Battery name',
    'batchCode': 'Batch ID',
    'manufacturer': 'Manufacturer',
    'model': 'Model',
    'serialNumber': 'Serial number',
    'customLabel': 'Custom label',
    'chemistry': 'Chemistry',
    'nominalVoltage': 'Voltage',
    'capacity': 'Capacity',
    'capacityUnit': 'Capacity unit',
    'purchaseDate': 'Purchase date (YYYY-MM-DD)',
    'purchaseLocation': 'Purchase location',
    'purchasePrice': 'Purchase price',
    'totalPackagePrice': 'Total package price',
    'perBatteryPrice': 'Per-battery price',
    'warrantyExpiration': 'Warranty expiration (YYYY-MM-DD)',
    'conditionNote': 'Condition note',
    'notes': 'Notes',
  };
  @override
  void initState() {
    super.initState();
    final v = widget.initialDraft ??
        widget.record?.values ??
        const BatteryDraft(userBatteryId: '');
    final initial = <String, Object?>{
      'userBatteryId': v.userBatteryId,
      'name': v.name,
      'batchCode': v.batchCode,
      'manufacturer': v.manufacturer,
      'model': v.model,
      'serialNumber': v.serialNumber,
      'customLabel': v.customLabel,
      'chemistry': v.chemistry,
      'nominalVoltage': v.nominalVoltage,
      'capacity': v.capacity,
      'capacityUnit': v.capacityUnit,
      'purchaseDate': v.purchaseDate?.toIso8601String().substring(0, 10),
      'purchaseLocation': v.purchaseLocation,
      'purchasePrice': v.purchasePrice,
      'totalPackagePrice': v.totalPackagePrice,
      'perBatteryPrice': v.perBatteryPrice,
      'warrantyExpiration':
          v.warrantyExpiration?.toIso8601String().substring(0, 10),
      'conditionNote': v.conditionNote,
      'notes': v.notes,
    };
    for (final key in labels.keys) {
      _fields[key] =
          TextEditingController(text: initial[key]?.toString() ?? '');
    }
    _icon = v.icon;
    _type = v.batteryTypeId;
    _status = v.status;
    _condition = v.condition;
    _rechargeable = v.rechargeable;
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.draftOnly
            ? 'Edit preview values'
            : widget.record == null
                ? 'Add Battery'
                : 'Edit Battery'),
        content: SizedBox(
            width: 740,
            child: SingleChildScrollView(
                child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(_error!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error))),
                        Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              BatteryTypeIcon(selection: _icon),
                              OutlinedButton(
                                  onPressed: _saving
                                      ? null
                                      : () async {
                                          final result =
                                              await IconPickerDialog.show(
                                                  context,
                                                  scope: IconScope.battery,
                                                  initialSelection: _icon);
                                          if (result != null && mounted)
                                            setState(() => _icon = result);
                                        },
                                  child: const Text('Choose icon and color')),
                              const Text(
                                  'Icon is primary. No photograph required.'),
                            ]),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<PermanentId?>(
                            initialValue: _type,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Battery Type'),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('No Battery Type')),
                              for (final type in widget.types
                                  .where((t) => t.isActive || t.id == _type))
                                DropdownMenuItem(
                                    value: type.id, child: Text(type.typeName))
                            ],
                            onChanged: _saving
                                ? null
                                : (value) => setState(() => _type = value)),
                        TextButton(
                            onPressed: _saving || _type == null
                                ? null
                                : _applyDefaults,
                            child: const Text(
                                'Apply type specifications and icon defaults')),
                        Wrap(spacing: 16, runSpacing: 14, children: [
                          for (final entry in labels.entries)
                            SizedBox(
                                width: 320,
                                child: TextFormField(
                                  key: ValueKey('battery-${entry.key}'),
                                  controller: _fields[entry.key],
                                  enabled: !_saving,
                                  decoration:
                                      InputDecoration(labelText: entry.value),
                                  maxLines: entry.key == 'notes' ? 3 : 1,
                                  validator: (text) =>
                                      _validateField(entry.key, text ?? ''),
                                )),
                        ]),
                        TextButton(
                            onPressed: _saving ? null : _suggest,
                            child: const Text('Suggest next Battery ID')),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration:
                                const InputDecoration(labelText: 'Status'),
                            items: [
                              for (final s in batteryStatuses)
                                DropdownMenuItem(value: s, child: Text(s))
                            ],
                            onChanged: _saving
                                ? null
                                : (s) => setState(() => _status = s!)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                            initialValue: _condition,
                            decoration:
                                const InputDecoration(labelText: 'Condition'),
                            items: [
                              for (final s in batteryConditions)
                                DropdownMenuItem(value: s, child: Text(s))
                            ],
                            onChanged: _saving
                                ? null
                                : (s) => setState(() => _condition = s!)),
                        SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Rechargeable'),
                            value: _rechargeable,
                            onChanged: _saving
                                ? null
                                : (v) => setState(() => _rechargeable = v)),
                      ],
                    )))),
        actions: [
          TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving
                  ? 'Saving…'
                  : widget.draftOnly
                      ? 'Use these values'
                      : 'Save Battery'))
        ],
      );

  String? _validateField(String key, String value) {
    if (key == 'userBatteryId' && value.trim().isEmpty)
      return 'Enter a Battery ID.';
    if ([
          'nominalVoltage',
          'capacity',
          'purchasePrice',
          'totalPackagePrice',
          'perBatteryPrice'
        ].contains(key) &&
        value.trim().isNotEmpty) {
      final number = double.tryParse(value.trim());
      if (number == null ||
          !number.isFinite ||
          number < 0 ||
          (['capacity', 'nominalVoltage'].contains(key) && number == 0))
        return 'Enter a valid ${[
          'capacity',
          'nominalVoltage'
        ].contains(key) ? 'positive' : 'nonnegative'} number.';
    }
    if (['purchaseDate', 'warrantyExpiration'].contains(key) &&
        value.trim().isNotEmpty) {
      final date = DateTime.tryParse(value.trim());
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim()) ||
          date == null ||
          date.toIso8601String().substring(0, 10) != value.trim())
        return 'Use a real date in YYYY-MM-DD format.';
    }
    return null;
  }

  void _applyDefaults() {
    final type = widget.types.firstWhere((t) => t.id == _type);
    setState(() {
      _fields['chemistry']!.text = type.chemistry ?? '';
      _fields['nominalVoltage']!.text = type.defaultVoltage?.toString() ?? '';
      _fields['capacity']!.text = type.defaultCapacity?.toString() ?? '';
      _fields['capacityUnit']!.text = type.capacityUnit ?? '';
      _icon = type.suggestedIcon;
    });
  }

  Future<void> _suggest() async {
    final prefix = TextEditingController(text: 'BAT');
    final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Sequential Battery ID'),
                content: TextField(
                    controller: prefix,
                    decoration: const InputDecoration(
                        labelText: 'Prefix',
                        helperText: 'Starts at 001 and skips existing IDs.')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, prefix.text),
                      child: const Text('Suggest'))
                ]));
    // Controllers are disposed after the dialog exit animation.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    prefix.dispose();
    if (result == null || !mounted) return;
    try {
      final suggestion =
          await ref.read(batteryRepositoryProvider).suggestId(prefix: result);
      if (mounted) setState(() => _fields['userBatteryId']!.text = suggestion);
    } on Object catch (e, s) {
      _failure(e, s);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_status == 'Retired' && widget.record?.values.status != 'Retired') {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                  title: const Text('Retire Battery?'),
                  content: const Text(
                      'The Battery will be marked Retired. Its identity and history will be preserved.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Retire'))
                  ]));
      if (confirmed != true || !mounted) return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    String t(String k) => _fields[k]!.text.trim();
    double? n(String k) => double.tryParse(t(k));
    DateTime? d(String k) =>
        t(k).isEmpty ? null : DateTime.parse('${t(k)}T00:00:00Z');
    try {
      final draft = BatteryDraft(
          userBatteryId: t('userBatteryId'),
          name: t('name'),
          batteryTypeId: _type,
          batchCode: t('batchCode'),
          manufacturer: t('manufacturer'),
          model: t('model'),
          serialNumber: t('serialNumber'),
          customLabel: t('customLabel'),
          chemistry: t('chemistry'),
          nominalVoltage: n('nominalVoltage'),
          capacity: n('capacity'),
          capacityUnit: t('capacityUnit'),
          rechargeable: _rechargeable,
          purchaseDate: d('purchaseDate'),
          purchaseLocation: t('purchaseLocation'),
          purchasePrice: n('purchasePrice'),
          totalPackagePrice: n('totalPackagePrice'),
          perBatteryPrice: n('perBatteryPrice'),
          warrantyExpiration: d('warrantyExpiration'),
          status: _status,
          condition: _condition,
          conditionNote: t('conditionNote'),
          notes: t('notes'),
          icon: _icon);
      draft.validate();
      if (widget.draftOnly) {
        if (mounted) Navigator.pop(context, draft);
        return;
      }
      await ref
          .read(batteryRepositoryProvider)
          .save(draft, id: widget.record?.id);
      if (mounted) Navigator.pop(context, true);
    } on Object catch (e, s) {
      _failure(e, s);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _failure(Object e, StackTrace s) {
    if (e is! BatteryValidationException)
      ref
          .read(appLogServiceProvider)
          .logger('batteries')
          .severe('Battery operation failed.', e, s);
    if (mounted)
      setState(() => _error = e is BatteryValidationException
          ? e.message
          : 'Battery could not be saved. Please try again.');
  }
}
