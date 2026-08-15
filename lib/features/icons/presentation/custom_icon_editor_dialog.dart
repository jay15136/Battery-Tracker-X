import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/identity/permanent_id.dart';
import '../data/built_in_icon_registry.dart';
import '../domain/icon_color.dart';
import '../domain/icon_definition.dart';
import '../domain/icon_registry.dart';
import '../domain/icon_repository.dart';
import 'icon_visual.dart';

final class CustomIconEditorResult {
  const CustomIconEditorResult({
    required this.name,
    required this.categoryId,
    required this.supportsColor,
  });

  final String name;
  final PermanentId categoryId;
  final bool supportsColor;
}

class CustomIconEditorDialog extends StatefulWidget {
  const CustomIconEditorDialog({
    required this.scope,
    required this.categories,
    required this.applicationSupportRoot,
    required this.onCreateCategory,
    this.source,
    this.existing,
    super.key,
  }) : assert(source != null || existing != null);

  final IconScope scope;
  final List<IconCategoryRecord> categories;
  final Uri applicationSupportRoot;
  final Uri? source;
  final CustomIconRecord? existing;
  final Future<IconCategoryRecord> Function(String name, IconScope scope)
      onCreateCategory;

  static Future<CustomIconEditorResult?> show(
    BuildContext context, {
    required IconScope scope,
    required List<IconCategoryRecord> categories,
    required Uri applicationSupportRoot,
    required Future<IconCategoryRecord> Function(
      String name,
      IconScope scope,
    ) onCreateCategory,
    Uri? source,
    CustomIconRecord? existing,
  }) {
    return showDialog<CustomIconEditorResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomIconEditorDialog(
        scope: scope,
        categories: categories,
        applicationSupportRoot: applicationSupportRoot,
        onCreateCategory: onCreateCategory,
        source: source,
        existing: existing,
      ),
    );
  }

  @override
  State<CustomIconEditorDialog> createState() => _CustomIconEditorDialogState();
}

class _CustomIconEditorDialogState extends State<CustomIconEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late List<IconCategoryRecord> _categories;
  late PermanentId _categoryId;
  late bool _supportsColor;

  @override
  void initState() {
    super.initState();
    _categories = widget.categories
        .where(
          (category) =>
              category.scope == widget.scope ||
              category.scope == IconScope.general,
        )
        .toList(growable: true);
    final preferred = widget.existing?.category ??
        _categories.firstWhere(
          (category) => category.scope == widget.scope,
          orElse: () => _categories.first,
        );
    _categoryId = preferred.id;
    _nameController = TextEditingController(
      text: widget.existing?.name ?? _suggestedName(widget.source!),
    );
    _supportsColor = widget.existing?.supportsColor ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Import Custom Icon' : 'Edit Icon'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _preview(),
                const SizedBox(height: 20),
                TextFormField(
                  key: const ValueKey('custom-icon-name-field'),
                  controller: _nameController,
                  autofocus: true,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Icon name',
                    hintText: 'Example: Patrol Radio',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an icon name.'
                      : null,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _categoryId.value,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: [
                          for (final category in _categories)
                            DropdownMenuItem(
                              value: category.id.value,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _categoryId = PermanentId.parse(value);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _createCategory,
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('New Category'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  key: const ValueKey('custom-icon-supports-color'),
                  contentPadding: EdgeInsets.zero,
                  value: _supportsColor,
                  title: const Text('Allow icon color'),
                  subtitle: const Text(
                    'Apply the selected record color as a single-color tint.',
                  ),
                  onChanged: (value) {
                    setState(() => _supportsColor = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Icon'),
        ),
      ],
    );
  }

  Widget _preview() {
    final existing = widget.existing;
    final source = widget.source;
    final visual = existing != null
        ? IconVisual(
            definition: existing.toDefinition(),
            color: existing.toDefinition().defaultColor,
            fallbackDefinition: IconRegistry(
              builtIns: BuiltInIconRegistry.definitions,
            ).defaultFor(widget.scope),
            applicationSupportRoot: widget.applicationSupportRoot,
            size: 76,
          )
        : _sourcePreview(source!);
    return Container(
      height: 130,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: visual,
    );
  }

  Widget _sourcePreview(Uri source) {
    final file = File.fromUri(source);
    if (file.path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        file,
        width: 76,
        height: 76,
        colorFilter: _supportsColor
            ? ColorFilter.mode(
                Color(IconColor.defaultColor.argbValue),
                BlendMode.srcIn,
              )
            : null,
      );
    }
    return Image.file(
      file,
      width: 76,
      height: 76,
      fit: BoxFit.contain,
      color: _supportsColor ? Color(IconColor.defaultColor.argbValue) : null,
      colorBlendMode: _supportsColor ? BlendMode.srcIn : null,
    );
  }

  Future<void> _createCategory() async {
    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _CreateCategoryDialog(),
    );
    if (name == null || !mounted) {
      return;
    }
    try {
      final category = await widget.onCreateCategory(name, widget.scope);
      if (!mounted) {
        return;
      }
      setState(() {
        _categories.add(category);
        _categories.sort((left, right) => left.name.compareTo(right.name));
        _categoryId = category.id;
      });
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The category could not be created.')),
        );
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      CustomIconEditorResult(
        name: _nameController.text.trim(),
        categoryId: _categoryId,
        supportsColor: _supportsColor,
      ),
    );
  }

  static String _suggestedName(Uri source) {
    final name = File.fromUri(source).uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    final withoutExtension = dot <= 0 ? name : name.substring(0, dot);
    return withoutExtension
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _CreateCategoryDialog extends StatefulWidget {
  const _CreateCategoryDialog();

  @override
  State<_CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<_CreateCategoryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Icon Category'),
      content: TextField(
        key: const ValueKey('category-name-field'),
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        decoration: const InputDecoration(labelText: 'Category name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create Category'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      Navigator.of(context).pop(name);
    }
  }
}
