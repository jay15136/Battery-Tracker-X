import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../battery_sets/domain/battery_set.dart';
import '../domain/bulk_creation.dart';

final class DriftBulkCreationRepository implements BulkCreationRepository {
  DriftBulkCreationRepository(
      {required this.db, required this.batteries, required this.sets});
  final AppDatabase db;
  final BatteryRepository batteries;
  final BatterySetRepository sets;
  @override
  Future<Set<String>> existingIds() async =>
      (await (db.select(db.batteries)..where((t) => t.deletedAt.isNull()))
              .get())
          .map((b) => b.userBatteryId)
          .toSet();
  @override
  Future<BulkResult> save(BulkRequest request,
          {Set<String> acceptedWarnings = const {}}) =>
      db.transaction(() async {
        if (request.rows.isEmpty || request.rows.length > 1000)
          throw const BulkValidationException(
              'Preview between 1 and 1000 Batteries.');
        final duplicates =
            BulkIds.duplicates(request.rows, await existingIds());
        if (duplicates.isNotEmpty)
          throw BulkValidationException(
              'Battery IDs already exist or repeat in this preview: ' +
                  duplicates.join(', '));
        for (final row in request.rows) {
          row.battery.validate();
          if (row.existingSet != null && row.newSet != null)
            throw const BulkValidationException(
                'Choose only one Set per Battery.');
          if (row.newSet != null && !request.newSets.containsKey(row.newSet))
            throw const BulkValidationException(
                'A preview Set no longer exists.');
        }
        final createdSets = <String, PermanentId>{};
        for (final entry in request.newSets.entries) {
          if (!request.rows.any((r) => r.newSet == entry.key)) continue;
          createdSets[entry.key] = (await sets.save(entry.value)).id;
        }
        final tagIds = <int>[];
        for (final tag in request.tags
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => s.toLowerCase())
            .toSet()) {
          final old = await (db.select(db.tags)
                ..where((t) => t.name.lower().equals(tag)))
              .getSingleOrNull();
          tagIds.add(old?.id ??
              await db.into(db.tags).insert(TagsCompanion.insert(
                  uuid: const UuidV4PermanentIdGenerator().next().value,
                  name: tag)));
        }
        final created = <PermanentId>[];
        for (final row in request.rows) {
          final battery = await batteries.save(row.battery);
          created.add(battery.id);
          final setId = row.existingSet ?? createdSets[row.newSet];
          if (setId != null)
            await sets.addMember(setId, battery.id,
                acceptedWarnings: acceptedWarnings);
          if (tagIds.isNotEmpty) {
            final record = await (db.select(db.batteries)
                  ..where((t) => t.uuid.equals(battery.id.value)))
                .getSingle();
            for (final tag in tagIds) {
              await db.into(db.batteryTags).insert(BatteryTagsCompanion.insert(
                  batteryId: record.id, tagId: tag));
            }
          }
        }
        await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
            uuid: const UuidV4PermanentIdGenerator().next().value,
            eventType: 'bulk_batteries_created',
            entityType: 'bulk_operation',
            entityUuid: const UuidV4PermanentIdGenerator().next().value,
            summary: 'Created ' +
                created.length.toString() +
                ' Batteries in one transaction.',
            metadataJson: Value(jsonEncode({
              'batteries': created.map((id) => id.value).toList(),
              'sets': createdSets.values.map((id) => id.value).toList(),
              'tags': request.tags
            }))));
        return BulkResult(
            List.unmodifiable(created), List.unmodifiable(createdSets.values));
      });
}
