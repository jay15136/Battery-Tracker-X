import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_color.dart';
import '../domain/dashboard.dart';

class DriftDashboardRepository implements DashboardRepository {
  DriftDashboardRepository(this.db, {DateTime Function()? now})
      : now = now ?? DateTime.now;
  final AppDatabase db;
  final DateTime Function() now;
  static const policyKey = 'dashboard_attention_policy';
  @override
  Stream<DashboardSnapshot> watch() => Stream.multi((controller) {
        var canceled = false;
        var pending = Future<void>.value();
        void reload() {
          pending = pending.then((_) async {
            if (canceled) return;
            try {
              final snapshot = await load();
              if (!canceled) controller.add(snapshot);
            } on Object catch (error, stack) {
              if (!canceled) controller.addError(error, stack);
            }
          });
        }

        // Subscribe before the initial read so writes cannot fall between them.
        final subscription = db
            .tableUpdates(TableUpdateQuery.onAllTables([
              db.batteries,
              db.batterySets,
              db.devices,
              db.assignments,
              db.batterySetMemberships,
              db.chargeRecords,
              db.activityLog,
              db.settings
            ]))
            .listen((_) => reload(), onError: controller.addError);
        reload();
        controller.onCancel = () async {
          canceled = true;
          await subscription.cancel();
        };
      });
  @override
  Future<void> savePolicy(AttentionPolicy policy) async {
    policy.validate();
    await db.into(db.settings).insertOnConflictUpdate(SettingsCompanion.insert(
        key: policyKey,
        value: jsonEncode(policy.toJson()),
        valueType: 'json',
        modifiedAt: Value(now().toUtc())));
  }

  @override
  Future<DashboardSnapshot> load() => db.transaction(() async {
        final at = now().toUtc();
        final setting = await (db.select(db.settings)
              ..where((t) => t.key.equals(policyKey)))
            .getSingleOrNull();
        final policy = setting == null
            ? const AttentionPolicy()
            : AttentionPolicy.fromJson(
                jsonDecode(setting.value) as Map<String, dynamic>);
        final rows = await db.customSelect('''
SELECT b.*, COALESCE(c.charges,0) AS charges, c.last_charge,
 EXISTS(SELECT 1 FROM assignments a JOIN devices d ON d.id=a.device_id WHERE a.battery_id=b.id AND a.removed_at IS NULL AND d.deleted_at IS NULL) AS assigned,
 EXISTS(SELECT 1 FROM battery_set_memberships m JOIN battery_sets s ON s.id=m.battery_set_id WHERE m.battery_id=b.id AND m.removed_at IS NULL AND s.deleted_at IS NULL) AS in_set
FROM batteries b LEFT JOIN (SELECT battery_id,COUNT(*) AS charges,MAX(charged_at) AS last_charge FROM charge_records GROUP BY battery_id) c ON c.battery_id=b.id
WHERE b.deleted_at IS NULL ORDER BY b.user_battery_id COLLATE NOCASE,b.uuid
''').get();
        final memberships = await db.customSelect(
            '''SELECT m.battery_id,m.battery_set_id FROM battery_set_memberships m JOIN battery_sets s ON s.id=m.battery_set_id WHERE m.removed_at IS NULL AND s.deleted_at IS NULL AND s.deactivated_at IS NULL''').get();
        final charges = {
          for (final r in rows) r.read<int>('id'): r.read<int>('charges')
        };
        final groups = <int, List<int>>{};
        for (final m in memberships) {
          final id = m.read<int>('battery_id');
          if (charges.containsKey(id))
            (groups[m.read<int>('battery_set_id')] ??= []).add(id);
        }
        final differences = <int, int>{};
        for (final ids in groups.values) {
          if (ids.length < 2) continue;
          final values = ids.map((id) => charges[id]!).toList()..sort();
          final difference = values.last - values.first;
          if (policy.setChargeDifference > 0 &&
              difference >= policy.setChargeDifference) {
            for (final id in ids) {
              if (difference > (differences[id] ?? 0))
                differences[id] = difference;
            }
          }
        }
        final counts = <String, int>{
          'Total Batteries': rows.length,
          'Available Batteries': 0,
          'Batteries Assigned to Devices': 0,
          'Batteries in Sets': 0,
          'Battery Sets': 0,
          'Batteries Charging': 0,
          'Batteries Needing Attention': 0,
          'Retired Batteries': 0,
          'Total Devices': 0
        };
        final attention = <AttentionBattery>[];
        for (final r in rows) {
          final status = r.read<String>('status'),
              condition = r.read<String>('condition');
          final retired = status == 'Retired' ||
              condition == 'Retired' ||
              r.readNullable<String>('retired_at') != null;
          final assigned = r.read<int>('assigned') == 1,
              inSet = r.read<int>('in_set') == 1;
          if (status == 'Available' && !assigned && !inSet && !retired)
            counts['Available Batteries'] = counts['Available Batteries']! + 1;
          if (assigned)
            counts['Batteries Assigned to Devices'] =
                counts['Batteries Assigned to Devices']! + 1;
          if (inSet)
            counts['Batteries in Sets'] = counts['Batteries in Sets']! + 1;
          if (status == 'Charging' && !retired)
            counts['Batteries Charging'] = counts['Batteries Charging']! + 1;
          if (retired)
            counts['Retired Batteries'] = counts['Retired Batteries']! + 1;
          final reasons = <String>[];
          if (retired) reasons.add('Retired');
          if (status == 'Needs Attention')
            reasons.add('Status: Needs Attention');
          if (status == 'Damaged' || condition == 'Damaged')
            reasons.add('Marked Damaged');
          if (condition == 'Poor') reasons.add('Condition: Poor');
          if (!retired && r.read<int>('rechargeable') == 1) {
            final last = r.readNullable<String>('last_charge');
            final age = at
                .difference(DateTime.parse(last ?? r.read<String>('created_at'))
                    .toUtc())
                .inDays;
            if (policy.daysWithoutCharge > 0 && age >= policy.daysWithoutCharge)
              reasons.add(last == null
                  ? 'No charge recorded for $age days'
                  : 'Last charged $age days ago');
            final total = r.read<int>('charges');
            if (policy.recordedChargeThreshold > 0 &&
                total >= policy.recordedChargeThreshold)
              reasons.add(
                  '$total Recorded Charges (threshold ${policy.recordedChargeThreshold})');
            final difference = differences[r.read<int>('id')];
            if (difference != null)
              reasons.add('Set members differ by $difference Recorded Charges');
          }
          if (reasons.isNotEmpty)
            attention.add(AttentionBattery(
                id: PermanentId.parse(r.read<String>('uuid')),
                label: r.read<String>('user_battery_id'),
                icon: IconSelection(
                    source:
                        IconSource.fromStorage(r.read<String>('icon_source')),
                    key: r.read<String>('icon_key'),
                    color: IconColor.parse(r.read<String>('icon_color'))),
                reasons: reasons));
        }
        counts['Batteries Needing Attention'] = attention.length;
        final sets = await (db.select(db.batterySets)
              ..where((t) => t.deletedAt.isNull()))
            .get();
        final devices = await (db.select(db.devices)
              ..where((t) => t.deletedAt.isNull()))
            .get();
        counts['Battery Sets'] = sets.length;
        counts['Total Devices'] = devices.length;
        final live = {
          'battery': rows.map((r) => r.read<String>('uuid')).toSet(),
          'battery_set': sets.map((s) => s.uuid).toSet(),
          'device': devices.map((d) => d.uuid).toSet()
        };
        final labels = {
          'battery': {
            for (final b in rows)
              b.read<String>('uuid'): b.read<String>('user_battery_id')
          },
          'battery_set': {for (final s in sets) s.uuid: s.userSetId},
          'device': {for (final d in devices) d.uuid: d.name},
        };
        final activity = await (db.select(db.activityLog)
              ..orderBy([
                (t) => OrderingTerm.desc(t.occurredAt),
                (t) => OrderingTerm.desc(t.id)
              ])
              ..limit(20))
            .get();
        return DashboardSnapshot(
            counts: counts,
            attention: attention,
            activity: activity.map((a) {
              PermanentId? id;
              try {
                id = PermanentId.parse(a.entityUuid);
              } on FormatException {/* Historical or non-inventory event. */}
              return DashboardActivity(
                  summary: a.summary,
                  at: a.occurredAt,
                  entityType: a.entityType,
                  entityLabel: labels[a.entityType]?[a.entityUuid],
                  entityId: id,
                  available:
                      live[a.entityType]?.contains(a.entityUuid) ?? false);
            }).toList(),
            policy: policy,
            at: at);
      });
}
