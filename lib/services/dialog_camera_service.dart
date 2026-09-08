import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'camera_service.dart';

/// Native camera UI stays outside inventory and photo domain code.
final class DialogCameraService implements CameraService {
  const DialogCameraService(this.context,
      {this.loadCameras = availableCameras});
  final BuildContext context;
  final Future<List<CameraDescription>> Function() loadCameras;
  @override
  Future<Uri?> capturePhoto() => showDialog<Uri>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CaptureDialog(loadCameras: loadCameras));
}

class _CaptureDialog extends StatefulWidget {
  const _CaptureDialog({required this.loadCameras});
  final Future<List<CameraDescription>> Function() loadCameras;
  @override
  State<_CaptureDialog> createState() => _CaptureDialogState();
}

class _CaptureDialogState extends State<_CaptureDialog>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  String? _error;
  bool _busy = true;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _discover();
  }

  Future<void> _discover() async {
    try {
      _cameras = await widget.loadCameras();
      if (_cameras.isEmpty) throw const _CameraUnavailable();
      if (mounted) await _open(_cameras.first);
    } on Object catch (e, s) {
      _fail(e, s);
    }
  }

  Future<void> _open(CameraDescription camera) async {
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    final previous = _controller;
    _controller = null;
    await previous?.dispose();
    final next =
        CameraController(camera, ResolutionPreset.high, enableAudio: false);
    try {
      await next.initialize();
      if (!mounted || generation != _generation) {
        await next.dispose();
        return;
      }
      setState(() {
        _controller = next;
        _busy = false;
      });
    } on Object catch (e, s) {
      await next.dispose();
      if (generation == _generation) _fail(e, s);
    }
  }

  void _fail(Object error, StackTrace stack) {
    Logger('camera').warning('Camera operation failed.', error, stack);
    if (mounted)
      setState(() {
        _busy = false;
        _error = error is _CameraUnavailable
            ? 'No camera was found. Connect a webcam or choose a photograph from your computer.'
            : 'The camera is unavailable. Check camera permissions or choose a photograph from your computer.';
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _generation++;
      final old = _controller;
      _controller = null;
      if (old != null) unawaited(old.dispose());
      if (mounted)
        setState(() {
          _busy = false;
          _error = 'Camera paused. Choose Retry to resume.';
        });
    }
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    final old = _controller;
    if (old != null) unawaited(old.dispose());
    super.dispose();
  }

  Future<void> _capture() async {
    final camera = _controller;
    if (camera == null) return;
    setState(() => _busy = true);
    try {
      final image = await camera.takePicture();
      if (mounted) Navigator.pop(context, File(image.path).uri);
    } on Object catch (e, s) {
      _fail(e, s);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Capture Photograph'),
          content: SizedBox(
              width: 640,
              height: 400,
              child: Column(children: [
                if (_cameras.length > 1)
                  DropdownButton<CameraDescription>(
                      isExpanded: true,
                      value: _controller?.description,
                      items: [
                        for (final camera in _cameras)
                          DropdownMenuItem(
                              value: camera,
                              child: Text(camera.name,
                                  overflow: TextOverflow.ellipsis))
                      ],
                      onChanged: _busy
                          ? null
                          : (c) {
                              if (c != null) _open(c);
                            }),
                Expanded(
                    child: _error != null
                        ? Center(child: Text(_error!))
                        : _controller == null
                            ? const Center(child: CircularProgressIndicator())
                            : CameraPreview(_controller!)),
              ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            if (_error != null)
              TextButton(
                  onPressed: _busy ? null : _discover,
                  child: const Text('Retry')),
            FilledButton(
                onPressed: _busy || _controller == null ? null : _capture,
                child: const Text('Take Photograph'))
          ]);
}

class _CameraUnavailable implements Exception {
  const _CameraUnavailable();
}
