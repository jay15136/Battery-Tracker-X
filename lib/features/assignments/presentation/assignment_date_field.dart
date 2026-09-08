import 'package:flutter/material.dart';

/// Retains local clock time when changing the calendar date; persistence uses UTC.
class AssignmentDateField extends StatefulWidget {
  const AssignmentDateField(
      {required this.initial,
      required this.onChanged,
      this.label = 'Assignment date',
      this.enabled = true,
      super.key});
  final DateTime initial;
  final ValueChanged<DateTime> onChanged;
  final String label;
  final bool enabled;
  @override
  State<AssignmentDateField> createState() => _AssignmentDateFieldState();
}

class _AssignmentDateFieldState extends State<AssignmentDateField> {
  late DateTime _date;
  @override
  void initState() {
    super.initState();
    _date = widget.initial.toLocal();
  }

  @override
  Widget build(BuildContext context) => Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${widget.label}: ${_date.toString().split('.').first}'),
            TextButton(
                onPressed: !widget.enabled
                    ? null
                    : () async {
                        final day = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now());
                        if (day == null || !mounted) return;
                        setState(() => _date = DateTime(day.year, day.month,
                            day.day, _date.hour, _date.minute, _date.second));
                        widget.onChanged(_date);
                      },
                child: const Text('Change date')),
            TextButton(
                onPressed: !widget.enabled
                    ? null
                    : () async {
                        final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_date));
                        if (time == null || !mounted) return;
                        setState(() => _date = DateTime(_date.year, _date.month,
                            _date.day, time.hour, time.minute));
                        widget.onChanged(_date);
                      },
                child: const Text('Change time'))
          ]);
}
