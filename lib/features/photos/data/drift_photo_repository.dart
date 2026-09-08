import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../domain/photo.dart';

final class DriftPhotoRepository implements PhotoRepository {
  DriftPhotoRepository(this.db,
      {this.ids = const UuidV4PermanentIdGenerator()});
  final AppDatabase db;
  final PermanentIdGenerator ids;
  ({String table, String link, String key, String entity}) _schema(
          PhotoOwner owner) =>
      switch (owner.kind) {
        PhotoOwnerKind.battery => (
            table: 'batteries',
            link: 'battery_photos',
            key: 'battery_id',
            entity: 'battery'
          ),
        PhotoOwnerKind.batterySet => (
            table: 'battery_sets',
            link: 'battery_set_photos',
            key: 'battery_set_id',
            entity: 'battery_set'
          ),
        PhotoOwnerKind.device => (
            table: 'devices',
            link: 'device_photos',
            key: 'device_id',
            entity: 'device'
          ),
      };
  Future<int> _owner(PhotoOwner owner) async {
    final s = _schema(owner);
    final row = await db.customSelect(
        'SELECT id FROM ${s.table} WHERE uuid = ? AND deleted_at IS NULL',
        variables: [Variable.withString(owner.id.value)]).getSingleOrNull();
    if (row == null)
      throw const PhotoException(
          'This inventory record is no longer available.');
    return row.read<int>('id');
  }

  @override
  Future<PhotoGallery> gallery(PhotoOwner owner) async {
    final s = _schema(owner);
    final ownerId = await _owner(owner);
    final rows = await db.customSelect(
        'SELECT m.*, p.is_primary FROM ${s.link} p JOIN media_assets m ON m.id=p.media_asset_id WHERE p.${s.key} = ? ORDER BY p.display_order, m.id',
        variables: [Variable.withInt(ownerId)]).get();
    final settings = await db.customSelect(
        'SELECT preferred_primary_visual FROM ${s.table} WHERE id = ?',
        variables: [Variable.withInt(ownerId)]).getSingle();
    return PhotoGallery(
        preferPhoto:
            settings.read<String>('preferred_primary_visual') == 'photo',
        photos: List.unmodifiable(rows.map((r) => PhotoRecord(
            id: PermanentId.parse(r.read<String>('uuid')),
            isPrimary: r.read<int>('is_primary') == 1,
            file: StoredPhoto(
                path:
                    ManagedRelativePath.parse(r.read<String>('relative_path')),
                filename: r.read<String>('original_filename'),
                mimeType: r.read<String>('mime_type'),
                byteSize: r.read<int>('byte_size'),
                width: r.readNullable<int>('width') ?? 0,
                height: r.readNullable<int>('height') ?? 0,
                checksum: r.read<String>('checksum'))))));
  }

  Future<int> _insert(PermanentId id, StoredPhoto file) =>
      db.into(db.mediaAssets).insert(MediaAssetsCompanion.insert(
          uuid: id.value,
          relativePath: file.path.value,
          originalFilename: file.filename,
          mimeType: file.mimeType,
          byteSize: file.byteSize,
          checksum: file.checksum,
          width: Value(file.width),
          height: Value(file.height)));
  @override
  Future<void> add(PhotoOwner owner, PermanentId id, StoredPhoto file) =>
      db.transaction(() async {
        final s = _schema(owner);
        final ownerId = await _owner(owner);
        final media = await _insert(id, file);
        final now = DateTime.now().toUtc().toIso8601String();
        final order = await db.customSelect(
            'SELECT COALESCE(MAX(display_order), -1)+1 AS next_order, COUNT(*) AS count FROM ${s.link} WHERE ${s.key} = ?',
            variables: [Variable.withInt(ownerId)]).getSingle();
        await db.customInsert(
            'INSERT INTO ${s.link} (${s.key},media_asset_id,is_primary,display_order,created_at,modified_at) VALUES (?,?,?,?,?,?)',
            variables: [
              Variable.withInt(ownerId),
              Variable.withInt(media),
              Variable.withInt(order.read<int>('count') == 0 ? 1 : 0),
              Variable.withInt(order.read<int>('next_order')),
              Variable.withString(now),
              Variable.withString(now)
            ]);
        // A primary photo selection is distinct from the preferred primary visual.
        await _event(owner, 'photo_added', 'Photograph added.');
      });
  @override
  Future<void> preferIcon(PhotoOwner owner) => db.transaction(() async {
        final ownerId = await _owner(owner);
        await _preference(owner, ownerId, false);
        await _event(
            owner, 'primary_visual_changed', 'Icon is the primary visual.');
      });
  Future<void> _preference(PhotoOwner owner, int ownerId, bool photo) async {
    final s = _schema(owner);
    await db.customUpdate(
        'UPDATE ${s.table} SET preferred_primary_visual = ?, modified_at = ? WHERE id = ?',
        variables: [
          Variable.withString(photo ? 'photo' : 'icon'),
          Variable.withString(DateTime.now().toUtc().toIso8601String()),
          Variable.withInt(ownerId)
        ]);
  }

  Future<QueryRow> _owned(
      PhotoOwner owner, int ownerId, PermanentId photo) async {
    final s = _schema(owner);
    final row = await db.customSelect(
        'SELECT m.id,m.relative_path,p.is_primary FROM ${s.link} p JOIN media_assets m ON m.id=p.media_asset_id WHERE p.${s.key} = ? AND m.uuid = ?',
        variables: [
          Variable.withInt(ownerId),
          Variable.withString(photo.value)
        ]).getSingleOrNull();
    if (row == null)
      throw const PhotoException(
          'This photograph is no longer attached to the record.');
    return row;
  }

  @override
  Future<void> choosePrimary(PhotoOwner owner, PermanentId id,
          {required bool preferPhoto}) =>
      db.transaction(() async {
        final s = _schema(owner);
        final ownerId = await _owner(owner);
        final media = await _owned(owner, ownerId, id);
        final now = DateTime.now().toUtc().toIso8601String();
        await db.customUpdate(
            'UPDATE ${s.link} SET is_primary = 0, modified_at = ? WHERE ${s.key} = ?',
            variables: [Variable.withString(now), Variable.withInt(ownerId)]);
        await db.customUpdate(
            'UPDATE ${s.link} SET is_primary = 1, modified_at = ? WHERE ${s.key} = ? AND media_asset_id = ?',
            variables: [
              Variable.withString(now),
              Variable.withInt(ownerId),
              Variable.withInt(media.read<int>('id'))
            ]);
        await _preference(owner, ownerId, preferPhoto);
        await _event(
            owner,
            'primary_photo_changed',
            preferPhoto
                ? 'Photograph is the primary visual.'
                : 'Primary photograph selected; icon remains primary.');
      });
  @override
  Future<ManagedRelativePath?> remove(PhotoOwner owner, PermanentId id) =>
      db.transaction(() async {
        final s = _schema(owner);
        final ownerId = await _owner(owner);
        final media = await _owned(owner, ownerId, id);
        await db.customUpdate(
            'DELETE FROM ${s.link} WHERE ${s.key} = ? AND media_asset_id = ?',
            variables: [
              Variable.withInt(ownerId),
              Variable.withInt(media.read<int>('id'))
            ]);
        if (media.read<int>('is_primary') == 1)
          await _preference(owner, ownerId, false);
        await _event(owner, 'photo_removed',
            'Photograph removed; inventory icon retained.');
        return _deleteUnreferenced(media);
      });
  @override
  Future<ManagedRelativePath?> replace(
          PhotoOwner owner, PermanentId id, StoredPhoto file) =>
      db.transaction(() async {
        final s = _schema(owner);
        final ownerId = await _owner(owner);
        final media = await _owned(owner, ownerId, id);
        final replacement = await _insert(ids.next(), file);
        await db.customUpdate(
            'UPDATE ${s.link} SET media_asset_id = ?, modified_at = ? WHERE ${s.key} = ? AND media_asset_id = ?',
            variables: [
              Variable.withInt(replacement),
              Variable.withString(DateTime.now().toUtc().toIso8601String()),
              Variable.withInt(ownerId),
              Variable.withInt(media.read<int>('id'))
            ]);
        await _event(owner, 'photo_replaced', 'Photograph replaced.');
        return _deleteUnreferenced(media);
      });
  Future<ManagedRelativePath?> _deleteUnreferenced(QueryRow media) async {
    final id = media.read<int>('id');
    final count = await db.customSelect(
        'SELECT (SELECT COUNT(*) FROM battery_photos WHERE media_asset_id = ?) + (SELECT COUNT(*) FROM battery_set_photos WHERE media_asset_id = ?) + (SELECT COUNT(*) FROM device_photos WHERE media_asset_id = ?) AS count',
        variables: [
          Variable.withInt(id),
          Variable.withInt(id),
          Variable.withInt(id)
        ]).getSingle();
    if (count.read<int>('count') != 0) return null;
    await (db.delete(db.mediaAssets)..where((t) => t.id.equals(id))).go();
    return ManagedRelativePath.parse(media.read<String>('relative_path'));
  }

  Future<void> _event(PhotoOwner owner, String type, String summary) async {
    await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
        uuid: ids.next().value,
        eventType: type,
        entityType: _schema(owner).entity,
        entityUuid: owner.id.value,
        summary: summary));
  }
}
