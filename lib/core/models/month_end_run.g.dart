// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_end_run.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMonthEndRunCollection on Isar {
  IsarCollection<MonthEndRun> get monthEndRuns => this.collection();
}

const MonthEndRunSchema = CollectionSchema(
  name: r'MonthEndRun',
  id: 8938237212234668156,
  properties: {
    r'actor': PropertySchema(
      id: 0,
      name: r'actor',
      type: IsarType.string,
    ),
    r'applied': PropertySchema(
      id: 1,
      name: r'applied',
      type: IsarType.bool,
    ),
    r'carriedMinor': PropertySchema(
      id: 2,
      name: r'carriedMinor',
      type: IsarType.long,
    ),
    r'contextGuid': PropertySchema(
      id: 3,
      name: r'contextGuid',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 5,
      name: r'currency',
      type: IsarType.string,
    ),
    r'destinationMonth': PropertySchema(
      id: 6,
      name: r'destinationMonth',
      type: IsarType.string,
    ),
    r'fingerprint': PropertySchema(
      id: 7,
      name: r'fingerprint',
      type: IsarType.string,
    ),
    r'hasConflict': PropertySchema(
      id: 8,
      name: r'hasConflict',
      type: IsarType.bool,
    ),
    r'profileId': PropertySchema(
      id: 9,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'releasedMinor': PropertySchema(
      id: 10,
      name: r'releasedMinor',
      type: IsarType.long,
    ),
    r'reportJson': PropertySchema(
      id: 11,
      name: r'reportJson',
      type: IsarType.string,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 12,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'syncGuid': PropertySchema(
      id: 13,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 14,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _monthEndRunEstimateSize,
  serialize: _monthEndRunSerialize,
  deserialize: _monthEndRunDeserialize,
  deserializeProp: _monthEndRunDeserializeProp,
  idName: r'id',
  indexes: {
    r'syncGuid': IndexSchema(
      id: 6159741003405035971,
      name: r'syncGuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'yearMonth': IndexSchema(
      id: 5465596700411800841,
      name: r'yearMonth',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'yearMonth',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _monthEndRunGetId,
  getLinks: _monthEndRunGetLinks,
  attach: _monthEndRunAttach,
  version: '3.1.0+1',
);

int _monthEndRunEstimateSize(
  MonthEndRun object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actor.length * 3;
  bytesCount += 3 + object.contextGuid.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.destinationMonth.length * 3;
  bytesCount += 3 + object.fingerprint.length * 3;
  bytesCount += 3 + object.reportJson.length * 3;
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _monthEndRunSerialize(
  MonthEndRun object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actor);
  writer.writeBool(offsets[1], object.applied);
  writer.writeLong(offsets[2], object.carriedMinor);
  writer.writeString(offsets[3], object.contextGuid);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.currency);
  writer.writeString(offsets[6], object.destinationMonth);
  writer.writeString(offsets[7], object.fingerprint);
  writer.writeBool(offsets[8], object.hasConflict);
  writer.writeLong(offsets[9], object.profileId);
  writer.writeLong(offsets[10], object.releasedMinor);
  writer.writeString(offsets[11], object.reportJson);
  writer.writeLong(offsets[12], object.sharedSpaceId);
  writer.writeString(offsets[13], object.syncGuid);
  writer.writeString(offsets[14], object.yearMonth);
}

MonthEndRun _monthEndRunDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MonthEndRun();
  object.actor = reader.readString(offsets[0]);
  object.applied = reader.readBool(offsets[1]);
  object.carriedMinor = reader.readLong(offsets[2]);
  object.contextGuid = reader.readString(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.currency = reader.readString(offsets[5]);
  object.destinationMonth = reader.readString(offsets[6]);
  object.fingerprint = reader.readString(offsets[7]);
  object.hasConflict = reader.readBool(offsets[8]);
  object.id = id;
  object.profileId = reader.readLongOrNull(offsets[9]);
  object.releasedMinor = reader.readLong(offsets[10]);
  object.reportJson = reader.readString(offsets[11]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[12]);
  object.syncGuid = reader.readString(offsets[13]);
  object.yearMonth = reader.readString(offsets[14]);
  return object;
}

P _monthEndRunDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _monthEndRunGetId(MonthEndRun object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _monthEndRunGetLinks(MonthEndRun object) {
  return [];
}

void _monthEndRunAttach(
    IsarCollection<dynamic> col, Id id, MonthEndRun object) {
  object.id = id;
}

extension MonthEndRunByIndex on IsarCollection<MonthEndRun> {
  Future<MonthEndRun?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  MonthEndRun? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<MonthEndRun?>> getAllBySyncGuid(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<MonthEndRun?> getAllBySyncGuidSync(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'syncGuid', values);
  }

  Future<int> deleteAllBySyncGuid(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'syncGuid', values);
  }

  int deleteAllBySyncGuidSync(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'syncGuid', values);
  }

  Future<Id> putBySyncGuid(MonthEndRun object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(MonthEndRun object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<MonthEndRun> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<MonthEndRun> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }
}

extension MonthEndRunQueryWhereSort
    on QueryBuilder<MonthEndRun, MonthEndRun, QWhere> {
  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MonthEndRunQueryWhere
    on QueryBuilder<MonthEndRun, MonthEndRun, QWhereClause> {
  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> idBetween(
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

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> syncGuidEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> syncGuidNotEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncGuid',
              lower: [],
              upper: [syncGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncGuid',
              lower: [syncGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncGuid',
              lower: [syncGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncGuid',
              lower: [],
              upper: [syncGuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> yearMonthEqualTo(
      String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'yearMonth',
        value: [yearMonth],
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterWhereClause> yearMonthNotEqualTo(
      String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [],
              upper: [yearMonth],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [yearMonth],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [yearMonth],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [],
              upper: [yearMonth],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MonthEndRunQueryFilter
    on QueryBuilder<MonthEndRun, MonthEndRun, QFilterCondition> {
  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> actorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      actorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> actorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> actorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> actorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> actorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> actorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> actorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> actorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actor',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      actorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actor',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> appliedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applied',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      carriedMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carriedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      carriedMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carriedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      carriedMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carriedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      carriedMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carriedMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contextGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contextGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contextGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contextGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contextGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contextGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contextGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      contextGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contextGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
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

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
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

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
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

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> currencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      currencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      currencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> currencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      currencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      currencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> currencyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'destinationMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'destinationMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'destinationMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      destinationMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'destinationMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      fingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      hasConflictEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasConflict',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      profileIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      profileIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      profileIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'profileId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      releasedMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'releasedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      releasedMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'releasedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      releasedMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'releasedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      releasedMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'releasedMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reportJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reportJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reportJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reportJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reportJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reportJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reportJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reportJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reportJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      reportJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reportJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      sharedSpaceIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      sharedSpaceIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      sharedSpaceIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharedSpaceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> syncGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      syncGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      syncGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> syncGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      syncGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      syncGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition> syncGuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'yearMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension MonthEndRunQueryObject
    on QueryBuilder<MonthEndRun, MonthEndRun, QFilterCondition> {}

extension MonthEndRunQueryLinks
    on QueryBuilder<MonthEndRun, MonthEndRun, QFilterCondition> {}

extension MonthEndRunQuerySortBy
    on QueryBuilder<MonthEndRun, MonthEndRun, QSortBy> {
  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByActor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actor', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByActorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actor', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByApplied() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applied', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByAppliedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applied', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByCarriedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carriedMinor', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      sortByCarriedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carriedMinor', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByContextGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextGuid', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByContextGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextGuid', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      sortByDestinationMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      sortByDestinationMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByHasConflict() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasConflict', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByHasConflictDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasConflict', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByReleasedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releasedMinor', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      sortByReleasedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releasedMinor', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByReportJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportJson', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByReportJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportJson', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MonthEndRunQuerySortThenBy
    on QueryBuilder<MonthEndRun, MonthEndRun, QSortThenBy> {
  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByActor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actor', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByActorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actor', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByApplied() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applied', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByAppliedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applied', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByCarriedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carriedMinor', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      thenByCarriedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carriedMinor', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByContextGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextGuid', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByContextGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextGuid', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      thenByDestinationMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      thenByDestinationMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByHasConflict() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasConflict', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByHasConflictDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasConflict', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByReleasedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releasedMinor', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      thenByReleasedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'releasedMinor', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByReportJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportJson', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByReportJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportJson', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QAfterSortBy> thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MonthEndRunQueryWhereDistinct
    on QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> {
  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByActor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByApplied() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'applied');
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByCarriedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carriedMinor');
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByContextGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByDestinationMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'destinationMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByFingerprint(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fingerprint', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByHasConflict() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasConflict');
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByReleasedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'releasedMinor');
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByReportJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reportJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthEndRun, MonthEndRun, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension MonthEndRunQueryProperty
    on QueryBuilder<MonthEndRun, MonthEndRun, QQueryProperty> {
  QueryBuilder<MonthEndRun, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MonthEndRun, String, QQueryOperations> actorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actor');
    });
  }

  QueryBuilder<MonthEndRun, bool, QQueryOperations> appliedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'applied');
    });
  }

  QueryBuilder<MonthEndRun, int, QQueryOperations> carriedMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carriedMinor');
    });
  }

  QueryBuilder<MonthEndRun, String, QQueryOperations> contextGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextGuid');
    });
  }

  QueryBuilder<MonthEndRun, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MonthEndRun, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MonthEndRun, String, QQueryOperations>
      destinationMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'destinationMonth');
    });
  }

  QueryBuilder<MonthEndRun, String, QQueryOperations> fingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fingerprint');
    });
  }

  QueryBuilder<MonthEndRun, bool, QQueryOperations> hasConflictProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasConflict');
    });
  }

  QueryBuilder<MonthEndRun, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MonthEndRun, int, QQueryOperations> releasedMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'releasedMinor');
    });
  }

  QueryBuilder<MonthEndRun, String, QQueryOperations> reportJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reportJson');
    });
  }

  QueryBuilder<MonthEndRun, int?, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<MonthEndRun, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<MonthEndRun, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
