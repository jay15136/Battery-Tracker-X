import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/storage/managed_relative_path.dart';

/// A missing or corrupt photograph always uses the caller's inventory icon.
class PhotoVisual extends StatelessWidget {
  const PhotoVisual(
      {required this.root,
      required this.path,
      required this.fallback,
      required this.onUnavailable,
      this.size = 80,
      super.key});
  final Uri root;
  final ManagedRelativePath? path;
  final Widget fallback;
  final VoidCallback onUnavailable;
  final double size;
  @override
  Widget build(BuildContext context) {
    final reference = path;
    if (reference == null) return fallback;
    final file = File.fromUri(root.resolve(reference.value));
    if (!file.existsSync()) {
      onUnavailable();
      return fallback;
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file,
            key: ValueKey(reference.value),
            width: size,
            height: size,
            cacheWidth: (size * 2).ceil(),
            fit: BoxFit.contain,
            frameBuilder: (_, child, frame, loaded) =>
                frame == null ? fallback : child,
            errorBuilder: (_, e, s) {
              onUnavailable();
              return fallback;
            }));
  }
}
