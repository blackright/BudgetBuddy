// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_cycle.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSalaryCycleCollection on Isar {
  IsarCollection<SalaryCycle> get salaryCycles => this.collection();
}

const SalaryCycleSchema = CollectionSchema(
  name: r'SalaryCycle',
  id: -5092203808307022808,
  properties: {
    r'adjustedPayday': PropertySchema(
      id: 0,
      name: r'adjustedPayday',
      type: IsarType.dateTime,
    ),
    r'confirmed': PropertySchema(
      id: 1,
      name: r'confirmed',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 3,
      name: r'currency',
      type: IsarType.string,
    ),
    r'expectedAmountMinor': PropertySchema(
      id: 4,
      name: r'expectedAmountMinor',
      type: IsarType.long,
    ),
    r'guid': PropertySchema(
      id: 5,
      name: r'guid',
      type: IsarType.string,
    ),
    r'nominalPayday': PropertySchema(
      id: 6,
      name: r'nominalPayday',
      type: IsarType.dateTime,
    ),
    r'occurrenceMonth': PropertySchema(
      id: 7,
      name: r'occurrenceMonth',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 8,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'receiptGroupGuid': PropertySchema(
      id: 9,
      name: r'receiptGroupGuid',
      type: IsarType.string,
    ),
    r'scheduleGuid': PropertySchema(
      id: 10,
      name: r'scheduleGuid',
      type: IsarType.string,
    ),
    r'sourceGuid': PropertySchema(
      id: 11,
      name: r'sourceGuid',
      type: IsarType.string,
    ),
    r'state': PropertySchema(
      id: 12,
      name: r'state',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _salaryCycleEstimateSize,
  serialize: _salaryCycleSerialize,
  deserialize: _salaryCycleDeserialize,
  deserializeProp: _salaryCycleDeserializeProp,
  idName: r'id',
  indexes: {
    r'guid': IndexSchema(
      id: 4245463075130215835,
      name: r'guid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'guid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'profileId': IndexSchema(
      id: 6052971939042612300,
      name: r'profileId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'profileId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'sourceGuid': IndexSchema(
      id: 341067348562467865,
      name: r'sourceGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sourceGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'occurrenceMonth': IndexSchema(
      id: -8318907008861240371,
      name: r'occurrenceMonth',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'occurrenceMonth',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _salaryCycleGetId,
  getLinks: _salaryCycleGetLinks,
  attach: _salaryCycleAttach,
  version: '3.1.0+1',
);

int _salaryCycleEstimateSize(
  SalaryCycle object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.guid.length * 3;
  bytesCount += 3 + object.occurrenceMonth.length * 3;
  {
    final value = object.receiptGroupGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.scheduleGuid.length * 3;
  bytesCount += 3 + object.sourceGuid.length * 3;
  bytesCount += 3 + object.state.length * 3;
  return bytesCount;
}

void _salaryCycleSerialize(
  SalaryCycle object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.adjustedPayday);
  writer.writeBool(offsets[1], object.confirmed);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.currency);
  writer.writeLong(offsets[4], object.expectedAmountMinor);
  writer.writeString(offsets[5], object.guid);
  writer.writeDateTime(offsets[6], object.nominalPayday);
  writer.writeString(offsets[7], object.occurrenceMonth);
  writer.writeLong(offsets[8], object.profileId);
  writer.writeString(offsets[9], object.receiptGroupGuid);
  writer.writeString(offsets[10], object.scheduleGuid);
  writer.writeString(offsets[11], object.sourceGuid);
  writer.writeString(offsets[12], object.state);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

SalaryCycle _salaryCycleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SalaryCycle();
  object.adjustedPayday = reader.readDateTime(offsets[0]);
  object.confirmed = reader.readBool(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.currency = reader.readString(offsets[3]);
  object.expectedAmountMinor = reader.readLong(offsets[4]);
  object.guid = reader.readString(offsets[5]);
  object.id = id;
  object.nominalPayday = reader.readDateTime(offsets[6]);
  object.occurrenceMonth = reader.readString(offsets[7]);
  object.profileId = reader.readLongOrNull(offsets[8]);
  object.receiptGroupGuid = reader.readStringOrNull(offsets[9]);
  object.scheduleGuid = reader.readString(offsets[10]);
  object.sourceGuid = reader.readString(offsets[11]);
  object.state = reader.readString(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _salaryCycleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _salaryCycleGetId(SalaryCycle object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _salaryCycleGetLinks(SalaryCycle object) {
  return [];
}

void _salaryCycleAttach(
    IsarCollection<dynamic> col, Id id, SalaryCycle object) {
  object.id = id;
}

extension SalaryCycleByIndex on IsarCollection<SalaryCycle> {
  Future<SalaryCycle?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  SalaryCycle? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<SalaryCycle?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<SalaryCycle?> getAllByGuidSync(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'guid', values);
  }

  Future<int> deleteAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'guid', values);
  }

  int deleteAllByGuidSync(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'guid', values);
  }

  Future<Id> putByGuid(SalaryCycle object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(SalaryCycle object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<SalaryCycle> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<SalaryCycle> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }
}

extension SalaryCycleQueryWhereSort
    on QueryBuilder<SalaryCycle, SalaryCycle, QWhere> {
  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension SalaryCycleQueryWhere
    on QueryBuilder<SalaryCycle, SalaryCycle, QWhereClause> {
  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> idBetween(
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> guidEqualTo(
      String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> guidNotEqualTo(
      String guid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'guid',
              lower: [],
              upper: [guid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'guid',
              lower: [guid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'guid',
              lower: [guid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'guid',
              lower: [],
              upper: [guid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> profileIdEqualTo(
      int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> profileIdNotEqualTo(
      int? profileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause>
      profileIdGreaterThan(
    int? profileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [profileId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> profileIdLessThan(
    int? profileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [],
        upper: [profileId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> profileIdBetween(
    int? lowerProfileId,
    int? upperProfileId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [lowerProfileId],
        includeLower: includeLower,
        upper: [upperProfileId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause> sourceGuidEqualTo(
      String sourceGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sourceGuid',
        value: [sourceGuid],
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause>
      sourceGuidNotEqualTo(String sourceGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceGuid',
              lower: [],
              upper: [sourceGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceGuid',
              lower: [sourceGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceGuid',
              lower: [sourceGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sourceGuid',
              lower: [],
              upper: [sourceGuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause>
      occurrenceMonthEqualTo(String occurrenceMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'occurrenceMonth',
        value: [occurrenceMonth],
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterWhereClause>
      occurrenceMonthNotEqualTo(String occurrenceMonth) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceMonth',
              lower: [],
              upper: [occurrenceMonth],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceMonth',
              lower: [occurrenceMonth],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceMonth',
              lower: [occurrenceMonth],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'occurrenceMonth',
              lower: [],
              upper: [occurrenceMonth],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SalaryCycleQueryFilter
    on QueryBuilder<SalaryCycle, SalaryCycle, QFilterCondition> {
  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      adjustedPaydayEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adjustedPayday',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      adjustedPaydayGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'adjustedPayday',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      adjustedPaydayLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'adjustedPayday',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      adjustedPaydayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'adjustedPayday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      confirmedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmed',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> currencyEqualTo(
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> currencyBetween(
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> currencyMatches(
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      expectedAmountMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      expectedAmountMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      expectedAmountMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      expectedAmountMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedAmountMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'guid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      nominalPaydayEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nominalPayday',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      nominalPaydayGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nominalPayday',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      nominalPaydayLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nominalPayday',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      nominalPaydayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nominalPayday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurrenceMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurrenceMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurrenceMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurrenceMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'occurrenceMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'occurrenceMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'occurrenceMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'occurrenceMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurrenceMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      occurrenceMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'occurrenceMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receiptGroupGuid',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receiptGroupGuid',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptGroupGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'receiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'receiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'receiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'receiptGroupGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptGroupGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      receiptGroupGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receiptGroupGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduleGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scheduleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scheduleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scheduleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scheduleGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduleGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      scheduleGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scheduleGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      sourceGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> stateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      stateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> stateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> stateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'state',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> stateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> stateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> stateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> stateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'state',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition> stateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      stateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterFilterCondition>
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

extension SalaryCycleQueryObject
    on QueryBuilder<SalaryCycle, SalaryCycle, QFilterCondition> {}

extension SalaryCycleQueryLinks
    on QueryBuilder<SalaryCycle, SalaryCycle, QFilterCondition> {}

extension SalaryCycleQuerySortBy
    on QueryBuilder<SalaryCycle, SalaryCycle, QSortBy> {
  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByAdjustedPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustedPayday', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      sortByAdjustedPaydayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustedPayday', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      sortByExpectedAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      sortByExpectedAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByNominalPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominalPayday', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      sortByNominalPaydayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominalPayday', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByOccurrenceMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceMonth', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      sortByOccurrenceMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceMonth', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      sortByReceiptGroupGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGroupGuid', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      sortByReceiptGroupGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGroupGuid', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByScheduleGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleGuid', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      sortByScheduleGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleGuid', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortBySourceGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortBySourceGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SalaryCycleQuerySortThenBy
    on QueryBuilder<SalaryCycle, SalaryCycle, QSortThenBy> {
  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByAdjustedPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustedPayday', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      thenByAdjustedPaydayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adjustedPayday', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      thenByExpectedAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      thenByExpectedAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByNominalPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominalPayday', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      thenByNominalPaydayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominalPayday', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByOccurrenceMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceMonth', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      thenByOccurrenceMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceMonth', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      thenByReceiptGroupGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGroupGuid', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      thenByReceiptGroupGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGroupGuid', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByScheduleGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleGuid', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy>
      thenByScheduleGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleGuid', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenBySourceGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenBySourceGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SalaryCycleQueryWhereDistinct
    on QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> {
  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByAdjustedPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'adjustedPayday');
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmed');
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct>
      distinctByExpectedAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedAmountMinor');
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByNominalPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nominalPayday');
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByOccurrenceMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurrenceMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByReceiptGroupGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptGroupGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByScheduleGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduleGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctBySourceGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryCycle, SalaryCycle, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SalaryCycleQueryProperty
    on QueryBuilder<SalaryCycle, SalaryCycle, QQueryProperty> {
  QueryBuilder<SalaryCycle, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SalaryCycle, DateTime, QQueryOperations>
      adjustedPaydayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'adjustedPayday');
    });
  }

  QueryBuilder<SalaryCycle, bool, QQueryOperations> confirmedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmed');
    });
  }

  QueryBuilder<SalaryCycle, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SalaryCycle, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<SalaryCycle, int, QQueryOperations>
      expectedAmountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedAmountMinor');
    });
  }

  QueryBuilder<SalaryCycle, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<SalaryCycle, DateTime, QQueryOperations>
      nominalPaydayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nominalPayday');
    });
  }

  QueryBuilder<SalaryCycle, String, QQueryOperations>
      occurrenceMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurrenceMonth');
    });
  }

  QueryBuilder<SalaryCycle, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<SalaryCycle, String?, QQueryOperations>
      receiptGroupGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptGroupGuid');
    });
  }

  QueryBuilder<SalaryCycle, String, QQueryOperations> scheduleGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduleGuid');
    });
  }

  QueryBuilder<SalaryCycle, String, QQueryOperations> sourceGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceGuid');
    });
  }

  QueryBuilder<SalaryCycle, String, QQueryOperations> stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }

  QueryBuilder<SalaryCycle, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
