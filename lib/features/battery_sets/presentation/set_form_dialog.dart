import 'package:flutter/material.dart';
import '../../../core/identity/permanent_id.dart';
import '../../battery_types/domain/battery_type.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/presentation/inventory_icon.dart';
import '../../icons/presentation/icon_picker_dialog.dart';
import '../domain/battery_set.dart';

class SetFormDialog extends StatefulWidget {
  const SetFormDialog(
      {required this.types,
      required this.save,
      required this.suggest,
      this.record,
      super.key});
  final List<BatteryTypeRecord> types;
  final Future<void> Function(SetDraft) save;
  final Future<String> Function(String, int) suggest;
  final SetRecord? record;
  @override
  State<SetFormDialog> createState() => _SetFormDialogState();
}

class _SetFormDialogState extends State<SetFormDialog> {
  final _id = TextEditingController(),
      _name = TextEditingController(),
      _description = TextEditingController(),
      _notes = TextEditingController(),
      _prefix = TextEditingController(text: 'SET'),
      _start = TextEditingController(text: '1');
  late IconSelection _icon;
  PermanentId? _type;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final v = widget.record?.values ?? const SetDraft(userSetId: '', name: '');
    _id.text = v.userSetId;
    _name.text = v.name;
    _description.text = v.description ?? '';
    _notes.text = v.notes ?? '';
    _icon = v.icon;
    _type = v.typeId;
  }

  @override
  void dispose() {
    for (final c in [_id, _name, _description, _notes, _prefix, _start]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on SetValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted)
        setState(
            () => _error = 'The Set could not be saved. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
          title: Text(
              widget.record == null ? 'Add Battery Set' : 'Edit Battery Set'),
          content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    InventoryIcon(
                        selection: _icon, scope: IconScope.batterySet),
                    TextButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                final icon = await IconPickerDialog.show(
                                    context,
                                    scope: IconScope.batterySet,
                                    initialSelection: _icon);
                                if (mounted && icon != null)
                                  setState(() => _icon = icon);
                              },
                        child: const Text('Choose icon and color')),
                    TextField(
                        key: const ValueKey('set-id'),
                        controller: _id,
                        enabled: !_busy,
                        decoration: const InputDecoration(labelText: 'Set ID')),
                    TextField(
                        key: const ValueKey('set-name'),
                        controller: _name,
                        enabled: !_busy,
                        decoration:
                            const InputDecoration(labelText: 'Set name')),
                    const SizedBox(height: 12),
                    Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                              width: 160,
                              child: TextField(
                                  controller: _prefix,
                                  enabled: !_busy,
                                  decoration: const InputDecoration(
                                      labelText: 'ID prefix'))),
                          SizedBox(
                              width: 160,
                              child: TextField(
                                  controller: _start,
                                  enabled: !_busy,
                                  decoration: const InputDecoration(
                                      labelText: 'Starting number'))),
                          TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _run(() async {
                                        final start = int.tryParse(_start.text);
                                        if (start == null)
                                          throw const SetValidationException(
                                              'Enter a whole starting number.');
                                        final next = await widget.suggest(
                                            _prefix.text, start);
                                        if (mounted) _id.text = next;
                                      }),
                              child: const Text('Suggest Set ID'))
                        ]),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PermanentId>(
                        initialValue: _type,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'Battery Type'),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('No Battery Type')),
                          for (final type in widget.types
                              .where((t) => t.isActive || t.id == _type))
                            DropdownMenuItem(
                                value: type.id, child: Text(type.typeName))
                        ],
                        onChanged:
                            _busy ? null : (v) => setState(() => _type = v)),
                    TextField(
                        controller: _description,
                        enabled: !_busy,
                        decoration:
                            const InputDecoration(labelText: 'Description')),
                    TextField(
                        controller: _notes,
                        enabled: !_busy,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Notes')),
                  ]))),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                          final draft = SetDraft(
                              userSetId: _id.text,
                              name: _name.text,
                              typeId: _type,
                              description: _description.text,
                              notes: _notes.text,
                              icon: _icon);
                          draft.validate();
                          await widget.save(draft);
                          if (mounted) Navigator.pop(context, true);
                        }),
                child: Text(_busy ? 'Saving…' : 'Save Set'))
          ]));
}
