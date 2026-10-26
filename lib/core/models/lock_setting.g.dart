// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock_setting.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLockSettingCollection on Isar {
  IsarCollection<LockSetting> get lockSettings => this.collection();
}

const LockSettingSchema = CollectionSchema(
  name: r'LockSetting',
  id: -4866152605732923038,
  properties: {
    r'awayTime': PropertySchema(
      id: 0,
      name: r'awayTime',
      type: IsarType.byte,
      enumMap: _LockSettingawayTimeEnumValueMap,
    ),
    r'biometricsEnabled': PropertySchema(
      id: 1,
      name: r'biometricsEnabled',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'lockEnabled': PropertySchema(
      id: 3,
      name: r'lockEnabled',
      type: IsarType.bool,
    ),
    r'subjectGuid': PropertySchema(
      id: 4,
      name: r'subjectGuid',
      type: IsarType.string,
    ),
    r'subjectKey': PropertySchema(
      id: 5,
      name: r'subjectKey',
      type: IsarType.string,
    ),
    r'subjectKind': PropertySchema(
      id: 6,
      name: r'subjectKind',
      type: IsarType.byte,
      enumMap: _LockSettingsubjectKindEnumValueMap,
    ),
    r'subjectLocalId': PropertySchema(
      id: 7,
      name: r'subjectLocalId',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _lockSettingEstimateSize,
  serialize: _lockSettingSerialize,
  deserialize: _lockSettingDeserialize,
  deserializeProp: _lockSettingDeserializeProp,
  idName: r'id',
  indexes: {
    r'subjectKey': IndexSchema(
      id: -7798896530269930676,
      name: r'subjectKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'subjectKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _lockSettingGetId,
  getLinks: _lockSettingGetLinks,
  attach: _lockSettingAttach,
  version: '3.1.0+1',
);

int _lockSettingEstimateSize(
  LockSetting object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.subjectGuid.length * 3;
  bytesCount += 3 + object.subjectKey.length * 3;
  return bytesCount;
}

void _lockSettingSerialize(
  LockSetting object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.awayTime.index);
  writer.writeBool(offsets[1], object.biometricsEnabled);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeBool(offsets[3], object.lockEnabled);
  writer.writeString(offsets[4], object.subjectGuid);
  writer.writeString(offsets[5], object.subjectKey);
  writer.writeByte(offsets[6], object.subjectKind.index);
  writer.writeLong(offsets[7], object.subjectLocalId);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

LockSetting _lockSettingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LockSetting();
  object.awayTime =
      _LockSettingawayTimeValueEnumMap[reader.readByteOrNull(offsets[0])] ??
          AwayTime.immediate;
  object.biometricsEnabled = reader.readBool(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.lockEnabled = reader.readBool(offsets[3]);
  object.subjectGuid = reader.readString(offsets[4]);
  object.subjectKey = reader.readString(offsets[5]);
  object.subjectKind =
      _LockSettingsubjectKindValueEnumMap[reader.readByteOrNull(offsets[6])] ??
          LockSubjectKind.profile;
  object.subjectLocalId = reader.readLong(offsets[7]);
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _lockSettingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_LockSettingawayTimeValueEnumMap[reader.readByteOrNull(offset)] ??
          AwayTime.immediate) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (_LockSettingsubjectKindValueEnumMap[
              reader.readByteOrNull(offset)] ??
          LockSubjectKind.profile) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LockSettingawayTimeEnumValueMap = {
  'immediate': 0,
  'thirtySeconds': 1,
  'oneMinute': 2,
  'twoMinutes': 3,
  'fiveMinutes': 4,
};
const _LockSettingawayTimeValueEnumMap = {
  0: AwayTime.immediate,
  1: AwayTime.thirtySeconds,
  2: AwayTime.oneMinute,
  3: AwayTime.twoMinutes,
  4: AwayTime.fiveMinutes,
};
const _LockSettingsubjectKindEnumValueMap = {
  'profile': 0,
  'space': 1,
};
const _LockSettingsubjectKindValueEnumMap = {
  0: LockSubjectKind.profile,
  1: LockSubjectKind.space,
};

Id _lockSettingGetId(LockSetting object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lockSettingGetLinks(LockSetting object) {
  return [];
}

void _lockSettingAttach(
    IsarCollection<dynamic> col, Id id, LockSetting object) {
  object.id = id;
}

extension LockSettingByIndex on IsarCollection<LockSetting> {
  Future<LockSetting?> getBySubjectKey(String subjectKey) {
    return getByIndex(r'subjectKey', [subjectKey]);
  }

  LockSetting? getBySubjectKeySync(String subjectKey) {
    return getByIndexSync(r'subjectKey', [subjectKey]);
  }

  Future<bool> deleteBySubjectKey(String subjectKey) {
    return deleteByIndex(r'subjectKey', [subjectKey]);
  }

  bool deleteBySubjectKeySync(String subjectKey) {
    return deleteByIndexSync(r'subjectKey', [subjectKey]);
  }

  Future<List<LockSetting?>> getAllBySubjectKey(List<String> subjectKeyValues) {
    final values = subjectKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'subjectKey', values);
  }

  List<LockSetting?> getAllBySubjectKeySync(List<String> subjectKeyValues) {
    final values = subjectKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'subjectKey', values);
  }

  Future<int> deleteAllBySubjectKey(List<String> subjectKeyValues) {
    final values = subjectKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'subjectKey', values);
  }

  int deleteAllBySubjectKeySync(List<String> subjectKeyValues) {
    final values = subjectKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'subjectKey', values);
  }

  Future<Id> putBySubjectKey(LockSetting object) {
    return putByIndex(r'subjectKey', object);
  }

  Id putBySubjectKeySync(LockSetting object, {bool saveLinks = true}) {
    return putByIndexSync(r'subjectKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySubjectKey(List<LockSetting> objects) {
    return putAllByIndex(r'subjectKey', objects);
  }

  List<Id> putAllBySubjectKeySync(List<LockSetting> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'subjectKey', objects, saveLinks: saveLinks);
  }
}

extension LockSettingQueryWhereSort
    on QueryBuilder<LockSetting, LockSetting, QWhere> {
  QueryBuilder<LockSetting, LockSetting, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LockSettingQueryWhere
    on QueryBuilder<LockSetting, LockSetting, QWhereClause> {
  QueryBuilder<LockSetting, LockSetting, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterWhereClause> subjectKeyEqualTo(
      String subjectKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectKey',
        value: [subjectKey],
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterWhereClause>
      subjectKeyNotEqualTo(String subjectKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectKey',
              lower: [],
              upper: [subjectKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectKey',
              lower: [subjectKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectKey',
              lower: [subjectKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectKey',
              lower: [],
              upper: [subjectKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LockSettingQueryFilter
    on QueryBuilder<LockSetting, LockSetting, QFilterCondition> {
  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition> awayTimeEqualTo(
      AwayTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'awayTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      awayTimeGreaterThan(
    AwayTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'awayTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      awayTimeLessThan(
    AwayTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'awayTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition> awayTimeBetween(
    AwayTime lower,
    AwayTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'awayTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      biometricsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'biometricsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      lockEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lockEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKindEqualTo(LockSubjectKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectKind',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKindGreaterThan(
    LockSubjectKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectKind',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKindLessThan(
    LockSubjectKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectKind',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectKindBetween(
    LockSubjectKind lower,
    LockSubjectKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectKind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectLocalIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectLocalIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectLocalIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      subjectLocalIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectLocalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LockSettingQueryObject
    on QueryBuilder<LockSetting, LockSetting, QFilterCondition> {}

extension LockSettingQueryLinks
    on QueryBuilder<LockSetting, LockSetting, QFilterCondition> {}

extension LockSettingQuerySortBy
    on QueryBuilder<LockSetting, LockSetting, QSortBy> {
  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortByAwayTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awayTime', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortByAwayTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awayTime', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy>
      sortByBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricsEnabled', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy>
      sortByBiometricsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricsEnabled', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortByLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockEnabled', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortByLockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockEnabled', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortBySubjectGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectGuid', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortBySubjectGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectGuid', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortBySubjectKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectKey', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortBySubjectKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectKey', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortBySubjectKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectKind', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortBySubjectKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectKind', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortBySubjectLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectLocalId', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy>
      sortBySubjectLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectLocalId', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LockSettingQuerySortThenBy
    on QueryBuilder<LockSetting, LockSetting, QSortThenBy> {
  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByAwayTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awayTime', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByAwayTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awayTime', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy>
      thenByBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricsEnabled', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy>
      thenByBiometricsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricsEnabled', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockEnabled', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByLockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockEnabled', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenBySubjectGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectGuid', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenBySubjectGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectGuid', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenBySubjectKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectKey', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenBySubjectKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectKey', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenBySubjectKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectKind', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenBySubjectKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectKind', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenBySubjectLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectLocalId', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy>
      thenBySubjectLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectLocalId', Sort.desc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LockSettingQueryWhereDistinct
    on QueryBuilder<LockSetting, LockSetting, QDistinct> {
  QueryBuilder<LockSetting, LockSetting, QDistinct> distinctByAwayTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'awayTime');
    });
  }

  QueryBuilder<LockSetting, LockSetting, QDistinct>
      distinctByBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'biometricsEnabled');
    });
  }

  QueryBuilder<LockSetting, LockSetting, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LockSetting, LockSetting, QDistinct> distinctByLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lockEnabled');
    });
  }

  QueryBuilder<LockSetting, LockSetting, QDistinct> distinctBySubjectGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QDistinct> distinctBySubjectKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LockSetting, LockSetting, QDistinct> distinctBySubjectKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectKind');
    });
  }

  QueryBuilder<LockSetting, LockSetting, QDistinct> distinctBySubjectLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectLocalId');
    });
  }

  QueryBuilder<LockSetting, LockSetting, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LockSettingQueryProperty
    on QueryBuilder<LockSetting, LockSetting, QQueryProperty> {
  QueryBuilder<LockSetting, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LockSetting, AwayTime, QQueryOperations> awayTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'awayTime');
    });
  }

  QueryBuilder<LockSetting, bool, QQueryOperations>
      biometricsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'biometricsEnabled');
    });
  }

  QueryBuilder<LockSetting, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LockSetting, bool, QQueryOperations> lockEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lockEnabled');
    });
  }

  QueryBuilder<LockSetting, String, QQueryOperations> subjectGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectGuid');
    });
  }

  QueryBuilder<LockSetting, String, QQueryOperations> subjectKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectKey');
    });
  }

  QueryBuilder<LockSetting, LockSubjectKind, QQueryOperations>
      subjectKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectKind');
    });
  }

  QueryBuilder<LockSetting, int, QQueryOperations> subjectLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectLocalId');
    });
  }

  QueryBuilder<LockSetting, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
