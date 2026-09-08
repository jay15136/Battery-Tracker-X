import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../application/canvas_label_renderer.dart';
import '../domain/labels.dart';

class LabelPagesPreview extends StatefulWidget {
  const LabelPagesPreview(
      {required this.targets,
      required this.layout,
      required this.sheet,
      required this.renderer,
      super.key});
  final List<LabelTarget> targets;
  final LabelLayout layout;
  final LabelSheet sheet;
  final LabelRenderer renderer;
  @override
  State<LabelPagesPreview> createState() => _LabelPagesPreviewState();
}

class _LabelPagesPreviewState extends State<LabelPagesPreview> {
  int _page = 0;
  late List<LabelPlacement> _positions;
  late Future<Map<int, Uint8List>> _images;
  @override
  void initState() {
    super.initState();
    _positions = widget.sheet.positions(widget.targets.length, widget.layout);
    _images = _render();
  }

  Future<Map<int, Uint8List>> _render() async {
    final page = _page;
    final result = <int, Uint8List>{};
    for (final p in _positions.where((p) => p.page == page)) {
      result[p.index] = await widget.renderer
          .renderLabel(widget.targets[p.index], widget.layout);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.sheet.enabled
            ? widget.sheet.paperWidth
            : widget.layout.pageWidth,
        h = widget.sheet.enabled
            ? widget.sheet.paperHeight
            : widget.layout.pageHeight;
    return AlertDialog(
        title: Text('Print preview · Page ' +
            (_page + 1).toString() +
            ' of ' +
            (_positions.last.page + 1).toString()),
        content: SizedBox(
            width: 800,
            height: MediaQuery.sizeOf(context).height * .7,
            child: FutureBuilder<Map<int, Uint8List>>(
                future: _images,
                builder: (c, s) {
                  if (s.hasError)
                    return Text(s.error is LabelValidationException
                        ? (s.error as LabelValidationException).message
                        : 'Preview could not be rendered.');
                  if (s.connectionState != ConnectionState.done || !s.hasData)
                    return const Center(child: CircularProgressIndicator());
                  return Center(
                      child: AspectRatio(
                          aspectRatio: w / h,
                          child: LayoutBuilder(
                              builder: (c, b) => Container(
                                  color: Colors.white,
                                  child: Stack(children: [
                                    for (final p in _positions
                                        .where((p) => p.page == _page))
                                      Positioned(
                                          left: p.x / w * b.maxWidth,
                                          top: p.y / h * b.maxHeight,
                                          width: widget.layout.pageWidth /
                                              w *
                                              b.maxWidth,
                                          height: widget.layout.pageHeight /
                                              h *
                                              b.maxHeight,
                                          child: Image.memory(s.data![p.index]!,
                                              fit: BoxFit.fill))
                                  ])))));
                })),
        actions: [
          TextButton(
              onPressed: _page == 0
                  ? null
                  : () => setState(() {
                        _page--;
                        _images = _render();
                      }),
              child: const Text('Previous page')),
          TextButton(
              onPressed: _page == _positions.last.page
                  ? null
                  : () => setState(() {
                        _page++;
                        _images = _render();
                      }),
              child: const Text('Next page')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close preview'))
        ]);
  }
}
