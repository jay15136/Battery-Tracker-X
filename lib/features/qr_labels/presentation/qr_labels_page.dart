import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../services/file_selection_service.dart';
import '../../batteries/presentation/batteries_page.dart';
import '../../battery_sets/presentation/battery_sets_page.dart';
import '../../devices/presentation/devices_page.dart';
import '../../icons/presentation/inventory_icon.dart';
import '../application/canvas_label_renderer.dart';
import '../domain/labels.dart';
import 'label_pages_preview.dart';

class QrLabelsDialog extends StatelessWidget {
  const QrLabelsDialog({this.initialRefs = const [], super.key});
  final List<LabelRef> initialRefs;
  @override
  Widget build(BuildContext context) => Dialog(
      child: SizedBox(
          width: 1250,
          height: MediaQuery.sizeOf(context).height * .92,
          child: Column(children: [
            Expanded(
                child:
                    QrLabelsPage(initialRefs: initialRefs, closeDialog: true)),
          ])));
}

class QrLabelsPage extends ConsumerStatefulWidget {
  const QrLabelsPage(
      {this.initialRefs = const [], this.closeDialog = false, super.key});
  final List<LabelRef> initialRefs;
  final bool closeDialog;
  @override
  ConsumerState<QrLabelsPage> createState() => _QrLabelsPageState();
}

class _QrLabelsPageState extends ConsumerState<QrLabelsPage> {
  final _selected = <LabelRef>{}, _fields = <String>{'id', 'name'};
  final _values = <String, TextEditingController>{};
  final _lookup = TextEditingController(),
      _custom = TextEditingController(),
      _templateName = TextEditingController();
  List<LabelTarget> _inventory = [];
  List<LabelTemplate> _templates = [];
  List<LabelJob> _jobs = [];
  PermanentId? _template;
  String _search = '', _align = 'left', _orientation = 'landscape';
  bool _icon = true, _photo = false, _sheet = false, _busy = false;
  String? _error, _notice;
  Future<Uint8List>? _preview;
  Timer? _timer;
  static const labels = {
    'width': 'Label width (in)',
    'height': 'Label height (in)',
    'qrSize': 'QR size (in)',
    'fontSize': 'Text size (pt)',
    'margin': 'Label margin (in)',
    'paperWidth': 'Paper width (in)',
    'paperHeight': 'Paper height (in)',
    'rows': 'Rows',
    'columns': 'Columns',
    'marginX': 'Page side margins (in)',
    'marginY': 'Page top/bottom margins (in)',
    'gapX': 'Horizontal gap (in)',
    'gapY': 'Vertical gap (in)',
    'start': 'Starting label position'
  };
  @override
  void initState() {
    super.initState();
    for (final k in labels.keys) {
      _values[k] = TextEditingController();
    }
    _selected.addAll(widget.initialRefs);
    _applyLayout(LabelLayout(), const LabelSheet());
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [..._values.values, _lookup, _custom, _templateName]) {
      c.dispose();
    }
    super.dispose();
  }

  LabelRepository get _repo => ref.read(labelRepositoryProvider);
  Future<void> _run(Future<void> Function() work) async {
    if (_busy) return;
    final logger = ref.read(appLogServiceProvider).logger('labels.ui');
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await work();
    } on LabelValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      logger.severe('Label operation failed.', e, s);
      if (mounted)
        setState(() => _error =
            'The label operation could not be completed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _load() => _run(() async {
        _inventory = await _repo.inventory();
        _templates = await _repo.templates();
        _jobs = await _repo.jobs();
        _refreshPreview();
      });
  void _applyLayout(LabelLayout l, LabelSheet s) {
    final j = {...l.toJson(), ...s.toJson()};
    for (final key in labels.keys) {
      final value = j[key] as num;
      _values[key]!.text =
          ['rows', 'columns', 'start', 'fontSize'].contains(key)
              ? value.toString()
              : (value / 72).toStringAsFixed(4);
    }
    _align = l.align;
    _orientation = l.orientation;
    _icon = l.showIcon;
    _photo = l.usePhoto;
    _sheet = s.enabled;
    _fields
      ..clear()
      ..addAll(l.fields);
    _custom.text = l.customText;
  }

  double _number(String key) {
    final v = double.tryParse(_values[key]!.text);
    if (v == null || !v.isFinite)
      throw LabelValidationException('Enter a valid ' + labels[key]! + '.');
    return ['fontSize', 'rows', 'columns', 'start'].contains(key) ? v : v * 72;
  }

  int _integer(String key) {
    final n = _number(key);
    if (n != n.roundToDouble())
      throw LabelValidationException(labels[key]! + ' must be a whole number.');
    return n.toInt();
  }

  LabelLayout _layout() => LabelLayout(
      width: _number('width'),
      height: _number('height'),
      qrSize: _number('qrSize'),
      fontSize: _number('fontSize'),
      margin: _number('margin'),
      align: _align,
      orientation: _orientation,
      showIcon: _icon,
      usePhoto: _photo,
      fields: _fields.toList(),
      customText: _custom.text);
  LabelSheet _sheetLayout() => LabelSheet(
      enabled: _sheet,
      paperWidth: _number('paperWidth'),
      paperHeight: _number('paperHeight'),
      rows: _integer('rows'),
      columns: _integer('columns'),
      marginX: _number('marginX'),
      marginY: _number('marginY'),
      gapX: _number('gapX'),
      gapY: _number('gapY'),
      start: _integer('start'));
  void _refreshPreview() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _preview = _renderSample();
        _preview!.ignore();
      });
    });
  }

  Future<Uint8List> _renderSample() async {
    final l = _layout();
    _sheetLayout().validate(l);
    final target =
        _inventory.where((t) => _selected.contains(t.ref)).firstOrNull ??
            _inventory.firstOrNull;
    if (target == null)
      throw const LabelValidationException('Add inventory to preview a label.');
    return ref.read(labelRendererProvider).renderLabel(target, l);
  }

  Future<List<LabelTarget>> _targets() async {
    if (_selected.isEmpty)
      throw const LabelValidationException('Select at least one record.');
    return Future.wait(_selected.map(_repo.resolve));
  }

  Future<String?> _name(String title) async {
    var name = '';
    return showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(title),
                content: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (v) => name = v),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, name),
                      child: const Text('Save'))
                ]));
  }

  Future<void> _output(bool print) => _run(() async {
        final repository = _repo;
        final renderer = ref.read(labelRendererProvider);
        final printer = ref.read(printServiceProvider);
        final files = ref.read(fileSelectionServiceProvider);
        final targets = await _targets(), l = _layout(), s = _sheetLayout();
        final bytes = await renderer.renderPdf(LabelDocument(targets, l, s));
        if (print) {
          final done = await printer.printPdf(
              bytes: bytes,
              jobName: 'Battery Tracker Labels',
              pageWidth: s.enabled ? s.paperWidth : l.pageWidth,
              pageHeight: s.enabled ? s.paperHeight : l.pageHeight);
          if (!done) {
            if (mounted) setState(() => _notice = 'Printing canceled.');
            return;
          }
        } else {
          final path = await files.chooseSaveLocation(
              suggestedFileName: 'Battery Tracker Labels.pdf');
          if (path == null) return;
          await File.fromUri(path).writeAsBytes(bytes, flush: true);
        }
        await repository.recordOutput(
            print ? 'qr_labels_printed' : 'qr_labels_exported',
            targets.map((t) => t.ref).toList());
        if (mounted)
          setState(() => _notice = print
              ? 'Labels submitted to the print system.'
              : 'PDF exported.');
      });
  Future<void> _openLookup(String value) async {
    final target = await _repo.resolve(LabelRef.parse(value));
    if (!mounted) return;
    await showDialog<void>(
        context: context,
        builder: (c) => Dialog(
            child: SizedBox(
                width: 1200,
                height: MediaQuery.sizeOf(c).height * .9,
                child: Column(children: [
                  Text('QR match: ' + target.title),
                  Expanded(
                      child: switch (target.ref.kind) {
                    LabelKind.battery =>
                      BatteriesPage(initialId: target.ref.id),
                    LabelKind.set => BatterySetsPage(initialId: target.ref.id),
                    LabelKind.device => DevicesPage(initialId: target.ref.id)
                  }),
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Close record'))
                ]))));
  }

  Future<void> _scan(bool camera) => _run(() async {
        final path = camera
            ? await ref
                .read(cameraServiceFactoryProvider)(context)
                .capturePhoto()
            : await ref
                .read(fileSelectionServiceProvider)
                .chooseOpenFile(acceptedTypes: const [
                FileTypeFilter(
                    label: 'QR image',
                    extensions: ['png', 'jpg', 'jpeg', 'webp'])
              ]);
        if (path == null) return;
        final file = File.fromUri(path);
        if (await file.length() > 30 * 1024 * 1024)
          throw const LabelValidationException('Use a QR image under 30 MB.');
        final uri = await ref
            .read(qrCodeServiceProvider)
            .decode(await file.readAsBytes());
        if (uri == null)
          throw const LabelValidationException(
              'No readable QR code found. Try a sharper, closer image.');
        _lookup.text = uri.toString();
        await _openLookup(uri.toString());
      });
  @override
  Widget build(BuildContext context) {
    final visible = _inventory
        .where((t) =>
            (t.title + ' ' + t.ref.kind.host).toLowerCase().contains(_search))
        .toList();
    return PopScope(
        canPop: !_busy,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(children: [
              if (widget.closeDialog)
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        child: const Text('Close labels'))),
              Text('QR Labels',
                  style: Theme.of(context).textTheme.headlineMedium),
              const Text(
                  'QR values use permanent UUIDs. Preview and PDF use the same 600-dpi label rendering. Print at actual size (100%).'),
              if (_busy) const Text('Working…'),
              if (_error != null)
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              if (_notice != null) Text(_notice!),
              Wrap(spacing: 8, runSpacing: 8, children: [
                SizedBox(
                    width: 460,
                    child: TextField(
                        controller: _lookup,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                            labelText: 'Enter or paste QR value'),
                        onSubmitted: (v) => _run(() => _openLookup(v)))),
                OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() => _openLookup(_lookup.text)),
                    child: const Text('Open QR record')),
                OutlinedButton(
                    onPressed: _busy ? null : () => _scan(false),
                    child: const Text('Read QR image')),
                OutlinedButton(
                    onPressed: _busy ? null : () => _scan(true),
                    child: const Text('Capture QR with webcam'))
              ]),
              const SizedBox(height: 12),
              Text(_selected.length.toString() + ' labels selected'),
              Wrap(spacing: 8, children: [
                SizedBox(
                    width: 300,
                    child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Find label records'),
                        onChanged: (v) =>
                            setState(() => _search = v.toLowerCase()))),
                TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _selected.addAll(visible.map((t) => t.ref));
                              _refreshPreview();
                            }),
                    child: const Text('Select matching')),
                TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _selected.clear();
                              _refreshPreview();
                            }),
                    child: const Text('Clear selection')),
                TextButton(
                    onPressed: _busy ? null : _load,
                    child: const Text('Refresh inventory'))
              ]),
              SizedBox(
                  height: 230,
                  child: ListView(children: [
                    if (visible.isEmpty)
                      const Text('No matching inventory records.'),
                    for (final t in visible)
                      CheckboxListTile(
                          value: _selected.contains(t.ref),
                          onChanged: _busy
                              ? null
                              : (v) => setState(() {
                                    if (v == true) {
                                      _selected.add(t.ref);
                                    } else {
                                      _selected.remove(t.ref);
                                    }
                                    _refreshPreview();
                                  }),
                          secondary: InventoryIcon(
                              selection: t.icon,
                              scope: t.ref.kind.scope,
                              size: 32),
                          title: Text(t.title + ' · ' + t.ref.kind.host),
                          subtitle: t.ref.kind == LabelKind.set
                              ? TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _run(() async {
                                            _selected.addAll(await _repo
                                                .setMembers(t.ref.id));
                                            _refreshPreview();
                                          }),
                                  child: const Text('Select Set member labels'))
                              : null)
                  ])),
              const Divider(),
              Text('Label designer',
                  style: Theme.of(context).textTheme.titleLarge),
              Wrap(spacing: 12, runSpacing: 12, children: [
                SizedBox(
                    width: 240,
                    child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'Size preset'),
                        items: [
                          for (final name in LabelLayout.presets.keys)
                            DropdownMenuItem(value: name, child: Text(name))
                        ],
                        onChanged: _busy
                            ? null
                            : (v) => setState(() {
                                  _applyLayout(
                                      LabelLayout.presets[v]!,
                                      v == 'Address Label Sheet'
                                          ? const LabelSheet(enabled: true)
                                          : const LabelSheet());
                                  _template = null;
                                  _refreshPreview();
                                }))),
                SizedBox(
                    width: 240,
                    child: DropdownButtonFormField<PermanentId>(
                        key: ValueKey(_template),
                        initialValue: _template,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'Saved template'),
                        items: [
                          for (final t in _templates)
                            DropdownMenuItem(value: t.id, child: Text(t.name))
                        ],
                        onChanged: _busy
                            ? null
                            : (id) => setState(() {
                                  final t =
                                      _templates.firstWhere((t) => t.id == id);
                                  _template = id;
                                  _templateName.text = t.name;
                                  _applyLayout(t.layout, t.sheet);
                                  _refreshPreview();
                                }))),
                SizedBox(
                    width: 240,
                    child: TextField(
                        controller: _templateName,
                        decoration:
                            const InputDecoration(labelText: 'Template name'))),
                OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() async {
                              await _repo.saveTemplate(
                                  _templateName.text,
                                  _selected.firstOrNull?.kind ??
                                      LabelKind.battery,
                                  _layout(),
                                  _sheetLayout());
                              _templates = await _repo.templates();
                              _notice = 'Template saved.';
                            }),
                    child: const Text('Save new template')),
                OutlinedButton(
                    onPressed: _busy || _template == null
                        ? null
                        : () => _run(() async {
                              await _repo.saveTemplate(
                                  _templateName.text,
                                  _selected.firstOrNull?.kind ??
                                      LabelKind.battery,
                                  _layout(),
                                  _sheetLayout(),
                                  id: _template);
                              _templates = await _repo.templates();
                              _notice = 'Template updated.';
                            }),
                    child: const Text('Update template'))
              ]),
              Wrap(spacing: 12, runSpacing: 8, children: [
                for (final k in [
                  'width',
                  'height',
                  'qrSize',
                  'fontSize',
                  'margin'
                ])
                  _field(k),
                SizedBox(
                    width: 170,
                    child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        key: ValueKey('orientation-' + _orientation),
                        initialValue: _orientation,
                        decoration:
                            const InputDecoration(labelText: 'Orientation'),
                        items: [
                          for (final v in ['landscape', 'portrait'])
                            DropdownMenuItem(value: v, child: Text(v))
                        ],
                        onChanged: _busy
                            ? null
                            : (v) => setState(() {
                                  _orientation = v!;
                                  _refreshPreview();
                                }))),
                SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        key: ValueKey('align-' + _align),
                        initialValue: _align,
                        decoration:
                            const InputDecoration(labelText: 'Alignment'),
                        items: [
                          for (final v in ['left', 'center', 'right'])
                            DropdownMenuItem(value: v, child: Text(v))
                        ],
                        onChanged: _busy
                            ? null
                            : (v) => setState(() {
                                  _align = v!;
                                  _refreshPreview();
                                })))
              ]),
              Wrap(spacing: 8, children: [
                for (final f in labelFields.entries)
                  FilterChip(
                      label: Text(f.value),
                      selected: _fields.contains(f.key),
                      onSelected: _busy
                          ? null
                          : (v) => setState(() {
                                if (v) {
                                  _fields.add(f.key);
                                } else {
                                  _fields.remove(f.key);
                                }
                                _refreshPreview();
                              }))
              ]),
              SwitchListTile(
                  title: const Text('Include icon'),
                  value: _icon,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() {
                            _icon = v;
                            _refreshPreview();
                          })),
              SwitchListTile(
                  title: const Text('Use photograph when available'),
                  subtitle: const Text(
                      'Missing or unreadable photographs fall back to the icon.'),
                  value: _photo,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() {
                            _photo = v;
                            _refreshPreview();
                          })),
              TextField(
                  controller: _custom,
                  enabled: !_busy,
                  decoration: const InputDecoration(labelText: 'Custom text'),
                  onChanged: (_) => _refreshPreview()),
              Text('Live label preview',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                  height: 220,
                  child: FutureBuilder<Uint8List>(
                      future: _preview,
                      builder: (c, s) {
                        if (s.hasError)
                          return Center(
                              child: Text(s.error is LabelValidationException
                                  ? (s.error as LabelValidationException)
                                      .message
                                  : 'Label preview unavailable.'));
                        if (!s.hasData)
                          return const Center(
                              child: Text('Preparing preview…'));
                        return Center(
                            child: Image.memory(s.data!,
                                fit: BoxFit.contain, gaplessPlayback: true));
                      })),
              SwitchListTile(
                  title: const Text('Print on label sheets'),
                  value: _sheet,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() {
                            _sheet = v;
                            _refreshPreview();
                          })),
              if (_sheet) ...[
                Wrap(spacing: 8, children: [
                  TextButton(
                      onPressed: () => setState(() {
                            _values['paperWidth']!.text = '8.5';
                            _values['paperHeight']!.text = '11';
                            _refreshPreview();
                          }),
                      child: const Text('Letter paper')),
                  TextButton(
                      onPressed: () => setState(() {
                            _values['paperWidth']!.text = '8.2677';
                            _values['paperHeight']!.text = '11.6929';
                            _refreshPreview();
                          }),
                      child: const Text('A4 paper'))
                ]),
                Wrap(spacing: 12, runSpacing: 8, children: [
                  for (final k in [
                    'paperWidth',
                    'paperHeight',
                    'rows',
                    'columns',
                    'marginX',
                    'marginY',
                    'gapX',
                    'gapY',
                    'start'
                  ])
                    _field(k)
                ])
              ],
              Wrap(spacing: 12, runSpacing: 8, children: [
                FilledButton(
                    onPressed: _busy || _selected.isEmpty
                        ? null
                        : () => _run(() async {
                              final targets = await _targets(),
                                  l = _layout(),
                                  s = _sheetLayout();
                              s.positions(targets.length, l);
                              if (!mounted) return;
                              await showDialog<void>(
                                  context: context,
                                  builder: (_) => LabelPagesPreview(
                                      targets: targets,
                                      layout: l,
                                      sheet: s,
                                      renderer:
                                          ref.read(labelRendererProvider)));
                            }),
                    child: const Text('Preview pages')),
                FilledButton(
                    onPressed: _busy || _selected.isEmpty
                        ? null
                        : () => _output(false),
                    child: const Text('Export labels to PDF')),
                OutlinedButton(
                    onPressed:
                        _busy || _selected.isEmpty ? null : () => _output(true),
                    child: const Text('Print labels')),
                OutlinedButton(
                    onPressed: _busy || _selected.isEmpty
                        ? null
                        : () => _run(() async {
                              final name = await _name('Save labels for later');
                              if (name == null) return;
                              await _repo.saveJob(name, _selected.toList(),
                                  _layout(), _sheetLayout());
                              _jobs = await _repo.jobs();
                              _notice = 'Labels saved for later.';
                            }),
                    child: const Text('Save for later')),
                SizedBox(
                    width: 250,
                    child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Saved label selections'),
                        items: [
                          for (final j in _jobs)
                            DropdownMenuItem(value: j.id, child: Text(j.name))
                        ],
                        onChanged: _busy
                            ? null
                            : (id) => setState(() {
                                  final j = _jobs.firstWhere((j) => j.id == id);
                                  _selected
                                    ..clear()
                                    ..addAll(j.refs);
                                  _applyLayout(j.layout, j.sheet);
                                  _refreshPreview();
                                })))
              ]),
              if (_error != null)
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              if (_notice != null) Text(_notice!),
            ])));
  }

  Widget _field(String key) => SizedBox(
      width: 170,
      child: TextField(
          key: ValueKey('label-' + key),
          controller: _values[key],
          enabled: !_busy,
          decoration: InputDecoration(labelText: labels[key]),
          onChanged: (_) => _refreshPreview()));
}
