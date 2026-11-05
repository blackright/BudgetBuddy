// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_schedule.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSalaryScheduleCollection on Isar {
  IsarCollection<SalarySchedule> get salarySchedules => this.collection();
}

const SalaryScheduleSchema = CollectionSchema(
  name: r'SalarySchedule',
  id: 1204624585677271746,
  properties: {
    r'calendarVerified': PropertySchema(
      id: 0,
      name: r'calendarVerified',
      type: IsarType.bool,
    ),
    r'countryCode': PropertySchema(
      id: 1,
      name: r'countryCode',
      type: IsarType.string,
    ),
    r'coverageEnd': PropertySchema(
      id: 2,
      name: r'coverageEnd',
      type: IsarType.dateTime,
    ),
    r'coverageStart': PropertySchema(
      id: 3,
      name: r'coverageStart',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'guid': PropertySchema(
      id: 5,
      name: r'guid',
      type: IsarType.string,
    ),
    r'nominalDay': PropertySchema(
      id: 6,
      name: r'nominalDay',
      type: IsarType.long,
    ),
    r'policyRevision': PropertySchema(
      id: 7,
      name: r'policyRevision',
      type: IsarType.long,
    ),
    r'profileId': PropertySchema(
      id: 8,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'regionCode': PropertySchema(
      id: 9,
      name: r'regionCode',
      type: IsarType.string,
    ),
    r'sourceGuid': PropertySchema(
      id: 10,
      name: r'sourceGuid',
      type: IsarType.string,
    ),
    r'timezone': PropertySchema(
      id: 11,
      name: r'timezone',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _salaryScheduleEstimateSize,
  serialize: _salaryScheduleSerialize,
  deserialize: _salaryScheduleDeserialize,
  deserializeProp: _salaryScheduleDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _salaryScheduleGetId,
  getLinks: _salaryScheduleGetLinks,
  attach: _salaryScheduleAttach,
  version: '3.1.0+1',
);

int _salaryScheduleEstimateSize(
  SalarySchedule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.countryCode.length * 3;
  bytesCount += 3 + object.guid.length * 3;
  {
    final value = object.regionCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceGuid.length * 3;
  bytesCount += 3 + object.timezone.length * 3;
  return bytesCount;
}

void _salaryScheduleSerialize(
  SalarySchedule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.calendarVerified);
  writer.writeString(offsets[1], object.countryCode);
  writer.writeDateTime(offsets[2], object.coverageEnd);
  writer.writeDateTime(offsets[3], object.coverageStart);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.guid);
  writer.writeLong(offsets[6], object.nominalDay);
  writer.writeLong(offsets[7], object.policyRevision);
  writer.writeLong(offsets[8], object.profileId);
  writer.writeString(offsets[9], object.regionCode);
  writer.writeString(offsets[10], object.sourceGuid);
  writer.writeString(offsets[11], object.timezone);
  writer.writeDateTime(offsets[12], object.updatedAt);
}

SalarySchedule _salaryScheduleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SalarySchedule();
  object.calendarVerified = reader.readBool(offsets[0]);
  object.countryCode = reader.readString(offsets[1]);
  object.coverageEnd = reader.readDateTimeOrNull(offsets[2]);
  object.coverageStart = reader.readDateTimeOrNull(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.guid = reader.readString(offsets[5]);
  object.id = id;
  object.nominalDay = reader.readLong(offsets[6]);
  object.policyRevision = reader.readLong(offsets[7]);
  object.profileId = reader.readLongOrNull(offsets[8]);
  object.regionCode = reader.readStringOrNull(offsets[9]);
  object.sourceGuid = reader.readString(offsets[10]);
  object.timezone = reader.readString(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  return object;
}

P _salaryScheduleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _salaryScheduleGetId(SalarySchedule object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _salaryScheduleGetLinks(SalarySchedule object) {
  return [];
}

void _salaryScheduleAttach(
    IsarCollection<dynamic> col, Id id, SalarySchedule object) {
  object.id = id;
}

extension SalaryScheduleByIndex on IsarCollection<SalarySchedule> {
  Future<SalarySchedule?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  SalarySchedule? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<SalarySchedule?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<SalarySchedule?> getAllByGuidSync(List<String> guidValues) {
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

  Future<Id> putByGuid(SalarySchedule object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(SalarySchedule object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<SalarySchedule> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<SalarySchedule> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }
}

extension SalaryScheduleQueryWhereSort
    on QueryBuilder<SalarySchedule, SalarySchedule, QWhere> {
  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension SalaryScheduleQueryWhere
    on QueryBuilder<SalarySchedule, SalarySchedule, QWhereClause> {
  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause> idBetween(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause> guidEqualTo(
      String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
      guidNotEqualTo(String guid) {
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
      profileIdEqualTo(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
      profileIdNotEqualTo(int? profileId) {
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
      profileIdLessThan(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
      profileIdBetween(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
      sourceGuidEqualTo(String sourceGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sourceGuid',
        value: [sourceGuid],
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterWhereClause>
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
}

extension SalaryScheduleQueryFilter
    on QueryBuilder<SalarySchedule, SalarySchedule, QFilterCondition> {
  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      calendarVerifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calendarVerified',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'countryCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'countryCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countryCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      countryCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'countryCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverageEnd',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverageEnd',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageEndEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverageEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageEndGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverageEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageEndLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverageEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverageEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'coverageStart',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'coverageStart',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverageStart',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageStartGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coverageStart',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageStartLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coverageStart',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      coverageStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coverageStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidEqualTo(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidGreaterThan(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidLessThan(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidBetween(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidStartsWith(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidEndsWith(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      nominalDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nominalDay',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      nominalDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nominalDay',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      nominalDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nominalDay',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      nominalDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nominalDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      policyRevisionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyRevision',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      policyRevisionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'policyRevision',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      policyRevisionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'policyRevision',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      policyRevisionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'policyRevision',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'regionCode',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'regionCode',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'regionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'regionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'regionCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'regionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'regionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'regionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'regionCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regionCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      regionCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'regionCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      sourceGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      sourceGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      sourceGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      sourceGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timezone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'timezone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timezone',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      timezoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'timezone',
        value: '',
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterFilterCondition>
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

extension SalaryScheduleQueryObject
    on QueryBuilder<SalarySchedule, SalarySchedule, QFilterCondition> {}

extension SalaryScheduleQueryLinks
    on QueryBuilder<SalarySchedule, SalarySchedule, QFilterCondition> {}

extension SalaryScheduleQuerySortBy
    on QueryBuilder<SalarySchedule, SalarySchedule, QSortBy> {
  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCalendarVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarVerified', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCalendarVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarVerified', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCoverageEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageEnd', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCoverageEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageEnd', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCoverageStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageStart', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCoverageStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageStart', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByNominalDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominalDay', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByNominalDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominalDay', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByPolicyRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyRevision', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByPolicyRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyRevision', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByRegionCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionCode', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByRegionCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionCode', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortBySourceGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortBySourceGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> sortByTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SalaryScheduleQuerySortThenBy
    on QueryBuilder<SalarySchedule, SalarySchedule, QSortThenBy> {
  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCalendarVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarVerified', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCalendarVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarVerified', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCoverageEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageEnd', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCoverageEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageEnd', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCoverageStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageStart', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCoverageStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageStart', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByNominalDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominalDay', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByNominalDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nominalDay', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByPolicyRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyRevision', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByPolicyRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyRevision', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByRegionCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionCode', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByRegionCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionCode', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenBySourceGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenBySourceGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> thenByTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.desc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SalaryScheduleQueryWhereDistinct
    on QueryBuilder<SalarySchedule, SalarySchedule, QDistinct> {
  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct>
      distinctByCalendarVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calendarVerified');
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct> distinctByCountryCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countryCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct>
      distinctByCoverageEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverageEnd');
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct>
      distinctByCoverageStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverageStart');
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct>
      distinctByNominalDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nominalDay');
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct>
      distinctByPolicyRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'policyRevision');
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct> distinctByRegionCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'regionCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct> distinctBySourceGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct> distinctByTimezone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timezone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalarySchedule, SalarySchedule, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SalaryScheduleQueryProperty
    on QueryBuilder<SalarySchedule, SalarySchedule, QQueryProperty> {
  QueryBuilder<SalarySchedule, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SalarySchedule, bool, QQueryOperations>
      calendarVerifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calendarVerified');
    });
  }

  QueryBuilder<SalarySchedule, String, QQueryOperations> countryCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countryCode');
    });
  }

  QueryBuilder<SalarySchedule, DateTime?, QQueryOperations>
      coverageEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverageEnd');
    });
  }

  QueryBuilder<SalarySchedule, DateTime?, QQueryOperations>
      coverageStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverageStart');
    });
  }

  QueryBuilder<SalarySchedule, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SalarySchedule, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<SalarySchedule, int, QQueryOperations> nominalDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nominalDay');
    });
  }

  QueryBuilder<SalarySchedule, int, QQueryOperations> policyRevisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'policyRevision');
    });
  }

  QueryBuilder<SalarySchedule, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<SalarySchedule, String?, QQueryOperations> regionCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'regionCode');
    });
  }

  QueryBuilder<SalarySchedule, String, QQueryOperations> sourceGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceGuid');
    });
  }

  QueryBuilder<SalarySchedule, String, QQueryOperations> timezoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timezone');
    });
  }

  QueryBuilder<SalarySchedule, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
