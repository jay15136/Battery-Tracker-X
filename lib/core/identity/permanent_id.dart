import 'package:uuid/uuid.dart';

/// Immutable application identity used independently of editable display IDs.
final class PermanentId {
  PermanentId._(this.value);

  factory PermanentId.parse(String source) {
    final normalized = source.toLowerCase();
    if (!Uuid.isValidUUID(fromString: normalized)) {
      throw FormatException('Invalid permanent UUID.', source);
    }
    return PermanentId._(normalized);
  }

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermanentId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Creates permanent identities without exposing a UUID package to features.
abstract interface class PermanentIdGenerator {
  PermanentId next();
}

final class UuidV4PermanentIdGenerator implements PermanentIdGenerator {
  const UuidV4PermanentIdGenerator();

  static const _uuid = Uuid();

  @override
  PermanentId next() => PermanentId.parse(_uuid.v4());
}
