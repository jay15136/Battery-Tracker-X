/// A platform-neutral reference to a file under application-managed storage.
final class ManagedRelativePath {
  ManagedRelativePath._(this.value);

  factory ManagedRelativePath.parse(String source) {
    final normalized = source.replaceAll('\\', '/');
    final segments = normalized.split('/');
    final hasDrivePrefix = RegExp(r'^[a-zA-Z]:').hasMatch(normalized);
    final hasInvalidSegment = segments.any(
      (segment) =>
          segment.isEmpty ||
          segment == '.' ||
          segment == '..' ||
          RegExp(r'[<>:"|?*\x00-\x1f]').hasMatch(segment),
    );

    if (normalized.startsWith('/') || hasDrivePrefix || hasInvalidSegment) {
      throw FormatException(
        'Managed paths must be safe, non-empty relative paths.',
        source,
      );
    }

    return ManagedRelativePath._(normalized);
  }

  factory ManagedRelativePath.fromSegments(Iterable<String> segments) {
    final parts = List<String>.unmodifiable(segments);
    if (parts
        .any((segment) => segment.contains('/') || segment.contains('\\'))) {
      throw const FormatException(
          'A logical path segment cannot contain a separator.');
    }
    return ManagedRelativePath.parse(parts.join('/'));
  }

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedRelativePath &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
