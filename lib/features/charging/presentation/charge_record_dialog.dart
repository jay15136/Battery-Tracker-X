import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../assignments/presentation/assignment_date_field.dart';
import '../domain/charge.dart';

class ChargeRecordDialog extends ConsumerStatefulWidget {
  const ChargeRecordDialog(
      {required this.labels,
      this.batteryIds = const [],
      this.setId,
      this.title = 'Mark Charged',
      super.key});
  final List<String> labels;
  final List<PermanentId> batteryIds;
  final PermanentId? setId;
  final String title;
  @override
  ConsumerState<ChargeRecordDialog> createState() => _ChargeRecordDialogState();
}

class _ChargeRecordDialogState extends ConsumerState<ChargeRecordDialog> {
  final _start = TextEditingController(),
      _end = TextEditingController(text: '100'),
      _charger = TextEditingController(),
      _notes = TextEditingController();
  DateTime _date = DateTime.now();
  bool _current = false, _busy = false;
  String? _error;
  @override
  void dispose() {
    for (final c in [_start, _end, _charger, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _percent(String value) {
    if (value.trim().isEmpty) return null;
    final p = int.tryParse(value.trim());
    if (p == null)
      throw const ChargeValidationException(
          'Percentages must be whole numbers from 0 to 100.');
    return p;
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final draft = ChargeDraft(
          chargedAt: _date,
          startPercent: _percent(_start.text),
          endPercent: _percent(_end.text),
          charger: _charger.text,
          notes: _notes.text,
          updateCurrentEstimate: _current);
      await ref
          .read(chargeRepositoryProvider)
          .record(draft, batteryIds: widget.batteryIds, setId: widget.setId);
      if (mounted) Navigator.pop(context, true);
    } on ChargeValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      ref
          .read(appLogServiceProvider)
          .logger('charging.ui')
          .severe('Recording charge failed.', e, s);
      if (mounted)
        setState(() =>
            _error = 'The charge could not be recorded. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
          title: Text(widget.title),
          content: SizedBox(
              width: 660,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    Text(
                        'Record one charge for each of ${widget.labels.length} Batteries:'),
                    Text(widget.labels.join(', ')),
                    const Text(
                        'Recorded Charges are logged events, not measured battery cycles. Percentages are user-entered estimates.'),
                    AssignmentDateField(
                        initial: _date,
                        label: 'Charge date',
                        enabled: !_busy,
                        onChanged: (v) => _date = v),
                    TextField(
                        key: const ValueKey('charge-start'),
                        controller: _start,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                            labelText: 'Starting percentage (optional)')),
                    TextField(
                        key: const ValueKey('charge-end'),
                        controller: _end,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                            labelText: 'Ending percentage (optional)')),
                    TextField(
                        key: const ValueKey('charge-charger'),
                        controller: _charger,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                            labelText: 'Charger (optional)')),
                    TextField(
                        key: const ValueKey('charge-notes'),
                        controller: _notes,
                        enabled: !_busy,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)')),
                    CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _current,
                        onChanged:
                            _busy ? null : (v) => setState(() => _current = v!),
                        title: const Text(
                            'Also set the current manual estimate to the ending value'),
                        subtitle: const Text(
                            'Leave unchecked to preserve current estimates when adding history.'))
                  ]))),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(_busy ? 'Saving…' : 'Confirm'))
          ]));
}
