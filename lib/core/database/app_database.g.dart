// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BatteryTypesTable extends BatteryTypes
    with TableInfo<$BatteryTypesTable, BatteryType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatteryTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _typeNameMeta =
      const VerificationMeta('typeName');
  @override
  late final GeneratedColumn<String> typeName = GeneratedColumn<String>(
      'type_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chemistryMeta =
      const VerificationMeta('chemistry');
  @override
  late final GeneratedColumn<String> chemistry = GeneratedColumn<String>(
      'chemistry', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultVoltageMeta =
      const VerificationMeta('defaultVoltage');
  @override
  late final GeneratedColumn<double> defaultVoltage = GeneratedColumn<double>(
      'default_voltage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _defaultCapacityMeta =
      const VerificationMeta('defaultCapacity');
  @override
  late final GeneratedColumn<double> defaultCapacity = GeneratedColumn<double>(
      'default_capacity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capacityUnitMeta =
      const VerificationMeta('capacityUnit');
  @override
  late final GeneratedColumn<String> capacityUnit = GeneratedColumn<String>(
      'capacity_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _physicalSizeMeta =
      const VerificationMeta('physicalSize');
  @override
  late final GeneratedColumn<String> physicalSize = GeneratedColumn<String>(
      'physical_size', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _suggestedIconSourceMeta =
      const VerificationMeta('suggestedIconSource');
  @override
  late final GeneratedColumn<String> suggestedIconSource =
      GeneratedColumn<String>('suggested_icon_source', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('builtin'));
  static const VerificationMeta _suggestedIconKeyMeta =
      const VerificationMeta('suggestedIconKey');
  @override
  late final GeneratedColumn<String> suggestedIconKey = GeneratedColumn<String>(
      'suggested_icon_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('battery_generic'));
  static const VerificationMeta _suggestedIconColorMeta =
      const VerificationMeta('suggestedIconColor');
  @override
  late final GeneratedColumn<String> suggestedIconColor =
      GeneratedColumn<String>('suggested_icon_color', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('#607D8B'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteryTypesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteryTypesTable.$convertermodifiedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deactivatedAt =
      GeneratedColumn<String>('deactivated_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $BatteryTypesTable.$converterdeactivatedAtn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        typeName,
        description,
        chemistry,
        defaultVoltage,
        defaultCapacity,
        capacityUnit,
        physicalSize,
        suggestedIconSource,
        suggestedIconKey,
        suggestedIconColor,
        notes,
        createdAt,
        modifiedAt,
        deactivatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'battery_types';
  @override
  VerificationContext validateIntegrity(Insertable<BatteryType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('type_name')) {
      context.handle(_typeNameMeta,
          typeName.isAcceptableOrUnknown(data['type_name']!, _typeNameMeta));
    } else if (isInserting) {
      context.missing(_typeNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('chemistry')) {
      context.handle(_chemistryMeta,
          chemistry.isAcceptableOrUnknown(data['chemistry']!, _chemistryMeta));
    }
    if (data.containsKey('default_voltage')) {
      context.handle(
          _defaultVoltageMeta,
          defaultVoltage.isAcceptableOrUnknown(
              data['default_voltage']!, _defaultVoltageMeta));
    }
    if (data.containsKey('default_capacity')) {
      context.handle(
          _defaultCapacityMeta,
          defaultCapacity.isAcceptableOrUnknown(
              data['default_capacity']!, _defaultCapacityMeta));
    }
    if (data.containsKey('capacity_unit')) {
      context.handle(
          _capacityUnitMeta,
          capacityUnit.isAcceptableOrUnknown(
              data['capacity_unit']!, _capacityUnitMeta));
    }
    if (data.containsKey('physical_size')) {
      context.handle(
          _physicalSizeMeta,
          physicalSize.isAcceptableOrUnknown(
              data['physical_size']!, _physicalSizeMeta));
    }
    if (data.containsKey('suggested_icon_source')) {
      context.handle(
          _suggestedIconSourceMeta,
          suggestedIconSource.isAcceptableOrUnknown(
              data['suggested_icon_source']!, _suggestedIconSourceMeta));
    }
    if (data.containsKey('suggested_icon_key')) {
      context.handle(
          _suggestedIconKeyMeta,
          suggestedIconKey.isAcceptableOrUnknown(
              data['suggested_icon_key']!, _suggestedIconKeyMeta));
    }
    if (data.containsKey('suggested_icon_color')) {
      context.handle(
          _suggestedIconColorMeta,
          suggestedIconColor.isAcceptableOrUnknown(
              data['suggested_icon_color']!, _suggestedIconColorMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatteryType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatteryType(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      typeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type_name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      chemistry: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chemistry']),
      defaultVoltage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}default_voltage']),
      defaultCapacity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}default_capacity']),
      capacityUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}capacity_unit']),
      physicalSize: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}physical_size']),
      suggestedIconSource: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}suggested_icon_source'])!,
      suggestedIconKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}suggested_icon_key'])!,
      suggestedIconColor: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}suggested_icon_color'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: $BatteryTypesTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $BatteryTypesTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
      deactivatedAt: $BatteryTypesTable.$converterdeactivatedAtn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}deactivated_at'])),
    );
  }

  @override
  $BatteryTypesTable createAlias(String alias) {
    return $BatteryTypesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterdeactivatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeactivatedAtn =
      NullAwareTypeConverter.wrap($converterdeactivatedAt);
}

class BatteryType extends DataClass implements Insertable<BatteryType> {
  final int id;
  final String uuid;
  final String typeName;
  final String? description;
  final String? chemistry;
  final double? defaultVoltage;
  final double? defaultCapacity;
  final String? capacityUnit;
  final String? physicalSize;
  final String suggestedIconSource;
  final String suggestedIconKey;
  final String suggestedIconColor;
  final String? notes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;
  const BatteryType(
      {required this.id,
      required this.uuid,
      required this.typeName,
      this.description,
      this.chemistry,
      this.defaultVoltage,
      this.defaultCapacity,
      this.capacityUnit,
      this.physicalSize,
      required this.suggestedIconSource,
      required this.suggestedIconKey,
      required this.suggestedIconColor,
      this.notes,
      required this.createdAt,
      required this.modifiedAt,
      this.deactivatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['type_name'] = Variable<String>(typeName);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || chemistry != null) {
      map['chemistry'] = Variable<String>(chemistry);
    }
    if (!nullToAbsent || defaultVoltage != null) {
      map['default_voltage'] = Variable<double>(defaultVoltage);
    }
    if (!nullToAbsent || defaultCapacity != null) {
      map['default_capacity'] = Variable<double>(defaultCapacity);
    }
    if (!nullToAbsent || capacityUnit != null) {
      map['capacity_unit'] = Variable<String>(capacityUnit);
    }
    if (!nullToAbsent || physicalSize != null) {
      map['physical_size'] = Variable<String>(physicalSize);
    }
    map['suggested_icon_source'] = Variable<String>(suggestedIconSource);
    map['suggested_icon_key'] = Variable<String>(suggestedIconKey);
    map['suggested_icon_color'] = Variable<String>(suggestedIconColor);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['created_at'] = Variable<String>(
          $BatteryTypesTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $BatteryTypesTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    if (!nullToAbsent || deactivatedAt != null) {
      map['deactivated_at'] = Variable<String>(
          $BatteryTypesTable.$converterdeactivatedAtn.toSql(deactivatedAt));
    }
    return map;
  }

  BatteryTypesCompanion toCompanion(bool nullToAbsent) {
    return BatteryTypesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      typeName: Value(typeName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      chemistry: chemistry == null && nullToAbsent
          ? const Value.absent()
          : Value(chemistry),
      defaultVoltage: defaultVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultVoltage),
      defaultCapacity: defaultCapacity == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultCapacity),
      capacityUnit: capacityUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(capacityUnit),
      physicalSize: physicalSize == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalSize),
      suggestedIconSource: Value(suggestedIconSource),
      suggestedIconKey: Value(suggestedIconKey),
      suggestedIconColor: Value(suggestedIconColor),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deactivatedAt: deactivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deactivatedAt),
    );
  }

  factory BatteryType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatteryType(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      typeName: serializer.fromJson<String>(json['typeName']),
      description: serializer.fromJson<String?>(json['description']),
      chemistry: serializer.fromJson<String?>(json['chemistry']),
      defaultVoltage: serializer.fromJson<double?>(json['defaultVoltage']),
      defaultCapacity: serializer.fromJson<double?>(json['defaultCapacity']),
      capacityUnit: serializer.fromJson<String?>(json['capacityUnit']),
      physicalSize: serializer.fromJson<String?>(json['physicalSize']),
      suggestedIconSource:
          serializer.fromJson<String>(json['suggestedIconSource']),
      suggestedIconKey: serializer.fromJson<String>(json['suggestedIconKey']),
      suggestedIconColor:
          serializer.fromJson<String>(json['suggestedIconColor']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deactivatedAt: serializer.fromJson<DateTime?>(json['deactivatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'typeName': serializer.toJson<String>(typeName),
      'description': serializer.toJson<String?>(description),
      'chemistry': serializer.toJson<String?>(chemistry),
      'defaultVoltage': serializer.toJson<double?>(defaultVoltage),
      'defaultCapacity': serializer.toJson<double?>(defaultCapacity),
      'capacityUnit': serializer.toJson<String?>(capacityUnit),
      'physicalSize': serializer.toJson<String?>(physicalSize),
      'suggestedIconSource': serializer.toJson<String>(suggestedIconSource),
      'suggestedIconKey': serializer.toJson<String>(suggestedIconKey),
      'suggestedIconColor': serializer.toJson<String>(suggestedIconColor),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deactivatedAt': serializer.toJson<DateTime?>(deactivatedAt),
    };
  }

  BatteryType copyWith(
          {int? id,
          String? uuid,
          String? typeName,
          Value<String?> description = const Value.absent(),
          Value<String?> chemistry = const Value.absent(),
          Value<double?> defaultVoltage = const Value.absent(),
          Value<double?> defaultCapacity = const Value.absent(),
          Value<String?> capacityUnit = const Value.absent(),
          Value<String?> physicalSize = const Value.absent(),
          String? suggestedIconSource,
          String? suggestedIconKey,
          String? suggestedIconColor,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deactivatedAt = const Value.absent()}) =>
      BatteryType(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        typeName: typeName ?? this.typeName,
        description: description.present ? description.value : this.description,
        chemistry: chemistry.present ? chemistry.value : this.chemistry,
        defaultVoltage:
            defaultVoltage.present ? defaultVoltage.value : this.defaultVoltage,
        defaultCapacity: defaultCapacity.present
            ? defaultCapacity.value
            : this.defaultCapacity,
        capacityUnit:
            capacityUnit.present ? capacityUnit.value : this.capacityUnit,
        physicalSize:
            physicalSize.present ? physicalSize.value : this.physicalSize,
        suggestedIconSource: suggestedIconSource ?? this.suggestedIconSource,
        suggestedIconKey: suggestedIconKey ?? this.suggestedIconKey,
        suggestedIconColor: suggestedIconColor ?? this.suggestedIconColor,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deactivatedAt:
            deactivatedAt.present ? deactivatedAt.value : this.deactivatedAt,
      );
  BatteryType copyWithCompanion(BatteryTypesCompanion data) {
    return BatteryType(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      typeName: data.typeName.present ? data.typeName.value : this.typeName,
      description:
          data.description.present ? data.description.value : this.description,
      chemistry: data.chemistry.present ? data.chemistry.value : this.chemistry,
      defaultVoltage: data.defaultVoltage.present
          ? data.defaultVoltage.value
          : this.defaultVoltage,
      defaultCapacity: data.defaultCapacity.present
          ? data.defaultCapacity.value
          : this.defaultCapacity,
      capacityUnit: data.capacityUnit.present
          ? data.capacityUnit.value
          : this.capacityUnit,
      physicalSize: data.physicalSize.present
          ? data.physicalSize.value
          : this.physicalSize,
      suggestedIconSource: data.suggestedIconSource.present
          ? data.suggestedIconSource.value
          : this.suggestedIconSource,
      suggestedIconKey: data.suggestedIconKey.present
          ? data.suggestedIconKey.value
          : this.suggestedIconKey,
      suggestedIconColor: data.suggestedIconColor.present
          ? data.suggestedIconColor.value
          : this.suggestedIconColor,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deactivatedAt: data.deactivatedAt.present
          ? data.deactivatedAt.value
          : this.deactivatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatteryType(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('typeName: $typeName, ')
          ..write('description: $description, ')
          ..write('chemistry: $chemistry, ')
          ..write('defaultVoltage: $defaultVoltage, ')
          ..write('defaultCapacity: $defaultCapacity, ')
          ..write('capacityUnit: $capacityUnit, ')
          ..write('physicalSize: $physicalSize, ')
          ..write('suggestedIconSource: $suggestedIconSource, ')
          ..write('suggestedIconKey: $suggestedIconKey, ')
          ..write('suggestedIconColor: $suggestedIconColor, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      typeName,
      description,
      chemistry,
      defaultVoltage,
      defaultCapacity,
      capacityUnit,
      physicalSize,
      suggestedIconSource,
      suggestedIconKey,
      suggestedIconColor,
      notes,
      createdAt,
      modifiedAt,
      deactivatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatteryType &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.typeName == this.typeName &&
          other.description == this.description &&
          other.chemistry == this.chemistry &&
          other.defaultVoltage == this.defaultVoltage &&
          other.defaultCapacity == this.defaultCapacity &&
          other.capacityUnit == this.capacityUnit &&
          other.physicalSize == this.physicalSize &&
          other.suggestedIconSource == this.suggestedIconSource &&
          other.suggestedIconKey == this.suggestedIconKey &&
          other.suggestedIconColor == this.suggestedIconColor &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deactivatedAt == this.deactivatedAt);
}

class BatteryTypesCompanion extends UpdateCompanion<BatteryType> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> typeName;
  final Value<String?> description;
  final Value<String?> chemistry;
  final Value<double?> defaultVoltage;
  final Value<double?> defaultCapacity;
  final Value<String?> capacityUnit;
  final Value<String?> physicalSize;
  final Value<String> suggestedIconSource;
  final Value<String> suggestedIconKey;
  final Value<String> suggestedIconColor;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deactivatedAt;
  const BatteryTypesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.typeName = const Value.absent(),
    this.description = const Value.absent(),
    this.chemistry = const Value.absent(),
    this.defaultVoltage = const Value.absent(),
    this.defaultCapacity = const Value.absent(),
    this.capacityUnit = const Value.absent(),
    this.physicalSize = const Value.absent(),
    this.suggestedIconSource = const Value.absent(),
    this.suggestedIconKey = const Value.absent(),
    this.suggestedIconColor = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
  });
  BatteryTypesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String typeName,
    this.description = const Value.absent(),
    this.chemistry = const Value.absent(),
    this.defaultVoltage = const Value.absent(),
    this.defaultCapacity = const Value.absent(),
    this.capacityUnit = const Value.absent(),
    this.physicalSize = const Value.absent(),
    this.suggestedIconSource = const Value.absent(),
    this.suggestedIconKey = const Value.absent(),
    this.suggestedIconColor = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        typeName = Value(typeName);
  static Insertable<BatteryType> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? typeName,
    Expression<String>? description,
    Expression<String>? chemistry,
    Expression<double>? defaultVoltage,
    Expression<double>? defaultCapacity,
    Expression<String>? capacityUnit,
    Expression<String>? physicalSize,
    Expression<String>? suggestedIconSource,
    Expression<String>? suggestedIconKey,
    Expression<String>? suggestedIconColor,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<String>? deactivatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (typeName != null) 'type_name': typeName,
      if (description != null) 'description': description,
      if (chemistry != null) 'chemistry': chemistry,
      if (defaultVoltage != null) 'default_voltage': defaultVoltage,
      if (defaultCapacity != null) 'default_capacity': defaultCapacity,
      if (capacityUnit != null) 'capacity_unit': capacityUnit,
      if (physicalSize != null) 'physical_size': physicalSize,
      if (suggestedIconSource != null)
        'suggested_icon_source': suggestedIconSource,
      if (suggestedIconKey != null) 'suggested_icon_key': suggestedIconKey,
      if (suggestedIconColor != null)
        'suggested_icon_color': suggestedIconColor,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deactivatedAt != null) 'deactivated_at': deactivatedAt,
    });
  }

  BatteryTypesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? typeName,
      Value<String?>? description,
      Value<String?>? chemistry,
      Value<double?>? defaultVoltage,
      Value<double?>? defaultCapacity,
      Value<String?>? capacityUnit,
      Value<String?>? physicalSize,
      Value<String>? suggestedIconSource,
      Value<String>? suggestedIconKey,
      Value<String>? suggestedIconColor,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deactivatedAt}) {
    return BatteryTypesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      typeName: typeName ?? this.typeName,
      description: description ?? this.description,
      chemistry: chemistry ?? this.chemistry,
      defaultVoltage: defaultVoltage ?? this.defaultVoltage,
      defaultCapacity: defaultCapacity ?? this.defaultCapacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      physicalSize: physicalSize ?? this.physicalSize,
      suggestedIconSource: suggestedIconSource ?? this.suggestedIconSource,
      suggestedIconKey: suggestedIconKey ?? this.suggestedIconKey,
      suggestedIconColor: suggestedIconColor ?? this.suggestedIconColor,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (typeName.present) {
      map['type_name'] = Variable<String>(typeName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (chemistry.present) {
      map['chemistry'] = Variable<String>(chemistry.value);
    }
    if (defaultVoltage.present) {
      map['default_voltage'] = Variable<double>(defaultVoltage.value);
    }
    if (defaultCapacity.present) {
      map['default_capacity'] = Variable<double>(defaultCapacity.value);
    }
    if (capacityUnit.present) {
      map['capacity_unit'] = Variable<String>(capacityUnit.value);
    }
    if (physicalSize.present) {
      map['physical_size'] = Variable<String>(physicalSize.value);
    }
    if (suggestedIconSource.present) {
      map['suggested_icon_source'] =
          Variable<String>(suggestedIconSource.value);
    }
    if (suggestedIconKey.present) {
      map['suggested_icon_key'] = Variable<String>(suggestedIconKey.value);
    }
    if (suggestedIconColor.present) {
      map['suggested_icon_color'] = Variable<String>(suggestedIconColor.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $BatteryTypesTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $BatteryTypesTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (deactivatedAt.present) {
      map['deactivated_at'] = Variable<String>($BatteryTypesTable
          .$converterdeactivatedAtn
          .toSql(deactivatedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatteryTypesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('typeName: $typeName, ')
          ..write('description: $description, ')
          ..write('chemistry: $chemistry, ')
          ..write('defaultVoltage: $defaultVoltage, ')
          ..write('defaultCapacity: $defaultCapacity, ')
          ..write('capacityUnit: $capacityUnit, ')
          ..write('physicalSize: $physicalSize, ')
          ..write('suggestedIconSource: $suggestedIconSource, ')
          ..write('suggestedIconKey: $suggestedIconKey, ')
          ..write('suggestedIconColor: $suggestedIconColor, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt')
          ..write(')'))
        .toString();
  }
}

class $BatteryBatchesTable extends BatteryBatches
    with TableInfo<$BatteryBatchesTable, BatteryBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatteryBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _batchCodeMeta =
      const VerificationMeta('batchCode');
  @override
  late final GeneratedColumn<String> batchCode = GeneratedColumn<String>(
      'batch_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> purchaseDate =
      GeneratedColumn<String>('purchase_date', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $BatteryBatchesTable.$converterpurchaseDaten);
  static const VerificationMeta _purchaseLocationMeta =
      const VerificationMeta('purchaseLocation');
  @override
  late final GeneratedColumn<String> purchaseLocation = GeneratedColumn<String>(
      'purchase_location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalPurchasePriceMeta =
      const VerificationMeta('totalPurchasePrice');
  @override
  late final GeneratedColumn<double> totalPurchasePrice =
      GeneratedColumn<double>('total_purchase_price', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteryBatchesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteryBatchesTable.$convertermodifiedAt);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        batchCode,
        description,
        purchaseDate,
        purchaseLocation,
        totalPurchasePrice,
        notes,
        createdAt,
        modifiedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'battery_batches';
  @override
  VerificationContext validateIntegrity(Insertable<BatteryBatche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('batch_code')) {
      context.handle(_batchCodeMeta,
          batchCode.isAcceptableOrUnknown(data['batch_code']!, _batchCodeMeta));
    } else if (isInserting) {
      context.missing(_batchCodeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('purchase_location')) {
      context.handle(
          _purchaseLocationMeta,
          purchaseLocation.isAcceptableOrUnknown(
              data['purchase_location']!, _purchaseLocationMeta));
    }
    if (data.containsKey('total_purchase_price')) {
      context.handle(
          _totalPurchasePriceMeta,
          totalPurchasePrice.isAcceptableOrUnknown(
              data['total_purchase_price']!, _totalPurchasePriceMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatteryBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatteryBatche(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      batchCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_code'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      purchaseDate: $BatteryBatchesTable.$converterpurchaseDaten.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}purchase_date'])),
      purchaseLocation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}purchase_location']),
      totalPurchasePrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_purchase_price']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: $BatteryBatchesTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $BatteryBatchesTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
    );
  }

  @override
  $BatteryBatchesTable createAlias(String alias) {
    return $BatteryBatchesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterpurchaseDate =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterpurchaseDaten =
      NullAwareTypeConverter.wrap($converterpurchaseDate);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
}

class BatteryBatche extends DataClass implements Insertable<BatteryBatche> {
  final int id;
  final String uuid;
  final String batchCode;
  final String? description;
  final DateTime? purchaseDate;
  final String? purchaseLocation;
  final double? totalPurchasePrice;
  final String? notes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  const BatteryBatche(
      {required this.id,
      required this.uuid,
      required this.batchCode,
      this.description,
      this.purchaseDate,
      this.purchaseLocation,
      this.totalPurchasePrice,
      this.notes,
      required this.createdAt,
      required this.modifiedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['batch_code'] = Variable<String>(batchCode);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<String>(
          $BatteryBatchesTable.$converterpurchaseDaten.toSql(purchaseDate));
    }
    if (!nullToAbsent || purchaseLocation != null) {
      map['purchase_location'] = Variable<String>(purchaseLocation);
    }
    if (!nullToAbsent || totalPurchasePrice != null) {
      map['total_purchase_price'] = Variable<double>(totalPurchasePrice);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['created_at'] = Variable<String>(
          $BatteryBatchesTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $BatteryBatchesTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    return map;
  }

  BatteryBatchesCompanion toCompanion(bool nullToAbsent) {
    return BatteryBatchesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      batchCode: Value(batchCode),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      purchaseLocation: purchaseLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseLocation),
      totalPurchasePrice: totalPurchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPurchasePrice),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory BatteryBatche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatteryBatche(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      batchCode: serializer.fromJson<String>(json['batchCode']),
      description: serializer.fromJson<String?>(json['description']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      purchaseLocation: serializer.fromJson<String?>(json['purchaseLocation']),
      totalPurchasePrice:
          serializer.fromJson<double?>(json['totalPurchasePrice']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'batchCode': serializer.toJson<String>(batchCode),
      'description': serializer.toJson<String?>(description),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'purchaseLocation': serializer.toJson<String?>(purchaseLocation),
      'totalPurchasePrice': serializer.toJson<double?>(totalPurchasePrice),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  BatteryBatche copyWith(
          {int? id,
          String? uuid,
          String? batchCode,
          Value<String?> description = const Value.absent(),
          Value<DateTime?> purchaseDate = const Value.absent(),
          Value<String?> purchaseLocation = const Value.absent(),
          Value<double?> totalPurchasePrice = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? modifiedAt}) =>
      BatteryBatche(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        batchCode: batchCode ?? this.batchCode,
        description: description.present ? description.value : this.description,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        purchaseLocation: purchaseLocation.present
            ? purchaseLocation.value
            : this.purchaseLocation,
        totalPurchasePrice: totalPurchasePrice.present
            ? totalPurchasePrice.value
            : this.totalPurchasePrice,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );
  BatteryBatche copyWithCompanion(BatteryBatchesCompanion data) {
    return BatteryBatche(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      batchCode: data.batchCode.present ? data.batchCode.value : this.batchCode,
      description:
          data.description.present ? data.description.value : this.description,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      purchaseLocation: data.purchaseLocation.present
          ? data.purchaseLocation.value
          : this.purchaseLocation,
      totalPurchasePrice: data.totalPurchasePrice.present
          ? data.totalPurchasePrice.value
          : this.totalPurchasePrice,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatteryBatche(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('batchCode: $batchCode, ')
          ..write('description: $description, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchaseLocation: $purchaseLocation, ')
          ..write('totalPurchasePrice: $totalPurchasePrice, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      batchCode,
      description,
      purchaseDate,
      purchaseLocation,
      totalPurchasePrice,
      notes,
      createdAt,
      modifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatteryBatche &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.batchCode == this.batchCode &&
          other.description == this.description &&
          other.purchaseDate == this.purchaseDate &&
          other.purchaseLocation == this.purchaseLocation &&
          other.totalPurchasePrice == this.totalPurchasePrice &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt);
}

class BatteryBatchesCompanion extends UpdateCompanion<BatteryBatche> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> batchCode;
  final Value<String?> description;
  final Value<DateTime?> purchaseDate;
  final Value<String?> purchaseLocation;
  final Value<double?> totalPurchasePrice;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  const BatteryBatchesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.batchCode = const Value.absent(),
    this.description = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchaseLocation = const Value.absent(),
    this.totalPurchasePrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  });
  BatteryBatchesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String batchCode,
    this.description = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchaseLocation = const Value.absent(),
    this.totalPurchasePrice = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        batchCode = Value(batchCode);
  static Insertable<BatteryBatche> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? batchCode,
    Expression<String>? description,
    Expression<String>? purchaseDate,
    Expression<String>? purchaseLocation,
    Expression<double>? totalPurchasePrice,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (batchCode != null) 'batch_code': batchCode,
      if (description != null) 'description': description,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchaseLocation != null) 'purchase_location': purchaseLocation,
      if (totalPurchasePrice != null)
        'total_purchase_price': totalPurchasePrice,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
    });
  }

  BatteryBatchesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? batchCode,
      Value<String?>? description,
      Value<DateTime?>? purchaseDate,
      Value<String?>? purchaseLocation,
      Value<double?>? totalPurchasePrice,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt}) {
    return BatteryBatchesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      batchCode: batchCode ?? this.batchCode,
      description: description ?? this.description,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      totalPurchasePrice: totalPurchasePrice ?? this.totalPurchasePrice,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (batchCode.present) {
      map['batch_code'] = Variable<String>(batchCode.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<String>($BatteryBatchesTable
          .$converterpurchaseDaten
          .toSql(purchaseDate.value));
    }
    if (purchaseLocation.present) {
      map['purchase_location'] = Variable<String>(purchaseLocation.value);
    }
    if (totalPurchasePrice.present) {
      map['total_purchase_price'] = Variable<double>(totalPurchasePrice.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $BatteryBatchesTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $BatteryBatchesTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatteryBatchesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('batchCode: $batchCode, ')
          ..write('description: $description, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchaseLocation: $purchaseLocation, ')
          ..write('totalPurchasePrice: $totalPurchasePrice, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }
}

class $BatteriesTable extends Batteries
    with TableInfo<$BatteriesTable, Battery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatteriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _userBatteryIdMeta =
      const VerificationMeta('userBatteryId');
  @override
  late final GeneratedColumn<String> userBatteryId = GeneratedColumn<String>(
      'user_battery_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _batteryTypeIdMeta =
      const VerificationMeta('batteryTypeId');
  @override
  late final GeneratedColumn<int> batteryTypeId = GeneratedColumn<int>(
      'battery_type_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES battery_types (id) ON DELETE RESTRICT'));
  static const VerificationMeta _batchIdMeta =
      const VerificationMeta('batchId');
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
      'batch_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES battery_batches (id) ON DELETE RESTRICT'));
  static const VerificationMeta _manufacturerMeta =
      const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
      'manufacturer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serialNumberMeta =
      const VerificationMeta('serialNumber');
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
      'serial_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customLabelMeta =
      const VerificationMeta('customLabel');
  @override
  late final GeneratedColumn<String> customLabel = GeneratedColumn<String>(
      'custom_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chemistryMeta =
      const VerificationMeta('chemistry');
  @override
  late final GeneratedColumn<String> chemistry = GeneratedColumn<String>(
      'chemistry', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nominalVoltageMeta =
      const VerificationMeta('nominalVoltage');
  @override
  late final GeneratedColumn<double> nominalVoltage = GeneratedColumn<double>(
      'nominal_voltage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capacityMeta =
      const VerificationMeta('capacity');
  @override
  late final GeneratedColumn<double> capacity = GeneratedColumn<double>(
      'capacity', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capacityUnitMeta =
      const VerificationMeta('capacityUnit');
  @override
  late final GeneratedColumn<String> capacityUnit = GeneratedColumn<String>(
      'capacity_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rechargeableMeta =
      const VerificationMeta('rechargeable');
  @override
  late final GeneratedColumn<bool> rechargeable = GeneratedColumn<bool>(
      'rechargeable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("rechargeable" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> purchaseDate =
      GeneratedColumn<String>('purchase_date', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($BatteriesTable.$converterpurchaseDaten);
  static const VerificationMeta _purchaseLocationMeta =
      const VerificationMeta('purchaseLocation');
  @override
  late final GeneratedColumn<String> purchaseLocation = GeneratedColumn<String>(
      'purchase_location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purchasePriceMeta =
      const VerificationMeta('purchasePrice');
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
      'purchase_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalPackagePriceMeta =
      const VerificationMeta('totalPackagePrice');
  @override
  late final GeneratedColumn<double> totalPackagePrice =
      GeneratedColumn<double>('total_package_price', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _perBatteryPriceMeta =
      const VerificationMeta('perBatteryPrice');
  @override
  late final GeneratedColumn<double> perBatteryPrice = GeneratedColumn<double>(
      'per_battery_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String>
      warrantyExpiration = GeneratedColumn<String>(
              'warranty_expiration', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $BatteriesTable.$converterwarrantyExpirationn);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Available'));
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('New'));
  static const VerificationMeta _conditionNoteMeta =
      const VerificationMeta('conditionNote');
  @override
  late final GeneratedColumn<String> conditionNote = GeneratedColumn<String>(
      'condition_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconSourceMeta =
      const VerificationMeta('iconSource');
  @override
  late final GeneratedColumn<String> iconSource = GeneratedColumn<String>(
      'icon_source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('builtin'));
  static const VerificationMeta _iconKeyMeta =
      const VerificationMeta('iconKey');
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
      'icon_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('battery_generic'));
  static const VerificationMeta _iconColorMeta =
      const VerificationMeta('iconColor');
  @override
  late final GeneratedColumn<String> iconColor = GeneratedColumn<String>(
      'icon_color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#607D8B'));
  static const VerificationMeta _preferredPrimaryVisualMeta =
      const VerificationMeta('preferredPrimaryVisual');
  @override
  late final GeneratedColumn<String> preferredPrimaryVisual =
      GeneratedColumn<String>('preferred_primary_visual', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('icon'));
  static const VerificationMeta _estimatedChargePercentMeta =
      const VerificationMeta('estimatedChargePercent');
  @override
  late final GeneratedColumn<int> estimatedChargePercent = GeneratedColumn<int>(
      'estimated_charge_percent', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> retiredAt =
      GeneratedColumn<String>('retired_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($BatteriesTable.$converterretiredAtn);
  static const VerificationMeta _retirementReasonMeta =
      const VerificationMeta('retirementReason');
  @override
  late final GeneratedColumn<String> retirementReason = GeneratedColumn<String>(
      'retirement_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteriesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteriesTable.$convertermodifiedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>('deleted_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($BatteriesTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        userBatteryId,
        name,
        batteryTypeId,
        batchId,
        manufacturer,
        model,
        serialNumber,
        customLabel,
        chemistry,
        nominalVoltage,
        capacity,
        capacityUnit,
        rechargeable,
        purchaseDate,
        purchaseLocation,
        purchasePrice,
        totalPackagePrice,
        perBatteryPrice,
        warrantyExpiration,
        status,
        condition,
        conditionNote,
        notes,
        iconSource,
        iconKey,
        iconColor,
        preferredPrimaryVisual,
        estimatedChargePercent,
        retiredAt,
        retirementReason,
        createdAt,
        modifiedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batteries';
  @override
  VerificationContext validateIntegrity(Insertable<Battery> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('user_battery_id')) {
      context.handle(
          _userBatteryIdMeta,
          userBatteryId.isAcceptableOrUnknown(
              data['user_battery_id']!, _userBatteryIdMeta));
    } else if (isInserting) {
      context.missing(_userBatteryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('battery_type_id')) {
      context.handle(
          _batteryTypeIdMeta,
          batteryTypeId.isAcceptableOrUnknown(
              data['battery_type_id']!, _batteryTypeIdMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta,
          batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
          _manufacturerMeta,
          manufacturer.isAcceptableOrUnknown(
              data['manufacturer']!, _manufacturerMeta));
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    }
    if (data.containsKey('serial_number')) {
      context.handle(
          _serialNumberMeta,
          serialNumber.isAcceptableOrUnknown(
              data['serial_number']!, _serialNumberMeta));
    }
    if (data.containsKey('custom_label')) {
      context.handle(
          _customLabelMeta,
          customLabel.isAcceptableOrUnknown(
              data['custom_label']!, _customLabelMeta));
    }
    if (data.containsKey('chemistry')) {
      context.handle(_chemistryMeta,
          chemistry.isAcceptableOrUnknown(data['chemistry']!, _chemistryMeta));
    }
    if (data.containsKey('nominal_voltage')) {
      context.handle(
          _nominalVoltageMeta,
          nominalVoltage.isAcceptableOrUnknown(
              data['nominal_voltage']!, _nominalVoltageMeta));
    }
    if (data.containsKey('capacity')) {
      context.handle(_capacityMeta,
          capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta));
    }
    if (data.containsKey('capacity_unit')) {
      context.handle(
          _capacityUnitMeta,
          capacityUnit.isAcceptableOrUnknown(
              data['capacity_unit']!, _capacityUnitMeta));
    }
    if (data.containsKey('rechargeable')) {
      context.handle(
          _rechargeableMeta,
          rechargeable.isAcceptableOrUnknown(
              data['rechargeable']!, _rechargeableMeta));
    }
    if (data.containsKey('purchase_location')) {
      context.handle(
          _purchaseLocationMeta,
          purchaseLocation.isAcceptableOrUnknown(
              data['purchase_location']!, _purchaseLocationMeta));
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
          _purchasePriceMeta,
          purchasePrice.isAcceptableOrUnknown(
              data['purchase_price']!, _purchasePriceMeta));
    }
    if (data.containsKey('total_package_price')) {
      context.handle(
          _totalPackagePriceMeta,
          totalPackagePrice.isAcceptableOrUnknown(
              data['total_package_price']!, _totalPackagePriceMeta));
    }
    if (data.containsKey('per_battery_price')) {
      context.handle(
          _perBatteryPriceMeta,
          perBatteryPrice.isAcceptableOrUnknown(
              data['per_battery_price']!, _perBatteryPriceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    }
    if (data.containsKey('condition_note')) {
      context.handle(
          _conditionNoteMeta,
          conditionNote.isAcceptableOrUnknown(
              data['condition_note']!, _conditionNoteMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('icon_source')) {
      context.handle(
          _iconSourceMeta,
          iconSource.isAcceptableOrUnknown(
              data['icon_source']!, _iconSourceMeta));
    }
    if (data.containsKey('icon_key')) {
      context.handle(_iconKeyMeta,
          iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta));
    }
    if (data.containsKey('icon_color')) {
      context.handle(_iconColorMeta,
          iconColor.isAcceptableOrUnknown(data['icon_color']!, _iconColorMeta));
    }
    if (data.containsKey('preferred_primary_visual')) {
      context.handle(
          _preferredPrimaryVisualMeta,
          preferredPrimaryVisual.isAcceptableOrUnknown(
              data['preferred_primary_visual']!, _preferredPrimaryVisualMeta));
    }
    if (data.containsKey('estimated_charge_percent')) {
      context.handle(
          _estimatedChargePercentMeta,
          estimatedChargePercent.isAcceptableOrUnknown(
              data['estimated_charge_percent']!, _estimatedChargePercentMeta));
    }
    if (data.containsKey('retirement_reason')) {
      context.handle(
          _retirementReasonMeta,
          retirementReason.isAcceptableOrUnknown(
              data['retirement_reason']!, _retirementReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Battery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Battery(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      userBatteryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}user_battery_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      batteryTypeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_type_id']),
      batchId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}batch_id']),
      manufacturer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manufacturer']),
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model']),
      serialNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serial_number']),
      customLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}custom_label']),
      chemistry: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chemistry']),
      nominalVoltage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}nominal_voltage']),
      capacity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}capacity']),
      capacityUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}capacity_unit']),
      rechargeable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}rechargeable'])!,
      purchaseDate: $BatteriesTable.$converterpurchaseDaten.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}purchase_date'])),
      purchaseLocation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}purchase_location']),
      purchasePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}purchase_price']),
      totalPackagePrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_package_price']),
      perBatteryPrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}per_battery_price']),
      warrantyExpiration: $BatteriesTable.$converterwarrantyExpirationn.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}warranty_expiration'])),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition'])!,
      conditionNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition_note']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      iconSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_source'])!,
      iconKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_key'])!,
      iconColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_color'])!,
      preferredPrimaryVisual: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_primary_visual'])!,
      estimatedChargePercent: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}estimated_charge_percent']),
      retiredAt: $BatteriesTable.$converterretiredAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}retired_at'])),
      retirementReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}retirement_reason']),
      createdAt: $BatteriesTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $BatteriesTable.$convertermodifiedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
      deletedAt: $BatteriesTable.$converterdeletedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at'])),
    );
  }

  @override
  $BatteriesTable createAlias(String alias) {
    return $BatteriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterpurchaseDate =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterpurchaseDaten =
      NullAwareTypeConverter.wrap($converterpurchaseDate);
  static TypeConverter<DateTime, String> $converterwarrantyExpiration =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterwarrantyExpirationn =
      NullAwareTypeConverter.wrap($converterwarrantyExpiration);
  static TypeConverter<DateTime, String> $converterretiredAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterretiredAtn =
      NullAwareTypeConverter.wrap($converterretiredAt);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class Battery extends DataClass implements Insertable<Battery> {
  final int id;
  final String uuid;
  final String userBatteryId;
  final String? name;
  final int? batteryTypeId;
  final int? batchId;
  final String? manufacturer;
  final String? model;
  final String? serialNumber;
  final String? customLabel;
  final String? chemistry;
  final double? nominalVoltage;
  final double? capacity;
  final String? capacityUnit;
  final bool rechargeable;
  final DateTime? purchaseDate;
  final String? purchaseLocation;
  final double? purchasePrice;
  final double? totalPackagePrice;
  final double? perBatteryPrice;
  final DateTime? warrantyExpiration;
  final String status;
  final String condition;
  final String? conditionNote;
  final String? notes;
  final String iconSource;
  final String iconKey;
  final String iconColor;
  final String preferredPrimaryVisual;
  final int? estimatedChargePercent;
  final DateTime? retiredAt;
  final String? retirementReason;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;
  const Battery(
      {required this.id,
      required this.uuid,
      required this.userBatteryId,
      this.name,
      this.batteryTypeId,
      this.batchId,
      this.manufacturer,
      this.model,
      this.serialNumber,
      this.customLabel,
      this.chemistry,
      this.nominalVoltage,
      this.capacity,
      this.capacityUnit,
      required this.rechargeable,
      this.purchaseDate,
      this.purchaseLocation,
      this.purchasePrice,
      this.totalPackagePrice,
      this.perBatteryPrice,
      this.warrantyExpiration,
      required this.status,
      required this.condition,
      this.conditionNote,
      this.notes,
      required this.iconSource,
      required this.iconKey,
      required this.iconColor,
      required this.preferredPrimaryVisual,
      this.estimatedChargePercent,
      this.retiredAt,
      this.retirementReason,
      required this.createdAt,
      required this.modifiedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['user_battery_id'] = Variable<String>(userBatteryId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || batteryTypeId != null) {
      map['battery_type_id'] = Variable<int>(batteryTypeId);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || serialNumber != null) {
      map['serial_number'] = Variable<String>(serialNumber);
    }
    if (!nullToAbsent || customLabel != null) {
      map['custom_label'] = Variable<String>(customLabel);
    }
    if (!nullToAbsent || chemistry != null) {
      map['chemistry'] = Variable<String>(chemistry);
    }
    if (!nullToAbsent || nominalVoltage != null) {
      map['nominal_voltage'] = Variable<double>(nominalVoltage);
    }
    if (!nullToAbsent || capacity != null) {
      map['capacity'] = Variable<double>(capacity);
    }
    if (!nullToAbsent || capacityUnit != null) {
      map['capacity_unit'] = Variable<String>(capacityUnit);
    }
    map['rechargeable'] = Variable<bool>(rechargeable);
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<String>(
          $BatteriesTable.$converterpurchaseDaten.toSql(purchaseDate));
    }
    if (!nullToAbsent || purchaseLocation != null) {
      map['purchase_location'] = Variable<String>(purchaseLocation);
    }
    if (!nullToAbsent || purchasePrice != null) {
      map['purchase_price'] = Variable<double>(purchasePrice);
    }
    if (!nullToAbsent || totalPackagePrice != null) {
      map['total_package_price'] = Variable<double>(totalPackagePrice);
    }
    if (!nullToAbsent || perBatteryPrice != null) {
      map['per_battery_price'] = Variable<double>(perBatteryPrice);
    }
    if (!nullToAbsent || warrantyExpiration != null) {
      map['warranty_expiration'] = Variable<String>($BatteriesTable
          .$converterwarrantyExpirationn
          .toSql(warrantyExpiration));
    }
    map['status'] = Variable<String>(status);
    map['condition'] = Variable<String>(condition);
    if (!nullToAbsent || conditionNote != null) {
      map['condition_note'] = Variable<String>(conditionNote);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['icon_source'] = Variable<String>(iconSource);
    map['icon_key'] = Variable<String>(iconKey);
    map['icon_color'] = Variable<String>(iconColor);
    map['preferred_primary_visual'] = Variable<String>(preferredPrimaryVisual);
    if (!nullToAbsent || estimatedChargePercent != null) {
      map['estimated_charge_percent'] = Variable<int>(estimatedChargePercent);
    }
    if (!nullToAbsent || retiredAt != null) {
      map['retired_at'] = Variable<String>(
          $BatteriesTable.$converterretiredAtn.toSql(retiredAt));
    }
    if (!nullToAbsent || retirementReason != null) {
      map['retirement_reason'] = Variable<String>(retirementReason);
    }
    {
      map['created_at'] = Variable<String>(
          $BatteriesTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $BatteriesTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
          $BatteriesTable.$converterdeletedAtn.toSql(deletedAt));
    }
    return map;
  }

  BatteriesCompanion toCompanion(bool nullToAbsent) {
    return BatteriesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      userBatteryId: Value(userBatteryId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      batteryTypeId: batteryTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryTypeId),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      model:
          model == null && nullToAbsent ? const Value.absent() : Value(model),
      serialNumber: serialNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(serialNumber),
      customLabel: customLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(customLabel),
      chemistry: chemistry == null && nullToAbsent
          ? const Value.absent()
          : Value(chemistry),
      nominalVoltage: nominalVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(nominalVoltage),
      capacity: capacity == null && nullToAbsent
          ? const Value.absent()
          : Value(capacity),
      capacityUnit: capacityUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(capacityUnit),
      rechargeable: Value(rechargeable),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      purchaseLocation: purchaseLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseLocation),
      purchasePrice: purchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePrice),
      totalPackagePrice: totalPackagePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPackagePrice),
      perBatteryPrice: perBatteryPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(perBatteryPrice),
      warrantyExpiration: warrantyExpiration == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyExpiration),
      status: Value(status),
      condition: Value(condition),
      conditionNote: conditionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionNote),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      iconSource: Value(iconSource),
      iconKey: Value(iconKey),
      iconColor: Value(iconColor),
      preferredPrimaryVisual: Value(preferredPrimaryVisual),
      estimatedChargePercent: estimatedChargePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedChargePercent),
      retiredAt: retiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredAt),
      retirementReason: retirementReason == null && nullToAbsent
          ? const Value.absent()
          : Value(retirementReason),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Battery.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Battery(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      userBatteryId: serializer.fromJson<String>(json['userBatteryId']),
      name: serializer.fromJson<String?>(json['name']),
      batteryTypeId: serializer.fromJson<int?>(json['batteryTypeId']),
      batchId: serializer.fromJson<int?>(json['batchId']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      model: serializer.fromJson<String?>(json['model']),
      serialNumber: serializer.fromJson<String?>(json['serialNumber']),
      customLabel: serializer.fromJson<String?>(json['customLabel']),
      chemistry: serializer.fromJson<String?>(json['chemistry']),
      nominalVoltage: serializer.fromJson<double?>(json['nominalVoltage']),
      capacity: serializer.fromJson<double?>(json['capacity']),
      capacityUnit: serializer.fromJson<String?>(json['capacityUnit']),
      rechargeable: serializer.fromJson<bool>(json['rechargeable']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      purchaseLocation: serializer.fromJson<String?>(json['purchaseLocation']),
      purchasePrice: serializer.fromJson<double?>(json['purchasePrice']),
      totalPackagePrice:
          serializer.fromJson<double?>(json['totalPackagePrice']),
      perBatteryPrice: serializer.fromJson<double?>(json['perBatteryPrice']),
      warrantyExpiration:
          serializer.fromJson<DateTime?>(json['warrantyExpiration']),
      status: serializer.fromJson<String>(json['status']),
      condition: serializer.fromJson<String>(json['condition']),
      conditionNote: serializer.fromJson<String?>(json['conditionNote']),
      notes: serializer.fromJson<String?>(json['notes']),
      iconSource: serializer.fromJson<String>(json['iconSource']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      iconColor: serializer.fromJson<String>(json['iconColor']),
      preferredPrimaryVisual:
          serializer.fromJson<String>(json['preferredPrimaryVisual']),
      estimatedChargePercent:
          serializer.fromJson<int?>(json['estimatedChargePercent']),
      retiredAt: serializer.fromJson<DateTime?>(json['retiredAt']),
      retirementReason: serializer.fromJson<String?>(json['retirementReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'userBatteryId': serializer.toJson<String>(userBatteryId),
      'name': serializer.toJson<String?>(name),
      'batteryTypeId': serializer.toJson<int?>(batteryTypeId),
      'batchId': serializer.toJson<int?>(batchId),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'model': serializer.toJson<String?>(model),
      'serialNumber': serializer.toJson<String?>(serialNumber),
      'customLabel': serializer.toJson<String?>(customLabel),
      'chemistry': serializer.toJson<String?>(chemistry),
      'nominalVoltage': serializer.toJson<double?>(nominalVoltage),
      'capacity': serializer.toJson<double?>(capacity),
      'capacityUnit': serializer.toJson<String?>(capacityUnit),
      'rechargeable': serializer.toJson<bool>(rechargeable),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'purchaseLocation': serializer.toJson<String?>(purchaseLocation),
      'purchasePrice': serializer.toJson<double?>(purchasePrice),
      'totalPackagePrice': serializer.toJson<double?>(totalPackagePrice),
      'perBatteryPrice': serializer.toJson<double?>(perBatteryPrice),
      'warrantyExpiration': serializer.toJson<DateTime?>(warrantyExpiration),
      'status': serializer.toJson<String>(status),
      'condition': serializer.toJson<String>(condition),
      'conditionNote': serializer.toJson<String?>(conditionNote),
      'notes': serializer.toJson<String?>(notes),
      'iconSource': serializer.toJson<String>(iconSource),
      'iconKey': serializer.toJson<String>(iconKey),
      'iconColor': serializer.toJson<String>(iconColor),
      'preferredPrimaryVisual':
          serializer.toJson<String>(preferredPrimaryVisual),
      'estimatedChargePercent': serializer.toJson<int?>(estimatedChargePercent),
      'retiredAt': serializer.toJson<DateTime?>(retiredAt),
      'retirementReason': serializer.toJson<String?>(retirementReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Battery copyWith(
          {int? id,
          String? uuid,
          String? userBatteryId,
          Value<String?> name = const Value.absent(),
          Value<int?> batteryTypeId = const Value.absent(),
          Value<int?> batchId = const Value.absent(),
          Value<String?> manufacturer = const Value.absent(),
          Value<String?> model = const Value.absent(),
          Value<String?> serialNumber = const Value.absent(),
          Value<String?> customLabel = const Value.absent(),
          Value<String?> chemistry = const Value.absent(),
          Value<double?> nominalVoltage = const Value.absent(),
          Value<double?> capacity = const Value.absent(),
          Value<String?> capacityUnit = const Value.absent(),
          bool? rechargeable,
          Value<DateTime?> purchaseDate = const Value.absent(),
          Value<String?> purchaseLocation = const Value.absent(),
          Value<double?> purchasePrice = const Value.absent(),
          Value<double?> totalPackagePrice = const Value.absent(),
          Value<double?> perBatteryPrice = const Value.absent(),
          Value<DateTime?> warrantyExpiration = const Value.absent(),
          String? status,
          String? condition,
          Value<String?> conditionNote = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? iconSource,
          String? iconKey,
          String? iconColor,
          String? preferredPrimaryVisual,
          Value<int?> estimatedChargePercent = const Value.absent(),
          Value<DateTime?> retiredAt = const Value.absent(),
          Value<String?> retirementReason = const Value.absent(),
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Battery(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        userBatteryId: userBatteryId ?? this.userBatteryId,
        name: name.present ? name.value : this.name,
        batteryTypeId:
            batteryTypeId.present ? batteryTypeId.value : this.batteryTypeId,
        batchId: batchId.present ? batchId.value : this.batchId,
        manufacturer:
            manufacturer.present ? manufacturer.value : this.manufacturer,
        model: model.present ? model.value : this.model,
        serialNumber:
            serialNumber.present ? serialNumber.value : this.serialNumber,
        customLabel: customLabel.present ? customLabel.value : this.customLabel,
        chemistry: chemistry.present ? chemistry.value : this.chemistry,
        nominalVoltage:
            nominalVoltage.present ? nominalVoltage.value : this.nominalVoltage,
        capacity: capacity.present ? capacity.value : this.capacity,
        capacityUnit:
            capacityUnit.present ? capacityUnit.value : this.capacityUnit,
        rechargeable: rechargeable ?? this.rechargeable,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        purchaseLocation: purchaseLocation.present
            ? purchaseLocation.value
            : this.purchaseLocation,
        purchasePrice:
            purchasePrice.present ? purchasePrice.value : this.purchasePrice,
        totalPackagePrice: totalPackagePrice.present
            ? totalPackagePrice.value
            : this.totalPackagePrice,
        perBatteryPrice: perBatteryPrice.present
            ? perBatteryPrice.value
            : this.perBatteryPrice,
        warrantyExpiration: warrantyExpiration.present
            ? warrantyExpiration.value
            : this.warrantyExpiration,
        status: status ?? this.status,
        condition: condition ?? this.condition,
        conditionNote:
            conditionNote.present ? conditionNote.value : this.conditionNote,
        notes: notes.present ? notes.value : this.notes,
        iconSource: iconSource ?? this.iconSource,
        iconKey: iconKey ?? this.iconKey,
        iconColor: iconColor ?? this.iconColor,
        preferredPrimaryVisual:
            preferredPrimaryVisual ?? this.preferredPrimaryVisual,
        estimatedChargePercent: estimatedChargePercent.present
            ? estimatedChargePercent.value
            : this.estimatedChargePercent,
        retiredAt: retiredAt.present ? retiredAt.value : this.retiredAt,
        retirementReason: retirementReason.present
            ? retirementReason.value
            : this.retirementReason,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Battery copyWithCompanion(BatteriesCompanion data) {
    return Battery(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      userBatteryId: data.userBatteryId.present
          ? data.userBatteryId.value
          : this.userBatteryId,
      name: data.name.present ? data.name.value : this.name,
      batteryTypeId: data.batteryTypeId.present
          ? data.batteryTypeId.value
          : this.batteryTypeId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      customLabel:
          data.customLabel.present ? data.customLabel.value : this.customLabel,
      chemistry: data.chemistry.present ? data.chemistry.value : this.chemistry,
      nominalVoltage: data.nominalVoltage.present
          ? data.nominalVoltage.value
          : this.nominalVoltage,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      capacityUnit: data.capacityUnit.present
          ? data.capacityUnit.value
          : this.capacityUnit,
      rechargeable: data.rechargeable.present
          ? data.rechargeable.value
          : this.rechargeable,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      purchaseLocation: data.purchaseLocation.present
          ? data.purchaseLocation.value
          : this.purchaseLocation,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      totalPackagePrice: data.totalPackagePrice.present
          ? data.totalPackagePrice.value
          : this.totalPackagePrice,
      perBatteryPrice: data.perBatteryPrice.present
          ? data.perBatteryPrice.value
          : this.perBatteryPrice,
      warrantyExpiration: data.warrantyExpiration.present
          ? data.warrantyExpiration.value
          : this.warrantyExpiration,
      status: data.status.present ? data.status.value : this.status,
      condition: data.condition.present ? data.condition.value : this.condition,
      conditionNote: data.conditionNote.present
          ? data.conditionNote.value
          : this.conditionNote,
      notes: data.notes.present ? data.notes.value : this.notes,
      iconSource:
          data.iconSource.present ? data.iconSource.value : this.iconSource,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      iconColor: data.iconColor.present ? data.iconColor.value : this.iconColor,
      preferredPrimaryVisual: data.preferredPrimaryVisual.present
          ? data.preferredPrimaryVisual.value
          : this.preferredPrimaryVisual,
      estimatedChargePercent: data.estimatedChargePercent.present
          ? data.estimatedChargePercent.value
          : this.estimatedChargePercent,
      retiredAt: data.retiredAt.present ? data.retiredAt.value : this.retiredAt,
      retirementReason: data.retirementReason.present
          ? data.retirementReason.value
          : this.retirementReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Battery(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('userBatteryId: $userBatteryId, ')
          ..write('name: $name, ')
          ..write('batteryTypeId: $batteryTypeId, ')
          ..write('batchId: $batchId, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('customLabel: $customLabel, ')
          ..write('chemistry: $chemistry, ')
          ..write('nominalVoltage: $nominalVoltage, ')
          ..write('capacity: $capacity, ')
          ..write('capacityUnit: $capacityUnit, ')
          ..write('rechargeable: $rechargeable, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchaseLocation: $purchaseLocation, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('totalPackagePrice: $totalPackagePrice, ')
          ..write('perBatteryPrice: $perBatteryPrice, ')
          ..write('warrantyExpiration: $warrantyExpiration, ')
          ..write('status: $status, ')
          ..write('condition: $condition, ')
          ..write('conditionNote: $conditionNote, ')
          ..write('notes: $notes, ')
          ..write('iconSource: $iconSource, ')
          ..write('iconKey: $iconKey, ')
          ..write('iconColor: $iconColor, ')
          ..write('preferredPrimaryVisual: $preferredPrimaryVisual, ')
          ..write('estimatedChargePercent: $estimatedChargePercent, ')
          ..write('retiredAt: $retiredAt, ')
          ..write('retirementReason: $retirementReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        uuid,
        userBatteryId,
        name,
        batteryTypeId,
        batchId,
        manufacturer,
        model,
        serialNumber,
        customLabel,
        chemistry,
        nominalVoltage,
        capacity,
        capacityUnit,
        rechargeable,
        purchaseDate,
        purchaseLocation,
        purchasePrice,
        totalPackagePrice,
        perBatteryPrice,
        warrantyExpiration,
        status,
        condition,
        conditionNote,
        notes,
        iconSource,
        iconKey,
        iconColor,
        preferredPrimaryVisual,
        estimatedChargePercent,
        retiredAt,
        retirementReason,
        createdAt,
        modifiedAt,
        deletedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Battery &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.userBatteryId == this.userBatteryId &&
          other.name == this.name &&
          other.batteryTypeId == this.batteryTypeId &&
          other.batchId == this.batchId &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.serialNumber == this.serialNumber &&
          other.customLabel == this.customLabel &&
          other.chemistry == this.chemistry &&
          other.nominalVoltage == this.nominalVoltage &&
          other.capacity == this.capacity &&
          other.capacityUnit == this.capacityUnit &&
          other.rechargeable == this.rechargeable &&
          other.purchaseDate == this.purchaseDate &&
          other.purchaseLocation == this.purchaseLocation &&
          other.purchasePrice == this.purchasePrice &&
          other.totalPackagePrice == this.totalPackagePrice &&
          other.perBatteryPrice == this.perBatteryPrice &&
          other.warrantyExpiration == this.warrantyExpiration &&
          other.status == this.status &&
          other.condition == this.condition &&
          other.conditionNote == this.conditionNote &&
          other.notes == this.notes &&
          other.iconSource == this.iconSource &&
          other.iconKey == this.iconKey &&
          other.iconColor == this.iconColor &&
          other.preferredPrimaryVisual == this.preferredPrimaryVisual &&
          other.estimatedChargePercent == this.estimatedChargePercent &&
          other.retiredAt == this.retiredAt &&
          other.retirementReason == this.retirementReason &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deletedAt == this.deletedAt);
}

class BatteriesCompanion extends UpdateCompanion<Battery> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> userBatteryId;
  final Value<String?> name;
  final Value<int?> batteryTypeId;
  final Value<int?> batchId;
  final Value<String?> manufacturer;
  final Value<String?> model;
  final Value<String?> serialNumber;
  final Value<String?> customLabel;
  final Value<String?> chemistry;
  final Value<double?> nominalVoltage;
  final Value<double?> capacity;
  final Value<String?> capacityUnit;
  final Value<bool> rechargeable;
  final Value<DateTime?> purchaseDate;
  final Value<String?> purchaseLocation;
  final Value<double?> purchasePrice;
  final Value<double?> totalPackagePrice;
  final Value<double?> perBatteryPrice;
  final Value<DateTime?> warrantyExpiration;
  final Value<String> status;
  final Value<String> condition;
  final Value<String?> conditionNote;
  final Value<String?> notes;
  final Value<String> iconSource;
  final Value<String> iconKey;
  final Value<String> iconColor;
  final Value<String> preferredPrimaryVisual;
  final Value<int?> estimatedChargePercent;
  final Value<DateTime?> retiredAt;
  final Value<String?> retirementReason;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deletedAt;
  const BatteriesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.userBatteryId = const Value.absent(),
    this.name = const Value.absent(),
    this.batteryTypeId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.customLabel = const Value.absent(),
    this.chemistry = const Value.absent(),
    this.nominalVoltage = const Value.absent(),
    this.capacity = const Value.absent(),
    this.capacityUnit = const Value.absent(),
    this.rechargeable = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchaseLocation = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.totalPackagePrice = const Value.absent(),
    this.perBatteryPrice = const Value.absent(),
    this.warrantyExpiration = const Value.absent(),
    this.status = const Value.absent(),
    this.condition = const Value.absent(),
    this.conditionNote = const Value.absent(),
    this.notes = const Value.absent(),
    this.iconSource = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.preferredPrimaryVisual = const Value.absent(),
    this.estimatedChargePercent = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.retirementReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  BatteriesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String userBatteryId,
    this.name = const Value.absent(),
    this.batteryTypeId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.customLabel = const Value.absent(),
    this.chemistry = const Value.absent(),
    this.nominalVoltage = const Value.absent(),
    this.capacity = const Value.absent(),
    this.capacityUnit = const Value.absent(),
    this.rechargeable = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchaseLocation = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.totalPackagePrice = const Value.absent(),
    this.perBatteryPrice = const Value.absent(),
    this.warrantyExpiration = const Value.absent(),
    this.status = const Value.absent(),
    this.condition = const Value.absent(),
    this.conditionNote = const Value.absent(),
    this.notes = const Value.absent(),
    this.iconSource = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.preferredPrimaryVisual = const Value.absent(),
    this.estimatedChargePercent = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.retirementReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        userBatteryId = Value(userBatteryId);
  static Insertable<Battery> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? userBatteryId,
    Expression<String>? name,
    Expression<int>? batteryTypeId,
    Expression<int>? batchId,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<String>? serialNumber,
    Expression<String>? customLabel,
    Expression<String>? chemistry,
    Expression<double>? nominalVoltage,
    Expression<double>? capacity,
    Expression<String>? capacityUnit,
    Expression<bool>? rechargeable,
    Expression<String>? purchaseDate,
    Expression<String>? purchaseLocation,
    Expression<double>? purchasePrice,
    Expression<double>? totalPackagePrice,
    Expression<double>? perBatteryPrice,
    Expression<String>? warrantyExpiration,
    Expression<String>? status,
    Expression<String>? condition,
    Expression<String>? conditionNote,
    Expression<String>? notes,
    Expression<String>? iconSource,
    Expression<String>? iconKey,
    Expression<String>? iconColor,
    Expression<String>? preferredPrimaryVisual,
    Expression<int>? estimatedChargePercent,
    Expression<String>? retiredAt,
    Expression<String>? retirementReason,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<String>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (userBatteryId != null) 'user_battery_id': userBatteryId,
      if (name != null) 'name': name,
      if (batteryTypeId != null) 'battery_type_id': batteryTypeId,
      if (batchId != null) 'batch_id': batchId,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (customLabel != null) 'custom_label': customLabel,
      if (chemistry != null) 'chemistry': chemistry,
      if (nominalVoltage != null) 'nominal_voltage': nominalVoltage,
      if (capacity != null) 'capacity': capacity,
      if (capacityUnit != null) 'capacity_unit': capacityUnit,
      if (rechargeable != null) 'rechargeable': rechargeable,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchaseLocation != null) 'purchase_location': purchaseLocation,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (totalPackagePrice != null) 'total_package_price': totalPackagePrice,
      if (perBatteryPrice != null) 'per_battery_price': perBatteryPrice,
      if (warrantyExpiration != null) 'warranty_expiration': warrantyExpiration,
      if (status != null) 'status': status,
      if (condition != null) 'condition': condition,
      if (conditionNote != null) 'condition_note': conditionNote,
      if (notes != null) 'notes': notes,
      if (iconSource != null) 'icon_source': iconSource,
      if (iconKey != null) 'icon_key': iconKey,
      if (iconColor != null) 'icon_color': iconColor,
      if (preferredPrimaryVisual != null)
        'preferred_primary_visual': preferredPrimaryVisual,
      if (estimatedChargePercent != null)
        'estimated_charge_percent': estimatedChargePercent,
      if (retiredAt != null) 'retired_at': retiredAt,
      if (retirementReason != null) 'retirement_reason': retirementReason,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  BatteriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? userBatteryId,
      Value<String?>? name,
      Value<int?>? batteryTypeId,
      Value<int?>? batchId,
      Value<String?>? manufacturer,
      Value<String?>? model,
      Value<String?>? serialNumber,
      Value<String?>? customLabel,
      Value<String?>? chemistry,
      Value<double?>? nominalVoltage,
      Value<double?>? capacity,
      Value<String?>? capacityUnit,
      Value<bool>? rechargeable,
      Value<DateTime?>? purchaseDate,
      Value<String?>? purchaseLocation,
      Value<double?>? purchasePrice,
      Value<double?>? totalPackagePrice,
      Value<double?>? perBatteryPrice,
      Value<DateTime?>? warrantyExpiration,
      Value<String>? status,
      Value<String>? condition,
      Value<String?>? conditionNote,
      Value<String?>? notes,
      Value<String>? iconSource,
      Value<String>? iconKey,
      Value<String>? iconColor,
      Value<String>? preferredPrimaryVisual,
      Value<int?>? estimatedChargePercent,
      Value<DateTime?>? retiredAt,
      Value<String?>? retirementReason,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deletedAt}) {
    return BatteriesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userBatteryId: userBatteryId ?? this.userBatteryId,
      name: name ?? this.name,
      batteryTypeId: batteryTypeId ?? this.batteryTypeId,
      batchId: batchId ?? this.batchId,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      customLabel: customLabel ?? this.customLabel,
      chemistry: chemistry ?? this.chemistry,
      nominalVoltage: nominalVoltage ?? this.nominalVoltage,
      capacity: capacity ?? this.capacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      rechargeable: rechargeable ?? this.rechargeable,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      totalPackagePrice: totalPackagePrice ?? this.totalPackagePrice,
      perBatteryPrice: perBatteryPrice ?? this.perBatteryPrice,
      warrantyExpiration: warrantyExpiration ?? this.warrantyExpiration,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      conditionNote: conditionNote ?? this.conditionNote,
      notes: notes ?? this.notes,
      iconSource: iconSource ?? this.iconSource,
      iconKey: iconKey ?? this.iconKey,
      iconColor: iconColor ?? this.iconColor,
      preferredPrimaryVisual:
          preferredPrimaryVisual ?? this.preferredPrimaryVisual,
      estimatedChargePercent:
          estimatedChargePercent ?? this.estimatedChargePercent,
      retiredAt: retiredAt ?? this.retiredAt,
      retirementReason: retirementReason ?? this.retirementReason,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (userBatteryId.present) {
      map['user_battery_id'] = Variable<String>(userBatteryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (batteryTypeId.present) {
      map['battery_type_id'] = Variable<int>(batteryTypeId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (customLabel.present) {
      map['custom_label'] = Variable<String>(customLabel.value);
    }
    if (chemistry.present) {
      map['chemistry'] = Variable<String>(chemistry.value);
    }
    if (nominalVoltage.present) {
      map['nominal_voltage'] = Variable<double>(nominalVoltage.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<double>(capacity.value);
    }
    if (capacityUnit.present) {
      map['capacity_unit'] = Variable<String>(capacityUnit.value);
    }
    if (rechargeable.present) {
      map['rechargeable'] = Variable<bool>(rechargeable.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<String>(
          $BatteriesTable.$converterpurchaseDaten.toSql(purchaseDate.value));
    }
    if (purchaseLocation.present) {
      map['purchase_location'] = Variable<String>(purchaseLocation.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (totalPackagePrice.present) {
      map['total_package_price'] = Variable<double>(totalPackagePrice.value);
    }
    if (perBatteryPrice.present) {
      map['per_battery_price'] = Variable<double>(perBatteryPrice.value);
    }
    if (warrantyExpiration.present) {
      map['warranty_expiration'] = Variable<String>($BatteriesTable
          .$converterwarrantyExpirationn
          .toSql(warrantyExpiration.value));
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (conditionNote.present) {
      map['condition_note'] = Variable<String>(conditionNote.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (iconSource.present) {
      map['icon_source'] = Variable<String>(iconSource.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (iconColor.present) {
      map['icon_color'] = Variable<String>(iconColor.value);
    }
    if (preferredPrimaryVisual.present) {
      map['preferred_primary_visual'] =
          Variable<String>(preferredPrimaryVisual.value);
    }
    if (estimatedChargePercent.present) {
      map['estimated_charge_percent'] =
          Variable<int>(estimatedChargePercent.value);
    }
    if (retiredAt.present) {
      map['retired_at'] = Variable<String>(
          $BatteriesTable.$converterretiredAtn.toSql(retiredAt.value));
    }
    if (retirementReason.present) {
      map['retirement_reason'] = Variable<String>(retirementReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $BatteriesTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $BatteriesTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
          $BatteriesTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatteriesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('userBatteryId: $userBatteryId, ')
          ..write('name: $name, ')
          ..write('batteryTypeId: $batteryTypeId, ')
          ..write('batchId: $batchId, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('customLabel: $customLabel, ')
          ..write('chemistry: $chemistry, ')
          ..write('nominalVoltage: $nominalVoltage, ')
          ..write('capacity: $capacity, ')
          ..write('capacityUnit: $capacityUnit, ')
          ..write('rechargeable: $rechargeable, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchaseLocation: $purchaseLocation, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('totalPackagePrice: $totalPackagePrice, ')
          ..write('perBatteryPrice: $perBatteryPrice, ')
          ..write('warrantyExpiration: $warrantyExpiration, ')
          ..write('status: $status, ')
          ..write('condition: $condition, ')
          ..write('conditionNote: $conditionNote, ')
          ..write('notes: $notes, ')
          ..write('iconSource: $iconSource, ')
          ..write('iconKey: $iconKey, ')
          ..write('iconColor: $iconColor, ')
          ..write('preferredPrimaryVisual: $preferredPrimaryVisual, ')
          ..write('estimatedChargePercent: $estimatedChargePercent, ')
          ..write('retiredAt: $retiredAt, ')
          ..write('retirementReason: $retirementReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $BatterySetsTable extends BatterySets
    with TableInfo<$BatterySetsTable, BatterySet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatterySetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _userSetIdMeta =
      const VerificationMeta('userSetId');
  @override
  late final GeneratedColumn<String> userSetId = GeneratedColumn<String>(
      'user_set_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _batteryTypeIdMeta =
      const VerificationMeta('batteryTypeId');
  @override
  late final GeneratedColumn<int> batteryTypeId = GeneratedColumn<int>(
      'battery_type_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES battery_types (id) ON DELETE RESTRICT'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconSourceMeta =
      const VerificationMeta('iconSource');
  @override
  late final GeneratedColumn<String> iconSource = GeneratedColumn<String>(
      'icon_source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('builtin'));
  static const VerificationMeta _iconKeyMeta =
      const VerificationMeta('iconKey');
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
      'icon_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('battery_set_generic'));
  static const VerificationMeta _iconColorMeta =
      const VerificationMeta('iconColor');
  @override
  late final GeneratedColumn<String> iconColor = GeneratedColumn<String>(
      'icon_color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#607D8B'));
  static const VerificationMeta _preferredPrimaryVisualMeta =
      const VerificationMeta('preferredPrimaryVisual');
  @override
  late final GeneratedColumn<String> preferredPrimaryVisual =
      GeneratedColumn<String>('preferred_primary_visual', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('icon'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatterySetsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatterySetsTable.$convertermodifiedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deactivatedAt =
      GeneratedColumn<String>('deactivated_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($BatterySetsTable.$converterdeactivatedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>('deleted_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($BatterySetsTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        userSetId,
        name,
        batteryTypeId,
        description,
        notes,
        iconSource,
        iconKey,
        iconColor,
        preferredPrimaryVisual,
        createdAt,
        modifiedAt,
        deactivatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'battery_sets';
  @override
  VerificationContext validateIntegrity(Insertable<BatterySet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('user_set_id')) {
      context.handle(
          _userSetIdMeta,
          userSetId.isAcceptableOrUnknown(
              data['user_set_id']!, _userSetIdMeta));
    } else if (isInserting) {
      context.missing(_userSetIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('battery_type_id')) {
      context.handle(
          _batteryTypeIdMeta,
          batteryTypeId.isAcceptableOrUnknown(
              data['battery_type_id']!, _batteryTypeIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('icon_source')) {
      context.handle(
          _iconSourceMeta,
          iconSource.isAcceptableOrUnknown(
              data['icon_source']!, _iconSourceMeta));
    }
    if (data.containsKey('icon_key')) {
      context.handle(_iconKeyMeta,
          iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta));
    }
    if (data.containsKey('icon_color')) {
      context.handle(_iconColorMeta,
          iconColor.isAcceptableOrUnknown(data['icon_color']!, _iconColorMeta));
    }
    if (data.containsKey('preferred_primary_visual')) {
      context.handle(
          _preferredPrimaryVisualMeta,
          preferredPrimaryVisual.isAcceptableOrUnknown(
              data['preferred_primary_visual']!, _preferredPrimaryVisualMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatterySet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatterySet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      userSetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_set_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      batteryTypeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_type_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      iconSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_source'])!,
      iconKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_key'])!,
      iconColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_color'])!,
      preferredPrimaryVisual: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_primary_visual'])!,
      createdAt: $BatterySetsTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $BatterySetsTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
      deactivatedAt: $BatterySetsTable.$converterdeactivatedAtn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}deactivated_at'])),
      deletedAt: $BatterySetsTable.$converterdeletedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at'])),
    );
  }

  @override
  $BatterySetsTable createAlias(String alias) {
    return $BatterySetsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterdeactivatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeactivatedAtn =
      NullAwareTypeConverter.wrap($converterdeactivatedAt);
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class BatterySet extends DataClass implements Insertable<BatterySet> {
  final int id;
  final String uuid;
  final String userSetId;
  final String name;
  final int? batteryTypeId;
  final String? description;
  final String? notes;
  final String iconSource;
  final String iconKey;
  final String iconColor;
  final String preferredPrimaryVisual;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;
  final DateTime? deletedAt;
  const BatterySet(
      {required this.id,
      required this.uuid,
      required this.userSetId,
      required this.name,
      this.batteryTypeId,
      this.description,
      this.notes,
      required this.iconSource,
      required this.iconKey,
      required this.iconColor,
      required this.preferredPrimaryVisual,
      required this.createdAt,
      required this.modifiedAt,
      this.deactivatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['user_set_id'] = Variable<String>(userSetId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || batteryTypeId != null) {
      map['battery_type_id'] = Variable<int>(batteryTypeId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['icon_source'] = Variable<String>(iconSource);
    map['icon_key'] = Variable<String>(iconKey);
    map['icon_color'] = Variable<String>(iconColor);
    map['preferred_primary_visual'] = Variable<String>(preferredPrimaryVisual);
    {
      map['created_at'] = Variable<String>(
          $BatterySetsTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $BatterySetsTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    if (!nullToAbsent || deactivatedAt != null) {
      map['deactivated_at'] = Variable<String>(
          $BatterySetsTable.$converterdeactivatedAtn.toSql(deactivatedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
          $BatterySetsTable.$converterdeletedAtn.toSql(deletedAt));
    }
    return map;
  }

  BatterySetsCompanion toCompanion(bool nullToAbsent) {
    return BatterySetsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      userSetId: Value(userSetId),
      name: Value(name),
      batteryTypeId: batteryTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryTypeId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      iconSource: Value(iconSource),
      iconKey: Value(iconKey),
      iconColor: Value(iconColor),
      preferredPrimaryVisual: Value(preferredPrimaryVisual),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deactivatedAt: deactivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deactivatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory BatterySet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatterySet(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      userSetId: serializer.fromJson<String>(json['userSetId']),
      name: serializer.fromJson<String>(json['name']),
      batteryTypeId: serializer.fromJson<int?>(json['batteryTypeId']),
      description: serializer.fromJson<String?>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
      iconSource: serializer.fromJson<String>(json['iconSource']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      iconColor: serializer.fromJson<String>(json['iconColor']),
      preferredPrimaryVisual:
          serializer.fromJson<String>(json['preferredPrimaryVisual']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deactivatedAt: serializer.fromJson<DateTime?>(json['deactivatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'userSetId': serializer.toJson<String>(userSetId),
      'name': serializer.toJson<String>(name),
      'batteryTypeId': serializer.toJson<int?>(batteryTypeId),
      'description': serializer.toJson<String?>(description),
      'notes': serializer.toJson<String?>(notes),
      'iconSource': serializer.toJson<String>(iconSource),
      'iconKey': serializer.toJson<String>(iconKey),
      'iconColor': serializer.toJson<String>(iconColor),
      'preferredPrimaryVisual':
          serializer.toJson<String>(preferredPrimaryVisual),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deactivatedAt': serializer.toJson<DateTime?>(deactivatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  BatterySet copyWith(
          {int? id,
          String? uuid,
          String? userSetId,
          String? name,
          Value<int?> batteryTypeId = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? iconSource,
          String? iconKey,
          String? iconColor,
          String? preferredPrimaryVisual,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deactivatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      BatterySet(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        userSetId: userSetId ?? this.userSetId,
        name: name ?? this.name,
        batteryTypeId:
            batteryTypeId.present ? batteryTypeId.value : this.batteryTypeId,
        description: description.present ? description.value : this.description,
        notes: notes.present ? notes.value : this.notes,
        iconSource: iconSource ?? this.iconSource,
        iconKey: iconKey ?? this.iconKey,
        iconColor: iconColor ?? this.iconColor,
        preferredPrimaryVisual:
            preferredPrimaryVisual ?? this.preferredPrimaryVisual,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deactivatedAt:
            deactivatedAt.present ? deactivatedAt.value : this.deactivatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  BatterySet copyWithCompanion(BatterySetsCompanion data) {
    return BatterySet(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      userSetId: data.userSetId.present ? data.userSetId.value : this.userSetId,
      name: data.name.present ? data.name.value : this.name,
      batteryTypeId: data.batteryTypeId.present
          ? data.batteryTypeId.value
          : this.batteryTypeId,
      description:
          data.description.present ? data.description.value : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
      iconSource:
          data.iconSource.present ? data.iconSource.value : this.iconSource,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      iconColor: data.iconColor.present ? data.iconColor.value : this.iconColor,
      preferredPrimaryVisual: data.preferredPrimaryVisual.present
          ? data.preferredPrimaryVisual.value
          : this.preferredPrimaryVisual,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deactivatedAt: data.deactivatedAt.present
          ? data.deactivatedAt.value
          : this.deactivatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatterySet(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('userSetId: $userSetId, ')
          ..write('name: $name, ')
          ..write('batteryTypeId: $batteryTypeId, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('iconSource: $iconSource, ')
          ..write('iconKey: $iconKey, ')
          ..write('iconColor: $iconColor, ')
          ..write('preferredPrimaryVisual: $preferredPrimaryVisual, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      userSetId,
      name,
      batteryTypeId,
      description,
      notes,
      iconSource,
      iconKey,
      iconColor,
      preferredPrimaryVisual,
      createdAt,
      modifiedAt,
      deactivatedAt,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatterySet &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.userSetId == this.userSetId &&
          other.name == this.name &&
          other.batteryTypeId == this.batteryTypeId &&
          other.description == this.description &&
          other.notes == this.notes &&
          other.iconSource == this.iconSource &&
          other.iconKey == this.iconKey &&
          other.iconColor == this.iconColor &&
          other.preferredPrimaryVisual == this.preferredPrimaryVisual &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deactivatedAt == this.deactivatedAt &&
          other.deletedAt == this.deletedAt);
}

class BatterySetsCompanion extends UpdateCompanion<BatterySet> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> userSetId;
  final Value<String> name;
  final Value<int?> batteryTypeId;
  final Value<String?> description;
  final Value<String?> notes;
  final Value<String> iconSource;
  final Value<String> iconKey;
  final Value<String> iconColor;
  final Value<String> preferredPrimaryVisual;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deactivatedAt;
  final Value<DateTime?> deletedAt;
  const BatterySetsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.userSetId = const Value.absent(),
    this.name = const Value.absent(),
    this.batteryTypeId = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.iconSource = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.preferredPrimaryVisual = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  BatterySetsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String userSetId,
    required String name,
    this.batteryTypeId = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.iconSource = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.preferredPrimaryVisual = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        userSetId = Value(userSetId),
        name = Value(name);
  static Insertable<BatterySet> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? userSetId,
    Expression<String>? name,
    Expression<int>? batteryTypeId,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<String>? iconSource,
    Expression<String>? iconKey,
    Expression<String>? iconColor,
    Expression<String>? preferredPrimaryVisual,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<String>? deactivatedAt,
    Expression<String>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (userSetId != null) 'user_set_id': userSetId,
      if (name != null) 'name': name,
      if (batteryTypeId != null) 'battery_type_id': batteryTypeId,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (iconSource != null) 'icon_source': iconSource,
      if (iconKey != null) 'icon_key': iconKey,
      if (iconColor != null) 'icon_color': iconColor,
      if (preferredPrimaryVisual != null)
        'preferred_primary_visual': preferredPrimaryVisual,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deactivatedAt != null) 'deactivated_at': deactivatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  BatterySetsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? userSetId,
      Value<String>? name,
      Value<int?>? batteryTypeId,
      Value<String?>? description,
      Value<String?>? notes,
      Value<String>? iconSource,
      Value<String>? iconKey,
      Value<String>? iconColor,
      Value<String>? preferredPrimaryVisual,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deactivatedAt,
      Value<DateTime?>? deletedAt}) {
    return BatterySetsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userSetId: userSetId ?? this.userSetId,
      name: name ?? this.name,
      batteryTypeId: batteryTypeId ?? this.batteryTypeId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      iconSource: iconSource ?? this.iconSource,
      iconKey: iconKey ?? this.iconKey,
      iconColor: iconColor ?? this.iconColor,
      preferredPrimaryVisual:
          preferredPrimaryVisual ?? this.preferredPrimaryVisual,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (userSetId.present) {
      map['user_set_id'] = Variable<String>(userSetId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (batteryTypeId.present) {
      map['battery_type_id'] = Variable<int>(batteryTypeId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (iconSource.present) {
      map['icon_source'] = Variable<String>(iconSource.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (iconColor.present) {
      map['icon_color'] = Variable<String>(iconColor.value);
    }
    if (preferredPrimaryVisual.present) {
      map['preferred_primary_visual'] =
          Variable<String>(preferredPrimaryVisual.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $BatterySetsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $BatterySetsTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (deactivatedAt.present) {
      map['deactivated_at'] = Variable<String>($BatterySetsTable
          .$converterdeactivatedAtn
          .toSql(deactivatedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
          $BatterySetsTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatterySetsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('userSetId: $userSetId, ')
          ..write('name: $name, ')
          ..write('batteryTypeId: $batteryTypeId, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('iconSource: $iconSource, ')
          ..write('iconKey: $iconKey, ')
          ..write('iconColor: $iconColor, ')
          ..write('preferredPrimaryVisual: $preferredPrimaryVisual, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $BatterySetMembershipsTable extends BatterySetMemberships
    with TableInfo<$BatterySetMembershipsTable, BatterySetMembership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatterySetMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _batteryIdMeta =
      const VerificationMeta('batteryId');
  @override
  late final GeneratedColumn<int> batteryId = GeneratedColumn<int>(
      'battery_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES batteries (id) ON DELETE RESTRICT'));
  static const VerificationMeta _batterySetIdMeta =
      const VerificationMeta('batterySetId');
  @override
  late final GeneratedColumn<int> batterySetId = GeneratedColumn<int>(
      'battery_set_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES battery_sets (id) ON DELETE RESTRICT'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> addedAt =
      GeneratedColumn<String>('added_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>(
              $BatterySetMembershipsTable.$converteraddedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> removedAt =
      GeneratedColumn<String>('removed_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $BatterySetMembershipsTable.$converterremovedAtn);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _operationUuidMeta =
      const VerificationMeta('operationUuid');
  @override
  late final GeneratedColumn<String> operationUuid = GeneratedColumn<String>(
      'operation_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        batteryId,
        batterySetId,
        addedAt,
        removedAt,
        notes,
        operationUuid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'battery_set_memberships';
  @override
  VerificationContext validateIntegrity(
      Insertable<BatterySetMembership> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('battery_id')) {
      context.handle(_batteryIdMeta,
          batteryId.isAcceptableOrUnknown(data['battery_id']!, _batteryIdMeta));
    } else if (isInserting) {
      context.missing(_batteryIdMeta);
    }
    if (data.containsKey('battery_set_id')) {
      context.handle(
          _batterySetIdMeta,
          batterySetId.isAcceptableOrUnknown(
              data['battery_set_id']!, _batterySetIdMeta));
    } else if (isInserting) {
      context.missing(_batterySetIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('operation_uuid')) {
      context.handle(
          _operationUuidMeta,
          operationUuid.isAcceptableOrUnknown(
              data['operation_uuid']!, _operationUuidMeta));
    } else if (isInserting) {
      context.missing(_operationUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatterySetMembership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatterySetMembership(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      batteryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_id'])!,
      batterySetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_set_id'])!,
      addedAt: $BatterySetMembershipsTable.$converteraddedAt.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}added_at'])!),
      removedAt: $BatterySetMembershipsTable.$converterremovedAtn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}removed_at'])),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      operationUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_uuid'])!,
    );
  }

  @override
  $BatterySetMembershipsTable createAlias(String alias) {
    return $BatterySetMembershipsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converteraddedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterremovedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterremovedAtn =
      NullAwareTypeConverter.wrap($converterremovedAt);
}

class BatterySetMembership extends DataClass
    implements Insertable<BatterySetMembership> {
  final int id;
  final String uuid;
  final int batteryId;
  final int batterySetId;
  final DateTime addedAt;
  final DateTime? removedAt;
  final String? notes;
  final String operationUuid;
  const BatterySetMembership(
      {required this.id,
      required this.uuid,
      required this.batteryId,
      required this.batterySetId,
      required this.addedAt,
      this.removedAt,
      this.notes,
      required this.operationUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['battery_id'] = Variable<int>(batteryId);
    map['battery_set_id'] = Variable<int>(batterySetId);
    {
      map['added_at'] = Variable<String>(
          $BatterySetMembershipsTable.$converteraddedAt.toSql(addedAt));
    }
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<String>(
          $BatterySetMembershipsTable.$converterremovedAtn.toSql(removedAt));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['operation_uuid'] = Variable<String>(operationUuid);
    return map;
  }

  BatterySetMembershipsCompanion toCompanion(bool nullToAbsent) {
    return BatterySetMembershipsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      batteryId: Value(batteryId),
      batterySetId: Value(batterySetId),
      addedAt: Value(addedAt),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      operationUuid: Value(operationUuid),
    );
  }

  factory BatterySetMembership.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatterySetMembership(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      batteryId: serializer.fromJson<int>(json['batteryId']),
      batterySetId: serializer.fromJson<int>(json['batterySetId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      operationUuid: serializer.fromJson<String>(json['operationUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'batteryId': serializer.toJson<int>(batteryId),
      'batterySetId': serializer.toJson<int>(batterySetId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
      'notes': serializer.toJson<String?>(notes),
      'operationUuid': serializer.toJson<String>(operationUuid),
    };
  }

  BatterySetMembership copyWith(
          {int? id,
          String? uuid,
          int? batteryId,
          int? batterySetId,
          DateTime? addedAt,
          Value<DateTime?> removedAt = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? operationUuid}) =>
      BatterySetMembership(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        batteryId: batteryId ?? this.batteryId,
        batterySetId: batterySetId ?? this.batterySetId,
        addedAt: addedAt ?? this.addedAt,
        removedAt: removedAt.present ? removedAt.value : this.removedAt,
        notes: notes.present ? notes.value : this.notes,
        operationUuid: operationUuid ?? this.operationUuid,
      );
  BatterySetMembership copyWithCompanion(BatterySetMembershipsCompanion data) {
    return BatterySetMembership(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      batteryId: data.batteryId.present ? data.batteryId.value : this.batteryId,
      batterySetId: data.batterySetId.present
          ? data.batterySetId.value
          : this.batterySetId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      operationUuid: data.operationUuid.present
          ? data.operationUuid.value
          : this.operationUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatterySetMembership(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('batteryId: $batteryId, ')
          ..write('batterySetId: $batterySetId, ')
          ..write('addedAt: $addedAt, ')
          ..write('removedAt: $removedAt, ')
          ..write('notes: $notes, ')
          ..write('operationUuid: $operationUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, batteryId, batterySetId, addedAt,
      removedAt, notes, operationUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatterySetMembership &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.batteryId == this.batteryId &&
          other.batterySetId == this.batterySetId &&
          other.addedAt == this.addedAt &&
          other.removedAt == this.removedAt &&
          other.notes == this.notes &&
          other.operationUuid == this.operationUuid);
}

class BatterySetMembershipsCompanion
    extends UpdateCompanion<BatterySetMembership> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> batteryId;
  final Value<int> batterySetId;
  final Value<DateTime> addedAt;
  final Value<DateTime?> removedAt;
  final Value<String?> notes;
  final Value<String> operationUuid;
  const BatterySetMembershipsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.batteryId = const Value.absent(),
    this.batterySetId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.operationUuid = const Value.absent(),
  });
  BatterySetMembershipsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required int batteryId,
    required int batterySetId,
    this.addedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.notes = const Value.absent(),
    required String operationUuid,
  })  : uuid = Value(uuid),
        batteryId = Value(batteryId),
        batterySetId = Value(batterySetId),
        operationUuid = Value(operationUuid);
  static Insertable<BatterySetMembership> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? batteryId,
    Expression<int>? batterySetId,
    Expression<String>? addedAt,
    Expression<String>? removedAt,
    Expression<String>? notes,
    Expression<String>? operationUuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (batteryId != null) 'battery_id': batteryId,
      if (batterySetId != null) 'battery_set_id': batterySetId,
      if (addedAt != null) 'added_at': addedAt,
      if (removedAt != null) 'removed_at': removedAt,
      if (notes != null) 'notes': notes,
      if (operationUuid != null) 'operation_uuid': operationUuid,
    });
  }

  BatterySetMembershipsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<int>? batteryId,
      Value<int>? batterySetId,
      Value<DateTime>? addedAt,
      Value<DateTime?>? removedAt,
      Value<String?>? notes,
      Value<String>? operationUuid}) {
    return BatterySetMembershipsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      batteryId: batteryId ?? this.batteryId,
      batterySetId: batterySetId ?? this.batterySetId,
      addedAt: addedAt ?? this.addedAt,
      removedAt: removedAt ?? this.removedAt,
      notes: notes ?? this.notes,
      operationUuid: operationUuid ?? this.operationUuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (batteryId.present) {
      map['battery_id'] = Variable<int>(batteryId.value);
    }
    if (batterySetId.present) {
      map['battery_set_id'] = Variable<int>(batterySetId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<String>(
          $BatterySetMembershipsTable.$converteraddedAt.toSql(addedAt.value));
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<String>($BatterySetMembershipsTable
          .$converterremovedAtn
          .toSql(removedAt.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (operationUuid.present) {
      map['operation_uuid'] = Variable<String>(operationUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatterySetMembershipsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('batteryId: $batteryId, ')
          ..write('batterySetId: $batterySetId, ')
          ..write('addedAt: $addedAt, ')
          ..write('removedAt: $removedAt, ')
          ..write('notes: $notes, ')
          ..write('operationUuid: $operationUuid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _manufacturerMeta =
      const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
      'manufacturer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serialNumberMeta =
      const VerificationMeta('serialNumber');
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
      'serial_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _requiredBatteryTypeIdMeta =
      const VerificationMeta('requiredBatteryTypeId');
  @override
  late final GeneratedColumn<int> requiredBatteryTypeId = GeneratedColumn<int>(
      'required_battery_type_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES battery_types (id) ON DELETE RESTRICT'));
  static const VerificationMeta _requiredBatteryQuantityMeta =
      const VerificationMeta('requiredBatteryQuantity');
  @override
  late final GeneratedColumn<int> requiredBatteryQuantity =
      GeneratedColumn<int>('required_battery_quantity', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _requiredVoltageMeta =
      const VerificationMeta('requiredVoltage');
  @override
  late final GeneratedColumn<double> requiredVoltage = GeneratedColumn<double>(
      'required_voltage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _requirementNotesMeta =
      const VerificationMeta('requirementNotes');
  @override
  late final GeneratedColumn<String> requirementNotes = GeneratedColumn<String>(
      'requirement_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconSourceMeta =
      const VerificationMeta('iconSource');
  @override
  late final GeneratedColumn<String> iconSource = GeneratedColumn<String>(
      'icon_source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('builtin'));
  static const VerificationMeta _iconKeyMeta =
      const VerificationMeta('iconKey');
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
      'icon_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('device_generic'));
  static const VerificationMeta _iconColorMeta =
      const VerificationMeta('iconColor');
  @override
  late final GeneratedColumn<String> iconColor = GeneratedColumn<String>(
      'icon_color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#607D8B'));
  static const VerificationMeta _preferredPrimaryVisualMeta =
      const VerificationMeta('preferredPrimaryVisual');
  @override
  late final GeneratedColumn<String> preferredPrimaryVisual =
      GeneratedColumn<String>('preferred_primary_visual', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('icon'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($DevicesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($DevicesTable.$convertermodifiedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deactivatedAt =
      GeneratedColumn<String>('deactivated_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($DevicesTable.$converterdeactivatedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>('deleted_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($DevicesTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        name,
        category,
        manufacturer,
        model,
        serialNumber,
        location,
        description,
        notes,
        requiredBatteryTypeId,
        requiredBatteryQuantity,
        requiredVoltage,
        requirementNotes,
        iconSource,
        iconKey,
        iconColor,
        preferredPrimaryVisual,
        createdAt,
        modifiedAt,
        deactivatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
          _manufacturerMeta,
          manufacturer.isAcceptableOrUnknown(
              data['manufacturer']!, _manufacturerMeta));
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    }
    if (data.containsKey('serial_number')) {
      context.handle(
          _serialNumberMeta,
          serialNumber.isAcceptableOrUnknown(
              data['serial_number']!, _serialNumberMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('required_battery_type_id')) {
      context.handle(
          _requiredBatteryTypeIdMeta,
          requiredBatteryTypeId.isAcceptableOrUnknown(
              data['required_battery_type_id']!, _requiredBatteryTypeIdMeta));
    }
    if (data.containsKey('required_battery_quantity')) {
      context.handle(
          _requiredBatteryQuantityMeta,
          requiredBatteryQuantity.isAcceptableOrUnknown(
              data['required_battery_quantity']!,
              _requiredBatteryQuantityMeta));
    }
    if (data.containsKey('required_voltage')) {
      context.handle(
          _requiredVoltageMeta,
          requiredVoltage.isAcceptableOrUnknown(
              data['required_voltage']!, _requiredVoltageMeta));
    }
    if (data.containsKey('requirement_notes')) {
      context.handle(
          _requirementNotesMeta,
          requirementNotes.isAcceptableOrUnknown(
              data['requirement_notes']!, _requirementNotesMeta));
    }
    if (data.containsKey('icon_source')) {
      context.handle(
          _iconSourceMeta,
          iconSource.isAcceptableOrUnknown(
              data['icon_source']!, _iconSourceMeta));
    }
    if (data.containsKey('icon_key')) {
      context.handle(_iconKeyMeta,
          iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta));
    }
    if (data.containsKey('icon_color')) {
      context.handle(_iconColorMeta,
          iconColor.isAcceptableOrUnknown(data['icon_color']!, _iconColorMeta));
    }
    if (data.containsKey('preferred_primary_visual')) {
      context.handle(
          _preferredPrimaryVisualMeta,
          preferredPrimaryVisual.isAcceptableOrUnknown(
              data['preferred_primary_visual']!, _preferredPrimaryVisualMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      manufacturer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manufacturer']),
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model']),
      serialNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serial_number']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      requiredBatteryTypeId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}required_battery_type_id']),
      requiredBatteryQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}required_battery_quantity']),
      requiredVoltage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}required_voltage']),
      requirementNotes: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}requirement_notes']),
      iconSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_source'])!,
      iconKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_key'])!,
      iconColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_color'])!,
      preferredPrimaryVisual: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_primary_visual'])!,
      createdAt: $DevicesTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $DevicesTable.$convertermodifiedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
      deactivatedAt: $DevicesTable.$converterdeactivatedAtn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}deactivated_at'])),
      deletedAt: $DevicesTable.$converterdeletedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at'])),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterdeactivatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeactivatedAtn =
      NullAwareTypeConverter.wrap($converterdeactivatedAt);
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class Device extends DataClass implements Insertable<Device> {
  final int id;
  final String uuid;
  final String name;
  final String? category;
  final String? manufacturer;
  final String? model;
  final String? serialNumber;
  final String? location;
  final String? description;
  final String? notes;
  final int? requiredBatteryTypeId;
  final int? requiredBatteryQuantity;
  final double? requiredVoltage;
  final String? requirementNotes;
  final String iconSource;
  final String iconKey;
  final String iconColor;
  final String preferredPrimaryVisual;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;
  final DateTime? deletedAt;
  const Device(
      {required this.id,
      required this.uuid,
      required this.name,
      this.category,
      this.manufacturer,
      this.model,
      this.serialNumber,
      this.location,
      this.description,
      this.notes,
      this.requiredBatteryTypeId,
      this.requiredBatteryQuantity,
      this.requiredVoltage,
      this.requirementNotes,
      required this.iconSource,
      required this.iconKey,
      required this.iconColor,
      required this.preferredPrimaryVisual,
      required this.createdAt,
      required this.modifiedAt,
      this.deactivatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || serialNumber != null) {
      map['serial_number'] = Variable<String>(serialNumber);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || requiredBatteryTypeId != null) {
      map['required_battery_type_id'] = Variable<int>(requiredBatteryTypeId);
    }
    if (!nullToAbsent || requiredBatteryQuantity != null) {
      map['required_battery_quantity'] = Variable<int>(requiredBatteryQuantity);
    }
    if (!nullToAbsent || requiredVoltage != null) {
      map['required_voltage'] = Variable<double>(requiredVoltage);
    }
    if (!nullToAbsent || requirementNotes != null) {
      map['requirement_notes'] = Variable<String>(requirementNotes);
    }
    map['icon_source'] = Variable<String>(iconSource);
    map['icon_key'] = Variable<String>(iconKey);
    map['icon_color'] = Variable<String>(iconColor);
    map['preferred_primary_visual'] = Variable<String>(preferredPrimaryVisual);
    {
      map['created_at'] =
          Variable<String>($DevicesTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $DevicesTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    if (!nullToAbsent || deactivatedAt != null) {
      map['deactivated_at'] = Variable<String>(
          $DevicesTable.$converterdeactivatedAtn.toSql(deactivatedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] =
          Variable<String>($DevicesTable.$converterdeletedAtn.toSql(deletedAt));
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      model:
          model == null && nullToAbsent ? const Value.absent() : Value(model),
      serialNumber: serialNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(serialNumber),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      requiredBatteryTypeId: requiredBatteryTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(requiredBatteryTypeId),
      requiredBatteryQuantity: requiredBatteryQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(requiredBatteryQuantity),
      requiredVoltage: requiredVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(requiredVoltage),
      requirementNotes: requirementNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(requirementNotes),
      iconSource: Value(iconSource),
      iconKey: Value(iconKey),
      iconColor: Value(iconColor),
      preferredPrimaryVisual: Value(preferredPrimaryVisual),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deactivatedAt: deactivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deactivatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      model: serializer.fromJson<String?>(json['model']),
      serialNumber: serializer.fromJson<String?>(json['serialNumber']),
      location: serializer.fromJson<String?>(json['location']),
      description: serializer.fromJson<String?>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
      requiredBatteryTypeId:
          serializer.fromJson<int?>(json['requiredBatteryTypeId']),
      requiredBatteryQuantity:
          serializer.fromJson<int?>(json['requiredBatteryQuantity']),
      requiredVoltage: serializer.fromJson<double?>(json['requiredVoltage']),
      requirementNotes: serializer.fromJson<String?>(json['requirementNotes']),
      iconSource: serializer.fromJson<String>(json['iconSource']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      iconColor: serializer.fromJson<String>(json['iconColor']),
      preferredPrimaryVisual:
          serializer.fromJson<String>(json['preferredPrimaryVisual']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deactivatedAt: serializer.fromJson<DateTime?>(json['deactivatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'model': serializer.toJson<String?>(model),
      'serialNumber': serializer.toJson<String?>(serialNumber),
      'location': serializer.toJson<String?>(location),
      'description': serializer.toJson<String?>(description),
      'notes': serializer.toJson<String?>(notes),
      'requiredBatteryTypeId': serializer.toJson<int?>(requiredBatteryTypeId),
      'requiredBatteryQuantity':
          serializer.toJson<int?>(requiredBatteryQuantity),
      'requiredVoltage': serializer.toJson<double?>(requiredVoltage),
      'requirementNotes': serializer.toJson<String?>(requirementNotes),
      'iconSource': serializer.toJson<String>(iconSource),
      'iconKey': serializer.toJson<String>(iconKey),
      'iconColor': serializer.toJson<String>(iconColor),
      'preferredPrimaryVisual':
          serializer.toJson<String>(preferredPrimaryVisual),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deactivatedAt': serializer.toJson<DateTime?>(deactivatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Device copyWith(
          {int? id,
          String? uuid,
          String? name,
          Value<String?> category = const Value.absent(),
          Value<String?> manufacturer = const Value.absent(),
          Value<String?> model = const Value.absent(),
          Value<String?> serialNumber = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<int?> requiredBatteryTypeId = const Value.absent(),
          Value<int?> requiredBatteryQuantity = const Value.absent(),
          Value<double?> requiredVoltage = const Value.absent(),
          Value<String?> requirementNotes = const Value.absent(),
          String? iconSource,
          String? iconKey,
          String? iconColor,
          String? preferredPrimaryVisual,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deactivatedAt = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Device(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        category: category.present ? category.value : this.category,
        manufacturer:
            manufacturer.present ? manufacturer.value : this.manufacturer,
        model: model.present ? model.value : this.model,
        serialNumber:
            serialNumber.present ? serialNumber.value : this.serialNumber,
        location: location.present ? location.value : this.location,
        description: description.present ? description.value : this.description,
        notes: notes.present ? notes.value : this.notes,
        requiredBatteryTypeId: requiredBatteryTypeId.present
            ? requiredBatteryTypeId.value
            : this.requiredBatteryTypeId,
        requiredBatteryQuantity: requiredBatteryQuantity.present
            ? requiredBatteryQuantity.value
            : this.requiredBatteryQuantity,
        requiredVoltage: requiredVoltage.present
            ? requiredVoltage.value
            : this.requiredVoltage,
        requirementNotes: requirementNotes.present
            ? requirementNotes.value
            : this.requirementNotes,
        iconSource: iconSource ?? this.iconSource,
        iconKey: iconKey ?? this.iconKey,
        iconColor: iconColor ?? this.iconColor,
        preferredPrimaryVisual:
            preferredPrimaryVisual ?? this.preferredPrimaryVisual,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deactivatedAt:
            deactivatedAt.present ? deactivatedAt.value : this.deactivatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      location: data.location.present ? data.location.value : this.location,
      description:
          data.description.present ? data.description.value : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
      requiredBatteryTypeId: data.requiredBatteryTypeId.present
          ? data.requiredBatteryTypeId.value
          : this.requiredBatteryTypeId,
      requiredBatteryQuantity: data.requiredBatteryQuantity.present
          ? data.requiredBatteryQuantity.value
          : this.requiredBatteryQuantity,
      requiredVoltage: data.requiredVoltage.present
          ? data.requiredVoltage.value
          : this.requiredVoltage,
      requirementNotes: data.requirementNotes.present
          ? data.requirementNotes.value
          : this.requirementNotes,
      iconSource:
          data.iconSource.present ? data.iconSource.value : this.iconSource,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      iconColor: data.iconColor.present ? data.iconColor.value : this.iconColor,
      preferredPrimaryVisual: data.preferredPrimaryVisual.present
          ? data.preferredPrimaryVisual.value
          : this.preferredPrimaryVisual,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deactivatedAt: data.deactivatedAt.present
          ? data.deactivatedAt.value
          : this.deactivatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('requiredBatteryTypeId: $requiredBatteryTypeId, ')
          ..write('requiredBatteryQuantity: $requiredBatteryQuantity, ')
          ..write('requiredVoltage: $requiredVoltage, ')
          ..write('requirementNotes: $requirementNotes, ')
          ..write('iconSource: $iconSource, ')
          ..write('iconKey: $iconKey, ')
          ..write('iconColor: $iconColor, ')
          ..write('preferredPrimaryVisual: $preferredPrimaryVisual, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        uuid,
        name,
        category,
        manufacturer,
        model,
        serialNumber,
        location,
        description,
        notes,
        requiredBatteryTypeId,
        requiredBatteryQuantity,
        requiredVoltage,
        requirementNotes,
        iconSource,
        iconKey,
        iconColor,
        preferredPrimaryVisual,
        createdAt,
        modifiedAt,
        deactivatedAt,
        deletedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.category == this.category &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.serialNumber == this.serialNumber &&
          other.location == this.location &&
          other.description == this.description &&
          other.notes == this.notes &&
          other.requiredBatteryTypeId == this.requiredBatteryTypeId &&
          other.requiredBatteryQuantity == this.requiredBatteryQuantity &&
          other.requiredVoltage == this.requiredVoltage &&
          other.requirementNotes == this.requirementNotes &&
          other.iconSource == this.iconSource &&
          other.iconKey == this.iconKey &&
          other.iconColor == this.iconColor &&
          other.preferredPrimaryVisual == this.preferredPrimaryVisual &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deactivatedAt == this.deactivatedAt &&
          other.deletedAt == this.deletedAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> manufacturer;
  final Value<String?> model;
  final Value<String?> serialNumber;
  final Value<String?> location;
  final Value<String?> description;
  final Value<String?> notes;
  final Value<int?> requiredBatteryTypeId;
  final Value<int?> requiredBatteryQuantity;
  final Value<double?> requiredVoltage;
  final Value<String?> requirementNotes;
  final Value<String> iconSource;
  final Value<String> iconKey;
  final Value<String> iconColor;
  final Value<String> preferredPrimaryVisual;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deactivatedAt;
  final Value<DateTime?> deletedAt;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.location = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.requiredBatteryTypeId = const Value.absent(),
    this.requiredBatteryQuantity = const Value.absent(),
    this.requiredVoltage = const Value.absent(),
    this.requirementNotes = const Value.absent(),
    this.iconSource = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.preferredPrimaryVisual = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    this.category = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.location = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.requiredBatteryTypeId = const Value.absent(),
    this.requiredBatteryQuantity = const Value.absent(),
    this.requiredVoltage = const Value.absent(),
    this.requirementNotes = const Value.absent(),
    this.iconSource = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.preferredPrimaryVisual = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<Device> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<String>? serialNumber,
    Expression<String>? location,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<int>? requiredBatteryTypeId,
    Expression<int>? requiredBatteryQuantity,
    Expression<double>? requiredVoltage,
    Expression<String>? requirementNotes,
    Expression<String>? iconSource,
    Expression<String>? iconKey,
    Expression<String>? iconColor,
    Expression<String>? preferredPrimaryVisual,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<String>? deactivatedAt,
    Expression<String>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (requiredBatteryTypeId != null)
        'required_battery_type_id': requiredBatteryTypeId,
      if (requiredBatteryQuantity != null)
        'required_battery_quantity': requiredBatteryQuantity,
      if (requiredVoltage != null) 'required_voltage': requiredVoltage,
      if (requirementNotes != null) 'requirement_notes': requirementNotes,
      if (iconSource != null) 'icon_source': iconSource,
      if (iconKey != null) 'icon_key': iconKey,
      if (iconColor != null) 'icon_color': iconColor,
      if (preferredPrimaryVisual != null)
        'preferred_primary_visual': preferredPrimaryVisual,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deactivatedAt != null) 'deactivated_at': deactivatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DevicesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<String?>? category,
      Value<String?>? manufacturer,
      Value<String?>? model,
      Value<String?>? serialNumber,
      Value<String?>? location,
      Value<String?>? description,
      Value<String?>? notes,
      Value<int?>? requiredBatteryTypeId,
      Value<int?>? requiredBatteryQuantity,
      Value<double?>? requiredVoltage,
      Value<String?>? requirementNotes,
      Value<String>? iconSource,
      Value<String>? iconKey,
      Value<String>? iconColor,
      Value<String>? preferredPrimaryVisual,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deactivatedAt,
      Value<DateTime?>? deletedAt}) {
    return DevicesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      requiredBatteryTypeId:
          requiredBatteryTypeId ?? this.requiredBatteryTypeId,
      requiredBatteryQuantity:
          requiredBatteryQuantity ?? this.requiredBatteryQuantity,
      requiredVoltage: requiredVoltage ?? this.requiredVoltage,
      requirementNotes: requirementNotes ?? this.requirementNotes,
      iconSource: iconSource ?? this.iconSource,
      iconKey: iconKey ?? this.iconKey,
      iconColor: iconColor ?? this.iconColor,
      preferredPrimaryVisual:
          preferredPrimaryVisual ?? this.preferredPrimaryVisual,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (requiredBatteryTypeId.present) {
      map['required_battery_type_id'] =
          Variable<int>(requiredBatteryTypeId.value);
    }
    if (requiredBatteryQuantity.present) {
      map['required_battery_quantity'] =
          Variable<int>(requiredBatteryQuantity.value);
    }
    if (requiredVoltage.present) {
      map['required_voltage'] = Variable<double>(requiredVoltage.value);
    }
    if (requirementNotes.present) {
      map['requirement_notes'] = Variable<String>(requirementNotes.value);
    }
    if (iconSource.present) {
      map['icon_source'] = Variable<String>(iconSource.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (iconColor.present) {
      map['icon_color'] = Variable<String>(iconColor.value);
    }
    if (preferredPrimaryVisual.present) {
      map['preferred_primary_visual'] =
          Variable<String>(preferredPrimaryVisual.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $DevicesTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $DevicesTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (deactivatedAt.present) {
      map['deactivated_at'] = Variable<String>(
          $DevicesTable.$converterdeactivatedAtn.toSql(deactivatedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
          $DevicesTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('requiredBatteryTypeId: $requiredBatteryTypeId, ')
          ..write('requiredBatteryQuantity: $requiredBatteryQuantity, ')
          ..write('requiredVoltage: $requiredVoltage, ')
          ..write('requirementNotes: $requirementNotes, ')
          ..write('iconSource: $iconSource, ')
          ..write('iconKey: $iconKey, ')
          ..write('iconColor: $iconColor, ')
          ..write('preferredPrimaryVisual: $preferredPrimaryVisual, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTable extends Assignments
    with TableInfo<$AssignmentsTable, Assignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _subjectTypeMeta =
      const VerificationMeta('subjectType');
  @override
  late final GeneratedColumn<String> subjectType = GeneratedColumn<String>(
      'subject_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _batteryIdMeta =
      const VerificationMeta('batteryId');
  @override
  late final GeneratedColumn<int> batteryId = GeneratedColumn<int>(
      'battery_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES batteries (id) ON DELETE RESTRICT'));
  static const VerificationMeta _batterySetIdMeta =
      const VerificationMeta('batterySetId');
  @override
  late final GeneratedColumn<int> batterySetId = GeneratedColumn<int>(
      'battery_set_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES battery_sets (id) ON DELETE RESTRICT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
      'device_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES devices (id) ON DELETE RESTRICT'));
  static const VerificationMeta _sourceSetAssignmentIdMeta =
      const VerificationMeta('sourceSetAssignmentId');
  @override
  late final GeneratedColumn<int> sourceSetAssignmentId = GeneratedColumn<int>(
      'source_set_assignment_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES assignments (id) ON DELETE RESTRICT'));
  static const VerificationMeta _operationUuidMeta =
      const VerificationMeta('operationUuid');
  @override
  late final GeneratedColumn<String> operationUuid = GeneratedColumn<String>(
      'operation_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> assignedAt =
      GeneratedColumn<String>('assigned_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($AssignmentsTable.$converterassignedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> removedAt =
      GeneratedColumn<String>('removed_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($AssignmentsTable.$converterremovedAtn);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _overrideReasonMeta =
      const VerificationMeta('overrideReason');
  @override
  late final GeneratedColumn<String> overrideReason = GeneratedColumn<String>(
      'override_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        subjectType,
        batteryId,
        batterySetId,
        deviceId,
        sourceSetAssignmentId,
        operationUuid,
        assignedAt,
        removedAt,
        notes,
        overrideReason
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(Insertable<Assignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('subject_type')) {
      context.handle(
          _subjectTypeMeta,
          subjectType.isAcceptableOrUnknown(
              data['subject_type']!, _subjectTypeMeta));
    } else if (isInserting) {
      context.missing(_subjectTypeMeta);
    }
    if (data.containsKey('battery_id')) {
      context.handle(_batteryIdMeta,
          batteryId.isAcceptableOrUnknown(data['battery_id']!, _batteryIdMeta));
    }
    if (data.containsKey('battery_set_id')) {
      context.handle(
          _batterySetIdMeta,
          batterySetId.isAcceptableOrUnknown(
              data['battery_set_id']!, _batterySetIdMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('source_set_assignment_id')) {
      context.handle(
          _sourceSetAssignmentIdMeta,
          sourceSetAssignmentId.isAcceptableOrUnknown(
              data['source_set_assignment_id']!, _sourceSetAssignmentIdMeta));
    }
    if (data.containsKey('operation_uuid')) {
      context.handle(
          _operationUuidMeta,
          operationUuid.isAcceptableOrUnknown(
              data['operation_uuid']!, _operationUuidMeta));
    } else if (isInserting) {
      context.missing(_operationUuidMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('override_reason')) {
      context.handle(
          _overrideReasonMeta,
          overrideReason.isAcceptableOrUnknown(
              data['override_reason']!, _overrideReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assignment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      subjectType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_type'])!,
      batteryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_id']),
      batterySetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_set_id']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}device_id'])!,
      sourceSetAssignmentId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}source_set_assignment_id']),
      operationUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_uuid'])!,
      assignedAt: $AssignmentsTable.$converterassignedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}assigned_at'])!),
      removedAt: $AssignmentsTable.$converterremovedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}removed_at'])),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      overrideReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}override_reason']),
    );
  }

  @override
  $AssignmentsTable createAlias(String alias) {
    return $AssignmentsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterassignedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterremovedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterremovedAtn =
      NullAwareTypeConverter.wrap($converterremovedAt);
}

class Assignment extends DataClass implements Insertable<Assignment> {
  final int id;
  final String uuid;
  final String subjectType;
  final int? batteryId;
  final int? batterySetId;
  final int deviceId;
  final int? sourceSetAssignmentId;
  final String operationUuid;
  final DateTime assignedAt;
  final DateTime? removedAt;
  final String? notes;
  final String? overrideReason;
  const Assignment(
      {required this.id,
      required this.uuid,
      required this.subjectType,
      this.batteryId,
      this.batterySetId,
      required this.deviceId,
      this.sourceSetAssignmentId,
      required this.operationUuid,
      required this.assignedAt,
      this.removedAt,
      this.notes,
      this.overrideReason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['subject_type'] = Variable<String>(subjectType);
    if (!nullToAbsent || batteryId != null) {
      map['battery_id'] = Variable<int>(batteryId);
    }
    if (!nullToAbsent || batterySetId != null) {
      map['battery_set_id'] = Variable<int>(batterySetId);
    }
    map['device_id'] = Variable<int>(deviceId);
    if (!nullToAbsent || sourceSetAssignmentId != null) {
      map['source_set_assignment_id'] = Variable<int>(sourceSetAssignmentId);
    }
    map['operation_uuid'] = Variable<String>(operationUuid);
    {
      map['assigned_at'] = Variable<String>(
          $AssignmentsTable.$converterassignedAt.toSql(assignedAt));
    }
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<String>(
          $AssignmentsTable.$converterremovedAtn.toSql(removedAt));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || overrideReason != null) {
      map['override_reason'] = Variable<String>(overrideReason);
    }
    return map;
  }

  AssignmentsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      subjectType: Value(subjectType),
      batteryId: batteryId == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryId),
      batterySetId: batterySetId == null && nullToAbsent
          ? const Value.absent()
          : Value(batterySetId),
      deviceId: Value(deviceId),
      sourceSetAssignmentId: sourceSetAssignmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSetAssignmentId),
      operationUuid: Value(operationUuid),
      assignedAt: Value(assignedAt),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      overrideReason: overrideReason == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideReason),
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assignment(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      subjectType: serializer.fromJson<String>(json['subjectType']),
      batteryId: serializer.fromJson<int?>(json['batteryId']),
      batterySetId: serializer.fromJson<int?>(json['batterySetId']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      sourceSetAssignmentId:
          serializer.fromJson<int?>(json['sourceSetAssignmentId']),
      operationUuid: serializer.fromJson<String>(json['operationUuid']),
      assignedAt: serializer.fromJson<DateTime>(json['assignedAt']),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      overrideReason: serializer.fromJson<String?>(json['overrideReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'subjectType': serializer.toJson<String>(subjectType),
      'batteryId': serializer.toJson<int?>(batteryId),
      'batterySetId': serializer.toJson<int?>(batterySetId),
      'deviceId': serializer.toJson<int>(deviceId),
      'sourceSetAssignmentId': serializer.toJson<int?>(sourceSetAssignmentId),
      'operationUuid': serializer.toJson<String>(operationUuid),
      'assignedAt': serializer.toJson<DateTime>(assignedAt),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
      'notes': serializer.toJson<String?>(notes),
      'overrideReason': serializer.toJson<String?>(overrideReason),
    };
  }

  Assignment copyWith(
          {int? id,
          String? uuid,
          String? subjectType,
          Value<int?> batteryId = const Value.absent(),
          Value<int?> batterySetId = const Value.absent(),
          int? deviceId,
          Value<int?> sourceSetAssignmentId = const Value.absent(),
          String? operationUuid,
          DateTime? assignedAt,
          Value<DateTime?> removedAt = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> overrideReason = const Value.absent()}) =>
      Assignment(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        subjectType: subjectType ?? this.subjectType,
        batteryId: batteryId.present ? batteryId.value : this.batteryId,
        batterySetId:
            batterySetId.present ? batterySetId.value : this.batterySetId,
        deviceId: deviceId ?? this.deviceId,
        sourceSetAssignmentId: sourceSetAssignmentId.present
            ? sourceSetAssignmentId.value
            : this.sourceSetAssignmentId,
        operationUuid: operationUuid ?? this.operationUuid,
        assignedAt: assignedAt ?? this.assignedAt,
        removedAt: removedAt.present ? removedAt.value : this.removedAt,
        notes: notes.present ? notes.value : this.notes,
        overrideReason:
            overrideReason.present ? overrideReason.value : this.overrideReason,
      );
  Assignment copyWithCompanion(AssignmentsCompanion data) {
    return Assignment(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      subjectType:
          data.subjectType.present ? data.subjectType.value : this.subjectType,
      batteryId: data.batteryId.present ? data.batteryId.value : this.batteryId,
      batterySetId: data.batterySetId.present
          ? data.batterySetId.value
          : this.batterySetId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      sourceSetAssignmentId: data.sourceSetAssignmentId.present
          ? data.sourceSetAssignmentId.value
          : this.sourceSetAssignmentId,
      operationUuid: data.operationUuid.present
          ? data.operationUuid.value
          : this.operationUuid,
      assignedAt:
          data.assignedAt.present ? data.assignedAt.value : this.assignedAt,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      overrideReason: data.overrideReason.present
          ? data.overrideReason.value
          : this.overrideReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assignment(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('subjectType: $subjectType, ')
          ..write('batteryId: $batteryId, ')
          ..write('batterySetId: $batterySetId, ')
          ..write('deviceId: $deviceId, ')
          ..write('sourceSetAssignmentId: $sourceSetAssignmentId, ')
          ..write('operationUuid: $operationUuid, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('removedAt: $removedAt, ')
          ..write('notes: $notes, ')
          ..write('overrideReason: $overrideReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      subjectType,
      batteryId,
      batterySetId,
      deviceId,
      sourceSetAssignmentId,
      operationUuid,
      assignedAt,
      removedAt,
      notes,
      overrideReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assignment &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.subjectType == this.subjectType &&
          other.batteryId == this.batteryId &&
          other.batterySetId == this.batterySetId &&
          other.deviceId == this.deviceId &&
          other.sourceSetAssignmentId == this.sourceSetAssignmentId &&
          other.operationUuid == this.operationUuid &&
          other.assignedAt == this.assignedAt &&
          other.removedAt == this.removedAt &&
          other.notes == this.notes &&
          other.overrideReason == this.overrideReason);
}

class AssignmentsCompanion extends UpdateCompanion<Assignment> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> subjectType;
  final Value<int?> batteryId;
  final Value<int?> batterySetId;
  final Value<int> deviceId;
  final Value<int?> sourceSetAssignmentId;
  final Value<String> operationUuid;
  final Value<DateTime> assignedAt;
  final Value<DateTime?> removedAt;
  final Value<String?> notes;
  final Value<String?> overrideReason;
  const AssignmentsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.subjectType = const Value.absent(),
    this.batteryId = const Value.absent(),
    this.batterySetId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.sourceSetAssignmentId = const Value.absent(),
    this.operationUuid = const Value.absent(),
    this.assignedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.overrideReason = const Value.absent(),
  });
  AssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String subjectType,
    this.batteryId = const Value.absent(),
    this.batterySetId = const Value.absent(),
    required int deviceId,
    this.sourceSetAssignmentId = const Value.absent(),
    required String operationUuid,
    this.assignedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.overrideReason = const Value.absent(),
  })  : uuid = Value(uuid),
        subjectType = Value(subjectType),
        deviceId = Value(deviceId),
        operationUuid = Value(operationUuid);
  static Insertable<Assignment> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? subjectType,
    Expression<int>? batteryId,
    Expression<int>? batterySetId,
    Expression<int>? deviceId,
    Expression<int>? sourceSetAssignmentId,
    Expression<String>? operationUuid,
    Expression<String>? assignedAt,
    Expression<String>? removedAt,
    Expression<String>? notes,
    Expression<String>? overrideReason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (subjectType != null) 'subject_type': subjectType,
      if (batteryId != null) 'battery_id': batteryId,
      if (batterySetId != null) 'battery_set_id': batterySetId,
      if (deviceId != null) 'device_id': deviceId,
      if (sourceSetAssignmentId != null)
        'source_set_assignment_id': sourceSetAssignmentId,
      if (operationUuid != null) 'operation_uuid': operationUuid,
      if (assignedAt != null) 'assigned_at': assignedAt,
      if (removedAt != null) 'removed_at': removedAt,
      if (notes != null) 'notes': notes,
      if (overrideReason != null) 'override_reason': overrideReason,
    });
  }

  AssignmentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? subjectType,
      Value<int?>? batteryId,
      Value<int?>? batterySetId,
      Value<int>? deviceId,
      Value<int?>? sourceSetAssignmentId,
      Value<String>? operationUuid,
      Value<DateTime>? assignedAt,
      Value<DateTime?>? removedAt,
      Value<String?>? notes,
      Value<String?>? overrideReason}) {
    return AssignmentsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      subjectType: subjectType ?? this.subjectType,
      batteryId: batteryId ?? this.batteryId,
      batterySetId: batterySetId ?? this.batterySetId,
      deviceId: deviceId ?? this.deviceId,
      sourceSetAssignmentId:
          sourceSetAssignmentId ?? this.sourceSetAssignmentId,
      operationUuid: operationUuid ?? this.operationUuid,
      assignedAt: assignedAt ?? this.assignedAt,
      removedAt: removedAt ?? this.removedAt,
      notes: notes ?? this.notes,
      overrideReason: overrideReason ?? this.overrideReason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (subjectType.present) {
      map['subject_type'] = Variable<String>(subjectType.value);
    }
    if (batteryId.present) {
      map['battery_id'] = Variable<int>(batteryId.value);
    }
    if (batterySetId.present) {
      map['battery_set_id'] = Variable<int>(batterySetId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (sourceSetAssignmentId.present) {
      map['source_set_assignment_id'] =
          Variable<int>(sourceSetAssignmentId.value);
    }
    if (operationUuid.present) {
      map['operation_uuid'] = Variable<String>(operationUuid.value);
    }
    if (assignedAt.present) {
      map['assigned_at'] = Variable<String>(
          $AssignmentsTable.$converterassignedAt.toSql(assignedAt.value));
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<String>(
          $AssignmentsTable.$converterremovedAtn.toSql(removedAt.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (overrideReason.present) {
      map['override_reason'] = Variable<String>(overrideReason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('subjectType: $subjectType, ')
          ..write('batteryId: $batteryId, ')
          ..write('batterySetId: $batterySetId, ')
          ..write('deviceId: $deviceId, ')
          ..write('sourceSetAssignmentId: $sourceSetAssignmentId, ')
          ..write('operationUuid: $operationUuid, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('removedAt: $removedAt, ')
          ..write('notes: $notes, ')
          ..write('overrideReason: $overrideReason')
          ..write(')'))
        .toString();
  }
}

class $SetChargeRecordsTable extends SetChargeRecords
    with TableInfo<$SetChargeRecordsTable, SetChargeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetChargeRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _batterySetIdMeta =
      const VerificationMeta('batterySetId');
  @override
  late final GeneratedColumn<int> batterySetId = GeneratedColumn<int>(
      'battery_set_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES battery_sets (id) ON DELETE RESTRICT'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> chargedAt =
      GeneratedColumn<String>('charged_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($SetChargeRecordsTable.$converterchargedAt);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($SetChargeRecordsTable.$convertercreatedAt);
  static const VerificationMeta _operationUuidMeta =
      const VerificationMeta('operationUuid');
  @override
  late final GeneratedColumn<String> operationUuid = GeneratedColumn<String>(
      'operation_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, uuid, batterySetId, chargedAt, notes, createdAt, operationUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_charge_records';
  @override
  VerificationContext validateIntegrity(Insertable<SetChargeRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('battery_set_id')) {
      context.handle(
          _batterySetIdMeta,
          batterySetId.isAcceptableOrUnknown(
              data['battery_set_id']!, _batterySetIdMeta));
    } else if (isInserting) {
      context.missing(_batterySetIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('operation_uuid')) {
      context.handle(
          _operationUuidMeta,
          operationUuid.isAcceptableOrUnknown(
              data['operation_uuid']!, _operationUuidMeta));
    } else if (isInserting) {
      context.missing(_operationUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetChargeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetChargeRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      batterySetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_set_id'])!,
      chargedAt: $SetChargeRecordsTable.$converterchargedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}charged_at'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: $SetChargeRecordsTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      operationUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_uuid'])!,
    );
  }

  @override
  $SetChargeRecordsTable createAlias(String alias) {
    return $SetChargeRecordsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterchargedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
}

class SetChargeRecord extends DataClass implements Insertable<SetChargeRecord> {
  final int id;
  final String uuid;
  final int batterySetId;
  final DateTime chargedAt;
  final String? notes;
  final DateTime createdAt;
  final String operationUuid;
  const SetChargeRecord(
      {required this.id,
      required this.uuid,
      required this.batterySetId,
      required this.chargedAt,
      this.notes,
      required this.createdAt,
      required this.operationUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['battery_set_id'] = Variable<int>(batterySetId);
    {
      map['charged_at'] = Variable<String>(
          $SetChargeRecordsTable.$converterchargedAt.toSql(chargedAt));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['created_at'] = Variable<String>(
          $SetChargeRecordsTable.$convertercreatedAt.toSql(createdAt));
    }
    map['operation_uuid'] = Variable<String>(operationUuid);
    return map;
  }

  SetChargeRecordsCompanion toCompanion(bool nullToAbsent) {
    return SetChargeRecordsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      batterySetId: Value(batterySetId),
      chargedAt: Value(chargedAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      operationUuid: Value(operationUuid),
    );
  }

  factory SetChargeRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetChargeRecord(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      batterySetId: serializer.fromJson<int>(json['batterySetId']),
      chargedAt: serializer.fromJson<DateTime>(json['chargedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      operationUuid: serializer.fromJson<String>(json['operationUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'batterySetId': serializer.toJson<int>(batterySetId),
      'chargedAt': serializer.toJson<DateTime>(chargedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'operationUuid': serializer.toJson<String>(operationUuid),
    };
  }

  SetChargeRecord copyWith(
          {int? id,
          String? uuid,
          int? batterySetId,
          DateTime? chargedAt,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          String? operationUuid}) =>
      SetChargeRecord(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        batterySetId: batterySetId ?? this.batterySetId,
        chargedAt: chargedAt ?? this.chargedAt,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        operationUuid: operationUuid ?? this.operationUuid,
      );
  SetChargeRecord copyWithCompanion(SetChargeRecordsCompanion data) {
    return SetChargeRecord(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      batterySetId: data.batterySetId.present
          ? data.batterySetId.value
          : this.batterySetId,
      chargedAt: data.chargedAt.present ? data.chargedAt.value : this.chargedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      operationUuid: data.operationUuid.present
          ? data.operationUuid.value
          : this.operationUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetChargeRecord(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('batterySetId: $batterySetId, ')
          ..write('chargedAt: $chargedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('operationUuid: $operationUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, uuid, batterySetId, chargedAt, notes, createdAt, operationUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetChargeRecord &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.batterySetId == this.batterySetId &&
          other.chargedAt == this.chargedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.operationUuid == this.operationUuid);
}

class SetChargeRecordsCompanion extends UpdateCompanion<SetChargeRecord> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> batterySetId;
  final Value<DateTime> chargedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String> operationUuid;
  const SetChargeRecordsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.batterySetId = const Value.absent(),
    this.chargedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.operationUuid = const Value.absent(),
  });
  SetChargeRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required int batterySetId,
    this.chargedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String operationUuid,
  })  : uuid = Value(uuid),
        batterySetId = Value(batterySetId),
        operationUuid = Value(operationUuid);
  static Insertable<SetChargeRecord> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? batterySetId,
    Expression<String>? chargedAt,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? operationUuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (batterySetId != null) 'battery_set_id': batterySetId,
      if (chargedAt != null) 'charged_at': chargedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (operationUuid != null) 'operation_uuid': operationUuid,
    });
  }

  SetChargeRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<int>? batterySetId,
      Value<DateTime>? chargedAt,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<String>? operationUuid}) {
    return SetChargeRecordsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      batterySetId: batterySetId ?? this.batterySetId,
      chargedAt: chargedAt ?? this.chargedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      operationUuid: operationUuid ?? this.operationUuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (batterySetId.present) {
      map['battery_set_id'] = Variable<int>(batterySetId.value);
    }
    if (chargedAt.present) {
      map['charged_at'] = Variable<String>(
          $SetChargeRecordsTable.$converterchargedAt.toSql(chargedAt.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $SetChargeRecordsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (operationUuid.present) {
      map['operation_uuid'] = Variable<String>(operationUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetChargeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('batterySetId: $batterySetId, ')
          ..write('chargedAt: $chargedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('operationUuid: $operationUuid')
          ..write(')'))
        .toString();
  }
}

class $ChargeRecordsTable extends ChargeRecords
    with TableInfo<$ChargeRecordsTable, ChargeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChargeRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _batteryIdMeta =
      const VerificationMeta('batteryId');
  @override
  late final GeneratedColumn<int> batteryId = GeneratedColumn<int>(
      'battery_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES batteries (id) ON DELETE RESTRICT'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> chargedAt =
      GeneratedColumn<String>('charged_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($ChargeRecordsTable.$converterchargedAt);
  static const VerificationMeta _startingChargePercentMeta =
      const VerificationMeta('startingChargePercent');
  @override
  late final GeneratedColumn<int> startingChargePercent = GeneratedColumn<int>(
      'starting_charge_percent', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _endingChargePercentMeta =
      const VerificationMeta('endingChargePercent');
  @override
  late final GeneratedColumn<int> endingChargePercent = GeneratedColumn<int>(
      'ending_charge_percent', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _chargerMeta =
      const VerificationMeta('charger');
  @override
  late final GeneratedColumn<String> charger = GeneratedColumn<String>(
      'charger', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceSetChargeIdMeta =
      const VerificationMeta('sourceSetChargeId');
  @override
  late final GeneratedColumn<int> sourceSetChargeId = GeneratedColumn<int>(
      'source_set_charge_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES set_charge_records (id) ON DELETE RESTRICT'));
  static const VerificationMeta _bulkOperationUuidMeta =
      const VerificationMeta('bulkOperationUuid');
  @override
  late final GeneratedColumn<String> bulkOperationUuid =
      GeneratedColumn<String>('bulk_operation_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($ChargeRecordsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        batteryId,
        chargedAt,
        startingChargePercent,
        endingChargePercent,
        charger,
        notes,
        sourceSetChargeId,
        bulkOperationUuid,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'charge_records';
  @override
  VerificationContext validateIntegrity(Insertable<ChargeRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('battery_id')) {
      context.handle(_batteryIdMeta,
          batteryId.isAcceptableOrUnknown(data['battery_id']!, _batteryIdMeta));
    } else if (isInserting) {
      context.missing(_batteryIdMeta);
    }
    if (data.containsKey('starting_charge_percent')) {
      context.handle(
          _startingChargePercentMeta,
          startingChargePercent.isAcceptableOrUnknown(
              data['starting_charge_percent']!, _startingChargePercentMeta));
    }
    if (data.containsKey('ending_charge_percent')) {
      context.handle(
          _endingChargePercentMeta,
          endingChargePercent.isAcceptableOrUnknown(
              data['ending_charge_percent']!, _endingChargePercentMeta));
    }
    if (data.containsKey('charger')) {
      context.handle(_chargerMeta,
          charger.isAcceptableOrUnknown(data['charger']!, _chargerMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('source_set_charge_id')) {
      context.handle(
          _sourceSetChargeIdMeta,
          sourceSetChargeId.isAcceptableOrUnknown(
              data['source_set_charge_id']!, _sourceSetChargeIdMeta));
    }
    if (data.containsKey('bulk_operation_uuid')) {
      context.handle(
          _bulkOperationUuidMeta,
          bulkOperationUuid.isAcceptableOrUnknown(
              data['bulk_operation_uuid']!, _bulkOperationUuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChargeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChargeRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      batteryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_id'])!,
      chargedAt: $ChargeRecordsTable.$converterchargedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}charged_at'])!),
      startingChargePercent: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}starting_charge_percent']),
      endingChargePercent: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}ending_charge_percent']),
      charger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}charger']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      sourceSetChargeId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}source_set_charge_id']),
      bulkOperationUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bulk_operation_uuid']),
      createdAt: $ChargeRecordsTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
    );
  }

  @override
  $ChargeRecordsTable createAlias(String alias) {
    return $ChargeRecordsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterchargedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
}

class ChargeRecord extends DataClass implements Insertable<ChargeRecord> {
  final int id;
  final String uuid;
  final int batteryId;
  final DateTime chargedAt;
  final int? startingChargePercent;
  final int? endingChargePercent;
  final String? charger;
  final String? notes;
  final int? sourceSetChargeId;
  final String? bulkOperationUuid;
  final DateTime createdAt;
  const ChargeRecord(
      {required this.id,
      required this.uuid,
      required this.batteryId,
      required this.chargedAt,
      this.startingChargePercent,
      this.endingChargePercent,
      this.charger,
      this.notes,
      this.sourceSetChargeId,
      this.bulkOperationUuid,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['battery_id'] = Variable<int>(batteryId);
    {
      map['charged_at'] = Variable<String>(
          $ChargeRecordsTable.$converterchargedAt.toSql(chargedAt));
    }
    if (!nullToAbsent || startingChargePercent != null) {
      map['starting_charge_percent'] = Variable<int>(startingChargePercent);
    }
    if (!nullToAbsent || endingChargePercent != null) {
      map['ending_charge_percent'] = Variable<int>(endingChargePercent);
    }
    if (!nullToAbsent || charger != null) {
      map['charger'] = Variable<String>(charger);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || sourceSetChargeId != null) {
      map['source_set_charge_id'] = Variable<int>(sourceSetChargeId);
    }
    if (!nullToAbsent || bulkOperationUuid != null) {
      map['bulk_operation_uuid'] = Variable<String>(bulkOperationUuid);
    }
    {
      map['created_at'] = Variable<String>(
          $ChargeRecordsTable.$convertercreatedAt.toSql(createdAt));
    }
    return map;
  }

  ChargeRecordsCompanion toCompanion(bool nullToAbsent) {
    return ChargeRecordsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      batteryId: Value(batteryId),
      chargedAt: Value(chargedAt),
      startingChargePercent: startingChargePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(startingChargePercent),
      endingChargePercent: endingChargePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(endingChargePercent),
      charger: charger == null && nullToAbsent
          ? const Value.absent()
          : Value(charger),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      sourceSetChargeId: sourceSetChargeId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSetChargeId),
      bulkOperationUuid: bulkOperationUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(bulkOperationUuid),
      createdAt: Value(createdAt),
    );
  }

  factory ChargeRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChargeRecord(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      batteryId: serializer.fromJson<int>(json['batteryId']),
      chargedAt: serializer.fromJson<DateTime>(json['chargedAt']),
      startingChargePercent:
          serializer.fromJson<int?>(json['startingChargePercent']),
      endingChargePercent:
          serializer.fromJson<int?>(json['endingChargePercent']),
      charger: serializer.fromJson<String?>(json['charger']),
      notes: serializer.fromJson<String?>(json['notes']),
      sourceSetChargeId: serializer.fromJson<int?>(json['sourceSetChargeId']),
      bulkOperationUuid:
          serializer.fromJson<String?>(json['bulkOperationUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'batteryId': serializer.toJson<int>(batteryId),
      'chargedAt': serializer.toJson<DateTime>(chargedAt),
      'startingChargePercent': serializer.toJson<int?>(startingChargePercent),
      'endingChargePercent': serializer.toJson<int?>(endingChargePercent),
      'charger': serializer.toJson<String?>(charger),
      'notes': serializer.toJson<String?>(notes),
      'sourceSetChargeId': serializer.toJson<int?>(sourceSetChargeId),
      'bulkOperationUuid': serializer.toJson<String?>(bulkOperationUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChargeRecord copyWith(
          {int? id,
          String? uuid,
          int? batteryId,
          DateTime? chargedAt,
          Value<int?> startingChargePercent = const Value.absent(),
          Value<int?> endingChargePercent = const Value.absent(),
          Value<String?> charger = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<int?> sourceSetChargeId = const Value.absent(),
          Value<String?> bulkOperationUuid = const Value.absent(),
          DateTime? createdAt}) =>
      ChargeRecord(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        batteryId: batteryId ?? this.batteryId,
        chargedAt: chargedAt ?? this.chargedAt,
        startingChargePercent: startingChargePercent.present
            ? startingChargePercent.value
            : this.startingChargePercent,
        endingChargePercent: endingChargePercent.present
            ? endingChargePercent.value
            : this.endingChargePercent,
        charger: charger.present ? charger.value : this.charger,
        notes: notes.present ? notes.value : this.notes,
        sourceSetChargeId: sourceSetChargeId.present
            ? sourceSetChargeId.value
            : this.sourceSetChargeId,
        bulkOperationUuid: bulkOperationUuid.present
            ? bulkOperationUuid.value
            : this.bulkOperationUuid,
        createdAt: createdAt ?? this.createdAt,
      );
  ChargeRecord copyWithCompanion(ChargeRecordsCompanion data) {
    return ChargeRecord(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      batteryId: data.batteryId.present ? data.batteryId.value : this.batteryId,
      chargedAt: data.chargedAt.present ? data.chargedAt.value : this.chargedAt,
      startingChargePercent: data.startingChargePercent.present
          ? data.startingChargePercent.value
          : this.startingChargePercent,
      endingChargePercent: data.endingChargePercent.present
          ? data.endingChargePercent.value
          : this.endingChargePercent,
      charger: data.charger.present ? data.charger.value : this.charger,
      notes: data.notes.present ? data.notes.value : this.notes,
      sourceSetChargeId: data.sourceSetChargeId.present
          ? data.sourceSetChargeId.value
          : this.sourceSetChargeId,
      bulkOperationUuid: data.bulkOperationUuid.present
          ? data.bulkOperationUuid.value
          : this.bulkOperationUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChargeRecord(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('batteryId: $batteryId, ')
          ..write('chargedAt: $chargedAt, ')
          ..write('startingChargePercent: $startingChargePercent, ')
          ..write('endingChargePercent: $endingChargePercent, ')
          ..write('charger: $charger, ')
          ..write('notes: $notes, ')
          ..write('sourceSetChargeId: $sourceSetChargeId, ')
          ..write('bulkOperationUuid: $bulkOperationUuid, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      batteryId,
      chargedAt,
      startingChargePercent,
      endingChargePercent,
      charger,
      notes,
      sourceSetChargeId,
      bulkOperationUuid,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChargeRecord &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.batteryId == this.batteryId &&
          other.chargedAt == this.chargedAt &&
          other.startingChargePercent == this.startingChargePercent &&
          other.endingChargePercent == this.endingChargePercent &&
          other.charger == this.charger &&
          other.notes == this.notes &&
          other.sourceSetChargeId == this.sourceSetChargeId &&
          other.bulkOperationUuid == this.bulkOperationUuid &&
          other.createdAt == this.createdAt);
}

class ChargeRecordsCompanion extends UpdateCompanion<ChargeRecord> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> batteryId;
  final Value<DateTime> chargedAt;
  final Value<int?> startingChargePercent;
  final Value<int?> endingChargePercent;
  final Value<String?> charger;
  final Value<String?> notes;
  final Value<int?> sourceSetChargeId;
  final Value<String?> bulkOperationUuid;
  final Value<DateTime> createdAt;
  const ChargeRecordsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.batteryId = const Value.absent(),
    this.chargedAt = const Value.absent(),
    this.startingChargePercent = const Value.absent(),
    this.endingChargePercent = const Value.absent(),
    this.charger = const Value.absent(),
    this.notes = const Value.absent(),
    this.sourceSetChargeId = const Value.absent(),
    this.bulkOperationUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChargeRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required int batteryId,
    this.chargedAt = const Value.absent(),
    this.startingChargePercent = const Value.absent(),
    this.endingChargePercent = const Value.absent(),
    this.charger = const Value.absent(),
    this.notes = const Value.absent(),
    this.sourceSetChargeId = const Value.absent(),
    this.bulkOperationUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : uuid = Value(uuid),
        batteryId = Value(batteryId);
  static Insertable<ChargeRecord> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? batteryId,
    Expression<String>? chargedAt,
    Expression<int>? startingChargePercent,
    Expression<int>? endingChargePercent,
    Expression<String>? charger,
    Expression<String>? notes,
    Expression<int>? sourceSetChargeId,
    Expression<String>? bulkOperationUuid,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (batteryId != null) 'battery_id': batteryId,
      if (chargedAt != null) 'charged_at': chargedAt,
      if (startingChargePercent != null)
        'starting_charge_percent': startingChargePercent,
      if (endingChargePercent != null)
        'ending_charge_percent': endingChargePercent,
      if (charger != null) 'charger': charger,
      if (notes != null) 'notes': notes,
      if (sourceSetChargeId != null) 'source_set_charge_id': sourceSetChargeId,
      if (bulkOperationUuid != null) 'bulk_operation_uuid': bulkOperationUuid,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChargeRecordsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<int>? batteryId,
      Value<DateTime>? chargedAt,
      Value<int?>? startingChargePercent,
      Value<int?>? endingChargePercent,
      Value<String?>? charger,
      Value<String?>? notes,
      Value<int?>? sourceSetChargeId,
      Value<String?>? bulkOperationUuid,
      Value<DateTime>? createdAt}) {
    return ChargeRecordsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      batteryId: batteryId ?? this.batteryId,
      chargedAt: chargedAt ?? this.chargedAt,
      startingChargePercent:
          startingChargePercent ?? this.startingChargePercent,
      endingChargePercent: endingChargePercent ?? this.endingChargePercent,
      charger: charger ?? this.charger,
      notes: notes ?? this.notes,
      sourceSetChargeId: sourceSetChargeId ?? this.sourceSetChargeId,
      bulkOperationUuid: bulkOperationUuid ?? this.bulkOperationUuid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (batteryId.present) {
      map['battery_id'] = Variable<int>(batteryId.value);
    }
    if (chargedAt.present) {
      map['charged_at'] = Variable<String>(
          $ChargeRecordsTable.$converterchargedAt.toSql(chargedAt.value));
    }
    if (startingChargePercent.present) {
      map['starting_charge_percent'] =
          Variable<int>(startingChargePercent.value);
    }
    if (endingChargePercent.present) {
      map['ending_charge_percent'] = Variable<int>(endingChargePercent.value);
    }
    if (charger.present) {
      map['charger'] = Variable<String>(charger.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sourceSetChargeId.present) {
      map['source_set_charge_id'] = Variable<int>(sourceSetChargeId.value);
    }
    if (bulkOperationUuid.present) {
      map['bulk_operation_uuid'] = Variable<String>(bulkOperationUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $ChargeRecordsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChargeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('batteryId: $batteryId, ')
          ..write('chargedAt: $chargedAt, ')
          ..write('startingChargePercent: $startingChargePercent, ')
          ..write('endingChargePercent: $endingChargePercent, ')
          ..write('charger: $charger, ')
          ..write('notes: $notes, ')
          ..write('sourceSetChargeId: $sourceSetChargeId, ')
          ..write('bulkOperationUuid: $bulkOperationUuid, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MediaAssetsTable extends MediaAssets
    with TableInfo<$MediaAssetsTable, MediaAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _relativePathMeta =
      const VerificationMeta('relativePath');
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
      'relative_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _originalFilenameMeta =
      const VerificationMeta('originalFilename');
  @override
  late final GeneratedColumn<String> originalFilename = GeneratedColumn<String>(
      'original_filename', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _byteSizeMeta =
      const VerificationMeta('byteSize');
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
      'byte_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($MediaAssetsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($MediaAssetsTable.$convertermodifiedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> missingAt =
      GeneratedColumn<String>('missing_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($MediaAssetsTable.$convertermissingAtn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        relativePath,
        originalFilename,
        mimeType,
        byteSize,
        checksum,
        width,
        height,
        createdAt,
        modifiedAt,
        missingAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_assets';
  @override
  VerificationContext validateIntegrity(Insertable<MediaAsset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
          _relativePathMeta,
          relativePath.isAcceptableOrUnknown(
              data['relative_path']!, _relativePathMeta));
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('original_filename')) {
      context.handle(
          _originalFilenameMeta,
          originalFilename.isAcceptableOrUnknown(
              data['original_filename']!, _originalFilenameMeta));
    } else if (isInserting) {
      context.missing(_originalFilenameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(_byteSizeMeta,
          byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta));
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAsset(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      relativePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relative_path'])!,
      originalFilename: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_filename'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type'])!,
      byteSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}byte_size'])!,
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width']),
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height']),
      createdAt: $MediaAssetsTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $MediaAssetsTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
      missingAt: $MediaAssetsTable.$convertermissingAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}missing_at'])),
    );
  }

  @override
  $MediaAssetsTable createAlias(String alias) {
    return $MediaAssetsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermissingAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $convertermissingAtn =
      NullAwareTypeConverter.wrap($convertermissingAt);
}

class MediaAsset extends DataClass implements Insertable<MediaAsset> {
  final int id;
  final String uuid;
  final String relativePath;
  final String originalFilename;
  final String mimeType;
  final int byteSize;
  final String checksum;
  final int? width;
  final int? height;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? missingAt;
  const MediaAsset(
      {required this.id,
      required this.uuid,
      required this.relativePath,
      required this.originalFilename,
      required this.mimeType,
      required this.byteSize,
      required this.checksum,
      this.width,
      this.height,
      required this.createdAt,
      required this.modifiedAt,
      this.missingAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['relative_path'] = Variable<String>(relativePath);
    map['original_filename'] = Variable<String>(originalFilename);
    map['mime_type'] = Variable<String>(mimeType);
    map['byte_size'] = Variable<int>(byteSize);
    map['checksum'] = Variable<String>(checksum);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    {
      map['created_at'] = Variable<String>(
          $MediaAssetsTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $MediaAssetsTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    if (!nullToAbsent || missingAt != null) {
      map['missing_at'] = Variable<String>(
          $MediaAssetsTable.$convertermissingAtn.toSql(missingAt));
    }
    return map;
  }

  MediaAssetsCompanion toCompanion(bool nullToAbsent) {
    return MediaAssetsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      relativePath: Value(relativePath),
      originalFilename: Value(originalFilename),
      mimeType: Value(mimeType),
      byteSize: Value(byteSize),
      checksum: Value(checksum),
      width:
          width == null && nullToAbsent ? const Value.absent() : Value(width),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      missingAt: missingAt == null && nullToAbsent
          ? const Value.absent()
          : Value(missingAt),
    );
  }

  factory MediaAsset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAsset(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      originalFilename: serializer.fromJson<String>(json['originalFilename']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      checksum: serializer.fromJson<String>(json['checksum']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      missingAt: serializer.fromJson<DateTime?>(json['missingAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'relativePath': serializer.toJson<String>(relativePath),
      'originalFilename': serializer.toJson<String>(originalFilename),
      'mimeType': serializer.toJson<String>(mimeType),
      'byteSize': serializer.toJson<int>(byteSize),
      'checksum': serializer.toJson<String>(checksum),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'missingAt': serializer.toJson<DateTime?>(missingAt),
    };
  }

  MediaAsset copyWith(
          {int? id,
          String? uuid,
          String? relativePath,
          String? originalFilename,
          String? mimeType,
          int? byteSize,
          String? checksum,
          Value<int?> width = const Value.absent(),
          Value<int?> height = const Value.absent(),
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> missingAt = const Value.absent()}) =>
      MediaAsset(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        relativePath: relativePath ?? this.relativePath,
        originalFilename: originalFilename ?? this.originalFilename,
        mimeType: mimeType ?? this.mimeType,
        byteSize: byteSize ?? this.byteSize,
        checksum: checksum ?? this.checksum,
        width: width.present ? width.value : this.width,
        height: height.present ? height.value : this.height,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        missingAt: missingAt.present ? missingAt.value : this.missingAt,
      );
  MediaAsset copyWithCompanion(MediaAssetsCompanion data) {
    return MediaAsset(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      originalFilename: data.originalFilename.present
          ? data.originalFilename.value
          : this.originalFilename,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      missingAt: data.missingAt.present ? data.missingAt.value : this.missingAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAsset(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('relativePath: $relativePath, ')
          ..write('originalFilename: $originalFilename, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('checksum: $checksum, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('missingAt: $missingAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      relativePath,
      originalFilename,
      mimeType,
      byteSize,
      checksum,
      width,
      height,
      createdAt,
      modifiedAt,
      missingAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAsset &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.relativePath == this.relativePath &&
          other.originalFilename == this.originalFilename &&
          other.mimeType == this.mimeType &&
          other.byteSize == this.byteSize &&
          other.checksum == this.checksum &&
          other.width == this.width &&
          other.height == this.height &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.missingAt == this.missingAt);
}

class MediaAssetsCompanion extends UpdateCompanion<MediaAsset> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> relativePath;
  final Value<String> originalFilename;
  final Value<String> mimeType;
  final Value<int> byteSize;
  final Value<String> checksum;
  final Value<int?> width;
  final Value<int?> height;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> missingAt;
  const MediaAssetsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.originalFilename = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.missingAt = const Value.absent(),
  });
  MediaAssetsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String relativePath,
    required String originalFilename,
    required String mimeType,
    required int byteSize,
    required String checksum,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.missingAt = const Value.absent(),
  })  : uuid = Value(uuid),
        relativePath = Value(relativePath),
        originalFilename = Value(originalFilename),
        mimeType = Value(mimeType),
        byteSize = Value(byteSize),
        checksum = Value(checksum);
  static Insertable<MediaAsset> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? relativePath,
    Expression<String>? originalFilename,
    Expression<String>? mimeType,
    Expression<int>? byteSize,
    Expression<String>? checksum,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<String>? missingAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (relativePath != null) 'relative_path': relativePath,
      if (originalFilename != null) 'original_filename': originalFilename,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteSize != null) 'byte_size': byteSize,
      if (checksum != null) 'checksum': checksum,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (missingAt != null) 'missing_at': missingAt,
    });
  }

  MediaAssetsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? relativePath,
      Value<String>? originalFilename,
      Value<String>? mimeType,
      Value<int>? byteSize,
      Value<String>? checksum,
      Value<int?>? width,
      Value<int?>? height,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? missingAt}) {
    return MediaAssetsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      relativePath: relativePath ?? this.relativePath,
      originalFilename: originalFilename ?? this.originalFilename,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      checksum: checksum ?? this.checksum,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      missingAt: missingAt ?? this.missingAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (originalFilename.present) {
      map['original_filename'] = Variable<String>(originalFilename.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $MediaAssetsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $MediaAssetsTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (missingAt.present) {
      map['missing_at'] = Variable<String>(
          $MediaAssetsTable.$convertermissingAtn.toSql(missingAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('relativePath: $relativePath, ')
          ..write('originalFilename: $originalFilename, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('checksum: $checksum, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('missingAt: $missingAt')
          ..write(')'))
        .toString();
  }
}

class $BatteryPhotosTable extends BatteryPhotos
    with TableInfo<$BatteryPhotosTable, BatteryPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatteryPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _batteryIdMeta =
      const VerificationMeta('batteryId');
  @override
  late final GeneratedColumn<int> batteryId = GeneratedColumn<int>(
      'battery_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES batteries (id) ON DELETE RESTRICT'));
  static const VerificationMeta _mediaAssetIdMeta =
      const VerificationMeta('mediaAssetId');
  @override
  late final GeneratedColumn<int> mediaAssetId = GeneratedColumn<int>(
      'media_asset_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES media_assets (id) ON DELETE RESTRICT'));
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteryPhotosTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteryPhotosTable.$convertermodifiedAt);
  @override
  List<GeneratedColumn> get $columns => [
        batteryId,
        mediaAssetId,
        isPrimary,
        displayOrder,
        caption,
        createdAt,
        modifiedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'battery_photos';
  @override
  VerificationContext validateIntegrity(Insertable<BatteryPhoto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('battery_id')) {
      context.handle(_batteryIdMeta,
          batteryId.isAcceptableOrUnknown(data['battery_id']!, _batteryIdMeta));
    } else if (isInserting) {
      context.missing(_batteryIdMeta);
    }
    if (data.containsKey('media_asset_id')) {
      context.handle(
          _mediaAssetIdMeta,
          mediaAssetId.isAcceptableOrUnknown(
              data['media_asset_id']!, _mediaAssetIdMeta));
    } else if (isInserting) {
      context.missing(_mediaAssetIdMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {batteryId, mediaAssetId};
  @override
  BatteryPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatteryPhoto(
      batteryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_id'])!,
      mediaAssetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}media_asset_id'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
      createdAt: $BatteryPhotosTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $BatteryPhotosTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
    );
  }

  @override
  $BatteryPhotosTable createAlias(String alias) {
    return $BatteryPhotosTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
}

class BatteryPhoto extends DataClass implements Insertable<BatteryPhoto> {
  final int batteryId;
  final int mediaAssetId;
  final bool isPrimary;
  final int displayOrder;
  final String? caption;
  final DateTime createdAt;
  final DateTime modifiedAt;
  const BatteryPhoto(
      {required this.batteryId,
      required this.mediaAssetId,
      required this.isPrimary,
      required this.displayOrder,
      this.caption,
      required this.createdAt,
      required this.modifiedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['battery_id'] = Variable<int>(batteryId);
    map['media_asset_id'] = Variable<int>(mediaAssetId);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['display_order'] = Variable<int>(displayOrder);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    {
      map['created_at'] = Variable<String>(
          $BatteryPhotosTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $BatteryPhotosTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    return map;
  }

  BatteryPhotosCompanion toCompanion(bool nullToAbsent) {
    return BatteryPhotosCompanion(
      batteryId: Value(batteryId),
      mediaAssetId: Value(mediaAssetId),
      isPrimary: Value(isPrimary),
      displayOrder: Value(displayOrder),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory BatteryPhoto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatteryPhoto(
      batteryId: serializer.fromJson<int>(json['batteryId']),
      mediaAssetId: serializer.fromJson<int>(json['mediaAssetId']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      caption: serializer.fromJson<String?>(json['caption']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'batteryId': serializer.toJson<int>(batteryId),
      'mediaAssetId': serializer.toJson<int>(mediaAssetId),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'caption': serializer.toJson<String?>(caption),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  BatteryPhoto copyWith(
          {int? batteryId,
          int? mediaAssetId,
          bool? isPrimary,
          int? displayOrder,
          Value<String?> caption = const Value.absent(),
          DateTime? createdAt,
          DateTime? modifiedAt}) =>
      BatteryPhoto(
        batteryId: batteryId ?? this.batteryId,
        mediaAssetId: mediaAssetId ?? this.mediaAssetId,
        isPrimary: isPrimary ?? this.isPrimary,
        displayOrder: displayOrder ?? this.displayOrder,
        caption: caption.present ? caption.value : this.caption,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );
  BatteryPhoto copyWithCompanion(BatteryPhotosCompanion data) {
    return BatteryPhoto(
      batteryId: data.batteryId.present ? data.batteryId.value : this.batteryId,
      mediaAssetId: data.mediaAssetId.present
          ? data.mediaAssetId.value
          : this.mediaAssetId,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      caption: data.caption.present ? data.caption.value : this.caption,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatteryPhoto(')
          ..write('batteryId: $batteryId, ')
          ..write('mediaAssetId: $mediaAssetId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(batteryId, mediaAssetId, isPrimary,
      displayOrder, caption, createdAt, modifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatteryPhoto &&
          other.batteryId == this.batteryId &&
          other.mediaAssetId == this.mediaAssetId &&
          other.isPrimary == this.isPrimary &&
          other.displayOrder == this.displayOrder &&
          other.caption == this.caption &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt);
}

class BatteryPhotosCompanion extends UpdateCompanion<BatteryPhoto> {
  final Value<int> batteryId;
  final Value<int> mediaAssetId;
  final Value<bool> isPrimary;
  final Value<int> displayOrder;
  final Value<String?> caption;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<int> rowid;
  const BatteryPhotosCompanion({
    this.batteryId = const Value.absent(),
    this.mediaAssetId = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatteryPhotosCompanion.insert({
    required int batteryId,
    required int mediaAssetId,
    this.isPrimary = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : batteryId = Value(batteryId),
        mediaAssetId = Value(mediaAssetId);
  static Insertable<BatteryPhoto> custom({
    Expression<int>? batteryId,
    Expression<int>? mediaAssetId,
    Expression<bool>? isPrimary,
    Expression<int>? displayOrder,
    Expression<String>? caption,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (batteryId != null) 'battery_id': batteryId,
      if (mediaAssetId != null) 'media_asset_id': mediaAssetId,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (displayOrder != null) 'display_order': displayOrder,
      if (caption != null) 'caption': caption,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatteryPhotosCompanion copyWith(
      {Value<int>? batteryId,
      Value<int>? mediaAssetId,
      Value<bool>? isPrimary,
      Value<int>? displayOrder,
      Value<String?>? caption,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<int>? rowid}) {
    return BatteryPhotosCompanion(
      batteryId: batteryId ?? this.batteryId,
      mediaAssetId: mediaAssetId ?? this.mediaAssetId,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (batteryId.present) {
      map['battery_id'] = Variable<int>(batteryId.value);
    }
    if (mediaAssetId.present) {
      map['media_asset_id'] = Variable<int>(mediaAssetId.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $BatteryPhotosTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $BatteryPhotosTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatteryPhotosCompanion(')
          ..write('batteryId: $batteryId, ')
          ..write('mediaAssetId: $mediaAssetId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatterySetPhotosTable extends BatterySetPhotos
    with TableInfo<$BatterySetPhotosTable, BatterySetPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatterySetPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _batterySetIdMeta =
      const VerificationMeta('batterySetId');
  @override
  late final GeneratedColumn<int> batterySetId = GeneratedColumn<int>(
      'battery_set_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES battery_sets (id) ON DELETE RESTRICT'));
  static const VerificationMeta _mediaAssetIdMeta =
      const VerificationMeta('mediaAssetId');
  @override
  late final GeneratedColumn<int> mediaAssetId = GeneratedColumn<int>(
      'media_asset_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES media_assets (id) ON DELETE RESTRICT'));
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatterySetPhotosTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatterySetPhotosTable.$convertermodifiedAt);
  @override
  List<GeneratedColumn> get $columns => [
        batterySetId,
        mediaAssetId,
        isPrimary,
        displayOrder,
        caption,
        createdAt,
        modifiedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'battery_set_photos';
  @override
  VerificationContext validateIntegrity(Insertable<BatterySetPhoto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('battery_set_id')) {
      context.handle(
          _batterySetIdMeta,
          batterySetId.isAcceptableOrUnknown(
              data['battery_set_id']!, _batterySetIdMeta));
    } else if (isInserting) {
      context.missing(_batterySetIdMeta);
    }
    if (data.containsKey('media_asset_id')) {
      context.handle(
          _mediaAssetIdMeta,
          mediaAssetId.isAcceptableOrUnknown(
              data['media_asset_id']!, _mediaAssetIdMeta));
    } else if (isInserting) {
      context.missing(_mediaAssetIdMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {batterySetId, mediaAssetId};
  @override
  BatterySetPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatterySetPhoto(
      batterySetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_set_id'])!,
      mediaAssetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}media_asset_id'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
      createdAt: $BatterySetPhotosTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $BatterySetPhotosTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
    );
  }

  @override
  $BatterySetPhotosTable createAlias(String alias) {
    return $BatterySetPhotosTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
}

class BatterySetPhoto extends DataClass implements Insertable<BatterySetPhoto> {
  final int batterySetId;
  final int mediaAssetId;
  final bool isPrimary;
  final int displayOrder;
  final String? caption;
  final DateTime createdAt;
  final DateTime modifiedAt;
  const BatterySetPhoto(
      {required this.batterySetId,
      required this.mediaAssetId,
      required this.isPrimary,
      required this.displayOrder,
      this.caption,
      required this.createdAt,
      required this.modifiedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['battery_set_id'] = Variable<int>(batterySetId);
    map['media_asset_id'] = Variable<int>(mediaAssetId);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['display_order'] = Variable<int>(displayOrder);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    {
      map['created_at'] = Variable<String>(
          $BatterySetPhotosTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $BatterySetPhotosTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    return map;
  }

  BatterySetPhotosCompanion toCompanion(bool nullToAbsent) {
    return BatterySetPhotosCompanion(
      batterySetId: Value(batterySetId),
      mediaAssetId: Value(mediaAssetId),
      isPrimary: Value(isPrimary),
      displayOrder: Value(displayOrder),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory BatterySetPhoto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatterySetPhoto(
      batterySetId: serializer.fromJson<int>(json['batterySetId']),
      mediaAssetId: serializer.fromJson<int>(json['mediaAssetId']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      caption: serializer.fromJson<String?>(json['caption']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'batterySetId': serializer.toJson<int>(batterySetId),
      'mediaAssetId': serializer.toJson<int>(mediaAssetId),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'caption': serializer.toJson<String?>(caption),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  BatterySetPhoto copyWith(
          {int? batterySetId,
          int? mediaAssetId,
          bool? isPrimary,
          int? displayOrder,
          Value<String?> caption = const Value.absent(),
          DateTime? createdAt,
          DateTime? modifiedAt}) =>
      BatterySetPhoto(
        batterySetId: batterySetId ?? this.batterySetId,
        mediaAssetId: mediaAssetId ?? this.mediaAssetId,
        isPrimary: isPrimary ?? this.isPrimary,
        displayOrder: displayOrder ?? this.displayOrder,
        caption: caption.present ? caption.value : this.caption,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );
  BatterySetPhoto copyWithCompanion(BatterySetPhotosCompanion data) {
    return BatterySetPhoto(
      batterySetId: data.batterySetId.present
          ? data.batterySetId.value
          : this.batterySetId,
      mediaAssetId: data.mediaAssetId.present
          ? data.mediaAssetId.value
          : this.mediaAssetId,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      caption: data.caption.present ? data.caption.value : this.caption,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatterySetPhoto(')
          ..write('batterySetId: $batterySetId, ')
          ..write('mediaAssetId: $mediaAssetId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(batterySetId, mediaAssetId, isPrimary,
      displayOrder, caption, createdAt, modifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatterySetPhoto &&
          other.batterySetId == this.batterySetId &&
          other.mediaAssetId == this.mediaAssetId &&
          other.isPrimary == this.isPrimary &&
          other.displayOrder == this.displayOrder &&
          other.caption == this.caption &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt);
}

class BatterySetPhotosCompanion extends UpdateCompanion<BatterySetPhoto> {
  final Value<int> batterySetId;
  final Value<int> mediaAssetId;
  final Value<bool> isPrimary;
  final Value<int> displayOrder;
  final Value<String?> caption;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<int> rowid;
  const BatterySetPhotosCompanion({
    this.batterySetId = const Value.absent(),
    this.mediaAssetId = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatterySetPhotosCompanion.insert({
    required int batterySetId,
    required int mediaAssetId,
    this.isPrimary = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : batterySetId = Value(batterySetId),
        mediaAssetId = Value(mediaAssetId);
  static Insertable<BatterySetPhoto> custom({
    Expression<int>? batterySetId,
    Expression<int>? mediaAssetId,
    Expression<bool>? isPrimary,
    Expression<int>? displayOrder,
    Expression<String>? caption,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (batterySetId != null) 'battery_set_id': batterySetId,
      if (mediaAssetId != null) 'media_asset_id': mediaAssetId,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (displayOrder != null) 'display_order': displayOrder,
      if (caption != null) 'caption': caption,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatterySetPhotosCompanion copyWith(
      {Value<int>? batterySetId,
      Value<int>? mediaAssetId,
      Value<bool>? isPrimary,
      Value<int>? displayOrder,
      Value<String?>? caption,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<int>? rowid}) {
    return BatterySetPhotosCompanion(
      batterySetId: batterySetId ?? this.batterySetId,
      mediaAssetId: mediaAssetId ?? this.mediaAssetId,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (batterySetId.present) {
      map['battery_set_id'] = Variable<int>(batterySetId.value);
    }
    if (mediaAssetId.present) {
      map['media_asset_id'] = Variable<int>(mediaAssetId.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $BatterySetPhotosTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $BatterySetPhotosTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatterySetPhotosCompanion(')
          ..write('batterySetId: $batterySetId, ')
          ..write('mediaAssetId: $mediaAssetId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicePhotosTable extends DevicePhotos
    with TableInfo<$DevicePhotosTable, DevicePhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicePhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
      'device_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES devices (id) ON DELETE RESTRICT'));
  static const VerificationMeta _mediaAssetIdMeta =
      const VerificationMeta('mediaAssetId');
  @override
  late final GeneratedColumn<int> mediaAssetId = GeneratedColumn<int>(
      'media_asset_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES media_assets (id) ON DELETE RESTRICT'));
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($DevicePhotosTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($DevicePhotosTable.$convertermodifiedAt);
  @override
  List<GeneratedColumn> get $columns => [
        deviceId,
        mediaAssetId,
        isPrimary,
        displayOrder,
        caption,
        createdAt,
        modifiedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_photos';
  @override
  VerificationContext validateIntegrity(Insertable<DevicePhoto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('media_asset_id')) {
      context.handle(
          _mediaAssetIdMeta,
          mediaAssetId.isAcceptableOrUnknown(
              data['media_asset_id']!, _mediaAssetIdMeta));
    } else if (isInserting) {
      context.missing(_mediaAssetIdMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, mediaAssetId};
  @override
  DevicePhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevicePhoto(
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}device_id'])!,
      mediaAssetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}media_asset_id'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
      createdAt: $DevicePhotosTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $DevicePhotosTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
    );
  }

  @override
  $DevicePhotosTable createAlias(String alias) {
    return $DevicePhotosTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
}

class DevicePhoto extends DataClass implements Insertable<DevicePhoto> {
  final int deviceId;
  final int mediaAssetId;
  final bool isPrimary;
  final int displayOrder;
  final String? caption;
  final DateTime createdAt;
  final DateTime modifiedAt;
  const DevicePhoto(
      {required this.deviceId,
      required this.mediaAssetId,
      required this.isPrimary,
      required this.displayOrder,
      this.caption,
      required this.createdAt,
      required this.modifiedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<int>(deviceId);
    map['media_asset_id'] = Variable<int>(mediaAssetId);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['display_order'] = Variable<int>(displayOrder);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    {
      map['created_at'] = Variable<String>(
          $DevicePhotosTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $DevicePhotosTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    return map;
  }

  DevicePhotosCompanion toCompanion(bool nullToAbsent) {
    return DevicePhotosCompanion(
      deviceId: Value(deviceId),
      mediaAssetId: Value(mediaAssetId),
      isPrimary: Value(isPrimary),
      displayOrder: Value(displayOrder),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory DevicePhoto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevicePhoto(
      deviceId: serializer.fromJson<int>(json['deviceId']),
      mediaAssetId: serializer.fromJson<int>(json['mediaAssetId']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      caption: serializer.fromJson<String?>(json['caption']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<int>(deviceId),
      'mediaAssetId': serializer.toJson<int>(mediaAssetId),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'caption': serializer.toJson<String?>(caption),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  DevicePhoto copyWith(
          {int? deviceId,
          int? mediaAssetId,
          bool? isPrimary,
          int? displayOrder,
          Value<String?> caption = const Value.absent(),
          DateTime? createdAt,
          DateTime? modifiedAt}) =>
      DevicePhoto(
        deviceId: deviceId ?? this.deviceId,
        mediaAssetId: mediaAssetId ?? this.mediaAssetId,
        isPrimary: isPrimary ?? this.isPrimary,
        displayOrder: displayOrder ?? this.displayOrder,
        caption: caption.present ? caption.value : this.caption,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );
  DevicePhoto copyWithCompanion(DevicePhotosCompanion data) {
    return DevicePhoto(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      mediaAssetId: data.mediaAssetId.present
          ? data.mediaAssetId.value
          : this.mediaAssetId,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      caption: data.caption.present ? data.caption.value : this.caption,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevicePhoto(')
          ..write('deviceId: $deviceId, ')
          ..write('mediaAssetId: $mediaAssetId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, mediaAssetId, isPrimary,
      displayOrder, caption, createdAt, modifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevicePhoto &&
          other.deviceId == this.deviceId &&
          other.mediaAssetId == this.mediaAssetId &&
          other.isPrimary == this.isPrimary &&
          other.displayOrder == this.displayOrder &&
          other.caption == this.caption &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt);
}

class DevicePhotosCompanion extends UpdateCompanion<DevicePhoto> {
  final Value<int> deviceId;
  final Value<int> mediaAssetId;
  final Value<bool> isPrimary;
  final Value<int> displayOrder;
  final Value<String?> caption;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<int> rowid;
  const DevicePhotosCompanion({
    this.deviceId = const Value.absent(),
    this.mediaAssetId = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicePhotosCompanion.insert({
    required int deviceId,
    required int mediaAssetId,
    this.isPrimary = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : deviceId = Value(deviceId),
        mediaAssetId = Value(mediaAssetId);
  static Insertable<DevicePhoto> custom({
    Expression<int>? deviceId,
    Expression<int>? mediaAssetId,
    Expression<bool>? isPrimary,
    Expression<int>? displayOrder,
    Expression<String>? caption,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (mediaAssetId != null) 'media_asset_id': mediaAssetId,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (displayOrder != null) 'display_order': displayOrder,
      if (caption != null) 'caption': caption,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicePhotosCompanion copyWith(
      {Value<int>? deviceId,
      Value<int>? mediaAssetId,
      Value<bool>? isPrimary,
      Value<int>? displayOrder,
      Value<String?>? caption,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<int>? rowid}) {
    return DevicePhotosCompanion(
      deviceId: deviceId ?? this.deviceId,
      mediaAssetId: mediaAssetId ?? this.mediaAssetId,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (mediaAssetId.present) {
      map['media_asset_id'] = Variable<int>(mediaAssetId.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $DevicePhotosTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $DevicePhotosTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicePhotosCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('mediaAssetId: $mediaAssetId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IconCategoriesTable extends IconCategories
    with TableInfo<$IconCategoriesTable, IconCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IconCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($IconCategoriesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($IconCategoriesTable.$convertermodifiedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deactivatedAt =
      GeneratedColumn<String>('deactivated_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $IconCategoriesTable.$converterdeactivatedAtn);
  @override
  List<GeneratedColumn> get $columns =>
      [id, uuid, name, scope, createdAt, modifiedAt, deactivatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icon_categories';
  @override
  VerificationContext validateIntegrity(Insertable<IconCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IconCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IconCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      createdAt: $IconCategoriesTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $IconCategoriesTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
      deactivatedAt: $IconCategoriesTable.$converterdeactivatedAtn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}deactivated_at'])),
    );
  }

  @override
  $IconCategoriesTable createAlias(String alias) {
    return $IconCategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterdeactivatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeactivatedAtn =
      NullAwareTypeConverter.wrap($converterdeactivatedAt);
}

class IconCategory extends DataClass implements Insertable<IconCategory> {
  final int id;
  final String uuid;
  final String name;
  final String scope;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;
  const IconCategory(
      {required this.id,
      required this.uuid,
      required this.name,
      required this.scope,
      required this.createdAt,
      required this.modifiedAt,
      this.deactivatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['scope'] = Variable<String>(scope);
    {
      map['created_at'] = Variable<String>(
          $IconCategoriesTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $IconCategoriesTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    if (!nullToAbsent || deactivatedAt != null) {
      map['deactivated_at'] = Variable<String>(
          $IconCategoriesTable.$converterdeactivatedAtn.toSql(deactivatedAt));
    }
    return map;
  }

  IconCategoriesCompanion toCompanion(bool nullToAbsent) {
    return IconCategoriesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      scope: Value(scope),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deactivatedAt: deactivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deactivatedAt),
    );
  }

  factory IconCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IconCategory(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      scope: serializer.fromJson<String>(json['scope']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deactivatedAt: serializer.fromJson<DateTime?>(json['deactivatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'scope': serializer.toJson<String>(scope),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deactivatedAt': serializer.toJson<DateTime?>(deactivatedAt),
    };
  }

  IconCategory copyWith(
          {int? id,
          String? uuid,
          String? name,
          String? scope,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deactivatedAt = const Value.absent()}) =>
      IconCategory(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        scope: scope ?? this.scope,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deactivatedAt:
            deactivatedAt.present ? deactivatedAt.value : this.deactivatedAt,
      );
  IconCategory copyWithCompanion(IconCategoriesCompanion data) {
    return IconCategory(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      scope: data.scope.present ? data.scope.value : this.scope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deactivatedAt: data.deactivatedAt.present
          ? data.deactivatedAt.value
          : this.deactivatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IconCategory(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uuid, name, scope, createdAt, modifiedAt, deactivatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IconCategory &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.scope == this.scope &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deactivatedAt == this.deactivatedAt);
}

class IconCategoriesCompanion extends UpdateCompanion<IconCategory> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> scope;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deactivatedAt;
  const IconCategoriesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.scope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
  });
  IconCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required String scope,
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        scope = Value(scope);
  static Insertable<IconCategory> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? scope,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<String>? deactivatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (scope != null) 'scope': scope,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deactivatedAt != null) 'deactivated_at': deactivatedAt,
    });
  }

  IconCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<String>? scope,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deactivatedAt}) {
    return IconCategoriesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $IconCategoriesTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $IconCategoriesTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (deactivatedAt.present) {
      map['deactivated_at'] = Variable<String>($IconCategoriesTable
          .$converterdeactivatedAtn
          .toSql(deactivatedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IconCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('scope: $scope, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt')
          ..write(')'))
        .toString();
  }
}

class $CustomIconsTable extends CustomIcons
    with TableInfo<$CustomIconsTable, CustomIcon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomIconsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES icon_categories (id) ON DELETE RESTRICT'));
  static const VerificationMeta _relativePathMeta =
      const VerificationMeta('relativePath');
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
      'relative_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _fileTypeMeta =
      const VerificationMeta('fileType');
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
      'file_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supportsColorMeta =
      const VerificationMeta('supportsColor');
  @override
  late final GeneratedColumn<bool> supportsColor = GeneratedColumn<bool>(
      'supports_color', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("supports_color" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($CustomIconsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($CustomIconsTable.$convertermodifiedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deactivatedAt =
      GeneratedColumn<String>('deactivated_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($CustomIconsTable.$converterdeactivatedAtn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        name,
        categoryId,
        relativePath,
        fileType,
        supportsColor,
        createdAt,
        modifiedAt,
        deactivatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_icons';
  @override
  VerificationContext validateIntegrity(Insertable<CustomIcon> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('relative_path')) {
      context.handle(
          _relativePathMeta,
          relativePath.isAcceptableOrUnknown(
              data['relative_path']!, _relativePathMeta));
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(_fileTypeMeta,
          fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta));
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('supports_color')) {
      context.handle(
          _supportsColorMeta,
          supportsColor.isAcceptableOrUnknown(
              data['supports_color']!, _supportsColorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomIcon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomIcon(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      relativePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relative_path'])!,
      fileType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_type'])!,
      supportsColor: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}supports_color'])!,
      createdAt: $CustomIconsTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $CustomIconsTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
      deactivatedAt: $CustomIconsTable.$converterdeactivatedAtn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}deactivated_at'])),
    );
  }

  @override
  $CustomIconsTable createAlias(String alias) {
    return $CustomIconsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterdeactivatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeactivatedAtn =
      NullAwareTypeConverter.wrap($converterdeactivatedAt);
}

class CustomIcon extends DataClass implements Insertable<CustomIcon> {
  final int id;
  final String uuid;
  final String name;
  final int? categoryId;
  final String relativePath;
  final String fileType;
  final bool supportsColor;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;
  const CustomIcon(
      {required this.id,
      required this.uuid,
      required this.name,
      this.categoryId,
      required this.relativePath,
      required this.fileType,
      required this.supportsColor,
      required this.createdAt,
      required this.modifiedAt,
      this.deactivatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['relative_path'] = Variable<String>(relativePath);
    map['file_type'] = Variable<String>(fileType);
    map['supports_color'] = Variable<bool>(supportsColor);
    {
      map['created_at'] = Variable<String>(
          $CustomIconsTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $CustomIconsTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    if (!nullToAbsent || deactivatedAt != null) {
      map['deactivated_at'] = Variable<String>(
          $CustomIconsTable.$converterdeactivatedAtn.toSql(deactivatedAt));
    }
    return map;
  }

  CustomIconsCompanion toCompanion(bool nullToAbsent) {
    return CustomIconsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      relativePath: Value(relativePath),
      fileType: Value(fileType),
      supportsColor: Value(supportsColor),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deactivatedAt: deactivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deactivatedAt),
    );
  }

  factory CustomIcon.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomIcon(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      fileType: serializer.fromJson<String>(json['fileType']),
      supportsColor: serializer.fromJson<bool>(json['supportsColor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deactivatedAt: serializer.fromJson<DateTime?>(json['deactivatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<int?>(categoryId),
      'relativePath': serializer.toJson<String>(relativePath),
      'fileType': serializer.toJson<String>(fileType),
      'supportsColor': serializer.toJson<bool>(supportsColor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deactivatedAt': serializer.toJson<DateTime?>(deactivatedAt),
    };
  }

  CustomIcon copyWith(
          {int? id,
          String? uuid,
          String? name,
          Value<int?> categoryId = const Value.absent(),
          String? relativePath,
          String? fileType,
          bool? supportsColor,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deactivatedAt = const Value.absent()}) =>
      CustomIcon(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        relativePath: relativePath ?? this.relativePath,
        fileType: fileType ?? this.fileType,
        supportsColor: supportsColor ?? this.supportsColor,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deactivatedAt:
            deactivatedAt.present ? deactivatedAt.value : this.deactivatedAt,
      );
  CustomIcon copyWithCompanion(CustomIconsCompanion data) {
    return CustomIcon(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      supportsColor: data.supportsColor.present
          ? data.supportsColor.value
          : this.supportsColor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deactivatedAt: data.deactivatedAt.present
          ? data.deactivatedAt.value
          : this.deactivatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomIcon(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('relativePath: $relativePath, ')
          ..write('fileType: $fileType, ')
          ..write('supportsColor: $supportsColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, name, categoryId, relativePath,
      fileType, supportsColor, createdAt, modifiedAt, deactivatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomIcon &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.relativePath == this.relativePath &&
          other.fileType == this.fileType &&
          other.supportsColor == this.supportsColor &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deactivatedAt == this.deactivatedAt);
}

class CustomIconsCompanion extends UpdateCompanion<CustomIcon> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<int?> categoryId;
  final Value<String> relativePath;
  final Value<String> fileType;
  final Value<bool> supportsColor;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deactivatedAt;
  const CustomIconsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.fileType = const Value.absent(),
    this.supportsColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
  });
  CustomIconsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    this.categoryId = const Value.absent(),
    required String relativePath,
    required String fileType,
    this.supportsColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        relativePath = Value(relativePath),
        fileType = Value(fileType);
  static Insertable<CustomIcon> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<int>? categoryId,
    Expression<String>? relativePath,
    Expression<String>? fileType,
    Expression<bool>? supportsColor,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<String>? deactivatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (relativePath != null) 'relative_path': relativePath,
      if (fileType != null) 'file_type': fileType,
      if (supportsColor != null) 'supports_color': supportsColor,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deactivatedAt != null) 'deactivated_at': deactivatedAt,
    });
  }

  CustomIconsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<int?>? categoryId,
      Value<String>? relativePath,
      Value<String>? fileType,
      Value<bool>? supportsColor,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deactivatedAt}) {
    return CustomIconsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      relativePath: relativePath ?? this.relativePath,
      fileType: fileType ?? this.fileType,
      supportsColor: supportsColor ?? this.supportsColor,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (supportsColor.present) {
      map['supports_color'] = Variable<bool>(supportsColor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $CustomIconsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $CustomIconsTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (deactivatedAt.present) {
      map['deactivated_at'] = Variable<String>($CustomIconsTable
          .$converterdeactivatedAtn
          .toSql(deactivatedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomIconsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('relativePath: $relativePath, ')
          ..write('fileType: $fileType, ')
          ..write('supportsColor: $supportsColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($TagsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($TagsTable.$convertermodifiedAt);
  @override
  List<GeneratedColumn> get $columns => [id, uuid, name, createdAt, modifiedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: $TagsTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $TagsTable.$convertermodifiedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String uuid;
  final String name;
  final DateTime createdAt;
  final DateTime modifiedAt;
  const Tag(
      {required this.id,
      required this.uuid,
      required this.name,
      required this.createdAt,
      required this.modifiedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    {
      map['created_at'] =
          Variable<String>($TagsTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] =
          Variable<String>($TagsTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  Tag copyWith(
          {int? id,
          String? uuid,
          String? name,
          DateTime? createdAt,
          DateTime? modifiedAt}) =>
      Tag(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, name, createdAt, modifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
    });
  }

  TagsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt}) {
    return TagsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $TagsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $TagsTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }
}

class $BatteryTagsTable extends BatteryTags
    with TableInfo<$BatteryTagsTable, BatteryTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatteryTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _batteryIdMeta =
      const VerificationMeta('batteryId');
  @override
  late final GeneratedColumn<int> batteryId = GeneratedColumn<int>(
      'battery_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES batteries (id) ON DELETE RESTRICT'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tags (id) ON DELETE RESTRICT'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($BatteryTagsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [batteryId, tagId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'battery_tags';
  @override
  VerificationContext validateIntegrity(Insertable<BatteryTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('battery_id')) {
      context.handle(_batteryIdMeta,
          batteryId.isAcceptableOrUnknown(data['battery_id']!, _batteryIdMeta));
    } else if (isInserting) {
      context.missing(_batteryIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {batteryId, tagId};
  @override
  BatteryTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatteryTag(
      batteryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}battery_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
      createdAt: $BatteryTagsTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
    );
  }

  @override
  $BatteryTagsTable createAlias(String alias) {
    return $BatteryTagsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
}

class BatteryTag extends DataClass implements Insertable<BatteryTag> {
  final int batteryId;
  final int tagId;
  final DateTime createdAt;
  const BatteryTag(
      {required this.batteryId, required this.tagId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['battery_id'] = Variable<int>(batteryId);
    map['tag_id'] = Variable<int>(tagId);
    {
      map['created_at'] = Variable<String>(
          $BatteryTagsTable.$convertercreatedAt.toSql(createdAt));
    }
    return map;
  }

  BatteryTagsCompanion toCompanion(bool nullToAbsent) {
    return BatteryTagsCompanion(
      batteryId: Value(batteryId),
      tagId: Value(tagId),
      createdAt: Value(createdAt),
    );
  }

  factory BatteryTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatteryTag(
      batteryId: serializer.fromJson<int>(json['batteryId']),
      tagId: serializer.fromJson<int>(json['tagId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'batteryId': serializer.toJson<int>(batteryId),
      'tagId': serializer.toJson<int>(tagId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BatteryTag copyWith({int? batteryId, int? tagId, DateTime? createdAt}) =>
      BatteryTag(
        batteryId: batteryId ?? this.batteryId,
        tagId: tagId ?? this.tagId,
        createdAt: createdAt ?? this.createdAt,
      );
  BatteryTag copyWithCompanion(BatteryTagsCompanion data) {
    return BatteryTag(
      batteryId: data.batteryId.present ? data.batteryId.value : this.batteryId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatteryTag(')
          ..write('batteryId: $batteryId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(batteryId, tagId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatteryTag &&
          other.batteryId == this.batteryId &&
          other.tagId == this.tagId &&
          other.createdAt == this.createdAt);
}

class BatteryTagsCompanion extends UpdateCompanion<BatteryTag> {
  final Value<int> batteryId;
  final Value<int> tagId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BatteryTagsCompanion({
    this.batteryId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatteryTagsCompanion.insert({
    required int batteryId,
    required int tagId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : batteryId = Value(batteryId),
        tagId = Value(tagId);
  static Insertable<BatteryTag> custom({
    Expression<int>? batteryId,
    Expression<int>? tagId,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (batteryId != null) 'battery_id': batteryId,
      if (tagId != null) 'tag_id': tagId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatteryTagsCompanion copyWith(
      {Value<int>? batteryId,
      Value<int>? tagId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BatteryTagsCompanion(
      batteryId: batteryId ?? this.batteryId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (batteryId.present) {
      map['battery_id'] = Variable<int>(batteryId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $BatteryTagsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatteryTagsCompanion(')
          ..write('batteryId: $batteryId, ')
          ..write('tagId: $tagId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QrLabelTemplatesTable extends QrLabelTemplates
    with TableInfo<$QrLabelTemplatesTable, QrLabelTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QrLabelTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetTypeMeta =
      const VerificationMeta('targetType');
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
      'target_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _widthPointsMeta =
      const VerificationMeta('widthPoints');
  @override
  late final GeneratedColumn<double> widthPoints = GeneratedColumn<double>(
      'width_points', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _heightPointsMeta =
      const VerificationMeta('heightPoints');
  @override
  late final GeneratedColumn<double> heightPoints = GeneratedColumn<double>(
      'height_points', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _layoutJsonMeta =
      const VerificationMeta('layoutJson');
  @override
  late final GeneratedColumn<String> layoutJson = GeneratedColumn<String>(
      'layout_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($QrLabelTemplatesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($QrLabelTemplatesTable.$convertermodifiedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deactivatedAt =
      GeneratedColumn<String>('deactivated_at', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>(
              $QrLabelTemplatesTable.$converterdeactivatedAtn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        name,
        targetType,
        widthPoints,
        heightPoints,
        layoutJson,
        createdAt,
        modifiedAt,
        deactivatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'qr_label_templates';
  @override
  VerificationContext validateIntegrity(Insertable<QrLabelTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
          _targetTypeMeta,
          targetType.isAcceptableOrUnknown(
              data['target_type']!, _targetTypeMeta));
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('width_points')) {
      context.handle(
          _widthPointsMeta,
          widthPoints.isAcceptableOrUnknown(
              data['width_points']!, _widthPointsMeta));
    } else if (isInserting) {
      context.missing(_widthPointsMeta);
    }
    if (data.containsKey('height_points')) {
      context.handle(
          _heightPointsMeta,
          heightPoints.isAcceptableOrUnknown(
              data['height_points']!, _heightPointsMeta));
    } else if (isInserting) {
      context.missing(_heightPointsMeta);
    }
    if (data.containsKey('layout_json')) {
      context.handle(
          _layoutJsonMeta,
          layoutJson.isAcceptableOrUnknown(
              data['layout_json']!, _layoutJsonMeta));
    } else if (isInserting) {
      context.missing(_layoutJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QrLabelTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QrLabelTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_type'])!,
      widthPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}width_points'])!,
      heightPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_points'])!,
      layoutJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}layout_json'])!,
      createdAt: $QrLabelTemplatesTable.$convertercreatedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      modifiedAt: $QrLabelTemplatesTable.$convertermodifiedAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
      deactivatedAt: $QrLabelTemplatesTable.$converterdeactivatedAtn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}deactivated_at'])),
    );
  }

  @override
  $QrLabelTemplatesTable createAlias(String alias) {
    return $QrLabelTemplatesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime, String> $converterdeactivatedAt =
      const UtcDateTimeTextConverter();
  static TypeConverter<DateTime?, String?> $converterdeactivatedAtn =
      NullAwareTypeConverter.wrap($converterdeactivatedAt);
}

class QrLabelTemplate extends DataClass implements Insertable<QrLabelTemplate> {
  final int id;
  final String uuid;
  final String name;
  final String targetType;
  final double widthPoints;
  final double heightPoints;
  final String layoutJson;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deactivatedAt;
  const QrLabelTemplate(
      {required this.id,
      required this.uuid,
      required this.name,
      required this.targetType,
      required this.widthPoints,
      required this.heightPoints,
      required this.layoutJson,
      required this.createdAt,
      required this.modifiedAt,
      this.deactivatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['target_type'] = Variable<String>(targetType);
    map['width_points'] = Variable<double>(widthPoints);
    map['height_points'] = Variable<double>(heightPoints);
    map['layout_json'] = Variable<String>(layoutJson);
    {
      map['created_at'] = Variable<String>(
          $QrLabelTemplatesTable.$convertercreatedAt.toSql(createdAt));
    }
    {
      map['modified_at'] = Variable<String>(
          $QrLabelTemplatesTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    if (!nullToAbsent || deactivatedAt != null) {
      map['deactivated_at'] = Variable<String>(
          $QrLabelTemplatesTable.$converterdeactivatedAtn.toSql(deactivatedAt));
    }
    return map;
  }

  QrLabelTemplatesCompanion toCompanion(bool nullToAbsent) {
    return QrLabelTemplatesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      targetType: Value(targetType),
      widthPoints: Value(widthPoints),
      heightPoints: Value(heightPoints),
      layoutJson: Value(layoutJson),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      deactivatedAt: deactivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deactivatedAt),
    );
  }

  factory QrLabelTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QrLabelTemplate(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      targetType: serializer.fromJson<String>(json['targetType']),
      widthPoints: serializer.fromJson<double>(json['widthPoints']),
      heightPoints: serializer.fromJson<double>(json['heightPoints']),
      layoutJson: serializer.fromJson<String>(json['layoutJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      deactivatedAt: serializer.fromJson<DateTime?>(json['deactivatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'targetType': serializer.toJson<String>(targetType),
      'widthPoints': serializer.toJson<double>(widthPoints),
      'heightPoints': serializer.toJson<double>(heightPoints),
      'layoutJson': serializer.toJson<String>(layoutJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'deactivatedAt': serializer.toJson<DateTime?>(deactivatedAt),
    };
  }

  QrLabelTemplate copyWith(
          {int? id,
          String? uuid,
          String? name,
          String? targetType,
          double? widthPoints,
          double? heightPoints,
          String? layoutJson,
          DateTime? createdAt,
          DateTime? modifiedAt,
          Value<DateTime?> deactivatedAt = const Value.absent()}) =>
      QrLabelTemplate(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        targetType: targetType ?? this.targetType,
        widthPoints: widthPoints ?? this.widthPoints,
        heightPoints: heightPoints ?? this.heightPoints,
        layoutJson: layoutJson ?? this.layoutJson,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        deactivatedAt:
            deactivatedAt.present ? deactivatedAt.value : this.deactivatedAt,
      );
  QrLabelTemplate copyWithCompanion(QrLabelTemplatesCompanion data) {
    return QrLabelTemplate(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      targetType:
          data.targetType.present ? data.targetType.value : this.targetType,
      widthPoints:
          data.widthPoints.present ? data.widthPoints.value : this.widthPoints,
      heightPoints: data.heightPoints.present
          ? data.heightPoints.value
          : this.heightPoints,
      layoutJson:
          data.layoutJson.present ? data.layoutJson.value : this.layoutJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
      deactivatedAt: data.deactivatedAt.present
          ? data.deactivatedAt.value
          : this.deactivatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QrLabelTemplate(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('targetType: $targetType, ')
          ..write('widthPoints: $widthPoints, ')
          ..write('heightPoints: $heightPoints, ')
          ..write('layoutJson: $layoutJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, name, targetType, widthPoints,
      heightPoints, layoutJson, createdAt, modifiedAt, deactivatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QrLabelTemplate &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.targetType == this.targetType &&
          other.widthPoints == this.widthPoints &&
          other.heightPoints == this.heightPoints &&
          other.layoutJson == this.layoutJson &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.deactivatedAt == this.deactivatedAt);
}

class QrLabelTemplatesCompanion extends UpdateCompanion<QrLabelTemplate> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> targetType;
  final Value<double> widthPoints;
  final Value<double> heightPoints;
  final Value<String> layoutJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<DateTime?> deactivatedAt;
  const QrLabelTemplatesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.targetType = const Value.absent(),
    this.widthPoints = const Value.absent(),
    this.heightPoints = const Value.absent(),
    this.layoutJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
  });
  QrLabelTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required String targetType,
    required double widthPoints,
    required double heightPoints,
    required String layoutJson,
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        targetType = Value(targetType),
        widthPoints = Value(widthPoints),
        heightPoints = Value(heightPoints),
        layoutJson = Value(layoutJson);
  static Insertable<QrLabelTemplate> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? targetType,
    Expression<double>? widthPoints,
    Expression<double>? heightPoints,
    Expression<String>? layoutJson,
    Expression<String>? createdAt,
    Expression<String>? modifiedAt,
    Expression<String>? deactivatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (targetType != null) 'target_type': targetType,
      if (widthPoints != null) 'width_points': widthPoints,
      if (heightPoints != null) 'height_points': heightPoints,
      if (layoutJson != null) 'layout_json': layoutJson,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (deactivatedAt != null) 'deactivated_at': deactivatedAt,
    });
  }

  QrLabelTemplatesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<String>? targetType,
      Value<double>? widthPoints,
      Value<double>? heightPoints,
      Value<String>? layoutJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? modifiedAt,
      Value<DateTime?>? deactivatedAt}) {
    return QrLabelTemplatesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      targetType: targetType ?? this.targetType,
      widthPoints: widthPoints ?? this.widthPoints,
      heightPoints: heightPoints ?? this.heightPoints,
      layoutJson: layoutJson ?? this.layoutJson,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (widthPoints.present) {
      map['width_points'] = Variable<double>(widthPoints.value);
    }
    if (heightPoints.present) {
      map['height_points'] = Variable<double>(heightPoints.value);
    }
    if (layoutJson.present) {
      map['layout_json'] = Variable<String>(layoutJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
          $QrLabelTemplatesTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $QrLabelTemplatesTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (deactivatedAt.present) {
      map['deactivated_at'] = Variable<String>($QrLabelTemplatesTable
          .$converterdeactivatedAtn
          .toSql(deactivatedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QrLabelTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('targetType: $targetType, ')
          ..write('widthPoints: $widthPoints, ')
          ..write('heightPoints: $heightPoints, ')
          ..write('layoutJson: $layoutJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('deactivatedAt: $deactivatedAt')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogTable extends ActivityLog
    with TableInfo<$ActivityLogTable, ActivityLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityUuidMeta =
      const VerificationMeta('entityUuid');
  @override
  late final GeneratedColumn<String> entityUuid = GeneratedColumn<String>(
      'entity_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relatedEntityTypeMeta =
      const VerificationMeta('relatedEntityType');
  @override
  late final GeneratedColumn<String> relatedEntityType =
      GeneratedColumn<String>('related_entity_type', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relatedEntityUuidMeta =
      const VerificationMeta('relatedEntityUuid');
  @override
  late final GeneratedColumn<String> relatedEntityUuid =
      GeneratedColumn<String>('related_entity_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _operationUuidMeta =
      const VerificationMeta('operationUuid');
  @override
  late final GeneratedColumn<String> operationUuid = GeneratedColumn<String>(
      'operation_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> occurredAt =
      GeneratedColumn<String>('occurred_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($ActivityLogTable.$converteroccurredAt);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        eventType,
        entityType,
        entityUuid,
        relatedEntityType,
        relatedEntityUuid,
        operationUuid,
        summary,
        metadataJson,
        occurredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_log';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_uuid')) {
      context.handle(
          _entityUuidMeta,
          entityUuid.isAcceptableOrUnknown(
              data['entity_uuid']!, _entityUuidMeta));
    } else if (isInserting) {
      context.missing(_entityUuidMeta);
    }
    if (data.containsKey('related_entity_type')) {
      context.handle(
          _relatedEntityTypeMeta,
          relatedEntityType.isAcceptableOrUnknown(
              data['related_entity_type']!, _relatedEntityTypeMeta));
    }
    if (data.containsKey('related_entity_uuid')) {
      context.handle(
          _relatedEntityUuidMeta,
          relatedEntityUuid.isAcceptableOrUnknown(
              data['related_entity_uuid']!, _relatedEntityUuidMeta));
    }
    if (data.containsKey('operation_uuid')) {
      context.handle(
          _operationUuidMeta,
          operationUuid.isAcceptableOrUnknown(
              data['operation_uuid']!, _operationUuidMeta));
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_uuid'])!,
      relatedEntityType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_entity_type']),
      relatedEntityUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_entity_uuid']),
      operationUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_uuid']),
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      occurredAt: $ActivityLogTable.$converteroccurredAt.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}occurred_at'])!),
    );
  }

  @override
  $ActivityLogTable createAlias(String alias) {
    return $ActivityLogTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converteroccurredAt =
      const UtcDateTimeTextConverter();
}

class ActivityLogData extends DataClass implements Insertable<ActivityLogData> {
  final int id;
  final String uuid;
  final String eventType;
  final String entityType;
  final String entityUuid;
  final String? relatedEntityType;
  final String? relatedEntityUuid;
  final String? operationUuid;
  final String summary;
  final String metadataJson;
  final DateTime occurredAt;
  const ActivityLogData(
      {required this.id,
      required this.uuid,
      required this.eventType,
      required this.entityType,
      required this.entityUuid,
      this.relatedEntityType,
      this.relatedEntityUuid,
      this.operationUuid,
      required this.summary,
      required this.metadataJson,
      required this.occurredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['event_type'] = Variable<String>(eventType);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_uuid'] = Variable<String>(entityUuid);
    if (!nullToAbsent || relatedEntityType != null) {
      map['related_entity_type'] = Variable<String>(relatedEntityType);
    }
    if (!nullToAbsent || relatedEntityUuid != null) {
      map['related_entity_uuid'] = Variable<String>(relatedEntityUuid);
    }
    if (!nullToAbsent || operationUuid != null) {
      map['operation_uuid'] = Variable<String>(operationUuid);
    }
    map['summary'] = Variable<String>(summary);
    map['metadata_json'] = Variable<String>(metadataJson);
    {
      map['occurred_at'] = Variable<String>(
          $ActivityLogTable.$converteroccurredAt.toSql(occurredAt));
    }
    return map;
  }

  ActivityLogCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogCompanion(
      id: Value(id),
      uuid: Value(uuid),
      eventType: Value(eventType),
      entityType: Value(entityType),
      entityUuid: Value(entityUuid),
      relatedEntityType: relatedEntityType == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntityType),
      relatedEntityUuid: relatedEntityUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntityUuid),
      operationUuid: operationUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(operationUuid),
      summary: Value(summary),
      metadataJson: Value(metadataJson),
      occurredAt: Value(occurredAt),
    );
  }

  factory ActivityLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      eventType: serializer.fromJson<String>(json['eventType']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityUuid: serializer.fromJson<String>(json['entityUuid']),
      relatedEntityType:
          serializer.fromJson<String?>(json['relatedEntityType']),
      relatedEntityUuid:
          serializer.fromJson<String?>(json['relatedEntityUuid']),
      operationUuid: serializer.fromJson<String?>(json['operationUuid']),
      summary: serializer.fromJson<String>(json['summary']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'eventType': serializer.toJson<String>(eventType),
      'entityType': serializer.toJson<String>(entityType),
      'entityUuid': serializer.toJson<String>(entityUuid),
      'relatedEntityType': serializer.toJson<String?>(relatedEntityType),
      'relatedEntityUuid': serializer.toJson<String?>(relatedEntityUuid),
      'operationUuid': serializer.toJson<String?>(operationUuid),
      'summary': serializer.toJson<String>(summary),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  ActivityLogData copyWith(
          {int? id,
          String? uuid,
          String? eventType,
          String? entityType,
          String? entityUuid,
          Value<String?> relatedEntityType = const Value.absent(),
          Value<String?> relatedEntityUuid = const Value.absent(),
          Value<String?> operationUuid = const Value.absent(),
          String? summary,
          String? metadataJson,
          DateTime? occurredAt}) =>
      ActivityLogData(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        eventType: eventType ?? this.eventType,
        entityType: entityType ?? this.entityType,
        entityUuid: entityUuid ?? this.entityUuid,
        relatedEntityType: relatedEntityType.present
            ? relatedEntityType.value
            : this.relatedEntityType,
        relatedEntityUuid: relatedEntityUuid.present
            ? relatedEntityUuid.value
            : this.relatedEntityUuid,
        operationUuid:
            operationUuid.present ? operationUuid.value : this.operationUuid,
        summary: summary ?? this.summary,
        metadataJson: metadataJson ?? this.metadataJson,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  ActivityLogData copyWithCompanion(ActivityLogCompanion data) {
    return ActivityLogData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityUuid:
          data.entityUuid.present ? data.entityUuid.value : this.entityUuid,
      relatedEntityType: data.relatedEntityType.present
          ? data.relatedEntityType.value
          : this.relatedEntityType,
      relatedEntityUuid: data.relatedEntityUuid.present
          ? data.relatedEntityUuid.value
          : this.relatedEntityUuid,
      operationUuid: data.operationUuid.present
          ? data.operationUuid.value
          : this.operationUuid,
      summary: data.summary.present ? data.summary.value : this.summary,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityUuid: $entityUuid, ')
          ..write('relatedEntityType: $relatedEntityType, ')
          ..write('relatedEntityUuid: $relatedEntityUuid, ')
          ..write('operationUuid: $operationUuid, ')
          ..write('summary: $summary, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      eventType,
      entityType,
      entityUuid,
      relatedEntityType,
      relatedEntityUuid,
      operationUuid,
      summary,
      metadataJson,
      occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.eventType == this.eventType &&
          other.entityType == this.entityType &&
          other.entityUuid == this.entityUuid &&
          other.relatedEntityType == this.relatedEntityType &&
          other.relatedEntityUuid == this.relatedEntityUuid &&
          other.operationUuid == this.operationUuid &&
          other.summary == this.summary &&
          other.metadataJson == this.metadataJson &&
          other.occurredAt == this.occurredAt);
}

class ActivityLogCompanion extends UpdateCompanion<ActivityLogData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> eventType;
  final Value<String> entityType;
  final Value<String> entityUuid;
  final Value<String?> relatedEntityType;
  final Value<String?> relatedEntityUuid;
  final Value<String?> operationUuid;
  final Value<String> summary;
  final Value<String> metadataJson;
  final Value<DateTime> occurredAt;
  const ActivityLogCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.eventType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityUuid = const Value.absent(),
    this.relatedEntityType = const Value.absent(),
    this.relatedEntityUuid = const Value.absent(),
    this.operationUuid = const Value.absent(),
    this.summary = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  ActivityLogCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String eventType,
    required String entityType,
    required String entityUuid,
    this.relatedEntityType = const Value.absent(),
    this.relatedEntityUuid = const Value.absent(),
    this.operationUuid = const Value.absent(),
    required String summary,
    this.metadataJson = const Value.absent(),
    this.occurredAt = const Value.absent(),
  })  : uuid = Value(uuid),
        eventType = Value(eventType),
        entityType = Value(entityType),
        entityUuid = Value(entityUuid),
        summary = Value(summary);
  static Insertable<ActivityLogData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? eventType,
    Expression<String>? entityType,
    Expression<String>? entityUuid,
    Expression<String>? relatedEntityType,
    Expression<String>? relatedEntityUuid,
    Expression<String>? operationUuid,
    Expression<String>? summary,
    Expression<String>? metadataJson,
    Expression<String>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (eventType != null) 'event_type': eventType,
      if (entityType != null) 'entity_type': entityType,
      if (entityUuid != null) 'entity_uuid': entityUuid,
      if (relatedEntityType != null) 'related_entity_type': relatedEntityType,
      if (relatedEntityUuid != null) 'related_entity_uuid': relatedEntityUuid,
      if (operationUuid != null) 'operation_uuid': operationUuid,
      if (summary != null) 'summary': summary,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  ActivityLogCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? eventType,
      Value<String>? entityType,
      Value<String>? entityUuid,
      Value<String?>? relatedEntityType,
      Value<String?>? relatedEntityUuid,
      Value<String?>? operationUuid,
      Value<String>? summary,
      Value<String>? metadataJson,
      Value<DateTime>? occurredAt}) {
    return ActivityLogCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      eventType: eventType ?? this.eventType,
      entityType: entityType ?? this.entityType,
      entityUuid: entityUuid ?? this.entityUuid,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityUuid: relatedEntityUuid ?? this.relatedEntityUuid,
      operationUuid: operationUuid ?? this.operationUuid,
      summary: summary ?? this.summary,
      metadataJson: metadataJson ?? this.metadataJson,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityUuid.present) {
      map['entity_uuid'] = Variable<String>(entityUuid.value);
    }
    if (relatedEntityType.present) {
      map['related_entity_type'] = Variable<String>(relatedEntityType.value);
    }
    if (relatedEntityUuid.present) {
      map['related_entity_uuid'] = Variable<String>(relatedEntityUuid.value);
    }
    if (operationUuid.present) {
      map['operation_uuid'] = Variable<String>(operationUuid.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<String>(
          $ActivityLogTable.$converteroccurredAt.toSql(occurredAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityUuid: $entityUuid, ')
          ..write('relatedEntityType: $relatedEntityType, ')
          ..write('relatedEntityUuid: $relatedEntityUuid, ')
          ..write('operationUuid: $operationUuid, ')
          ..write('summary: $summary, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'setting_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueTypeMeta =
      const VerificationMeta('valueType');
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
      'value_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> modifiedAt =
      GeneratedColumn<String>('modified_at', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: _utcNow)
          .withConverter<DateTime>($SettingsTable.$convertermodifiedAt);
  @override
  List<GeneratedColumn> get $columns => [key, value, valueType, modifiedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['setting_key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('value_type')) {
      context.handle(_valueTypeMeta,
          valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta));
    } else if (isInserting) {
      context.missing(_valueTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      valueType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value_type'])!,
      modifiedAt: $SettingsTable.$convertermodifiedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modified_at'])!),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertermodifiedAt =
      const UtcDateTimeTextConverter();
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  final String valueType;
  final DateTime modifiedAt;
  const Setting(
      {required this.key,
      required this.value,
      required this.valueType,
      required this.modifiedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['value_type'] = Variable<String>(valueType);
    {
      map['modified_at'] = Variable<String>(
          $SettingsTable.$convertermodifiedAt.toSql(modifiedAt));
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      valueType: Value(valueType),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      valueType: serializer.fromJson<String>(json['valueType']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'valueType': serializer.toJson<String>(valueType),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  Setting copyWith(
          {String? key,
          String? value,
          String? valueType,
          DateTime? modifiedAt}) =>
      Setting(
        key: key ?? this.key,
        value: value ?? this.value,
        valueType: valueType ?? this.valueType,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      modifiedAt:
          data.modifiedAt.present ? data.modifiedAt.value : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('valueType: $valueType, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, valueType, modifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.valueType == this.valueType &&
          other.modifiedAt == this.modifiedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<String> valueType;
  final Value<DateTime> modifiedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.valueType = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    required String valueType,
    this.modifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        valueType = Value(valueType);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? valueType,
    Expression<String>? modifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'setting_key': key,
      if (value != null) 'value': value,
      if (valueType != null) 'value_type': valueType,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<String>? valueType,
      Value<DateTime>? modifiedAt,
      Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['setting_key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(
          $SettingsTable.$convertermodifiedAt.toSql(modifiedAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('valueType: $valueType, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BatteryTypesTable batteryTypes = $BatteryTypesTable(this);
  late final $BatteryBatchesTable batteryBatches = $BatteryBatchesTable(this);
  late final $BatteriesTable batteries = $BatteriesTable(this);
  late final $BatterySetsTable batterySets = $BatterySetsTable(this);
  late final $BatterySetMembershipsTable batterySetMemberships =
      $BatterySetMembershipsTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $AssignmentsTable assignments = $AssignmentsTable(this);
  late final $SetChargeRecordsTable setChargeRecords =
      $SetChargeRecordsTable(this);
  late final $ChargeRecordsTable chargeRecords = $ChargeRecordsTable(this);
  late final $MediaAssetsTable mediaAssets = $MediaAssetsTable(this);
  late final $BatteryPhotosTable batteryPhotos = $BatteryPhotosTable(this);
  late final $BatterySetPhotosTable batterySetPhotos =
      $BatterySetPhotosTable(this);
  late final $DevicePhotosTable devicePhotos = $DevicePhotosTable(this);
  late final $IconCategoriesTable iconCategories = $IconCategoriesTable(this);
  late final $CustomIconsTable customIcons = $CustomIconsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $BatteryTagsTable batteryTags = $BatteryTagsTable(this);
  late final $QrLabelTemplatesTable qrLabelTemplates =
      $QrLabelTemplatesTable(this);
  late final $ActivityLogTable activityLog = $ActivityLogTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        batteryTypes,
        batteryBatches,
        batteries,
        batterySets,
        batterySetMemberships,
        devices,
        assignments,
        setChargeRecords,
        chargeRecords,
        mediaAssets,
        batteryPhotos,
        batterySetPhotos,
        devicePhotos,
        iconCategories,
        customIcons,
        tags,
        batteryTags,
        qrLabelTemplates,
        activityLog,
        settings
      ];
}

typedef $$BatteryTypesTableCreateCompanionBuilder = BatteryTypesCompanion
    Function({
  Value<int> id,
  required String uuid,
  required String typeName,
  Value<String?> description,
  Value<String?> chemistry,
  Value<double?> defaultVoltage,
  Value<double?> defaultCapacity,
  Value<String?> capacityUnit,
  Value<String?> physicalSize,
  Value<String> suggestedIconSource,
  Value<String> suggestedIconKey,
  Value<String> suggestedIconColor,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
});
typedef $$BatteryTypesTableUpdateCompanionBuilder = BatteryTypesCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> typeName,
  Value<String?> description,
  Value<String?> chemistry,
  Value<double?> defaultVoltage,
  Value<double?> defaultCapacity,
  Value<String?> capacityUnit,
  Value<String?> physicalSize,
  Value<String> suggestedIconSource,
  Value<String> suggestedIconKey,
  Value<String> suggestedIconColor,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
});

final class $$BatteryTypesTableReferences
    extends BaseReferences<_$AppDatabase, $BatteryTypesTable, BatteryType> {
  $$BatteryTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BatteriesTable, List<Battery>>
      _batteriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batteries,
              aliasName: 'battery_types__id__batteries__battery_type_id');

  $$BatteriesTableProcessedTableManager get batteriesRefs {
    final manager = $$BatteriesTableTableManager($_db, $_db.batteries)
        .filter((f) => f.batteryTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batteriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BatterySetsTable, List<BatterySet>>
      _batterySetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batterySets,
              aliasName: 'battery_types__id__battery_sets__battery_type_id');

  $$BatterySetsTableProcessedTableManager get batterySetsRefs {
    final manager = $$BatterySetsTableTableManager($_db, $_db.batterySets)
        .filter((f) => f.batteryTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batterySetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DevicesTable, List<Device>> _devicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.devices,
          aliasName: 'battery_types__id__devices__required_battery_type_id');

  $$DevicesTableProcessedTableManager get devicesRefs {
    final manager = $$DevicesTableTableManager($_db, $_db.devices).filter(
        (f) => f.requiredBatteryTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_devicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BatteryTypesTableFilterComposer
    extends Composer<_$AppDatabase, $BatteryTypesTable> {
  $$BatteryTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeName => $composableBuilder(
      column: $table.typeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chemistry => $composableBuilder(
      column: $table.chemistry, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultVoltage => $composableBuilder(
      column: $table.defaultVoltage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultCapacity => $composableBuilder(
      column: $table.defaultCapacity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get capacityUnit => $composableBuilder(
      column: $table.capacityUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get physicalSize => $composableBuilder(
      column: $table.physicalSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedIconSource => $composableBuilder(
      column: $table.suggestedIconSource,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedIconKey => $composableBuilder(
      column: $table.suggestedIconKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestedIconColor => $composableBuilder(
      column: $table.suggestedIconColor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get deactivatedAt => $composableBuilder(
          column: $table.deactivatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> batteriesRefs(
      Expression<bool> Function($$BatteriesTableFilterComposer f) f) {
    final $$BatteriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.batteryTypeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableFilterComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> batterySetsRefs(
      Expression<bool> Function($$BatterySetsTableFilterComposer f) f) {
    final $$BatterySetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.batteryTypeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableFilterComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> devicesRefs(
      Expression<bool> Function($$DevicesTableFilterComposer f) f) {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.requiredBatteryTypeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableFilterComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BatteryTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatteryTypesTable> {
  $$BatteryTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeName => $composableBuilder(
      column: $table.typeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chemistry => $composableBuilder(
      column: $table.chemistry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultVoltage => $composableBuilder(
      column: $table.defaultVoltage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultCapacity => $composableBuilder(
      column: $table.defaultCapacity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get capacityUnit => $composableBuilder(
      column: $table.capacityUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get physicalSize => $composableBuilder(
      column: $table.physicalSize,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedIconSource => $composableBuilder(
      column: $table.suggestedIconSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedIconKey => $composableBuilder(
      column: $table.suggestedIconKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestedIconColor => $composableBuilder(
      column: $table.suggestedIconColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deactivatedAt => $composableBuilder(
      column: $table.deactivatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$BatteryTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatteryTypesTable> {
  $$BatteryTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get typeName =>
      $composableBuilder(column: $table.typeName, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get chemistry =>
      $composableBuilder(column: $table.chemistry, builder: (column) => column);

  GeneratedColumn<double> get defaultVoltage => $composableBuilder(
      column: $table.defaultVoltage, builder: (column) => column);

  GeneratedColumn<double> get defaultCapacity => $composableBuilder(
      column: $table.defaultCapacity, builder: (column) => column);

  GeneratedColumn<String> get capacityUnit => $composableBuilder(
      column: $table.capacityUnit, builder: (column) => column);

  GeneratedColumn<String> get physicalSize => $composableBuilder(
      column: $table.physicalSize, builder: (column) => column);

  GeneratedColumn<String> get suggestedIconSource => $composableBuilder(
      column: $table.suggestedIconSource, builder: (column) => column);

  GeneratedColumn<String> get suggestedIconKey => $composableBuilder(
      column: $table.suggestedIconKey, builder: (column) => column);

  GeneratedColumn<String> get suggestedIconColor => $composableBuilder(
      column: $table.suggestedIconColor, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deactivatedAt =>
      $composableBuilder(
          column: $table.deactivatedAt, builder: (column) => column);

  Expression<T> batteriesRefs<T extends Object>(
      Expression<T> Function($$BatteriesTableAnnotationComposer a) f) {
    final $$BatteriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.batteryTypeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> batterySetsRefs<T extends Object>(
      Expression<T> Function($$BatterySetsTableAnnotationComposer a) f) {
    final $$BatterySetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.batteryTypeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableAnnotationComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> devicesRefs<T extends Object>(
      Expression<T> Function($$DevicesTableAnnotationComposer a) f) {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.requiredBatteryTypeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BatteryTypesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatteryTypesTable,
    BatteryType,
    $$BatteryTypesTableFilterComposer,
    $$BatteryTypesTableOrderingComposer,
    $$BatteryTypesTableAnnotationComposer,
    $$BatteryTypesTableCreateCompanionBuilder,
    $$BatteryTypesTableUpdateCompanionBuilder,
    (BatteryType, $$BatteryTypesTableReferences),
    BatteryType,
    PrefetchHooks Function(
        {bool batteriesRefs, bool batterySetsRefs, bool devicesRefs})> {
  $$BatteryTypesTableTableManager(_$AppDatabase db, $BatteryTypesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatteryTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatteryTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatteryTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> typeName = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> chemistry = const Value.absent(),
            Value<double?> defaultVoltage = const Value.absent(),
            Value<double?> defaultCapacity = const Value.absent(),
            Value<String?> capacityUnit = const Value.absent(),
            Value<String?> physicalSize = const Value.absent(),
            Value<String> suggestedIconSource = const Value.absent(),
            Value<String> suggestedIconKey = const Value.absent(),
            Value<String> suggestedIconColor = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
          }) =>
              BatteryTypesCompanion(
            id: id,
            uuid: uuid,
            typeName: typeName,
            description: description,
            chemistry: chemistry,
            defaultVoltage: defaultVoltage,
            defaultCapacity: defaultCapacity,
            capacityUnit: capacityUnit,
            physicalSize: physicalSize,
            suggestedIconSource: suggestedIconSource,
            suggestedIconKey: suggestedIconKey,
            suggestedIconColor: suggestedIconColor,
            notes: notes,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String typeName,
            Value<String?> description = const Value.absent(),
            Value<String?> chemistry = const Value.absent(),
            Value<double?> defaultVoltage = const Value.absent(),
            Value<double?> defaultCapacity = const Value.absent(),
            Value<String?> capacityUnit = const Value.absent(),
            Value<String?> physicalSize = const Value.absent(),
            Value<String> suggestedIconSource = const Value.absent(),
            Value<String> suggestedIconKey = const Value.absent(),
            Value<String> suggestedIconColor = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
          }) =>
              BatteryTypesCompanion.insert(
            id: id,
            uuid: uuid,
            typeName: typeName,
            description: description,
            chemistry: chemistry,
            defaultVoltage: defaultVoltage,
            defaultCapacity: defaultCapacity,
            capacityUnit: capacityUnit,
            physicalSize: physicalSize,
            suggestedIconSource: suggestedIconSource,
            suggestedIconKey: suggestedIconKey,
            suggestedIconColor: suggestedIconColor,
            notes: notes,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BatteryTypesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {batteriesRefs = false,
              batterySetsRefs = false,
              devicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (batteriesRefs) db.batteries,
                if (batterySetsRefs) db.batterySets,
                if (devicesRefs) db.devices
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (batteriesRefs)
                    await $_getPrefetchedData<BatteryType, $BatteryTypesTable,
                            Battery>(
                        currentTable: table,
                        referencedTable: $$BatteryTypesTableReferences
                            ._batteriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteryTypesTableReferences(db, table, p0)
                                .batteriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batteryTypeId == item.id),
                        typedResults: items),
                  if (batterySetsRefs)
                    await $_getPrefetchedData<BatteryType, $BatteryTypesTable,
                            BatterySet>(
                        currentTable: table,
                        referencedTable: $$BatteryTypesTableReferences
                            ._batterySetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteryTypesTableReferences(db, table, p0)
                                .batterySetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batteryTypeId == item.id),
                        typedResults: items),
                  if (devicesRefs)
                    await $_getPrefetchedData<BatteryType, $BatteryTypesTable,
                            Device>(
                        currentTable: table,
                        referencedTable:
                            $$BatteryTypesTableReferences._devicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteryTypesTableReferences(db, table, p0)
                                .devicesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.requiredBatteryTypeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BatteryTypesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BatteryTypesTable,
    BatteryType,
    $$BatteryTypesTableFilterComposer,
    $$BatteryTypesTableOrderingComposer,
    $$BatteryTypesTableAnnotationComposer,
    $$BatteryTypesTableCreateCompanionBuilder,
    $$BatteryTypesTableUpdateCompanionBuilder,
    (BatteryType, $$BatteryTypesTableReferences),
    BatteryType,
    PrefetchHooks Function(
        {bool batteriesRefs, bool batterySetsRefs, bool devicesRefs})>;
typedef $$BatteryBatchesTableCreateCompanionBuilder = BatteryBatchesCompanion
    Function({
  Value<int> id,
  required String uuid,
  required String batchCode,
  Value<String?> description,
  Value<DateTime?> purchaseDate,
  Value<String?> purchaseLocation,
  Value<double?> totalPurchasePrice,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
});
typedef $$BatteryBatchesTableUpdateCompanionBuilder = BatteryBatchesCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> batchCode,
  Value<String?> description,
  Value<DateTime?> purchaseDate,
  Value<String?> purchaseLocation,
  Value<double?> totalPurchasePrice,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
});

final class $$BatteryBatchesTableReferences
    extends BaseReferences<_$AppDatabase, $BatteryBatchesTable, BatteryBatche> {
  $$BatteryBatchesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BatteriesTable, List<Battery>>
      _batteriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batteries,
              aliasName: 'battery_batches__id__batteries__batch_id');

  $$BatteriesTableProcessedTableManager get batteriesRefs {
    final manager = $$BatteriesTableTableManager($_db, $_db.batteries)
        .filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batteriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BatteryBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatteryBatchesTable> {
  $$BatteryBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchCode => $composableBuilder(
      column: $table.batchCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get purchaseDate => $composableBuilder(
          column: $table.purchaseDate,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get purchaseLocation => $composableBuilder(
      column: $table.purchaseLocation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPurchasePrice => $composableBuilder(
      column: $table.totalPurchasePrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> batteriesRefs(
      Expression<bool> Function($$BatteriesTableFilterComposer f) f) {
    final $$BatteriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.batchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableFilterComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BatteryBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatteryBatchesTable> {
  $$BatteryBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchCode => $composableBuilder(
      column: $table.batchCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseLocation => $composableBuilder(
      column: $table.purchaseLocation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPurchasePrice => $composableBuilder(
      column: $table.totalPurchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));
}

class $$BatteryBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatteryBatchesTable> {
  $$BatteryBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get batchCode =>
      $composableBuilder(column: $table.batchCode, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get purchaseDate =>
      $composableBuilder(
          column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<String> get purchaseLocation => $composableBuilder(
      column: $table.purchaseLocation, builder: (column) => column);

  GeneratedColumn<double> get totalPurchasePrice => $composableBuilder(
      column: $table.totalPurchasePrice, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  Expression<T> batteriesRefs<T extends Object>(
      Expression<T> Function($$BatteriesTableAnnotationComposer a) f) {
    final $$BatteriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.batchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BatteryBatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatteryBatchesTable,
    BatteryBatche,
    $$BatteryBatchesTableFilterComposer,
    $$BatteryBatchesTableOrderingComposer,
    $$BatteryBatchesTableAnnotationComposer,
    $$BatteryBatchesTableCreateCompanionBuilder,
    $$BatteryBatchesTableUpdateCompanionBuilder,
    (BatteryBatche, $$BatteryBatchesTableReferences),
    BatteryBatche,
    PrefetchHooks Function({bool batteriesRefs})> {
  $$BatteryBatchesTableTableManager(
      _$AppDatabase db, $BatteryBatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatteryBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatteryBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatteryBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> batchCode = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<String?> purchaseLocation = const Value.absent(),
            Value<double?> totalPurchasePrice = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
          }) =>
              BatteryBatchesCompanion(
            id: id,
            uuid: uuid,
            batchCode: batchCode,
            description: description,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            totalPurchasePrice: totalPurchasePrice,
            notes: notes,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String batchCode,
            Value<String?> description = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<String?> purchaseLocation = const Value.absent(),
            Value<double?> totalPurchasePrice = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
          }) =>
              BatteryBatchesCompanion.insert(
            id: id,
            uuid: uuid,
            batchCode: batchCode,
            description: description,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            totalPurchasePrice: totalPurchasePrice,
            notes: notes,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BatteryBatchesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({batteriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (batteriesRefs) db.batteries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (batteriesRefs)
                    await $_getPrefetchedData<BatteryBatche,
                            $BatteryBatchesTable, Battery>(
                        currentTable: table,
                        referencedTable: $$BatteryBatchesTableReferences
                            ._batteriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteryBatchesTableReferences(db, table, p0)
                                .batteriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.batchId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BatteryBatchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BatteryBatchesTable,
    BatteryBatche,
    $$BatteryBatchesTableFilterComposer,
    $$BatteryBatchesTableOrderingComposer,
    $$BatteryBatchesTableAnnotationComposer,
    $$BatteryBatchesTableCreateCompanionBuilder,
    $$BatteryBatchesTableUpdateCompanionBuilder,
    (BatteryBatche, $$BatteryBatchesTableReferences),
    BatteryBatche,
    PrefetchHooks Function({bool batteriesRefs})>;
typedef $$BatteriesTableCreateCompanionBuilder = BatteriesCompanion Function({
  Value<int> id,
  required String uuid,
  required String userBatteryId,
  Value<String?> name,
  Value<int?> batteryTypeId,
  Value<int?> batchId,
  Value<String?> manufacturer,
  Value<String?> model,
  Value<String?> serialNumber,
  Value<String?> customLabel,
  Value<String?> chemistry,
  Value<double?> nominalVoltage,
  Value<double?> capacity,
  Value<String?> capacityUnit,
  Value<bool> rechargeable,
  Value<DateTime?> purchaseDate,
  Value<String?> purchaseLocation,
  Value<double?> purchasePrice,
  Value<double?> totalPackagePrice,
  Value<double?> perBatteryPrice,
  Value<DateTime?> warrantyExpiration,
  Value<String> status,
  Value<String> condition,
  Value<String?> conditionNote,
  Value<String?> notes,
  Value<String> iconSource,
  Value<String> iconKey,
  Value<String> iconColor,
  Value<String> preferredPrimaryVisual,
  Value<int?> estimatedChargePercent,
  Value<DateTime?> retiredAt,
  Value<String?> retirementReason,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deletedAt,
});
typedef $$BatteriesTableUpdateCompanionBuilder = BatteriesCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> userBatteryId,
  Value<String?> name,
  Value<int?> batteryTypeId,
  Value<int?> batchId,
  Value<String?> manufacturer,
  Value<String?> model,
  Value<String?> serialNumber,
  Value<String?> customLabel,
  Value<String?> chemistry,
  Value<double?> nominalVoltage,
  Value<double?> capacity,
  Value<String?> capacityUnit,
  Value<bool> rechargeable,
  Value<DateTime?> purchaseDate,
  Value<String?> purchaseLocation,
  Value<double?> purchasePrice,
  Value<double?> totalPackagePrice,
  Value<double?> perBatteryPrice,
  Value<DateTime?> warrantyExpiration,
  Value<String> status,
  Value<String> condition,
  Value<String?> conditionNote,
  Value<String?> notes,
  Value<String> iconSource,
  Value<String> iconKey,
  Value<String> iconColor,
  Value<String> preferredPrimaryVisual,
  Value<int?> estimatedChargePercent,
  Value<DateTime?> retiredAt,
  Value<String?> retirementReason,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deletedAt,
});

final class $$BatteriesTableReferences
    extends BaseReferences<_$AppDatabase, $BatteriesTable, Battery> {
  $$BatteriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BatteryTypesTable _batteryTypeIdTable(_$AppDatabase db) =>
      db.batteryTypes
          .createAlias('batteries__battery_type_id__battery_types__id');

  $$BatteryTypesTableProcessedTableManager? get batteryTypeId {
    final $_column = $_itemColumn<int>('battery_type_id');
    if ($_column == null) return null;
    final manager = $$BatteryTypesTableTableManager($_db, $_db.batteryTypes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batteryTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BatteryBatchesTable _batchIdTable(_$AppDatabase db) =>
      db.batteryBatches.createAlias('batteries__batch_id__battery_batches__id');

  $$BatteryBatchesTableProcessedTableManager? get batchId {
    final $_column = $_itemColumn<int>('batch_id');
    if ($_column == null) return null;
    final manager = $$BatteryBatchesTableTableManager($_db, $_db.batteryBatches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BatterySetMembershipsTable,
      List<BatterySetMembership>> _batterySetMembershipsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.batterySetMemberships,
          aliasName: 'batteries__id__battery_set_memberships__battery_id');

  $$BatterySetMembershipsTableProcessedTableManager
      get batterySetMembershipsRefs {
    final manager = $$BatterySetMembershipsTableTableManager(
            $_db, $_db.batterySetMemberships)
        .filter((f) => f.batteryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_batterySetMembershipsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AssignmentsTable, List<Assignment>>
      _assignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.assignments,
              aliasName: 'batteries__id__assignments__battery_id');

  $$AssignmentsTableProcessedTableManager get assignmentsRefs {
    final manager = $$AssignmentsTableTableManager($_db, $_db.assignments)
        .filter((f) => f.batteryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ChargeRecordsTable, List<ChargeRecord>>
      _chargeRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.chargeRecords,
              aliasName: 'batteries__id__charge_records__battery_id');

  $$ChargeRecordsTableProcessedTableManager get chargeRecordsRefs {
    final manager = $$ChargeRecordsTableTableManager($_db, $_db.chargeRecords)
        .filter((f) => f.batteryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chargeRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BatteryPhotosTable, List<BatteryPhoto>>
      _batteryPhotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batteryPhotos,
              aliasName: 'batteries__id__battery_photos__battery_id');

  $$BatteryPhotosTableProcessedTableManager get batteryPhotosRefs {
    final manager = $$BatteryPhotosTableTableManager($_db, $_db.batteryPhotos)
        .filter((f) => f.batteryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batteryPhotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BatteryTagsTable, List<BatteryTag>>
      _batteryTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batteryTags,
              aliasName: 'batteries__id__battery_tags__battery_id');

  $$BatteryTagsTableProcessedTableManager get batteryTagsRefs {
    final manager = $$BatteryTagsTableTableManager($_db, $_db.batteryTags)
        .filter((f) => f.batteryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batteryTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BatteriesTableFilterComposer
    extends Composer<_$AppDatabase, $BatteriesTable> {
  $$BatteriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userBatteryId => $composableBuilder(
      column: $table.userBatteryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serialNumber => $composableBuilder(
      column: $table.serialNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customLabel => $composableBuilder(
      column: $table.customLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chemistry => $composableBuilder(
      column: $table.chemistry, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get nominalVoltage => $composableBuilder(
      column: $table.nominalVoltage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get capacity => $composableBuilder(
      column: $table.capacity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get capacityUnit => $composableBuilder(
      column: $table.capacityUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rechargeable => $composableBuilder(
      column: $table.rechargeable, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get purchaseDate => $composableBuilder(
          column: $table.purchaseDate,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get purchaseLocation => $composableBuilder(
      column: $table.purchaseLocation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPackagePrice => $composableBuilder(
      column: $table.totalPackagePrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get perBatteryPrice => $composableBuilder(
      column: $table.perBatteryPrice,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get warrantyExpiration => $composableBuilder(
          column: $table.warrantyExpiration,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionNote => $composableBuilder(
      column: $table.conditionNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconColor => $composableBuilder(
      column: $table.iconColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedChargePercent => $composableBuilder(
      column: $table.estimatedChargePercent,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get retiredAt =>
      $composableBuilder(
          column: $table.retiredAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get retirementReason => $composableBuilder(
      column: $table.retirementReason,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$BatteryTypesTableFilterComposer get batteryTypeId {
    final $$BatteryTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableFilterComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatteryBatchesTableFilterComposer get batchId {
    final $$BatteryBatchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchId,
        referencedTable: $db.batteryBatches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryBatchesTableFilterComposer(
              $db: $db,
              $table: $db.batteryBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> batterySetMembershipsRefs(
      Expression<bool> Function($$BatterySetMembershipsTableFilterComposer f)
          f) {
    final $$BatterySetMembershipsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.batterySetMemberships,
            getReferencedColumn: (t) => t.batteryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BatterySetMembershipsTableFilterComposer(
                  $db: $db,
                  $table: $db.batterySetMemberships,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> assignmentsRefs(
      Expression<bool> Function($$AssignmentsTableFilterComposer f) f) {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.batteryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> chargeRecordsRefs(
      Expression<bool> Function($$ChargeRecordsTableFilterComposer f) f) {
    final $$ChargeRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chargeRecords,
        getReferencedColumn: (t) => t.batteryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChargeRecordsTableFilterComposer(
              $db: $db,
              $table: $db.chargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> batteryPhotosRefs(
      Expression<bool> Function($$BatteryPhotosTableFilterComposer f) f) {
    final $$BatteryPhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteryPhotos,
        getReferencedColumn: (t) => t.batteryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryPhotosTableFilterComposer(
              $db: $db,
              $table: $db.batteryPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> batteryTagsRefs(
      Expression<bool> Function($$BatteryTagsTableFilterComposer f) f) {
    final $$BatteryTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteryTags,
        getReferencedColumn: (t) => t.batteryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTagsTableFilterComposer(
              $db: $db,
              $table: $db.batteryTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BatteriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatteriesTable> {
  $$BatteriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userBatteryId => $composableBuilder(
      column: $table.userBatteryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serialNumber => $composableBuilder(
      column: $table.serialNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customLabel => $composableBuilder(
      column: $table.customLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chemistry => $composableBuilder(
      column: $table.chemistry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get nominalVoltage => $composableBuilder(
      column: $table.nominalVoltage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get capacity => $composableBuilder(
      column: $table.capacity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get capacityUnit => $composableBuilder(
      column: $table.capacityUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rechargeable => $composableBuilder(
      column: $table.rechargeable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purchaseLocation => $composableBuilder(
      column: $table.purchaseLocation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPackagePrice => $composableBuilder(
      column: $table.totalPackagePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get perBatteryPrice => $composableBuilder(
      column: $table.perBatteryPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warrantyExpiration => $composableBuilder(
      column: $table.warrantyExpiration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionNote => $composableBuilder(
      column: $table.conditionNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconColor => $composableBuilder(
      column: $table.iconColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedChargePercent => $composableBuilder(
      column: $table.estimatedChargePercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get retiredAt => $composableBuilder(
      column: $table.retiredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get retirementReason => $composableBuilder(
      column: $table.retirementReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$BatteryTypesTableOrderingComposer get batteryTypeId {
    final $$BatteryTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableOrderingComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatteryBatchesTableOrderingComposer get batchId {
    final $$BatteryBatchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchId,
        referencedTable: $db.batteryBatches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryBatchesTableOrderingComposer(
              $db: $db,
              $table: $db.batteryBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatteriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatteriesTable> {
  $$BatteriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get userBatteryId => $composableBuilder(
      column: $table.userBatteryId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
      column: $table.serialNumber, builder: (column) => column);

  GeneratedColumn<String> get customLabel => $composableBuilder(
      column: $table.customLabel, builder: (column) => column);

  GeneratedColumn<String> get chemistry =>
      $composableBuilder(column: $table.chemistry, builder: (column) => column);

  GeneratedColumn<double> get nominalVoltage => $composableBuilder(
      column: $table.nominalVoltage, builder: (column) => column);

  GeneratedColumn<double> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get capacityUnit => $composableBuilder(
      column: $table.capacityUnit, builder: (column) => column);

  GeneratedColumn<bool> get rechargeable => $composableBuilder(
      column: $table.rechargeable, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get purchaseDate =>
      $composableBuilder(
          column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<String> get purchaseLocation => $composableBuilder(
      column: $table.purchaseLocation, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
      column: $table.purchasePrice, builder: (column) => column);

  GeneratedColumn<double> get totalPackagePrice => $composableBuilder(
      column: $table.totalPackagePrice, builder: (column) => column);

  GeneratedColumn<double> get perBatteryPrice => $composableBuilder(
      column: $table.perBatteryPrice, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get warrantyExpiration =>
      $composableBuilder(
          column: $table.warrantyExpiration, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get conditionNote => $composableBuilder(
      column: $table.conditionNote, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get iconColor =>
      $composableBuilder(column: $table.iconColor, builder: (column) => column);

  GeneratedColumn<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual, builder: (column) => column);

  GeneratedColumn<int> get estimatedChargePercent => $composableBuilder(
      column: $table.estimatedChargePercent, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get retiredAt =>
      $composableBuilder(column: $table.retiredAt, builder: (column) => column);

  GeneratedColumn<String> get retirementReason => $composableBuilder(
      column: $table.retirementReason, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$BatteryTypesTableAnnotationComposer get batteryTypeId {
    final $$BatteryTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatteryBatchesTableAnnotationComposer get batchId {
    final $$BatteryBatchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batchId,
        referencedTable: $db.batteryBatches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryBatchesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteryBatches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> batterySetMembershipsRefs<T extends Object>(
      Expression<T> Function($$BatterySetMembershipsTableAnnotationComposer a)
          f) {
    final $$BatterySetMembershipsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.batterySetMemberships,
            getReferencedColumn: (t) => t.batteryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BatterySetMembershipsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.batterySetMemberships,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> assignmentsRefs<T extends Object>(
      Expression<T> Function($$AssignmentsTableAnnotationComposer a) f) {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.batteryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> chargeRecordsRefs<T extends Object>(
      Expression<T> Function($$ChargeRecordsTableAnnotationComposer a) f) {
    final $$ChargeRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chargeRecords,
        getReferencedColumn: (t) => t.batteryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChargeRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.chargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> batteryPhotosRefs<T extends Object>(
      Expression<T> Function($$BatteryPhotosTableAnnotationComposer a) f) {
    final $$BatteryPhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteryPhotos,
        getReferencedColumn: (t) => t.batteryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryPhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.batteryPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> batteryTagsRefs<T extends Object>(
      Expression<T> Function($$BatteryTagsTableAnnotationComposer a) f) {
    final $$BatteryTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteryTags,
        getReferencedColumn: (t) => t.batteryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.batteryTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BatteriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatteriesTable,
    Battery,
    $$BatteriesTableFilterComposer,
    $$BatteriesTableOrderingComposer,
    $$BatteriesTableAnnotationComposer,
    $$BatteriesTableCreateCompanionBuilder,
    $$BatteriesTableUpdateCompanionBuilder,
    (Battery, $$BatteriesTableReferences),
    Battery,
    PrefetchHooks Function(
        {bool batteryTypeId,
        bool batchId,
        bool batterySetMembershipsRefs,
        bool assignmentsRefs,
        bool chargeRecordsRefs,
        bool batteryPhotosRefs,
        bool batteryTagsRefs})> {
  $$BatteriesTableTableManager(_$AppDatabase db, $BatteriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatteriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatteriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatteriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> userBatteryId = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int?> batteryTypeId = const Value.absent(),
            Value<int?> batchId = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> model = const Value.absent(),
            Value<String?> serialNumber = const Value.absent(),
            Value<String?> customLabel = const Value.absent(),
            Value<String?> chemistry = const Value.absent(),
            Value<double?> nominalVoltage = const Value.absent(),
            Value<double?> capacity = const Value.absent(),
            Value<String?> capacityUnit = const Value.absent(),
            Value<bool> rechargeable = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<String?> purchaseLocation = const Value.absent(),
            Value<double?> purchasePrice = const Value.absent(),
            Value<double?> totalPackagePrice = const Value.absent(),
            Value<double?> perBatteryPrice = const Value.absent(),
            Value<DateTime?> warrantyExpiration = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> condition = const Value.absent(),
            Value<String?> conditionNote = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> iconSource = const Value.absent(),
            Value<String> iconKey = const Value.absent(),
            Value<String> iconColor = const Value.absent(),
            Value<String> preferredPrimaryVisual = const Value.absent(),
            Value<int?> estimatedChargePercent = const Value.absent(),
            Value<DateTime?> retiredAt = const Value.absent(),
            Value<String?> retirementReason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              BatteriesCompanion(
            id: id,
            uuid: uuid,
            userBatteryId: userBatteryId,
            name: name,
            batteryTypeId: batteryTypeId,
            batchId: batchId,
            manufacturer: manufacturer,
            model: model,
            serialNumber: serialNumber,
            customLabel: customLabel,
            chemistry: chemistry,
            nominalVoltage: nominalVoltage,
            capacity: capacity,
            capacityUnit: capacityUnit,
            rechargeable: rechargeable,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            purchasePrice: purchasePrice,
            totalPackagePrice: totalPackagePrice,
            perBatteryPrice: perBatteryPrice,
            warrantyExpiration: warrantyExpiration,
            status: status,
            condition: condition,
            conditionNote: conditionNote,
            notes: notes,
            iconSource: iconSource,
            iconKey: iconKey,
            iconColor: iconColor,
            preferredPrimaryVisual: preferredPrimaryVisual,
            estimatedChargePercent: estimatedChargePercent,
            retiredAt: retiredAt,
            retirementReason: retirementReason,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String userBatteryId,
            Value<String?> name = const Value.absent(),
            Value<int?> batteryTypeId = const Value.absent(),
            Value<int?> batchId = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> model = const Value.absent(),
            Value<String?> serialNumber = const Value.absent(),
            Value<String?> customLabel = const Value.absent(),
            Value<String?> chemistry = const Value.absent(),
            Value<double?> nominalVoltage = const Value.absent(),
            Value<double?> capacity = const Value.absent(),
            Value<String?> capacityUnit = const Value.absent(),
            Value<bool> rechargeable = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<String?> purchaseLocation = const Value.absent(),
            Value<double?> purchasePrice = const Value.absent(),
            Value<double?> totalPackagePrice = const Value.absent(),
            Value<double?> perBatteryPrice = const Value.absent(),
            Value<DateTime?> warrantyExpiration = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> condition = const Value.absent(),
            Value<String?> conditionNote = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> iconSource = const Value.absent(),
            Value<String> iconKey = const Value.absent(),
            Value<String> iconColor = const Value.absent(),
            Value<String> preferredPrimaryVisual = const Value.absent(),
            Value<int?> estimatedChargePercent = const Value.absent(),
            Value<DateTime?> retiredAt = const Value.absent(),
            Value<String?> retirementReason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              BatteriesCompanion.insert(
            id: id,
            uuid: uuid,
            userBatteryId: userBatteryId,
            name: name,
            batteryTypeId: batteryTypeId,
            batchId: batchId,
            manufacturer: manufacturer,
            model: model,
            serialNumber: serialNumber,
            customLabel: customLabel,
            chemistry: chemistry,
            nominalVoltage: nominalVoltage,
            capacity: capacity,
            capacityUnit: capacityUnit,
            rechargeable: rechargeable,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            purchasePrice: purchasePrice,
            totalPackagePrice: totalPackagePrice,
            perBatteryPrice: perBatteryPrice,
            warrantyExpiration: warrantyExpiration,
            status: status,
            condition: condition,
            conditionNote: conditionNote,
            notes: notes,
            iconSource: iconSource,
            iconKey: iconKey,
            iconColor: iconColor,
            preferredPrimaryVisual: preferredPrimaryVisual,
            estimatedChargePercent: estimatedChargePercent,
            retiredAt: retiredAt,
            retirementReason: retirementReason,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BatteriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {batteryTypeId = false,
              batchId = false,
              batterySetMembershipsRefs = false,
              assignmentsRefs = false,
              chargeRecordsRefs = false,
              batteryPhotosRefs = false,
              batteryTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (batterySetMembershipsRefs) db.batterySetMemberships,
                if (assignmentsRefs) db.assignments,
                if (chargeRecordsRefs) db.chargeRecords,
                if (batteryPhotosRefs) db.batteryPhotos,
                if (batteryTagsRefs) db.batteryTags
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batteryTypeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batteryTypeId,
                    referencedTable:
                        $$BatteriesTableReferences._batteryTypeIdTable(db),
                    referencedColumn:
                        $$BatteriesTableReferences._batteryTypeIdTable(db).id,
                  ) as T;
                }
                if (batchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batchId,
                    referencedTable:
                        $$BatteriesTableReferences._batchIdTable(db),
                    referencedColumn:
                        $$BatteriesTableReferences._batchIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (batterySetMembershipsRefs)
                    await $_getPrefetchedData<Battery, $BatteriesTable,
                            BatterySetMembership>(
                        currentTable: table,
                        referencedTable: $$BatteriesTableReferences
                            ._batterySetMembershipsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteriesTableReferences(db, table, p0)
                                .batterySetMembershipsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batteryId == item.id),
                        typedResults: items),
                  if (assignmentsRefs)
                    await $_getPrefetchedData<Battery, $BatteriesTable,
                            Assignment>(
                        currentTable: table,
                        referencedTable: $$BatteriesTableReferences
                            ._assignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteriesTableReferences(db, table, p0)
                                .assignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batteryId == item.id),
                        typedResults: items),
                  if (chargeRecordsRefs)
                    await $_getPrefetchedData<Battery, $BatteriesTable,
                            ChargeRecord>(
                        currentTable: table,
                        referencedTable: $$BatteriesTableReferences
                            ._chargeRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteriesTableReferences(db, table, p0)
                                .chargeRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batteryId == item.id),
                        typedResults: items),
                  if (batteryPhotosRefs)
                    await $_getPrefetchedData<Battery, $BatteriesTable,
                            BatteryPhoto>(
                        currentTable: table,
                        referencedTable: $$BatteriesTableReferences
                            ._batteryPhotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteriesTableReferences(db, table, p0)
                                .batteryPhotosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batteryId == item.id),
                        typedResults: items),
                  if (batteryTagsRefs)
                    await $_getPrefetchedData<Battery, $BatteriesTable,
                            BatteryTag>(
                        currentTable: table,
                        referencedTable: $$BatteriesTableReferences
                            ._batteryTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatteriesTableReferences(db, table, p0)
                                .batteryTagsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batteryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BatteriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BatteriesTable,
    Battery,
    $$BatteriesTableFilterComposer,
    $$BatteriesTableOrderingComposer,
    $$BatteriesTableAnnotationComposer,
    $$BatteriesTableCreateCompanionBuilder,
    $$BatteriesTableUpdateCompanionBuilder,
    (Battery, $$BatteriesTableReferences),
    Battery,
    PrefetchHooks Function(
        {bool batteryTypeId,
        bool batchId,
        bool batterySetMembershipsRefs,
        bool assignmentsRefs,
        bool chargeRecordsRefs,
        bool batteryPhotosRefs,
        bool batteryTagsRefs})>;
typedef $$BatterySetsTableCreateCompanionBuilder = BatterySetsCompanion
    Function({
  Value<int> id,
  required String uuid,
  required String userSetId,
  required String name,
  Value<int?> batteryTypeId,
  Value<String?> description,
  Value<String?> notes,
  Value<String> iconSource,
  Value<String> iconKey,
  Value<String> iconColor,
  Value<String> preferredPrimaryVisual,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$BatterySetsTableUpdateCompanionBuilder = BatterySetsCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> userSetId,
  Value<String> name,
  Value<int?> batteryTypeId,
  Value<String?> description,
  Value<String?> notes,
  Value<String> iconSource,
  Value<String> iconKey,
  Value<String> iconColor,
  Value<String> preferredPrimaryVisual,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
  Value<DateTime?> deletedAt,
});

final class $$BatterySetsTableReferences
    extends BaseReferences<_$AppDatabase, $BatterySetsTable, BatterySet> {
  $$BatterySetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BatteryTypesTable _batteryTypeIdTable(_$AppDatabase db) =>
      db.batteryTypes
          .createAlias('battery_sets__battery_type_id__battery_types__id');

  $$BatteryTypesTableProcessedTableManager? get batteryTypeId {
    final $_column = $_itemColumn<int>('battery_type_id');
    if ($_column == null) return null;
    final manager = $$BatteryTypesTableTableManager($_db, $_db.batteryTypes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batteryTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BatterySetMembershipsTable,
      List<BatterySetMembership>> _batterySetMembershipsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.batterySetMemberships,
          aliasName:
              'battery_sets__id__battery_set_memberships__battery_set_id');

  $$BatterySetMembershipsTableProcessedTableManager
      get batterySetMembershipsRefs {
    final manager = $$BatterySetMembershipsTableTableManager(
            $_db, $_db.batterySetMemberships)
        .filter((f) => f.batterySetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_batterySetMembershipsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AssignmentsTable, List<Assignment>>
      _assignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.assignments,
              aliasName: 'battery_sets__id__assignments__battery_set_id');

  $$AssignmentsTableProcessedTableManager get assignmentsRefs {
    final manager = $$AssignmentsTableTableManager($_db, $_db.assignments)
        .filter((f) => f.batterySetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SetChargeRecordsTable, List<SetChargeRecord>>
      _setChargeRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.setChargeRecords,
              aliasName:
                  'battery_sets__id__set_charge_records__battery_set_id');

  $$SetChargeRecordsTableProcessedTableManager get setChargeRecordsRefs {
    final manager = $$SetChargeRecordsTableTableManager(
            $_db, $_db.setChargeRecords)
        .filter((f) => f.batterySetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_setChargeRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BatterySetPhotosTable, List<BatterySetPhoto>>
      _batterySetPhotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batterySetPhotos,
              aliasName:
                  'battery_sets__id__battery_set_photos__battery_set_id');

  $$BatterySetPhotosTableProcessedTableManager get batterySetPhotosRefs {
    final manager = $$BatterySetPhotosTableTableManager(
            $_db, $_db.batterySetPhotos)
        .filter((f) => f.batterySetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_batterySetPhotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BatterySetsTableFilterComposer
    extends Composer<_$AppDatabase, $BatterySetsTable> {
  $$BatterySetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userSetId => $composableBuilder(
      column: $table.userSetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconColor => $composableBuilder(
      column: $table.iconColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get deactivatedAt => $composableBuilder(
          column: $table.deactivatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$BatteryTypesTableFilterComposer get batteryTypeId {
    final $$BatteryTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableFilterComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> batterySetMembershipsRefs(
      Expression<bool> Function($$BatterySetMembershipsTableFilterComposer f)
          f) {
    final $$BatterySetMembershipsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.batterySetMemberships,
            getReferencedColumn: (t) => t.batterySetId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BatterySetMembershipsTableFilterComposer(
                  $db: $db,
                  $table: $db.batterySetMemberships,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> assignmentsRefs(
      Expression<bool> Function($$AssignmentsTableFilterComposer f) f) {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.batterySetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> setChargeRecordsRefs(
      Expression<bool> Function($$SetChargeRecordsTableFilterComposer f) f) {
    final $$SetChargeRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setChargeRecords,
        getReferencedColumn: (t) => t.batterySetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetChargeRecordsTableFilterComposer(
              $db: $db,
              $table: $db.setChargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> batterySetPhotosRefs(
      Expression<bool> Function($$BatterySetPhotosTableFilterComposer f) f) {
    final $$BatterySetPhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batterySetPhotos,
        getReferencedColumn: (t) => t.batterySetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetPhotosTableFilterComposer(
              $db: $db,
              $table: $db.batterySetPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BatterySetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BatterySetsTable> {
  $$BatterySetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userSetId => $composableBuilder(
      column: $table.userSetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconColor => $composableBuilder(
      column: $table.iconColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deactivatedAt => $composableBuilder(
      column: $table.deactivatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$BatteryTypesTableOrderingComposer get batteryTypeId {
    final $$BatteryTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableOrderingComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatterySetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatterySetsTable> {
  $$BatterySetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get userSetId =>
      $composableBuilder(column: $table.userSetId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get iconColor =>
      $composableBuilder(column: $table.iconColor, builder: (column) => column);

  GeneratedColumn<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deactivatedAt =>
      $composableBuilder(
          column: $table.deactivatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$BatteryTypesTableAnnotationComposer get batteryTypeId {
    final $$BatteryTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> batterySetMembershipsRefs<T extends Object>(
      Expression<T> Function($$BatterySetMembershipsTableAnnotationComposer a)
          f) {
    final $$BatterySetMembershipsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.batterySetMemberships,
            getReferencedColumn: (t) => t.batterySetId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BatterySetMembershipsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.batterySetMemberships,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> assignmentsRefs<T extends Object>(
      Expression<T> Function($$AssignmentsTableAnnotationComposer a) f) {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.batterySetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> setChargeRecordsRefs<T extends Object>(
      Expression<T> Function($$SetChargeRecordsTableAnnotationComposer a) f) {
    final $$SetChargeRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setChargeRecords,
        getReferencedColumn: (t) => t.batterySetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetChargeRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.setChargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> batterySetPhotosRefs<T extends Object>(
      Expression<T> Function($$BatterySetPhotosTableAnnotationComposer a) f) {
    final $$BatterySetPhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batterySetPhotos,
        getReferencedColumn: (t) => t.batterySetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetPhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.batterySetPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BatterySetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatterySetsTable,
    BatterySet,
    $$BatterySetsTableFilterComposer,
    $$BatterySetsTableOrderingComposer,
    $$BatterySetsTableAnnotationComposer,
    $$BatterySetsTableCreateCompanionBuilder,
    $$BatterySetsTableUpdateCompanionBuilder,
    (BatterySet, $$BatterySetsTableReferences),
    BatterySet,
    PrefetchHooks Function(
        {bool batteryTypeId,
        bool batterySetMembershipsRefs,
        bool assignmentsRefs,
        bool setChargeRecordsRefs,
        bool batterySetPhotosRefs})> {
  $$BatterySetsTableTableManager(_$AppDatabase db, $BatterySetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatterySetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatterySetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatterySetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> userSetId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> batteryTypeId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> iconSource = const Value.absent(),
            Value<String> iconKey = const Value.absent(),
            Value<String> iconColor = const Value.absent(),
            Value<String> preferredPrimaryVisual = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              BatterySetsCompanion(
            id: id,
            uuid: uuid,
            userSetId: userSetId,
            name: name,
            batteryTypeId: batteryTypeId,
            description: description,
            notes: notes,
            iconSource: iconSource,
            iconKey: iconKey,
            iconColor: iconColor,
            preferredPrimaryVisual: preferredPrimaryVisual,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String userSetId,
            required String name,
            Value<int?> batteryTypeId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> iconSource = const Value.absent(),
            Value<String> iconKey = const Value.absent(),
            Value<String> iconColor = const Value.absent(),
            Value<String> preferredPrimaryVisual = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              BatterySetsCompanion.insert(
            id: id,
            uuid: uuid,
            userSetId: userSetId,
            name: name,
            batteryTypeId: batteryTypeId,
            description: description,
            notes: notes,
            iconSource: iconSource,
            iconKey: iconKey,
            iconColor: iconColor,
            preferredPrimaryVisual: preferredPrimaryVisual,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BatterySetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {batteryTypeId = false,
              batterySetMembershipsRefs = false,
              assignmentsRefs = false,
              setChargeRecordsRefs = false,
              batterySetPhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (batterySetMembershipsRefs) db.batterySetMemberships,
                if (assignmentsRefs) db.assignments,
                if (setChargeRecordsRefs) db.setChargeRecords,
                if (batterySetPhotosRefs) db.batterySetPhotos
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batteryTypeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batteryTypeId,
                    referencedTable:
                        $$BatterySetsTableReferences._batteryTypeIdTable(db),
                    referencedColumn:
                        $$BatterySetsTableReferences._batteryTypeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (batterySetMembershipsRefs)
                    await $_getPrefetchedData<BatterySet, $BatterySetsTable,
                            BatterySetMembership>(
                        currentTable: table,
                        referencedTable: $$BatterySetsTableReferences
                            ._batterySetMembershipsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatterySetsTableReferences(db, table, p0)
                                .batterySetMembershipsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batterySetId == item.id),
                        typedResults: items),
                  if (assignmentsRefs)
                    await $_getPrefetchedData<BatterySet, $BatterySetsTable,
                            Assignment>(
                        currentTable: table,
                        referencedTable: $$BatterySetsTableReferences
                            ._assignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatterySetsTableReferences(db, table, p0)
                                .assignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batterySetId == item.id),
                        typedResults: items),
                  if (setChargeRecordsRefs)
                    await $_getPrefetchedData<BatterySet, $BatterySetsTable,
                            SetChargeRecord>(
                        currentTable: table,
                        referencedTable: $$BatterySetsTableReferences
                            ._setChargeRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatterySetsTableReferences(db, table, p0)
                                .setChargeRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batterySetId == item.id),
                        typedResults: items),
                  if (batterySetPhotosRefs)
                    await $_getPrefetchedData<BatterySet, $BatterySetsTable,
                            BatterySetPhoto>(
                        currentTable: table,
                        referencedTable: $$BatterySetsTableReferences
                            ._batterySetPhotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BatterySetsTableReferences(db, table, p0)
                                .batterySetPhotosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.batterySetId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BatterySetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BatterySetsTable,
    BatterySet,
    $$BatterySetsTableFilterComposer,
    $$BatterySetsTableOrderingComposer,
    $$BatterySetsTableAnnotationComposer,
    $$BatterySetsTableCreateCompanionBuilder,
    $$BatterySetsTableUpdateCompanionBuilder,
    (BatterySet, $$BatterySetsTableReferences),
    BatterySet,
    PrefetchHooks Function(
        {bool batteryTypeId,
        bool batterySetMembershipsRefs,
        bool assignmentsRefs,
        bool setChargeRecordsRefs,
        bool batterySetPhotosRefs})>;
typedef $$BatterySetMembershipsTableCreateCompanionBuilder
    = BatterySetMembershipsCompanion Function({
  Value<int> id,
  required String uuid,
  required int batteryId,
  required int batterySetId,
  Value<DateTime> addedAt,
  Value<DateTime?> removedAt,
  Value<String?> notes,
  required String operationUuid,
});
typedef $$BatterySetMembershipsTableUpdateCompanionBuilder
    = BatterySetMembershipsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<int> batteryId,
  Value<int> batterySetId,
  Value<DateTime> addedAt,
  Value<DateTime?> removedAt,
  Value<String?> notes,
  Value<String> operationUuid,
});

final class $$BatterySetMembershipsTableReferences extends BaseReferences<
    _$AppDatabase, $BatterySetMembershipsTable, BatterySetMembership> {
  $$BatterySetMembershipsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BatteriesTable _batteryIdTable(_$AppDatabase db) => db.batteries
      .createAlias('battery_set_memberships__battery_id__batteries__id');

  $$BatteriesTableProcessedTableManager get batteryId {
    final $_column = $_itemColumn<int>('battery_id')!;

    final manager = $$BatteriesTableTableManager($_db, $_db.batteries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batteryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BatterySetsTable _batterySetIdTable(_$AppDatabase db) => db
      .batterySets
      .createAlias('battery_set_memberships__battery_set_id__battery_sets__id');

  $$BatterySetsTableProcessedTableManager get batterySetId {
    final $_column = $_itemColumn<int>('battery_set_id')!;

    final manager = $$BatterySetsTableTableManager($_db, $_db.batterySets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batterySetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BatterySetMembershipsTableFilterComposer
    extends Composer<_$AppDatabase, $BatterySetMembershipsTable> {
  $$BatterySetMembershipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get addedAt =>
      $composableBuilder(
          column: $table.addedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get removedAt =>
      $composableBuilder(
          column: $table.removedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid, builder: (column) => ColumnFilters(column));

  $$BatteriesTableFilterComposer get batteryId {
    final $$BatteriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableFilterComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatterySetsTableFilterComposer get batterySetId {
    final $$BatterySetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableFilterComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatterySetMembershipsTableOrderingComposer
    extends Composer<_$AppDatabase, $BatterySetMembershipsTable> {
  $$BatterySetMembershipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get removedAt => $composableBuilder(
      column: $table.removedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid,
      builder: (column) => ColumnOrderings(column));

  $$BatteriesTableOrderingComposer get batteryId {
    final $$BatteriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableOrderingComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatterySetsTableOrderingComposer get batterySetId {
    final $$BatterySetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableOrderingComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatterySetMembershipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatterySetMembershipsTable> {
  $$BatterySetMembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid, builder: (column) => column);

  $$BatteriesTableAnnotationComposer get batteryId {
    final $$BatteriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatterySetsTableAnnotationComposer get batterySetId {
    final $$BatterySetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableAnnotationComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatterySetMembershipsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatterySetMembershipsTable,
    BatterySetMembership,
    $$BatterySetMembershipsTableFilterComposer,
    $$BatterySetMembershipsTableOrderingComposer,
    $$BatterySetMembershipsTableAnnotationComposer,
    $$BatterySetMembershipsTableCreateCompanionBuilder,
    $$BatterySetMembershipsTableUpdateCompanionBuilder,
    (BatterySetMembership, $$BatterySetMembershipsTableReferences),
    BatterySetMembership,
    PrefetchHooks Function({bool batteryId, bool batterySetId})> {
  $$BatterySetMembershipsTableTableManager(
      _$AppDatabase db, $BatterySetMembershipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatterySetMembershipsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$BatterySetMembershipsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatterySetMembershipsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<int> batteryId = const Value.absent(),
            Value<int> batterySetId = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<DateTime?> removedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> operationUuid = const Value.absent(),
          }) =>
              BatterySetMembershipsCompanion(
            id: id,
            uuid: uuid,
            batteryId: batteryId,
            batterySetId: batterySetId,
            addedAt: addedAt,
            removedAt: removedAt,
            notes: notes,
            operationUuid: operationUuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required int batteryId,
            required int batterySetId,
            Value<DateTime> addedAt = const Value.absent(),
            Value<DateTime?> removedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required String operationUuid,
          }) =>
              BatterySetMembershipsCompanion.insert(
            id: id,
            uuid: uuid,
            batteryId: batteryId,
            batterySetId: batterySetId,
            addedAt: addedAt,
            removedAt: removedAt,
            notes: notes,
            operationUuid: operationUuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BatterySetMembershipsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({batteryId = false, batterySetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batteryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batteryId,
                    referencedTable: $$BatterySetMembershipsTableReferences
                        ._batteryIdTable(db),
                    referencedColumn: $$BatterySetMembershipsTableReferences
                        ._batteryIdTable(db)
                        .id,
                  ) as T;
                }
                if (batterySetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batterySetId,
                    referencedTable: $$BatterySetMembershipsTableReferences
                        ._batterySetIdTable(db),
                    referencedColumn: $$BatterySetMembershipsTableReferences
                        ._batterySetIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BatterySetMembershipsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $BatterySetMembershipsTable,
        BatterySetMembership,
        $$BatterySetMembershipsTableFilterComposer,
        $$BatterySetMembershipsTableOrderingComposer,
        $$BatterySetMembershipsTableAnnotationComposer,
        $$BatterySetMembershipsTableCreateCompanionBuilder,
        $$BatterySetMembershipsTableUpdateCompanionBuilder,
        (BatterySetMembership, $$BatterySetMembershipsTableReferences),
        BatterySetMembership,
        PrefetchHooks Function({bool batteryId, bool batterySetId})>;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  required String uuid,
  required String name,
  Value<String?> category,
  Value<String?> manufacturer,
  Value<String?> model,
  Value<String?> serialNumber,
  Value<String?> location,
  Value<String?> description,
  Value<String?> notes,
  Value<int?> requiredBatteryTypeId,
  Value<int?> requiredBatteryQuantity,
  Value<double?> requiredVoltage,
  Value<String?> requirementNotes,
  Value<String> iconSource,
  Value<String> iconKey,
  Value<String> iconColor,
  Value<String> preferredPrimaryVisual,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> name,
  Value<String?> category,
  Value<String?> manufacturer,
  Value<String?> model,
  Value<String?> serialNumber,
  Value<String?> location,
  Value<String?> description,
  Value<String?> notes,
  Value<int?> requiredBatteryTypeId,
  Value<int?> requiredBatteryQuantity,
  Value<double?> requiredVoltage,
  Value<String?> requirementNotes,
  Value<String> iconSource,
  Value<String> iconKey,
  Value<String> iconColor,
  Value<String> preferredPrimaryVisual,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
  Value<DateTime?> deletedAt,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDatabase, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BatteryTypesTable _requiredBatteryTypeIdTable(_$AppDatabase db) =>
      db.batteryTypes
          .createAlias('devices__required_battery_type_id__battery_types__id');

  $$BatteryTypesTableProcessedTableManager? get requiredBatteryTypeId {
    final $_column = $_itemColumn<int>('required_battery_type_id');
    if ($_column == null) return null;
    final manager = $$BatteryTypesTableTableManager($_db, $_db.batteryTypes)
        .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_requiredBatteryTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AssignmentsTable, List<Assignment>>
      _assignmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.assignments,
              aliasName: 'devices__id__assignments__device_id');

  $$AssignmentsTableProcessedTableManager get assignmentsRefs {
    final manager = $$AssignmentsTableTableManager($_db, $_db.assignments)
        .filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DevicePhotosTable, List<DevicePhoto>>
      _devicePhotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.devicePhotos,
              aliasName: 'devices__id__device_photos__device_id');

  $$DevicePhotosTableProcessedTableManager get devicePhotosRefs {
    final manager = $$DevicePhotosTableTableManager($_db, $_db.devicePhotos)
        .filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_devicePhotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serialNumber => $composableBuilder(
      column: $table.serialNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get requiredBatteryQuantity => $composableBuilder(
      column: $table.requiredBatteryQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get requiredVoltage => $composableBuilder(
      column: $table.requiredVoltage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get requirementNotes => $composableBuilder(
      column: $table.requirementNotes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconColor => $composableBuilder(
      column: $table.iconColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get deactivatedAt => $composableBuilder(
          column: $table.deactivatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$BatteryTypesTableFilterComposer get requiredBatteryTypeId {
    final $$BatteryTypesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.requiredBatteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableFilterComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> assignmentsRefs(
      Expression<bool> Function($$AssignmentsTableFilterComposer f) f) {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.deviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> devicePhotosRefs(
      Expression<bool> Function($$DevicePhotosTableFilterComposer f) f) {
    final $$DevicePhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devicePhotos,
        getReferencedColumn: (t) => t.deviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicePhotosTableFilterComposer(
              $db: $db,
              $table: $db.devicePhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serialNumber => $composableBuilder(
      column: $table.serialNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get requiredBatteryQuantity => $composableBuilder(
      column: $table.requiredBatteryQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get requiredVoltage => $composableBuilder(
      column: $table.requiredVoltage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get requirementNotes => $composableBuilder(
      column: $table.requirementNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconKey => $composableBuilder(
      column: $table.iconKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconColor => $composableBuilder(
      column: $table.iconColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deactivatedAt => $composableBuilder(
      column: $table.deactivatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$BatteryTypesTableOrderingComposer get requiredBatteryTypeId {
    final $$BatteryTypesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.requiredBatteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableOrderingComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
      column: $table.serialNumber, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get requiredBatteryQuantity => $composableBuilder(
      column: $table.requiredBatteryQuantity, builder: (column) => column);

  GeneratedColumn<double> get requiredVoltage => $composableBuilder(
      column: $table.requiredVoltage, builder: (column) => column);

  GeneratedColumn<String> get requirementNotes => $composableBuilder(
      column: $table.requirementNotes, builder: (column) => column);

  GeneratedColumn<String> get iconSource => $composableBuilder(
      column: $table.iconSource, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get iconColor =>
      $composableBuilder(column: $table.iconColor, builder: (column) => column);

  GeneratedColumn<String> get preferredPrimaryVisual => $composableBuilder(
      column: $table.preferredPrimaryVisual, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deactivatedAt =>
      $composableBuilder(
          column: $table.deactivatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$BatteryTypesTableAnnotationComposer get requiredBatteryTypeId {
    final $$BatteryTypesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.requiredBatteryTypeId,
        referencedTable: $db.batteryTypes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTypesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteryTypes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> assignmentsRefs<T extends Object>(
      Expression<T> Function($$AssignmentsTableAnnotationComposer a) f) {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.deviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> devicePhotosRefs<T extends Object>(
      Expression<T> Function($$DevicePhotosTableAnnotationComposer a) f) {
    final $$DevicePhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devicePhotos,
        getReferencedColumn: (t) => t.deviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicePhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.devicePhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, $$DevicesTableReferences),
    Device,
    PrefetchHooks Function(
        {bool requiredBatteryTypeId,
        bool assignmentsRefs,
        bool devicePhotosRefs})> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> model = const Value.absent(),
            Value<String?> serialNumber = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> requiredBatteryTypeId = const Value.absent(),
            Value<int?> requiredBatteryQuantity = const Value.absent(),
            Value<double?> requiredVoltage = const Value.absent(),
            Value<String?> requirementNotes = const Value.absent(),
            Value<String> iconSource = const Value.absent(),
            Value<String> iconKey = const Value.absent(),
            Value<String> iconColor = const Value.absent(),
            Value<String> preferredPrimaryVisual = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            uuid: uuid,
            name: name,
            category: category,
            manufacturer: manufacturer,
            model: model,
            serialNumber: serialNumber,
            location: location,
            description: description,
            notes: notes,
            requiredBatteryTypeId: requiredBatteryTypeId,
            requiredBatteryQuantity: requiredBatteryQuantity,
            requiredVoltage: requiredVoltage,
            requirementNotes: requirementNotes,
            iconSource: iconSource,
            iconKey: iconKey,
            iconColor: iconColor,
            preferredPrimaryVisual: preferredPrimaryVisual,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String name,
            Value<String?> category = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> model = const Value.absent(),
            Value<String?> serialNumber = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> requiredBatteryTypeId = const Value.absent(),
            Value<int?> requiredBatteryQuantity = const Value.absent(),
            Value<double?> requiredVoltage = const Value.absent(),
            Value<String?> requirementNotes = const Value.absent(),
            Value<String> iconSource = const Value.absent(),
            Value<String> iconKey = const Value.absent(),
            Value<String> iconColor = const Value.absent(),
            Value<String> preferredPrimaryVisual = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            uuid: uuid,
            name: name,
            category: category,
            manufacturer: manufacturer,
            model: model,
            serialNumber: serialNumber,
            location: location,
            description: description,
            notes: notes,
            requiredBatteryTypeId: requiredBatteryTypeId,
            requiredBatteryQuantity: requiredBatteryQuantity,
            requiredVoltage: requiredVoltage,
            requirementNotes: requirementNotes,
            iconSource: iconSource,
            iconKey: iconKey,
            iconColor: iconColor,
            preferredPrimaryVisual: preferredPrimaryVisual,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DevicesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {requiredBatteryTypeId = false,
              assignmentsRefs = false,
              devicePhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assignmentsRefs) db.assignments,
                if (devicePhotosRefs) db.devicePhotos
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (requiredBatteryTypeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.requiredBatteryTypeId,
                    referencedTable: $$DevicesTableReferences
                        ._requiredBatteryTypeIdTable(db),
                    referencedColumn: $$DevicesTableReferences
                        ._requiredBatteryTypeIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assignmentsRefs)
                    await $_getPrefetchedData<Device, $DevicesTable,
                            Assignment>(
                        currentTable: table,
                        referencedTable:
                            $$DevicesTableReferences._assignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DevicesTableReferences(db, table, p0)
                                .assignmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.deviceId == item.id),
                        typedResults: items),
                  if (devicePhotosRefs)
                    await $_getPrefetchedData<Device, $DevicesTable,
                            DevicePhoto>(
                        currentTable: table,
                        referencedTable:
                            $$DevicesTableReferences._devicePhotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DevicesTableReferences(db, table, p0)
                                .devicePhotosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.deviceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, $$DevicesTableReferences),
    Device,
    PrefetchHooks Function(
        {bool requiredBatteryTypeId,
        bool assignmentsRefs,
        bool devicePhotosRefs})>;
typedef $$AssignmentsTableCreateCompanionBuilder = AssignmentsCompanion
    Function({
  Value<int> id,
  required String uuid,
  required String subjectType,
  Value<int?> batteryId,
  Value<int?> batterySetId,
  required int deviceId,
  Value<int?> sourceSetAssignmentId,
  required String operationUuid,
  Value<DateTime> assignedAt,
  Value<DateTime?> removedAt,
  Value<String?> notes,
  Value<String?> overrideReason,
});
typedef $$AssignmentsTableUpdateCompanionBuilder = AssignmentsCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> subjectType,
  Value<int?> batteryId,
  Value<int?> batterySetId,
  Value<int> deviceId,
  Value<int?> sourceSetAssignmentId,
  Value<String> operationUuid,
  Value<DateTime> assignedAt,
  Value<DateTime?> removedAt,
  Value<String?> notes,
  Value<String?> overrideReason,
});

final class $$AssignmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssignmentsTable, Assignment> {
  $$AssignmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BatteriesTable _batteryIdTable(_$AppDatabase db) =>
      db.batteries.createAlias('assignments__battery_id__batteries__id');

  $$BatteriesTableProcessedTableManager? get batteryId {
    final $_column = $_itemColumn<int>('battery_id');
    if ($_column == null) return null;
    final manager = $$BatteriesTableTableManager($_db, $_db.batteries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batteryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BatterySetsTable _batterySetIdTable(_$AppDatabase db) =>
      db.batterySets
          .createAlias('assignments__battery_set_id__battery_sets__id');

  $$BatterySetsTableProcessedTableManager? get batterySetId {
    final $_column = $_itemColumn<int>('battery_set_id');
    if ($_column == null) return null;
    final manager = $$BatterySetsTableTableManager($_db, $_db.batterySets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batterySetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DevicesTable _deviceIdTable(_$AppDatabase db) =>
      db.devices.createAlias('assignments__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $$DevicesTableTableManager($_db, $_db.devices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AssignmentsTable _sourceSetAssignmentIdTable(_$AppDatabase db) => db
      .assignments
      .createAlias('assignments__source_set_assignment_id__assignments__id');

  $$AssignmentsTableProcessedTableManager? get sourceSetAssignmentId {
    final $_column = $_itemColumn<int>('source_set_assignment_id');
    if ($_column == null) return null;
    final manager = $$AssignmentsTableTableManager($_db, $_db.assignments)
        .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_sourceSetAssignmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectType => $composableBuilder(
      column: $table.subjectType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get assignedAt =>
      $composableBuilder(
          column: $table.assignedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get removedAt =>
      $composableBuilder(
          column: $table.removedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overrideReason => $composableBuilder(
      column: $table.overrideReason,
      builder: (column) => ColumnFilters(column));

  $$BatteriesTableFilterComposer get batteryId {
    final $$BatteriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableFilterComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatterySetsTableFilterComposer get batterySetId {
    final $$BatterySetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableFilterComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableFilterComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AssignmentsTableFilterComposer get sourceSetAssignmentId {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceSetAssignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableFilterComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectType => $composableBuilder(
      column: $table.subjectType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedAt => $composableBuilder(
      column: $table.assignedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get removedAt => $composableBuilder(
      column: $table.removedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overrideReason => $composableBuilder(
      column: $table.overrideReason,
      builder: (column) => ColumnOrderings(column));

  $$BatteriesTableOrderingComposer get batteryId {
    final $$BatteriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableOrderingComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatterySetsTableOrderingComposer get batterySetId {
    final $$BatterySetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableOrderingComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableOrderingComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AssignmentsTableOrderingComposer get sourceSetAssignmentId {
    final $$AssignmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceSetAssignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableOrderingComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get subjectType => $composableBuilder(
      column: $table.subjectType, builder: (column) => column);

  GeneratedColumn<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get assignedAt =>
      $composableBuilder(
          column: $table.assignedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get overrideReason => $composableBuilder(
      column: $table.overrideReason, builder: (column) => column);

  $$BatteriesTableAnnotationComposer get batteryId {
    final $$BatteriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BatterySetsTableAnnotationComposer get batterySetId {
    final $$BatterySetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableAnnotationComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AssignmentsTableAnnotationComposer get sourceSetAssignmentId {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceSetAssignmentId,
        referencedTable: $db.assignments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssignmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assignments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    Assignment,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (Assignment, $$AssignmentsTableReferences),
    Assignment,
    PrefetchHooks Function(
        {bool batteryId,
        bool batterySetId,
        bool deviceId,
        bool sourceSetAssignmentId})> {
  $$AssignmentsTableTableManager(_$AppDatabase db, $AssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> subjectType = const Value.absent(),
            Value<int?> batteryId = const Value.absent(),
            Value<int?> batterySetId = const Value.absent(),
            Value<int> deviceId = const Value.absent(),
            Value<int?> sourceSetAssignmentId = const Value.absent(),
            Value<String> operationUuid = const Value.absent(),
            Value<DateTime> assignedAt = const Value.absent(),
            Value<DateTime?> removedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> overrideReason = const Value.absent(),
          }) =>
              AssignmentsCompanion(
            id: id,
            uuid: uuid,
            subjectType: subjectType,
            batteryId: batteryId,
            batterySetId: batterySetId,
            deviceId: deviceId,
            sourceSetAssignmentId: sourceSetAssignmentId,
            operationUuid: operationUuid,
            assignedAt: assignedAt,
            removedAt: removedAt,
            notes: notes,
            overrideReason: overrideReason,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String subjectType,
            Value<int?> batteryId = const Value.absent(),
            Value<int?> batterySetId = const Value.absent(),
            required int deviceId,
            Value<int?> sourceSetAssignmentId = const Value.absent(),
            required String operationUuid,
            Value<DateTime> assignedAt = const Value.absent(),
            Value<DateTime?> removedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> overrideReason = const Value.absent(),
          }) =>
              AssignmentsCompanion.insert(
            id: id,
            uuid: uuid,
            subjectType: subjectType,
            batteryId: batteryId,
            batterySetId: batterySetId,
            deviceId: deviceId,
            sourceSetAssignmentId: sourceSetAssignmentId,
            operationUuid: operationUuid,
            assignedAt: assignedAt,
            removedAt: removedAt,
            notes: notes,
            overrideReason: overrideReason,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AssignmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {batteryId = false,
              batterySetId = false,
              deviceId = false,
              sourceSetAssignmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batteryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batteryId,
                    referencedTable:
                        $$AssignmentsTableReferences._batteryIdTable(db),
                    referencedColumn:
                        $$AssignmentsTableReferences._batteryIdTable(db).id,
                  ) as T;
                }
                if (batterySetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batterySetId,
                    referencedTable:
                        $$AssignmentsTableReferences._batterySetIdTable(db),
                    referencedColumn:
                        $$AssignmentsTableReferences._batterySetIdTable(db).id,
                  ) as T;
                }
                if (deviceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deviceId,
                    referencedTable:
                        $$AssignmentsTableReferences._deviceIdTable(db),
                    referencedColumn:
                        $$AssignmentsTableReferences._deviceIdTable(db).id,
                  ) as T;
                }
                if (sourceSetAssignmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceSetAssignmentId,
                    referencedTable: $$AssignmentsTableReferences
                        ._sourceSetAssignmentIdTable(db),
                    referencedColumn: $$AssignmentsTableReferences
                        ._sourceSetAssignmentIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AssignmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    Assignment,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (Assignment, $$AssignmentsTableReferences),
    Assignment,
    PrefetchHooks Function(
        {bool batteryId,
        bool batterySetId,
        bool deviceId,
        bool sourceSetAssignmentId})>;
typedef $$SetChargeRecordsTableCreateCompanionBuilder
    = SetChargeRecordsCompanion Function({
  Value<int> id,
  required String uuid,
  required int batterySetId,
  Value<DateTime> chargedAt,
  Value<String?> notes,
  Value<DateTime> createdAt,
  required String operationUuid,
});
typedef $$SetChargeRecordsTableUpdateCompanionBuilder
    = SetChargeRecordsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<int> batterySetId,
  Value<DateTime> chargedAt,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<String> operationUuid,
});

final class $$SetChargeRecordsTableReferences extends BaseReferences<
    _$AppDatabase, $SetChargeRecordsTable, SetChargeRecord> {
  $$SetChargeRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BatterySetsTable _batterySetIdTable(_$AppDatabase db) =>
      db.batterySets
          .createAlias('set_charge_records__battery_set_id__battery_sets__id');

  $$BatterySetsTableProcessedTableManager get batterySetId {
    final $_column = $_itemColumn<int>('battery_set_id')!;

    final manager = $$BatterySetsTableTableManager($_db, $_db.batterySets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batterySetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ChargeRecordsTable,
      List<ChargeRecord>> _chargeRecordsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.chargeRecords,
          aliasName:
              'set_charge_records__id__charge_records__source_set_charge_id');

  $$ChargeRecordsTableProcessedTableManager get chargeRecordsRefs {
    final manager = $$ChargeRecordsTableTableManager($_db, $_db.chargeRecords)
        .filter(
            (f) => f.sourceSetChargeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chargeRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SetChargeRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SetChargeRecordsTable> {
  $$SetChargeRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get chargedAt =>
      $composableBuilder(
          column: $table.chargedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid, builder: (column) => ColumnFilters(column));

  $$BatterySetsTableFilterComposer get batterySetId {
    final $$BatterySetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableFilterComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> chargeRecordsRefs(
      Expression<bool> Function($$ChargeRecordsTableFilterComposer f) f) {
    final $$ChargeRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chargeRecords,
        getReferencedColumn: (t) => t.sourceSetChargeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChargeRecordsTableFilterComposer(
              $db: $db,
              $table: $db.chargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SetChargeRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetChargeRecordsTable> {
  $$SetChargeRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chargedAt => $composableBuilder(
      column: $table.chargedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid,
      builder: (column) => ColumnOrderings(column));

  $$BatterySetsTableOrderingComposer get batterySetId {
    final $$BatterySetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableOrderingComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SetChargeRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetChargeRecordsTable> {
  $$SetChargeRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get chargedAt =>
      $composableBuilder(column: $table.chargedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid, builder: (column) => column);

  $$BatterySetsTableAnnotationComposer get batterySetId {
    final $$BatterySetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableAnnotationComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> chargeRecordsRefs<T extends Object>(
      Expression<T> Function($$ChargeRecordsTableAnnotationComposer a) f) {
    final $$ChargeRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chargeRecords,
        getReferencedColumn: (t) => t.sourceSetChargeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChargeRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.chargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SetChargeRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SetChargeRecordsTable,
    SetChargeRecord,
    $$SetChargeRecordsTableFilterComposer,
    $$SetChargeRecordsTableOrderingComposer,
    $$SetChargeRecordsTableAnnotationComposer,
    $$SetChargeRecordsTableCreateCompanionBuilder,
    $$SetChargeRecordsTableUpdateCompanionBuilder,
    (SetChargeRecord, $$SetChargeRecordsTableReferences),
    SetChargeRecord,
    PrefetchHooks Function({bool batterySetId, bool chargeRecordsRefs})> {
  $$SetChargeRecordsTableTableManager(
      _$AppDatabase db, $SetChargeRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetChargeRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetChargeRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetChargeRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<int> batterySetId = const Value.absent(),
            Value<DateTime> chargedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> operationUuid = const Value.absent(),
          }) =>
              SetChargeRecordsCompanion(
            id: id,
            uuid: uuid,
            batterySetId: batterySetId,
            chargedAt: chargedAt,
            notes: notes,
            createdAt: createdAt,
            operationUuid: operationUuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required int batterySetId,
            Value<DateTime> chargedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            required String operationUuid,
          }) =>
              SetChargeRecordsCompanion.insert(
            id: id,
            uuid: uuid,
            batterySetId: batterySetId,
            chargedAt: chargedAt,
            notes: notes,
            createdAt: createdAt,
            operationUuid: operationUuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SetChargeRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {batterySetId = false, chargeRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (chargeRecordsRefs) db.chargeRecords
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batterySetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batterySetId,
                    referencedTable: $$SetChargeRecordsTableReferences
                        ._batterySetIdTable(db),
                    referencedColumn: $$SetChargeRecordsTableReferences
                        ._batterySetIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chargeRecordsRefs)
                    await $_getPrefetchedData<SetChargeRecord,
                            $SetChargeRecordsTable, ChargeRecord>(
                        currentTable: table,
                        referencedTable: $$SetChargeRecordsTableReferences
                            ._chargeRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SetChargeRecordsTableReferences(db, table, p0)
                                .chargeRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sourceSetChargeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SetChargeRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SetChargeRecordsTable,
    SetChargeRecord,
    $$SetChargeRecordsTableFilterComposer,
    $$SetChargeRecordsTableOrderingComposer,
    $$SetChargeRecordsTableAnnotationComposer,
    $$SetChargeRecordsTableCreateCompanionBuilder,
    $$SetChargeRecordsTableUpdateCompanionBuilder,
    (SetChargeRecord, $$SetChargeRecordsTableReferences),
    SetChargeRecord,
    PrefetchHooks Function({bool batterySetId, bool chargeRecordsRefs})>;
typedef $$ChargeRecordsTableCreateCompanionBuilder = ChargeRecordsCompanion
    Function({
  Value<int> id,
  required String uuid,
  required int batteryId,
  Value<DateTime> chargedAt,
  Value<int?> startingChargePercent,
  Value<int?> endingChargePercent,
  Value<String?> charger,
  Value<String?> notes,
  Value<int?> sourceSetChargeId,
  Value<String?> bulkOperationUuid,
  Value<DateTime> createdAt,
});
typedef $$ChargeRecordsTableUpdateCompanionBuilder = ChargeRecordsCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<int> batteryId,
  Value<DateTime> chargedAt,
  Value<int?> startingChargePercent,
  Value<int?> endingChargePercent,
  Value<String?> charger,
  Value<String?> notes,
  Value<int?> sourceSetChargeId,
  Value<String?> bulkOperationUuid,
  Value<DateTime> createdAt,
});

final class $$ChargeRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ChargeRecordsTable, ChargeRecord> {
  $$ChargeRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BatteriesTable _batteryIdTable(_$AppDatabase db) =>
      db.batteries.createAlias('charge_records__battery_id__batteries__id');

  $$BatteriesTableProcessedTableManager get batteryId {
    final $_column = $_itemColumn<int>('battery_id')!;

    final manager = $$BatteriesTableTableManager($_db, $_db.batteries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batteryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SetChargeRecordsTable _sourceSetChargeIdTable(_$AppDatabase db) =>
      db.setChargeRecords.createAlias(
          'charge_records__source_set_charge_id__set_charge_records__id');

  $$SetChargeRecordsTableProcessedTableManager? get sourceSetChargeId {
    final $_column = $_itemColumn<int>('source_set_charge_id');
    if ($_column == null) return null;
    final manager =
        $$SetChargeRecordsTableTableManager($_db, $_db.setChargeRecords)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSetChargeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ChargeRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ChargeRecordsTable> {
  $$ChargeRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get chargedAt =>
      $composableBuilder(
          column: $table.chargedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get startingChargePercent => $composableBuilder(
      column: $table.startingChargePercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endingChargePercent => $composableBuilder(
      column: $table.endingChargePercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get charger => $composableBuilder(
      column: $table.charger, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bulkOperationUuid => $composableBuilder(
      column: $table.bulkOperationUuid,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$BatteriesTableFilterComposer get batteryId {
    final $$BatteriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableFilterComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SetChargeRecordsTableFilterComposer get sourceSetChargeId {
    final $$SetChargeRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceSetChargeId,
        referencedTable: $db.setChargeRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetChargeRecordsTableFilterComposer(
              $db: $db,
              $table: $db.setChargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChargeRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChargeRecordsTable> {
  $$ChargeRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chargedAt => $composableBuilder(
      column: $table.chargedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startingChargePercent => $composableBuilder(
      column: $table.startingChargePercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endingChargePercent => $composableBuilder(
      column: $table.endingChargePercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get charger => $composableBuilder(
      column: $table.charger, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bulkOperationUuid => $composableBuilder(
      column: $table.bulkOperationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BatteriesTableOrderingComposer get batteryId {
    final $$BatteriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableOrderingComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SetChargeRecordsTableOrderingComposer get sourceSetChargeId {
    final $$SetChargeRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceSetChargeId,
        referencedTable: $db.setChargeRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetChargeRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.setChargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChargeRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChargeRecordsTable> {
  $$ChargeRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get chargedAt =>
      $composableBuilder(column: $table.chargedAt, builder: (column) => column);

  GeneratedColumn<int> get startingChargePercent => $composableBuilder(
      column: $table.startingChargePercent, builder: (column) => column);

  GeneratedColumn<int> get endingChargePercent => $composableBuilder(
      column: $table.endingChargePercent, builder: (column) => column);

  GeneratedColumn<String> get charger =>
      $composableBuilder(column: $table.charger, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get bulkOperationUuid => $composableBuilder(
      column: $table.bulkOperationUuid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BatteriesTableAnnotationComposer get batteryId {
    final $$BatteriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SetChargeRecordsTableAnnotationComposer get sourceSetChargeId {
    final $$SetChargeRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceSetChargeId,
        referencedTable: $db.setChargeRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetChargeRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.setChargeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChargeRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChargeRecordsTable,
    ChargeRecord,
    $$ChargeRecordsTableFilterComposer,
    $$ChargeRecordsTableOrderingComposer,
    $$ChargeRecordsTableAnnotationComposer,
    $$ChargeRecordsTableCreateCompanionBuilder,
    $$ChargeRecordsTableUpdateCompanionBuilder,
    (ChargeRecord, $$ChargeRecordsTableReferences),
    ChargeRecord,
    PrefetchHooks Function({bool batteryId, bool sourceSetChargeId})> {
  $$ChargeRecordsTableTableManager(_$AppDatabase db, $ChargeRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChargeRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChargeRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChargeRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<int> batteryId = const Value.absent(),
            Value<DateTime> chargedAt = const Value.absent(),
            Value<int?> startingChargePercent = const Value.absent(),
            Value<int?> endingChargePercent = const Value.absent(),
            Value<String?> charger = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> sourceSetChargeId = const Value.absent(),
            Value<String?> bulkOperationUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChargeRecordsCompanion(
            id: id,
            uuid: uuid,
            batteryId: batteryId,
            chargedAt: chargedAt,
            startingChargePercent: startingChargePercent,
            endingChargePercent: endingChargePercent,
            charger: charger,
            notes: notes,
            sourceSetChargeId: sourceSetChargeId,
            bulkOperationUuid: bulkOperationUuid,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required int batteryId,
            Value<DateTime> chargedAt = const Value.absent(),
            Value<int?> startingChargePercent = const Value.absent(),
            Value<int?> endingChargePercent = const Value.absent(),
            Value<String?> charger = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> sourceSetChargeId = const Value.absent(),
            Value<String?> bulkOperationUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChargeRecordsCompanion.insert(
            id: id,
            uuid: uuid,
            batteryId: batteryId,
            chargedAt: chargedAt,
            startingChargePercent: startingChargePercent,
            endingChargePercent: endingChargePercent,
            charger: charger,
            notes: notes,
            sourceSetChargeId: sourceSetChargeId,
            bulkOperationUuid: bulkOperationUuid,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ChargeRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {batteryId = false, sourceSetChargeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batteryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batteryId,
                    referencedTable:
                        $$ChargeRecordsTableReferences._batteryIdTable(db),
                    referencedColumn:
                        $$ChargeRecordsTableReferences._batteryIdTable(db).id,
                  ) as T;
                }
                if (sourceSetChargeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceSetChargeId,
                    referencedTable: $$ChargeRecordsTableReferences
                        ._sourceSetChargeIdTable(db),
                    referencedColumn: $$ChargeRecordsTableReferences
                        ._sourceSetChargeIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChargeRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChargeRecordsTable,
    ChargeRecord,
    $$ChargeRecordsTableFilterComposer,
    $$ChargeRecordsTableOrderingComposer,
    $$ChargeRecordsTableAnnotationComposer,
    $$ChargeRecordsTableCreateCompanionBuilder,
    $$ChargeRecordsTableUpdateCompanionBuilder,
    (ChargeRecord, $$ChargeRecordsTableReferences),
    ChargeRecord,
    PrefetchHooks Function({bool batteryId, bool sourceSetChargeId})>;
typedef $$MediaAssetsTableCreateCompanionBuilder = MediaAssetsCompanion
    Function({
  Value<int> id,
  required String uuid,
  required String relativePath,
  required String originalFilename,
  required String mimeType,
  required int byteSize,
  required String checksum,
  Value<int?> width,
  Value<int?> height,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> missingAt,
});
typedef $$MediaAssetsTableUpdateCompanionBuilder = MediaAssetsCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> relativePath,
  Value<String> originalFilename,
  Value<String> mimeType,
  Value<int> byteSize,
  Value<String> checksum,
  Value<int?> width,
  Value<int?> height,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> missingAt,
});

final class $$MediaAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaAssetsTable, MediaAsset> {
  $$MediaAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BatteryPhotosTable, List<BatteryPhoto>>
      _batteryPhotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batteryPhotos,
              aliasName: 'media_assets__id__battery_photos__media_asset_id');

  $$BatteryPhotosTableProcessedTableManager get batteryPhotosRefs {
    final manager = $$BatteryPhotosTableTableManager($_db, $_db.batteryPhotos)
        .filter((f) => f.mediaAssetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batteryPhotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BatterySetPhotosTable, List<BatterySetPhoto>>
      _batterySetPhotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batterySetPhotos,
              aliasName:
                  'media_assets__id__battery_set_photos__media_asset_id');

  $$BatterySetPhotosTableProcessedTableManager get batterySetPhotosRefs {
    final manager = $$BatterySetPhotosTableTableManager(
            $_db, $_db.batterySetPhotos)
        .filter((f) => f.mediaAssetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_batterySetPhotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DevicePhotosTable, List<DevicePhoto>>
      _devicePhotosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.devicePhotos,
              aliasName: 'media_assets__id__device_photos__media_asset_id');

  $$DevicePhotosTableProcessedTableManager get devicePhotosRefs {
    final manager = $$DevicePhotosTableTableManager($_db, $_db.devicePhotos)
        .filter((f) => f.mediaAssetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_devicePhotosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MediaAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalFilename => $composableBuilder(
      column: $table.originalFilename,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get byteSize => $composableBuilder(
      column: $table.byteSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get missingAt =>
      $composableBuilder(
          column: $table.missingAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> batteryPhotosRefs(
      Expression<bool> Function($$BatteryPhotosTableFilterComposer f) f) {
    final $$BatteryPhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteryPhotos,
        getReferencedColumn: (t) => t.mediaAssetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryPhotosTableFilterComposer(
              $db: $db,
              $table: $db.batteryPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> batterySetPhotosRefs(
      Expression<bool> Function($$BatterySetPhotosTableFilterComposer f) f) {
    final $$BatterySetPhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batterySetPhotos,
        getReferencedColumn: (t) => t.mediaAssetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetPhotosTableFilterComposer(
              $db: $db,
              $table: $db.batterySetPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> devicePhotosRefs(
      Expression<bool> Function($$DevicePhotosTableFilterComposer f) f) {
    final $$DevicePhotosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devicePhotos,
        getReferencedColumn: (t) => t.mediaAssetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicePhotosTableFilterComposer(
              $db: $db,
              $table: $db.devicePhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MediaAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relativePath => $composableBuilder(
      column: $table.relativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalFilename => $composableBuilder(
      column: $table.originalFilename,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get byteSize => $composableBuilder(
      column: $table.byteSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get missingAt => $composableBuilder(
      column: $table.missingAt, builder: (column) => ColumnOrderings(column));
}

class $$MediaAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => column);

  GeneratedColumn<String> get originalFilename => $composableBuilder(
      column: $table.originalFilename, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get missingAt =>
      $composableBuilder(column: $table.missingAt, builder: (column) => column);

  Expression<T> batteryPhotosRefs<T extends Object>(
      Expression<T> Function($$BatteryPhotosTableAnnotationComposer a) f) {
    final $$BatteryPhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteryPhotos,
        getReferencedColumn: (t) => t.mediaAssetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryPhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.batteryPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> batterySetPhotosRefs<T extends Object>(
      Expression<T> Function($$BatterySetPhotosTableAnnotationComposer a) f) {
    final $$BatterySetPhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batterySetPhotos,
        getReferencedColumn: (t) => t.mediaAssetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetPhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.batterySetPhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> devicePhotosRefs<T extends Object>(
      Expression<T> Function($$DevicePhotosTableAnnotationComposer a) f) {
    final $$DevicePhotosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devicePhotos,
        getReferencedColumn: (t) => t.mediaAssetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicePhotosTableAnnotationComposer(
              $db: $db,
              $table: $db.devicePhotos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MediaAssetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaAssetsTable,
    MediaAsset,
    $$MediaAssetsTableFilterComposer,
    $$MediaAssetsTableOrderingComposer,
    $$MediaAssetsTableAnnotationComposer,
    $$MediaAssetsTableCreateCompanionBuilder,
    $$MediaAssetsTableUpdateCompanionBuilder,
    (MediaAsset, $$MediaAssetsTableReferences),
    MediaAsset,
    PrefetchHooks Function(
        {bool batteryPhotosRefs,
        bool batterySetPhotosRefs,
        bool devicePhotosRefs})> {
  $$MediaAssetsTableTableManager(_$AppDatabase db, $MediaAssetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> relativePath = const Value.absent(),
            Value<String> originalFilename = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            Value<int> byteSize = const Value.absent(),
            Value<String> checksum = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> missingAt = const Value.absent(),
          }) =>
              MediaAssetsCompanion(
            id: id,
            uuid: uuid,
            relativePath: relativePath,
            originalFilename: originalFilename,
            mimeType: mimeType,
            byteSize: byteSize,
            checksum: checksum,
            width: width,
            height: height,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            missingAt: missingAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String relativePath,
            required String originalFilename,
            required String mimeType,
            required int byteSize,
            required String checksum,
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> missingAt = const Value.absent(),
          }) =>
              MediaAssetsCompanion.insert(
            id: id,
            uuid: uuid,
            relativePath: relativePath,
            originalFilename: originalFilename,
            mimeType: mimeType,
            byteSize: byteSize,
            checksum: checksum,
            width: width,
            height: height,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            missingAt: missingAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MediaAssetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {batteryPhotosRefs = false,
              batterySetPhotosRefs = false,
              devicePhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (batteryPhotosRefs) db.batteryPhotos,
                if (batterySetPhotosRefs) db.batterySetPhotos,
                if (devicePhotosRefs) db.devicePhotos
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (batteryPhotosRefs)
                    await $_getPrefetchedData<MediaAsset, $MediaAssetsTable,
                            BatteryPhoto>(
                        currentTable: table,
                        referencedTable: $$MediaAssetsTableReferences
                            ._batteryPhotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MediaAssetsTableReferences(db, table, p0)
                                .batteryPhotosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mediaAssetId == item.id),
                        typedResults: items),
                  if (batterySetPhotosRefs)
                    await $_getPrefetchedData<MediaAsset, $MediaAssetsTable,
                            BatterySetPhoto>(
                        currentTable: table,
                        referencedTable: $$MediaAssetsTableReferences
                            ._batterySetPhotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MediaAssetsTableReferences(db, table, p0)
                                .batterySetPhotosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mediaAssetId == item.id),
                        typedResults: items),
                  if (devicePhotosRefs)
                    await $_getPrefetchedData<MediaAsset, $MediaAssetsTable,
                            DevicePhoto>(
                        currentTable: table,
                        referencedTable: $$MediaAssetsTableReferences
                            ._devicePhotosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MediaAssetsTableReferences(db, table, p0)
                                .devicePhotosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mediaAssetId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MediaAssetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaAssetsTable,
    MediaAsset,
    $$MediaAssetsTableFilterComposer,
    $$MediaAssetsTableOrderingComposer,
    $$MediaAssetsTableAnnotationComposer,
    $$MediaAssetsTableCreateCompanionBuilder,
    $$MediaAssetsTableUpdateCompanionBuilder,
    (MediaAsset, $$MediaAssetsTableReferences),
    MediaAsset,
    PrefetchHooks Function(
        {bool batteryPhotosRefs,
        bool batterySetPhotosRefs,
        bool devicePhotosRefs})>;
typedef $$BatteryPhotosTableCreateCompanionBuilder = BatteryPhotosCompanion
    Function({
  required int batteryId,
  required int mediaAssetId,
  Value<bool> isPrimary,
  Value<int> displayOrder,
  Value<String?> caption,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});
typedef $$BatteryPhotosTableUpdateCompanionBuilder = BatteryPhotosCompanion
    Function({
  Value<int> batteryId,
  Value<int> mediaAssetId,
  Value<bool> isPrimary,
  Value<int> displayOrder,
  Value<String?> caption,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});

final class $$BatteryPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $BatteryPhotosTable, BatteryPhoto> {
  $$BatteryPhotosTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BatteriesTable _batteryIdTable(_$AppDatabase db) =>
      db.batteries.createAlias('battery_photos__battery_id__batteries__id');

  $$BatteriesTableProcessedTableManager get batteryId {
    final $_column = $_itemColumn<int>('battery_id')!;

    final manager = $$BatteriesTableTableManager($_db, $_db.batteries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batteryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MediaAssetsTable _mediaAssetIdTable(_$AppDatabase db) =>
      db.mediaAssets
          .createAlias('battery_photos__media_asset_id__media_assets__id');

  $$MediaAssetsTableProcessedTableManager get mediaAssetId {
    final $_column = $_itemColumn<int>('media_asset_id')!;

    final manager = $$MediaAssetsTableTableManager($_db, $_db.mediaAssets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaAssetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BatteryPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $BatteryPhotosTable> {
  $$BatteryPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$BatteriesTableFilterComposer get batteryId {
    final $$BatteriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableFilterComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableFilterComposer get mediaAssetId {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableFilterComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatteryPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $BatteryPhotosTable> {
  $$BatteryPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  $$BatteriesTableOrderingComposer get batteryId {
    final $$BatteriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableOrderingComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableOrderingComposer get mediaAssetId {
    final $$MediaAssetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableOrderingComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatteryPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatteryPhotosTable> {
  $$BatteryPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  $$BatteriesTableAnnotationComposer get batteryId {
    final $$BatteriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableAnnotationComposer get mediaAssetId {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatteryPhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatteryPhotosTable,
    BatteryPhoto,
    $$BatteryPhotosTableFilterComposer,
    $$BatteryPhotosTableOrderingComposer,
    $$BatteryPhotosTableAnnotationComposer,
    $$BatteryPhotosTableCreateCompanionBuilder,
    $$BatteryPhotosTableUpdateCompanionBuilder,
    (BatteryPhoto, $$BatteryPhotosTableReferences),
    BatteryPhoto,
    PrefetchHooks Function({bool batteryId, bool mediaAssetId})> {
  $$BatteryPhotosTableTableManager(_$AppDatabase db, $BatteryPhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatteryPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatteryPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatteryPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> batteryId = const Value.absent(),
            Value<int> mediaAssetId = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BatteryPhotosCompanion(
            batteryId: batteryId,
            mediaAssetId: mediaAssetId,
            isPrimary: isPrimary,
            displayOrder: displayOrder,
            caption: caption,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int batteryId,
            required int mediaAssetId,
            Value<bool> isPrimary = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BatteryPhotosCompanion.insert(
            batteryId: batteryId,
            mediaAssetId: mediaAssetId,
            isPrimary: isPrimary,
            displayOrder: displayOrder,
            caption: caption,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BatteryPhotosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({batteryId = false, mediaAssetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batteryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batteryId,
                    referencedTable:
                        $$BatteryPhotosTableReferences._batteryIdTable(db),
                    referencedColumn:
                        $$BatteryPhotosTableReferences._batteryIdTable(db).id,
                  ) as T;
                }
                if (mediaAssetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mediaAssetId,
                    referencedTable:
                        $$BatteryPhotosTableReferences._mediaAssetIdTable(db),
                    referencedColumn: $$BatteryPhotosTableReferences
                        ._mediaAssetIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BatteryPhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BatteryPhotosTable,
    BatteryPhoto,
    $$BatteryPhotosTableFilterComposer,
    $$BatteryPhotosTableOrderingComposer,
    $$BatteryPhotosTableAnnotationComposer,
    $$BatteryPhotosTableCreateCompanionBuilder,
    $$BatteryPhotosTableUpdateCompanionBuilder,
    (BatteryPhoto, $$BatteryPhotosTableReferences),
    BatteryPhoto,
    PrefetchHooks Function({bool batteryId, bool mediaAssetId})>;
typedef $$BatterySetPhotosTableCreateCompanionBuilder
    = BatterySetPhotosCompanion Function({
  required int batterySetId,
  required int mediaAssetId,
  Value<bool> isPrimary,
  Value<int> displayOrder,
  Value<String?> caption,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});
typedef $$BatterySetPhotosTableUpdateCompanionBuilder
    = BatterySetPhotosCompanion Function({
  Value<int> batterySetId,
  Value<int> mediaAssetId,
  Value<bool> isPrimary,
  Value<int> displayOrder,
  Value<String?> caption,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});

final class $$BatterySetPhotosTableReferences extends BaseReferences<
    _$AppDatabase, $BatterySetPhotosTable, BatterySetPhoto> {
  $$BatterySetPhotosTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BatterySetsTable _batterySetIdTable(_$AppDatabase db) =>
      db.batterySets
          .createAlias('battery_set_photos__battery_set_id__battery_sets__id');

  $$BatterySetsTableProcessedTableManager get batterySetId {
    final $_column = $_itemColumn<int>('battery_set_id')!;

    final manager = $$BatterySetsTableTableManager($_db, $_db.batterySets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batterySetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MediaAssetsTable _mediaAssetIdTable(_$AppDatabase db) =>
      db.mediaAssets
          .createAlias('battery_set_photos__media_asset_id__media_assets__id');

  $$MediaAssetsTableProcessedTableManager get mediaAssetId {
    final $_column = $_itemColumn<int>('media_asset_id')!;

    final manager = $$MediaAssetsTableTableManager($_db, $_db.mediaAssets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaAssetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BatterySetPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $BatterySetPhotosTable> {
  $$BatterySetPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$BatterySetsTableFilterComposer get batterySetId {
    final $$BatterySetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableFilterComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableFilterComposer get mediaAssetId {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableFilterComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatterySetPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $BatterySetPhotosTable> {
  $$BatterySetPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  $$BatterySetsTableOrderingComposer get batterySetId {
    final $$BatterySetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableOrderingComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableOrderingComposer get mediaAssetId {
    final $$MediaAssetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableOrderingComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatterySetPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatterySetPhotosTable> {
  $$BatterySetPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  $$BatterySetsTableAnnotationComposer get batterySetId {
    final $$BatterySetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batterySetId,
        referencedTable: $db.batterySets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatterySetsTableAnnotationComposer(
              $db: $db,
              $table: $db.batterySets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableAnnotationComposer get mediaAssetId {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatterySetPhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatterySetPhotosTable,
    BatterySetPhoto,
    $$BatterySetPhotosTableFilterComposer,
    $$BatterySetPhotosTableOrderingComposer,
    $$BatterySetPhotosTableAnnotationComposer,
    $$BatterySetPhotosTableCreateCompanionBuilder,
    $$BatterySetPhotosTableUpdateCompanionBuilder,
    (BatterySetPhoto, $$BatterySetPhotosTableReferences),
    BatterySetPhoto,
    PrefetchHooks Function({bool batterySetId, bool mediaAssetId})> {
  $$BatterySetPhotosTableTableManager(
      _$AppDatabase db, $BatterySetPhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatterySetPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatterySetPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatterySetPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> batterySetId = const Value.absent(),
            Value<int> mediaAssetId = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BatterySetPhotosCompanion(
            batterySetId: batterySetId,
            mediaAssetId: mediaAssetId,
            isPrimary: isPrimary,
            displayOrder: displayOrder,
            caption: caption,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int batterySetId,
            required int mediaAssetId,
            Value<bool> isPrimary = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BatterySetPhotosCompanion.insert(
            batterySetId: batterySetId,
            mediaAssetId: mediaAssetId,
            isPrimary: isPrimary,
            displayOrder: displayOrder,
            caption: caption,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BatterySetPhotosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {batterySetId = false, mediaAssetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batterySetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batterySetId,
                    referencedTable: $$BatterySetPhotosTableReferences
                        ._batterySetIdTable(db),
                    referencedColumn: $$BatterySetPhotosTableReferences
                        ._batterySetIdTable(db)
                        .id,
                  ) as T;
                }
                if (mediaAssetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mediaAssetId,
                    referencedTable: $$BatterySetPhotosTableReferences
                        ._mediaAssetIdTable(db),
                    referencedColumn: $$BatterySetPhotosTableReferences
                        ._mediaAssetIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BatterySetPhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BatterySetPhotosTable,
    BatterySetPhoto,
    $$BatterySetPhotosTableFilterComposer,
    $$BatterySetPhotosTableOrderingComposer,
    $$BatterySetPhotosTableAnnotationComposer,
    $$BatterySetPhotosTableCreateCompanionBuilder,
    $$BatterySetPhotosTableUpdateCompanionBuilder,
    (BatterySetPhoto, $$BatterySetPhotosTableReferences),
    BatterySetPhoto,
    PrefetchHooks Function({bool batterySetId, bool mediaAssetId})>;
typedef $$DevicePhotosTableCreateCompanionBuilder = DevicePhotosCompanion
    Function({
  required int deviceId,
  required int mediaAssetId,
  Value<bool> isPrimary,
  Value<int> displayOrder,
  Value<String?> caption,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});
typedef $$DevicePhotosTableUpdateCompanionBuilder = DevicePhotosCompanion
    Function({
  Value<int> deviceId,
  Value<int> mediaAssetId,
  Value<bool> isPrimary,
  Value<int> displayOrder,
  Value<String?> caption,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});

final class $$DevicePhotosTableReferences
    extends BaseReferences<_$AppDatabase, $DevicePhotosTable, DevicePhoto> {
  $$DevicePhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$AppDatabase db) =>
      db.devices.createAlias('device_photos__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $$DevicesTableTableManager($_db, $_db.devices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MediaAssetsTable _mediaAssetIdTable(_$AppDatabase db) =>
      db.mediaAssets
          .createAlias('device_photos__media_asset_id__media_assets__id');

  $$MediaAssetsTableProcessedTableManager get mediaAssetId {
    final $_column = $_itemColumn<int>('media_asset_id')!;

    final manager = $$MediaAssetsTableTableManager($_db, $_db.mediaAssets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaAssetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DevicePhotosTableFilterComposer
    extends Composer<_$AppDatabase, $DevicePhotosTable> {
  $$DevicePhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableFilterComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableFilterComposer get mediaAssetId {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableFilterComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DevicePhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicePhotosTable> {
  $$DevicePhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableOrderingComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableOrderingComposer get mediaAssetId {
    final $$MediaAssetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableOrderingComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DevicePhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicePhotosTable> {
  $$DevicePhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceId,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaAssetsTableAnnotationComposer get mediaAssetId {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaAssetId,
        referencedTable: $db.mediaAssets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaAssetsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DevicePhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicePhotosTable,
    DevicePhoto,
    $$DevicePhotosTableFilterComposer,
    $$DevicePhotosTableOrderingComposer,
    $$DevicePhotosTableAnnotationComposer,
    $$DevicePhotosTableCreateCompanionBuilder,
    $$DevicePhotosTableUpdateCompanionBuilder,
    (DevicePhoto, $$DevicePhotosTableReferences),
    DevicePhoto,
    PrefetchHooks Function({bool deviceId, bool mediaAssetId})> {
  $$DevicePhotosTableTableManager(_$AppDatabase db, $DevicePhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicePhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicePhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicePhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> deviceId = const Value.absent(),
            Value<int> mediaAssetId = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicePhotosCompanion(
            deviceId: deviceId,
            mediaAssetId: mediaAssetId,
            isPrimary: isPrimary,
            displayOrder: displayOrder,
            caption: caption,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int deviceId,
            required int mediaAssetId,
            Value<bool> isPrimary = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<String?> caption = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicePhotosCompanion.insert(
            deviceId: deviceId,
            mediaAssetId: mediaAssetId,
            isPrimary: isPrimary,
            displayOrder: displayOrder,
            caption: caption,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DevicePhotosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({deviceId = false, mediaAssetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (deviceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deviceId,
                    referencedTable:
                        $$DevicePhotosTableReferences._deviceIdTable(db),
                    referencedColumn:
                        $$DevicePhotosTableReferences._deviceIdTable(db).id,
                  ) as T;
                }
                if (mediaAssetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mediaAssetId,
                    referencedTable:
                        $$DevicePhotosTableReferences._mediaAssetIdTable(db),
                    referencedColumn:
                        $$DevicePhotosTableReferences._mediaAssetIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DevicePhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicePhotosTable,
    DevicePhoto,
    $$DevicePhotosTableFilterComposer,
    $$DevicePhotosTableOrderingComposer,
    $$DevicePhotosTableAnnotationComposer,
    $$DevicePhotosTableCreateCompanionBuilder,
    $$DevicePhotosTableUpdateCompanionBuilder,
    (DevicePhoto, $$DevicePhotosTableReferences),
    DevicePhoto,
    PrefetchHooks Function({bool deviceId, bool mediaAssetId})>;
typedef $$IconCategoriesTableCreateCompanionBuilder = IconCategoriesCompanion
    Function({
  Value<int> id,
  required String uuid,
  required String name,
  required String scope,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
});
typedef $$IconCategoriesTableUpdateCompanionBuilder = IconCategoriesCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> name,
  Value<String> scope,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
});

final class $$IconCategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $IconCategoriesTable, IconCategory> {
  $$IconCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomIconsTable, List<CustomIcon>>
      _customIconsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.customIcons,
              aliasName: 'icon_categories__id__custom_icons__category_id');

  $$CustomIconsTableProcessedTableManager get customIconsRefs {
    final manager = $$CustomIconsTableTableManager($_db, $_db.customIcons)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_customIconsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$IconCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $IconCategoriesTable> {
  $$IconCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get deactivatedAt => $composableBuilder(
          column: $table.deactivatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> customIconsRefs(
      Expression<bool> Function($$CustomIconsTableFilterComposer f) f) {
    final $$CustomIconsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.customIcons,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomIconsTableFilterComposer(
              $db: $db,
              $table: $db.customIcons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$IconCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $IconCategoriesTable> {
  $$IconCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deactivatedAt => $composableBuilder(
      column: $table.deactivatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$IconCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IconCategoriesTable> {
  $$IconCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deactivatedAt =>
      $composableBuilder(
          column: $table.deactivatedAt, builder: (column) => column);

  Expression<T> customIconsRefs<T extends Object>(
      Expression<T> Function($$CustomIconsTableAnnotationComposer a) f) {
    final $$CustomIconsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.customIcons,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomIconsTableAnnotationComposer(
              $db: $db,
              $table: $db.customIcons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$IconCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IconCategoriesTable,
    IconCategory,
    $$IconCategoriesTableFilterComposer,
    $$IconCategoriesTableOrderingComposer,
    $$IconCategoriesTableAnnotationComposer,
    $$IconCategoriesTableCreateCompanionBuilder,
    $$IconCategoriesTableUpdateCompanionBuilder,
    (IconCategory, $$IconCategoriesTableReferences),
    IconCategory,
    PrefetchHooks Function({bool customIconsRefs})> {
  $$IconCategoriesTableTableManager(
      _$AppDatabase db, $IconCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IconCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IconCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IconCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
          }) =>
              IconCategoriesCompanion(
            id: id,
            uuid: uuid,
            name: name,
            scope: scope,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String name,
            required String scope,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
          }) =>
              IconCategoriesCompanion.insert(
            id: id,
            uuid: uuid,
            name: name,
            scope: scope,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$IconCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({customIconsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (customIconsRefs) db.customIcons],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customIconsRefs)
                    await $_getPrefetchedData<IconCategory,
                            $IconCategoriesTable, CustomIcon>(
                        currentTable: table,
                        referencedTable: $$IconCategoriesTableReferences
                            ._customIconsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$IconCategoriesTableReferences(db, table, p0)
                                .customIconsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$IconCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IconCategoriesTable,
    IconCategory,
    $$IconCategoriesTableFilterComposer,
    $$IconCategoriesTableOrderingComposer,
    $$IconCategoriesTableAnnotationComposer,
    $$IconCategoriesTableCreateCompanionBuilder,
    $$IconCategoriesTableUpdateCompanionBuilder,
    (IconCategory, $$IconCategoriesTableReferences),
    IconCategory,
    PrefetchHooks Function({bool customIconsRefs})>;
typedef $$CustomIconsTableCreateCompanionBuilder = CustomIconsCompanion
    Function({
  Value<int> id,
  required String uuid,
  required String name,
  Value<int?> categoryId,
  required String relativePath,
  required String fileType,
  Value<bool> supportsColor,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
});
typedef $$CustomIconsTableUpdateCompanionBuilder = CustomIconsCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> name,
  Value<int?> categoryId,
  Value<String> relativePath,
  Value<String> fileType,
  Value<bool> supportsColor,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
});

final class $$CustomIconsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomIconsTable, CustomIcon> {
  $$CustomIconsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $IconCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.iconCategories
          .createAlias('custom_icons__category_id__icon_categories__id');

  $$IconCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$IconCategoriesTableTableManager($_db, $_db.iconCategories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CustomIconsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomIconsTable> {
  $$CustomIconsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileType => $composableBuilder(
      column: $table.fileType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get supportsColor => $composableBuilder(
      column: $table.supportsColor, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get deactivatedAt => $composableBuilder(
          column: $table.deactivatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$IconCategoriesTableFilterComposer get categoryId {
    final $$IconCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.iconCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IconCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.iconCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CustomIconsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomIconsTable> {
  $$CustomIconsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relativePath => $composableBuilder(
      column: $table.relativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileType => $composableBuilder(
      column: $table.fileType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get supportsColor => $composableBuilder(
      column: $table.supportsColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deactivatedAt => $composableBuilder(
      column: $table.deactivatedAt,
      builder: (column) => ColumnOrderings(column));

  $$IconCategoriesTableOrderingComposer get categoryId {
    final $$IconCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.iconCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IconCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.iconCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CustomIconsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomIconsTable> {
  $$CustomIconsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<bool> get supportsColor => $composableBuilder(
      column: $table.supportsColor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deactivatedAt =>
      $composableBuilder(
          column: $table.deactivatedAt, builder: (column) => column);

  $$IconCategoriesTableAnnotationComposer get categoryId {
    final $$IconCategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.iconCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$IconCategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.iconCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CustomIconsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomIconsTable,
    CustomIcon,
    $$CustomIconsTableFilterComposer,
    $$CustomIconsTableOrderingComposer,
    $$CustomIconsTableAnnotationComposer,
    $$CustomIconsTableCreateCompanionBuilder,
    $$CustomIconsTableUpdateCompanionBuilder,
    (CustomIcon, $$CustomIconsTableReferences),
    CustomIcon,
    PrefetchHooks Function({bool categoryId})> {
  $$CustomIconsTableTableManager(_$AppDatabase db, $CustomIconsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomIconsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomIconsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomIconsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<String> relativePath = const Value.absent(),
            Value<String> fileType = const Value.absent(),
            Value<bool> supportsColor = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
          }) =>
              CustomIconsCompanion(
            id: id,
            uuid: uuid,
            name: name,
            categoryId: categoryId,
            relativePath: relativePath,
            fileType: fileType,
            supportsColor: supportsColor,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String name,
            Value<int?> categoryId = const Value.absent(),
            required String relativePath,
            required String fileType,
            Value<bool> supportsColor = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
          }) =>
              CustomIconsCompanion.insert(
            id: id,
            uuid: uuid,
            name: name,
            categoryId: categoryId,
            relativePath: relativePath,
            fileType: fileType,
            supportsColor: supportsColor,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CustomIconsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$CustomIconsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$CustomIconsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CustomIconsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomIconsTable,
    CustomIcon,
    $$CustomIconsTableFilterComposer,
    $$CustomIconsTableOrderingComposer,
    $$CustomIconsTableAnnotationComposer,
    $$CustomIconsTableCreateCompanionBuilder,
    $$CustomIconsTableUpdateCompanionBuilder,
    (CustomIcon, $$CustomIconsTableReferences),
    CustomIcon,
    PrefetchHooks Function({bool categoryId})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String uuid,
  required String name,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BatteryTagsTable, List<BatteryTag>>
      _batteryTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.batteryTags,
              aliasName: 'tags__id__battery_tags__tag_id');

  $$BatteryTagsTableProcessedTableManager get batteryTagsRefs {
    final manager = $$BatteryTagsTableTableManager($_db, $_db.batteryTags)
        .filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_batteryTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> batteryTagsRefs(
      Expression<bool> Function($$BatteryTagsTableFilterComposer f) f) {
    final $$BatteryTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteryTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTagsTableFilterComposer(
              $db: $db,
              $table: $db.batteryTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  Expression<T> batteryTagsRefs<T extends Object>(
      Expression<T> Function($$BatteryTagsTableAnnotationComposer a) f) {
    final $$BatteryTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.batteryTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteryTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.batteryTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool batteryTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            uuid: uuid,
            name: name,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String name,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            uuid: uuid,
            name: name,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({batteryTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (batteryTagsRefs) db.batteryTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (batteryTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, BatteryTag>(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._batteryTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0)
                                .batteryTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool batteryTagsRefs})>;
typedef $$BatteryTagsTableCreateCompanionBuilder = BatteryTagsCompanion
    Function({
  required int batteryId,
  required int tagId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$BatteryTagsTableUpdateCompanionBuilder = BatteryTagsCompanion
    Function({
  Value<int> batteryId,
  Value<int> tagId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$BatteryTagsTableReferences
    extends BaseReferences<_$AppDatabase, $BatteryTagsTable, BatteryTag> {
  $$BatteryTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BatteriesTable _batteryIdTable(_$AppDatabase db) =>
      db.batteries.createAlias('battery_tags__battery_id__batteries__id');

  $$BatteriesTableProcessedTableManager get batteryId {
    final $_column = $_itemColumn<int>('battery_id')!;

    final manager = $$BatteriesTableTableManager($_db, $_db.batteries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batteryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('battery_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BatteryTagsTableFilterComposer
    extends Composer<_$AppDatabase, $BatteryTagsTable> {
  $$BatteryTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$BatteriesTableFilterComposer get batteryId {
    final $$BatteriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableFilterComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableFilterComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatteryTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $BatteryTagsTable> {
  $$BatteryTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BatteriesTableOrderingComposer get batteryId {
    final $$BatteriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableOrderingComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableOrderingComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatteryTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatteryTagsTable> {
  $$BatteryTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BatteriesTableAnnotationComposer get batteryId {
    final $$BatteriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.batteryId,
        referencedTable: $db.batteries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BatteriesTableAnnotationComposer(
              $db: $db,
              $table: $db.batteries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableAnnotationComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BatteryTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatteryTagsTable,
    BatteryTag,
    $$BatteryTagsTableFilterComposer,
    $$BatteryTagsTableOrderingComposer,
    $$BatteryTagsTableAnnotationComposer,
    $$BatteryTagsTableCreateCompanionBuilder,
    $$BatteryTagsTableUpdateCompanionBuilder,
    (BatteryTag, $$BatteryTagsTableReferences),
    BatteryTag,
    PrefetchHooks Function({bool batteryId, bool tagId})> {
  $$BatteryTagsTableTableManager(_$AppDatabase db, $BatteryTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatteryTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatteryTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatteryTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> batteryId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BatteryTagsCompanion(
            batteryId: batteryId,
            tagId: tagId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int batteryId,
            required int tagId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BatteryTagsCompanion.insert(
            batteryId: batteryId,
            tagId: tagId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BatteryTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({batteryId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (batteryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.batteryId,
                    referencedTable:
                        $$BatteryTagsTableReferences._batteryIdTable(db),
                    referencedColumn:
                        $$BatteryTagsTableReferences._batteryIdTable(db).id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable:
                        $$BatteryTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$BatteryTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BatteryTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BatteryTagsTable,
    BatteryTag,
    $$BatteryTagsTableFilterComposer,
    $$BatteryTagsTableOrderingComposer,
    $$BatteryTagsTableAnnotationComposer,
    $$BatteryTagsTableCreateCompanionBuilder,
    $$BatteryTagsTableUpdateCompanionBuilder,
    (BatteryTag, $$BatteryTagsTableReferences),
    BatteryTag,
    PrefetchHooks Function({bool batteryId, bool tagId})>;
typedef $$QrLabelTemplatesTableCreateCompanionBuilder
    = QrLabelTemplatesCompanion Function({
  Value<int> id,
  required String uuid,
  required String name,
  required String targetType,
  required double widthPoints,
  required double heightPoints,
  required String layoutJson,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
});
typedef $$QrLabelTemplatesTableUpdateCompanionBuilder
    = QrLabelTemplatesCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> name,
  Value<String> targetType,
  Value<double> widthPoints,
  Value<double> heightPoints,
  Value<String> layoutJson,
  Value<DateTime> createdAt,
  Value<DateTime> modifiedAt,
  Value<DateTime?> deactivatedAt,
});

class $$QrLabelTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $QrLabelTemplatesTable> {
  $$QrLabelTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get widthPoints => $composableBuilder(
      column: $table.widthPoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightPoints => $composableBuilder(
      column: $table.heightPoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get layoutJson => $composableBuilder(
      column: $table.layoutJson, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
      get deactivatedAt => $composableBuilder(
          column: $table.deactivatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$QrLabelTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $QrLabelTemplatesTable> {
  $$QrLabelTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get widthPoints => $composableBuilder(
      column: $table.widthPoints, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightPoints => $composableBuilder(
      column: $table.heightPoints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get layoutJson => $composableBuilder(
      column: $table.layoutJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deactivatedAt => $composableBuilder(
      column: $table.deactivatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$QrLabelTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QrLabelTemplatesTable> {
  $$QrLabelTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => column);

  GeneratedColumn<double> get widthPoints => $composableBuilder(
      column: $table.widthPoints, builder: (column) => column);

  GeneratedColumn<double> get heightPoints => $composableBuilder(
      column: $table.heightPoints, builder: (column) => column);

  GeneratedColumn<String> get layoutJson => $composableBuilder(
      column: $table.layoutJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deactivatedAt =>
      $composableBuilder(
          column: $table.deactivatedAt, builder: (column) => column);
}

class $$QrLabelTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QrLabelTemplatesTable,
    QrLabelTemplate,
    $$QrLabelTemplatesTableFilterComposer,
    $$QrLabelTemplatesTableOrderingComposer,
    $$QrLabelTemplatesTableAnnotationComposer,
    $$QrLabelTemplatesTableCreateCompanionBuilder,
    $$QrLabelTemplatesTableUpdateCompanionBuilder,
    (
      QrLabelTemplate,
      BaseReferences<_$AppDatabase, $QrLabelTemplatesTable, QrLabelTemplate>
    ),
    QrLabelTemplate,
    PrefetchHooks Function()> {
  $$QrLabelTemplatesTableTableManager(
      _$AppDatabase db, $QrLabelTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QrLabelTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QrLabelTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QrLabelTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> targetType = const Value.absent(),
            Value<double> widthPoints = const Value.absent(),
            Value<double> heightPoints = const Value.absent(),
            Value<String> layoutJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
          }) =>
              QrLabelTemplatesCompanion(
            id: id,
            uuid: uuid,
            name: name,
            targetType: targetType,
            widthPoints: widthPoints,
            heightPoints: heightPoints,
            layoutJson: layoutJson,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String name,
            required String targetType,
            required double widthPoints,
            required double heightPoints,
            required String layoutJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<DateTime?> deactivatedAt = const Value.absent(),
          }) =>
              QrLabelTemplatesCompanion.insert(
            id: id,
            uuid: uuid,
            name: name,
            targetType: targetType,
            widthPoints: widthPoints,
            heightPoints: heightPoints,
            layoutJson: layoutJson,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            deactivatedAt: deactivatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QrLabelTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QrLabelTemplatesTable,
    QrLabelTemplate,
    $$QrLabelTemplatesTableFilterComposer,
    $$QrLabelTemplatesTableOrderingComposer,
    $$QrLabelTemplatesTableAnnotationComposer,
    $$QrLabelTemplatesTableCreateCompanionBuilder,
    $$QrLabelTemplatesTableUpdateCompanionBuilder,
    (
      QrLabelTemplate,
      BaseReferences<_$AppDatabase, $QrLabelTemplatesTable, QrLabelTemplate>
    ),
    QrLabelTemplate,
    PrefetchHooks Function()>;
typedef $$ActivityLogTableCreateCompanionBuilder = ActivityLogCompanion
    Function({
  Value<int> id,
  required String uuid,
  required String eventType,
  required String entityType,
  required String entityUuid,
  Value<String?> relatedEntityType,
  Value<String?> relatedEntityUuid,
  Value<String?> operationUuid,
  required String summary,
  Value<String> metadataJson,
  Value<DateTime> occurredAt,
});
typedef $$ActivityLogTableUpdateCompanionBuilder = ActivityLogCompanion
    Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> eventType,
  Value<String> entityType,
  Value<String> entityUuid,
  Value<String?> relatedEntityType,
  Value<String?> relatedEntityUuid,
  Value<String?> operationUuid,
  Value<String> summary,
  Value<String> metadataJson,
  Value<DateTime> occurredAt,
});

class $$ActivityLogTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityUuid => $composableBuilder(
      column: $table.entityUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedEntityUuid => $composableBuilder(
      column: $table.relatedEntityUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get occurredAt =>
      $composableBuilder(
          column: $table.occurredAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$ActivityLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityUuid => $composableBuilder(
      column: $table.entityUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedEntityUuid => $composableBuilder(
      column: $table.relatedEntityUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));
}

class $$ActivityLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityUuid => $composableBuilder(
      column: $table.entityUuid, builder: (column) => column);

  GeneratedColumn<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType, builder: (column) => column);

  GeneratedColumn<String> get relatedEntityUuid => $composableBuilder(
      column: $table.relatedEntityUuid, builder: (column) => column);

  GeneratedColumn<String> get operationUuid => $composableBuilder(
      column: $table.operationUuid, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get occurredAt =>
      $composableBuilder(
          column: $table.occurredAt, builder: (column) => column);
}

class $$ActivityLogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityLogTable,
    ActivityLogData,
    $$ActivityLogTableFilterComposer,
    $$ActivityLogTableOrderingComposer,
    $$ActivityLogTableAnnotationComposer,
    $$ActivityLogTableCreateCompanionBuilder,
    $$ActivityLogTableUpdateCompanionBuilder,
    (
      ActivityLogData,
      BaseReferences<_$AppDatabase, $ActivityLogTable, ActivityLogData>
    ),
    ActivityLogData,
    PrefetchHooks Function()> {
  $$ActivityLogTableTableManager(_$AppDatabase db, $ActivityLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityUuid = const Value.absent(),
            Value<String?> relatedEntityType = const Value.absent(),
            Value<String?> relatedEntityUuid = const Value.absent(),
            Value<String?> operationUuid = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
          }) =>
              ActivityLogCompanion(
            id: id,
            uuid: uuid,
            eventType: eventType,
            entityType: entityType,
            entityUuid: entityUuid,
            relatedEntityType: relatedEntityType,
            relatedEntityUuid: relatedEntityUuid,
            operationUuid: operationUuid,
            summary: summary,
            metadataJson: metadataJson,
            occurredAt: occurredAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String eventType,
            required String entityType,
            required String entityUuid,
            Value<String?> relatedEntityType = const Value.absent(),
            Value<String?> relatedEntityUuid = const Value.absent(),
            Value<String?> operationUuid = const Value.absent(),
            required String summary,
            Value<String> metadataJson = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
          }) =>
              ActivityLogCompanion.insert(
            id: id,
            uuid: uuid,
            eventType: eventType,
            entityType: entityType,
            entityUuid: entityUuid,
            relatedEntityType: relatedEntityType,
            relatedEntityUuid: relatedEntityUuid,
            operationUuid: operationUuid,
            summary: summary,
            metadataJson: metadataJson,
            occurredAt: occurredAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivityLogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityLogTable,
    ActivityLogData,
    $$ActivityLogTableFilterComposer,
    $$ActivityLogTableOrderingComposer,
    $$ActivityLogTableAnnotationComposer,
    $$ActivityLogTableCreateCompanionBuilder,
    $$ActivityLogTableUpdateCompanionBuilder,
    (
      ActivityLogData,
      BaseReferences<_$AppDatabase, $ActivityLogTable, ActivityLogData>
    ),
    ActivityLogData,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  required String valueType,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<String> valueType,
  Value<DateTime> modifiedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valueType => $composableBuilder(
      column: $table.valueType, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valueType => $composableBuilder(
      column: $table.valueType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
      column: $table.modifiedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get modifiedAt =>
      $composableBuilder(
          column: $table.modifiedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<String> valueType = const Value.absent(),
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            valueType: valueType,
            modifiedAt: modifiedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required String valueType,
            Value<DateTime> modifiedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            valueType: valueType,
            modifiedAt: modifiedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BatteryTypesTableTableManager get batteryTypes =>
      $$BatteryTypesTableTableManager(_db, _db.batteryTypes);
  $$BatteryBatchesTableTableManager get batteryBatches =>
      $$BatteryBatchesTableTableManager(_db, _db.batteryBatches);
  $$BatteriesTableTableManager get batteries =>
      $$BatteriesTableTableManager(_db, _db.batteries);
  $$BatterySetsTableTableManager get batterySets =>
      $$BatterySetsTableTableManager(_db, _db.batterySets);
  $$BatterySetMembershipsTableTableManager get batterySetMemberships =>
      $$BatterySetMembershipsTableTableManager(_db, _db.batterySetMemberships);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$AssignmentsTableTableManager get assignments =>
      $$AssignmentsTableTableManager(_db, _db.assignments);
  $$SetChargeRecordsTableTableManager get setChargeRecords =>
      $$SetChargeRecordsTableTableManager(_db, _db.setChargeRecords);
  $$ChargeRecordsTableTableManager get chargeRecords =>
      $$ChargeRecordsTableTableManager(_db, _db.chargeRecords);
  $$MediaAssetsTableTableManager get mediaAssets =>
      $$MediaAssetsTableTableManager(_db, _db.mediaAssets);
  $$BatteryPhotosTableTableManager get batteryPhotos =>
      $$BatteryPhotosTableTableManager(_db, _db.batteryPhotos);
  $$BatterySetPhotosTableTableManager get batterySetPhotos =>
      $$BatterySetPhotosTableTableManager(_db, _db.batterySetPhotos);
  $$DevicePhotosTableTableManager get devicePhotos =>
      $$DevicePhotosTableTableManager(_db, _db.devicePhotos);
  $$IconCategoriesTableTableManager get iconCategories =>
      $$IconCategoriesTableTableManager(_db, _db.iconCategories);
  $$CustomIconsTableTableManager get customIcons =>
      $$CustomIconsTableTableManager(_db, _db.customIcons);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$BatteryTagsTableTableManager get batteryTags =>
      $$BatteryTagsTableTableManager(_db, _db.batteryTags);
  $$QrLabelTemplatesTableTableManager get qrLabelTemplates =>
      $$QrLabelTemplatesTableTableManager(_db, _db.qrLabelTemplates);
  $$ActivityLogTableTableManager get activityLog =>
      $$ActivityLogTableTableManager(_db, _db.activityLog);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
