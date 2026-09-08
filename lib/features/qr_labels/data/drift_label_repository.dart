import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../battery_sets/domain/battery_set.dart';
import '../../devices/domain/device.dart';
import '../../photos/data/drift_photo_repository.dart';
import '../../photos/domain/photo.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../domain/labels.dart';

final class DriftLabelRepository implements LabelRepository {
  DriftLabelRepository(
      {required this.db,
      required this.batteries,
      required this.sets,
      required this.devices});
  final AppDatabase db;
  final BatteryRepository batteries;
  final BatterySetRepository sets;
  final DeviceRepository devices;
  Future<ManagedRelativePath?> _photo(LabelRef ref) async {
    final gallery = await DriftPhotoRepository(db).gallery(PhotoOwner(
        switch (ref.kind) {
          LabelKind.battery => PhotoOwnerKind.battery,
          LabelKind.set => PhotoOwnerKind.batterySet,
          LabelKind.device => PhotoOwnerKind.device,
        },
        ref.id));
    return (gallery.photos.where((p) => p.isPrimary).firstOrNull ??
            gallery.photos.firstOrNull)
        ?.file
        .path;
  }

  Future<String> _type(PermanentId? id) async {
    if (id == null) return '';
    return (await (db.select(db.batteryTypes)
                  ..where((t) => t.uuid.equals(id.value)))
                .getSingleOrNull())
            ?.typeName ??
        '';
  }

  @override
  Future<LabelTarget> resolve(LabelRef ref) async {
    try {
      switch (ref.kind) {
        case LabelKind.battery:
          final b = await batteries.get(ref.id);
          final v = b.values;
          return LabelTarget(
              ref: ref,
              icon: v.icon,
              photo: await _photo(ref),
              fields: {
                'id': v.userBatteryId,
                'name': v.name ?? '',
                'type': await _type(v.batteryTypeId),
                'manufacturer': v.manufacturer ?? '',
                'model': v.model ?? '',
                'capacity': v.capacity == null
                    ? ''
                    : v.capacity.toString() + ' ' + (v.capacityUnit ?? '')
              });
        case LabelKind.set:
          final s = await sets.get(ref.id);
          return LabelTarget(
              ref: ref,
              icon: s.values.icon,
              photo: await _photo(ref),
              fields: {
                'id': s.values.userSetId,
                'name': s.values.name,
                'type': await _type(s.values.typeId),
                'members': s.members.length.toString() + ' Batteries'
              });
        case LabelKind.device:
          final d = await devices.get(ref.id);
          return LabelTarget(
              ref: ref,
              icon: d.values.icon,
              photo: await _photo(ref),
              fields: {
                'name': d.values.name,
                'manufacturer': d.values.manufacturer ?? '',
                'model': d.values.model ?? '',
                'category': d.values.category ?? ''
              });
      }
    } on BatteryValidationException {
      throw const LabelValidationException(
          'This Battery is no longer available.');
    } on SetValidationException {
      throw const LabelValidationException('This Set is no longer available.');
    } on DeviceValidationException {
      throw const LabelValidationException(
          'This Device is no longer available.');
    }
  }

  @override
  Future<List<LabelTarget>> inventory() async {
    final refs = [
      for (final b in await batteries.list()) LabelRef(LabelKind.battery, b.id),
      for (final s in await sets.list()) LabelRef(LabelKind.set, s.id),
      for (final d in await devices.list()) LabelRef(LabelKind.device, d.id)
    ];
    return Future.wait(refs.map(resolve));
  }

  @override
  Future<List<LabelRef>> setMembers(PermanentId id) async =>
      (await sets.get(id))
          .members
          .map((b) => LabelRef(LabelKind.battery, b.id))
          .toList();
  @override
  Future<List<LabelTemplate>> templates() async {
    final rows = await (db.select(db.qrLabelTemplates)
          ..where((t) => t.deactivatedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map((r) {
      final j = jsonDecode(r.layoutJson) as Map<String, dynamic>;
      final l = LabelLayout.fromJson(j['label'] as Map<String, dynamic>),
          s = LabelSheet.fromJson(j['sheet'] as Map<String, dynamic>);
      s.validate(l);
      return LabelTemplate(PermanentId.parse(r.uuid), r.name,
          LabelKind.values.firstWhere((k) => k.storage == r.targetType), l, s);
    }).toList();
  }

  @override
  Future<void> saveTemplate(
          String name, LabelKind kind, LabelLayout layout, LabelSheet sheet,
          {PermanentId? id}) =>
      db.transaction(() async {
        sheet.validate(layout);
        if (name.trim().isEmpty)
          throw const LabelValidationException('Enter a template name.');
        final duplicate = await (db.select(db.qrLabelTemplates)
              ..where((t) =>
                  t.name.lower().equals(name.trim().toLowerCase()) &
                  t.deactivatedAt.isNull()))
            .get();
        if (duplicate.any((r) => r.uuid != id?.value))
          throw const LabelValidationException(
              'That template name is already in use.');
        final uuid = id ?? const UuidV4PermanentIdGenerator().next();
        final values = QrLabelTemplatesCompanion.insert(
            uuid: uuid.value,
            name: name.trim(),
            targetType: kind.storage,
            widthPoints: layout.width,
            heightPoints: layout.height,
            layoutJson:
                jsonEncode({'label': layout.toJson(), 'sheet': sheet.toJson()}),
            modifiedAt: Value(DateTime.now().toUtc()));
        if (id == null) {
          await db.into(db.qrLabelTemplates).insert(values);
        } else {
          final count = await (db.update(db.qrLabelTemplates)
                ..where(
                    (t) => t.uuid.equals(id.value) & t.deactivatedAt.isNull()))
              .write(values);
          if (count != 1)
            throw const LabelValidationException(
                'This template is no longer available.');
        }
      });
  @override
  Future<void> deactivateTemplate(PermanentId id) async {
    await (db.update(db.qrLabelTemplates)
          ..where((t) => t.uuid.equals(id.value)))
        .write(QrLabelTemplatesCompanion(
            deactivatedAt: Value(DateTime.now().toUtc())));
  }

  @override
  Future<void> saveJob(String name, List<LabelRef> refs, LabelLayout layout,
      LabelSheet sheet) async {
    sheet.positions(refs.length, layout);
    if (name.trim().isEmpty)
      throw const LabelValidationException('Enter a saved selection name.');
    final id = const UuidV4PermanentIdGenerator().next().value;
    await db.into(db.settings).insert(SettingsCompanion.insert(
        key: 'qr_job_' + id,
        value: jsonEncode({
          'id': id,
          'name': name.trim(),
          'refs': refs.map((r) => r.uri.toString()).toList(),
          'label': layout.toJson(),
          'sheet': sheet.toJson()
        }),
        valueType: 'json'));
  }

  @override
  Future<List<LabelJob>> jobs() async {
    final rows = await (db.select(db.settings)
          ..where((t) => t.key.like('qr_job_%')))
        .get();
    return rows.map((r) {
      final j = jsonDecode(r.value) as Map<String, dynamic>;
      return LabelJob(
          j['id'] as String,
          j['name'] as String,
          (j['refs'] as List).map((v) => LabelRef.parse(v as String)).toList(),
          LabelLayout.fromJson(j['label'] as Map<String, dynamic>),
          LabelSheet.fromJson(j['sheet'] as Map<String, dynamic>));
    }).toList();
  }

  @override
  Future<void> recordOutput(String event, List<LabelRef> refs) =>
      db.transaction(() async {
        if (!['qr_labels_exported', 'qr_labels_printed'].contains(event))
          throw const LabelValidationException('Unknown label output action.');
        final operation = const UuidV4PermanentIdGenerator().next().value;
        for (final ref in refs) {
          await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
              uuid: const UuidV4PermanentIdGenerator().next().value,
              eventType: event,
              entityType: ref.kind.storage,
              entityUuid: ref.id.value,
              operationUuid: Value(operation),
              summary: event == 'qr_labels_exported'
                  ? 'QR label exported to PDF.'
                  : 'QR label submitted to the print system.'));
        }
      });
}
