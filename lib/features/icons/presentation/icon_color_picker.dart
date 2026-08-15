import 'package:flutter/material.dart';

import '../domain/icon_color.dart';

class IconColorPicker extends StatefulWidget {
  const IconColorPicker({
    required this.selected,
    required this.defaultColor,
    required this.onChanged,
    super.key,
  });

  final IconColor selected;
  final IconColor defaultColor;
  final ValueChanged<IconColor> onChanged;

  @override
  State<IconColorPicker> createState() => _IconColorPickerState();
}

class _IconColorPickerState extends State<IconColorPicker> {
  late final TextEditingController _customController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(text: widget.selected.value);
  }

  @override
  void didUpdateWidget(covariant IconColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected &&
        _customController.text.toUpperCase() != widget.selected.value) {
      _customController.text = widget.selected.value;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icon Color', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in IconColor.presets)
              ChoiceChip(
                key: ValueKey('icon-color-${preset.color.value}'),
                selected: widget.selected == preset.color,
                avatar: _ColorSwatch(color: preset.color),
                label: Text(preset.label),
                onSelected: (_) => _select(preset.color),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                key: const ValueKey('custom-icon-color-field'),
                controller: _customController,
                decoration: InputDecoration(
                  labelText: 'Custom hexadecimal color',
                  hintText: '#3F51B5',
                  errorText: _error,
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: _submitCustom,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton.icon(
                onPressed: () => _select(widget.defaultColor),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset Icon Color'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _select(IconColor color) {
    setState(() {
      _error = null;
      _customController.text = color.value;
    });
    widget.onChanged(color);
  }

  void _submitCustom(String value) {
    try {
      _select(IconColor.parse(value));
    } on FormatException {
      setState(() {
        _error = 'Use six hexadecimal digits, such as #3F51B5.';
      });
    }
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});

  final IconColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Color(color.argbValue),
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}
