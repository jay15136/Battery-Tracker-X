import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

/// Converts plugin files to local URIs at the platform boundary.
class PhotographDropTarget extends StatelessWidget {
  const PhotographDropTarget(
      {required this.child,
      required this.onFiles,
      this.enabled = true,
      super.key});
  final Widget child;
  final void Function(List<Uri>) onFiles;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    if (!(Platform.isWindows || Platform.isMacOS || Platform.isLinux))
      return child;
    return DropTarget(
        enable: enabled,
        onDragDone: (details) =>
            onFiles(details.files.map((f) => File(f.path).uri).toList()),
        child: child);
  }
}
