import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../services/file_selection_service.dart';
import '../../../services/photograph_drop_target.dart';
import '../application/photo_providers.dart';
import '../domain/photo.dart';
import 'photo_visual.dart';

class PhotoManagerDialog extends ConsumerStatefulWidget {
  const PhotoManagerDialog(
      {required this.owner, required this.fallback, super.key});
  final PhotoOwner owner;
  final Widget fallback;
  @override
  ConsumerState<PhotoManagerDialog> createState() => _PhotoManagerDialogState();
}

class _PhotoManagerDialogState extends ConsumerState<PhotoManagerDialog> {
  bool _busy = false;
  bool _choosingVisual = false;
  String? _error;
  final _reported = <String>{};
  static const _types = [
    FileTypeFilter(
        label: 'Photographs', extensions: ['png', 'jpg', 'jpeg', 'webp'])
  ];
  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(photoGalleryProvider(widget.owner));
    return PopScope(
        canPop: !_busy,
        child: AlertDialog(
            title: const Text('Photographs'),
            content: SizedBox(
                width: 760,
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text(
                          'Icons identify inventory. Photographs add detail.'),
                      const SizedBox(height: 12),
                      if (_error != null)
                        Text(_error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        FilledButton.icon(
                            onPressed: _busy ? null : () => _pick(),
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Add Photograph')),
                        OutlinedButton.icon(
                            onPressed: _busy ? null : _camera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Capture Photograph')),
                        TextButton(
                            onPressed: _busy
                                ? null
                                : () => _run(() => ref
                                    .read(photoServiceProvider)
                                    .repository
                                    .preferIcon(widget.owner)),
                            child: const Text('Use Icon as Primary')),
                      ]),
                      const SizedBox(height: 12),
                      PhotographDropTarget(
                          enabled: !_busy,
                          onFiles: (files) => _drop(files),
                          child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text(
                                  'Drop PNG, JPEG, or WebP photographs here. Maximum 25 MB and 40 megapixels each.'))),
                      if (_busy && !_choosingVisual)
                        const LinearProgressIndicator(),
                      const SizedBox(height: 16),
                      gallery.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (e, s) {
                            ref
                                .read(appLogServiceProvider)
                                .logger('photos')
                                .warning(
                                    'Photo gallery could not be loaded.', e, s);
                            return TextButton(
                                onPressed: () => ref.invalidate(
                                    photoGalleryProvider(widget.owner)),
                                child: const Text(
                                    'Could not load photographs. Retry'));
                          },
                          data: (g) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        g.preferPhoto
                                            ? 'Primary visual: Photograph'
                                            : 'Primary visual: Icon',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    if (g.photos.isEmpty)
                                      const Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Text(
                                              'No photographs. Your icon is ready to use.')),
                                    for (final photo in g.photos)
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: Card(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        PhotoVisual(
                                                            root: ref.watch(
                                                                applicationSupportRootProvider),
                                                            path:
                                                                photo.file.path,
                                                            fallback: Column(
                                                                children: [
                                                                  widget
                                                                      .fallback,
                                                                  const Text(
                                                                      'Photograph unavailable — using icon.')
                                                                ]),
                                                            size: 180,
                                                            onUnavailable: () =>
                                                                _report(photo)),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                            photo.file.filename,
                                                            softWrap: true),
                                                        Text(
                                                            '${photo.file.width} × ${photo.file.height}${photo.isPrimary ? ' • Primary photograph' : ''}'),
                                                        Wrap(
                                                            spacing: 8,
                                                            children: [
                                                              TextButton(
                                                                  onPressed: _busy
                                                                      ? null
                                                                      : () => _run(() => ref
                                                                          .read(
                                                                              photoServiceProvider)
                                                                          .usePhoto(
                                                                              widget
                                                                                  .owner,
                                                                              photo)),
                                                                  child: const Text(
                                                                      'Use Photo as Primary')),
                                                              TextButton(
                                                                  onPressed: _busy
                                                                      ? null
                                                                      : () => _run(() => ref.read(photoServiceProvider).repository.choosePrimary(
                                                                          widget
                                                                              .owner,
                                                                          photo
                                                                              .id,
                                                                          preferPhoto: g
                                                                              .preferPhoto)),
                                                                  child: const Text(
                                                                      'Select primary photograph')),
                                                              TextButton(
                                                                  onPressed: _busy
                                                                      ? null
                                                                      : () => _pick(
                                                                          replace: photo
                                                                              .id),
                                                                  child: const Text(
                                                                      'Replace')),
                                                              TextButton(
                                                                  onPressed: _busy
                                                                      ? null
                                                                      : () => _remove(
                                                                          photo),
                                                                  child: const Text(
                                                                      'Remove')),
                                                            ]),
                                                      ])))),
                                  ])),
                    ]))),
            actions: [
              TextButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  child: const Text('Done'))
            ]));
  }

  void _report(PhotoRecord photo) {
    if (_reported.add(photo.file.path.value))
      ref.read(appLogServiceProvider).logger('photos').warning(
          'Photograph missing or unreadable: ${photo.file.path.value}');
  }

  Future<void> _run(Future<void> Function() work) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await work();
    } on Object catch (e, s) {
      ref
          .read(appLogServiceProvider)
          .logger('photos')
          .warning('Photograph operation failed.', e, s);
      if (mounted)
        setState(() => _error = e is PhotoException
            ? e.message
            : 'The photograph operation could not be completed. Please try again.');
    } finally {
      if (mounted) {
        ref.invalidate(photoGalleryProvider(widget.owner));
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _pick({PermanentId? replace}) => _run(() async {
        final source = await ref
            .read(fileSelectionServiceProvider)
            .chooseOpenFile(acceptedTypes: _types);
        if (source == null || !mounted) return;
        if (replace != null) {
          await ref
              .read(photoServiceProvider)
              .replace(widget.owner, replace, source);
        } else {
          await _import(source);
        }
      });
  Future<void> _camera() => _run(() async {
        final source = await ref
            .read(cameraServiceFactoryProvider)(context)
            .capturePhoto();
        if (source != null && mounted) await _import(source);
      });
  Future<void> _drop(List<Uri> sources) => _run(() async {
        var imported = 0;
        PermanentId? lastImported;
        try {
          for (final source in sources) {
            lastImported =
                await ref.read(photoServiceProvider).add(widget.owner, source);
            imported++;
          }
        } on Object catch (e, s) {
          ref
              .read(appLogServiceProvider)
              .logger('photos')
              .warning('Dropped photograph import failed.', e, s);
          throw PhotoException(
              '$imported of ${sources.length} photographs imported. Remaining files were not imported; check their format and size.');
        }
        if (lastImported != null && mounted) await _choice(lastImported);
      });
  Future<void> _import(Uri source) async {
    final id = await ref.read(photoServiceProvider).add(widget.owner, source);
    if (mounted) await _choice(id);
  }

  Future<void> _choice(PermanentId id) async {
    setState(() => _choosingVisual = true);
    final choice = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Photograph added'),
                content:
                    const Text('Choose the primary visual for this record.'),
                actions: [
                  OutlinedButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Use Photo as Primary')),
                  FilledButton(
                      autofocus: true,
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Keep Icon as Primary'))
                ]));
    if (!mounted) return;
    setState(() => _choosingVisual = false);
    if (choice == null) return;
    final service = ref.read(photoServiceProvider);
    if (choice) {
      final gallery = await service.repository.gallery(widget.owner);
      await service.usePhoto(
          widget.owner, gallery.photos.firstWhere((photo) => photo.id == id));
    } else {
      await service.repository.preferIcon(widget.owner);
    }
  }

  Future<void> _remove(PhotoRecord photo) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Remove photograph?'),
                content: const Text(
                    'The inventory record and its icon will remain. Removing the primary photograph switches back to the icon.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Remove'))
                ]));
    if (confirm == true && mounted)
      await _run(
          () => ref.read(photoServiceProvider).remove(widget.owner, photo.id));
  }
}
