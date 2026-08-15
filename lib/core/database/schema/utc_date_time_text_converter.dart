import 'package:drift/drift.dart';

/// Persists timestamps as normalized UTC ISO-8601 text.
final class UtcDateTimeTextConverter extends TypeConverter<DateTime, String> {
  const UtcDateTimeTextConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toUtc();

  @override
  String toSql(DateTime value) => value.toUtc().toIso8601String();
}
