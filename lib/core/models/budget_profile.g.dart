// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBudgetProfileCollection on Isar {
  IsarCollection<BudgetProfile> get budgetProfiles => this.collection();
}

const BudgetProfileSchema = CollectionSchema(
  name: r'BudgetProfile',
  id: -2685555096098057569,
  properties: {
    r'allocation': PropertySchema(
      id: 0,
      name: r'allocation',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'defaultAllocationMinor': PropertySchema(
      id: 2,
      name: r'defaultAllocationMinor',
      type: IsarType.long,
    ),
    r'familyGuid': PropertySchema(
      id: 3,
      name: r'familyGuid',
      type: IsarType.string,
    ),
    r'monthEndFingerprint': PropertySchema(
      id: 4,
      name: r'monthEndFingerprint',
      type: IsarType.string,
    ),
    r'monthEndOriginGuid': PropertySchema(
      id: 5,
      name: r'monthEndOriginGuid',
      type: IsarType.string,
    ),
    r'monthEndRule': PropertySchema(
      id: 6,
      name: r'monthEndRule',
      type: IsarType.byte,
      enumMap: _BudgetProfilemonthEndRuleEnumValueMap,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 8,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 9,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'spent': PropertySchema(
      id: 10,
      name: r'spent',
      type: IsarType.long,
    ),
    r'syncGuid': PropertySchema(
      id: 11,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'yearMonth': PropertySchema(
      id: 13,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _budgetProfileEstimateSize,
  serialize: _budgetProfileSerialize,
  deserialize: _budgetProfileDeserialize,
  deserializeProp: _budgetProfileDeserializeProp,
  idName: r'id',
  indexes: {
    r'syncGuid': IndexSchema(
      id: 6159741003405035971,
      name: r'syncGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'familyGuid': IndexSchema(
      id: 6174364082624124110,
      name: r'familyGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'familyGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _budgetProfileGetId,
  getLinks: _budgetProfileGetLinks,
  attach: _budgetProfileAttach,
  version: '3.1.0+1',
);

int _budgetProfileEstimateSize(
  BudgetProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.familyGuid.length * 3;
  {
    final value = object.monthEndFingerprint;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.monthEndOriginGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _budgetProfileSerialize(
  BudgetProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.allocation);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.defaultAllocationMinor);
  writer.writeString(offsets[3], object.familyGuid);
  writer.writeString(offsets[4], object.monthEndFingerprint);
  writer.writeString(offsets[5], object.monthEndOriginGuid);
  writer.writeByte(offsets[6], object.monthEndRule.index);
  writer.writeString(offsets[7], object.name);
  writer.writeLong(offsets[8], object.profileId);
  writer.writeLong(offsets[9], object.sharedSpaceId);
  writer.writeLong(offsets[10], object.spent);
  writer.writeString(offsets[11], object.syncGuid);
  writer.writeDateTime(offsets[12], object.updatedAt);
  writer.writeString(offsets[13], object.yearMonth);
}

BudgetProfile _budgetProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BudgetProfile();
  object.allocation = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.defaultAllocationMinor = reader.readLongOrNull(offsets[2]);
  object.familyGuid = reader.readString(offsets[3]);
  object.id = id;
  object.monthEndFingerprint = reader.readStringOrNull(offsets[4]);
  object.monthEndOriginGuid = reader.readStringOrNull(offsets[5]);
  object.monthEndRule = _BudgetProfilemonthEndRuleValueEnumMap[
          reader.readByteOrNull(offsets[6])] ??
      MonthEndRule.reset;
  object.name = reader.readString(offsets[7]);
  object.profileId = reader.readLongOrNull(offsets[8]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[9]);
  object.spent = reader.readLong(offsets[10]);
  object.syncGuid = reader.readString(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  object.yearMonth = reader.readString(offsets[13]);
  return object;
}

P _budgetProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (_BudgetProfilemonthEndRuleValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MonthEndRule.reset) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BudgetProfilemonthEndRuleEnumValueMap = {
  'reset': 0,
  'carryForward': 1,
};
const _BudgetProfilemonthEndRuleValueEnumMap = {
  0: MonthEndRule.reset,
  1: MonthEndRule.carryForward,
};

Id _budgetProfileGetId(BudgetProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _budgetProfileGetLinks(BudgetProfile object) {
  return [];
}

void _budgetProfileAttach(
    IsarCollection<dynamic> col, Id id, BudgetProfile object) {
  object.id = id;
}

extension BudgetProfileQueryWhereSort
    on QueryBuilder<BudgetProfile, BudgetProfile, QWhere> {
  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BudgetProfileQueryWhere
    on QueryBuilder<BudgetProfile, BudgetProfile, QWhereClause> {
  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause> idBetween(
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause> syncGuidEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause>
      syncGuidNotEqualTo(String syncGuid) {
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause>
      familyGuidEqualTo(String familyGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'familyGuid',
        value: [familyGuid],
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterWhereClause>
      familyGuidNotEqualTo(String familyGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'familyGuid',
              lower: [],
              upper: [familyGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'familyGuid',
              lower: [familyGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'familyGuid',
              lower: [familyGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'familyGuid',
              lower: [],
              upper: [familyGuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BudgetProfileQueryFilter
    on QueryBuilder<BudgetProfile, BudgetProfile, QFilterCondition> {
  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      allocationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allocation',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      allocationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'allocation',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      allocationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'allocation',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      allocationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'allocation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      defaultAllocationMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'defaultAllocationMinor',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      defaultAllocationMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'defaultAllocationMinor',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      defaultAllocationMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultAllocationMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      defaultAllocationMinorGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultAllocationMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      defaultAllocationMinorLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultAllocationMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      defaultAllocationMinorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultAllocationMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'familyGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'familyGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'familyGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'familyGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'familyGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'familyGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'familyGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'familyGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'familyGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      familyGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'familyGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'monthEndFingerprint',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'monthEndFingerprint',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthEndFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthEndFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthEndFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthEndFingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monthEndFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monthEndFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monthEndFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monthEndFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthEndFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monthEndFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'monthEndOriginGuid',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'monthEndOriginGuid',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthEndOriginGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthEndOriginGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthEndOriginGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthEndOriginGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monthEndOriginGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monthEndOriginGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monthEndOriginGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monthEndOriginGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthEndOriginGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndOriginGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monthEndOriginGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndRuleEqualTo(MonthEndRule value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthEndRule',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndRuleGreaterThan(
    MonthEndRule value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthEndRule',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndRuleLessThan(
    MonthEndRule value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthEndRule',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      monthEndRuleBetween(
    MonthEndRule lower,
    MonthEndRule upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthEndRule',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      spentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spent',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      spentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spent',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      spentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spent',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      spentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      syncGuidEqualTo(
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      syncGuidBetween(
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
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

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension BudgetProfileQueryObject
    on QueryBuilder<BudgetProfile, BudgetProfile, QFilterCondition> {}

extension BudgetProfileQueryLinks
    on QueryBuilder<BudgetProfile, BudgetProfile, QFilterCondition> {}

extension BudgetProfileQuerySortBy
    on QueryBuilder<BudgetProfile, BudgetProfile, QSortBy> {
  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortByAllocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allocation', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByAllocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allocation', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByDefaultAllocationMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultAllocationMinor', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByDefaultAllocationMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultAllocationMinor', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortByFamilyGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyGuid', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByFamilyGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyGuid', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByMonthEndFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndFingerprint', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByMonthEndFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndFingerprint', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByMonthEndOriginGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndOriginGuid', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByMonthEndOriginGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndOriginGuid', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByMonthEndRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndRule', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByMonthEndRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndRule', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortBySpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spent', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortBySpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spent', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension BudgetProfileQuerySortThenBy
    on QueryBuilder<BudgetProfile, BudgetProfile, QSortThenBy> {
  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByAllocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allocation', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByAllocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allocation', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByDefaultAllocationMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultAllocationMinor', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByDefaultAllocationMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultAllocationMinor', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByFamilyGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyGuid', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByFamilyGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyGuid', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByMonthEndFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndFingerprint', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByMonthEndFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndFingerprint', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByMonthEndOriginGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndOriginGuid', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByMonthEndOriginGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndOriginGuid', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByMonthEndRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndRule', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByMonthEndRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthEndRule', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenBySpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spent', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenBySpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spent', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy> thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension BudgetProfileQueryWhereDistinct
    on QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> {
  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctByAllocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allocation');
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct>
      distinctByDefaultAllocationMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultAllocationMinor');
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctByFamilyGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'familyGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct>
      distinctByMonthEndFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthEndFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct>
      distinctByMonthEndOriginGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthEndOriginGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct>
      distinctByMonthEndRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthEndRule');
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctBySpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spent');
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BudgetProfile, BudgetProfile, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension BudgetProfileQueryProperty
    on QueryBuilder<BudgetProfile, BudgetProfile, QQueryProperty> {
  QueryBuilder<BudgetProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BudgetProfile, int, QQueryOperations> allocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allocation');
    });
  }

  QueryBuilder<BudgetProfile, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BudgetProfile, int?, QQueryOperations>
      defaultAllocationMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultAllocationMinor');
    });
  }

  QueryBuilder<BudgetProfile, String, QQueryOperations> familyGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'familyGuid');
    });
  }

  QueryBuilder<BudgetProfile, String?, QQueryOperations>
      monthEndFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthEndFingerprint');
    });
  }

  QueryBuilder<BudgetProfile, String?, QQueryOperations>
      monthEndOriginGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthEndOriginGuid');
    });
  }

  QueryBuilder<BudgetProfile, MonthEndRule, QQueryOperations>
      monthEndRuleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthEndRule');
    });
  }

  QueryBuilder<BudgetProfile, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<BudgetProfile, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<BudgetProfile, int?, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<BudgetProfile, int, QQueryOperations> spentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spent');
    });
  }

  QueryBuilder<BudgetProfile, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<BudgetProfile, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BudgetProfile, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
