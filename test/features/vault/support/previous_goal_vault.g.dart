// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'previous_goal_vault.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreviousGoalVaultCollection on Isar {
  IsarCollection<PreviousGoalVault> get previousGoalVaults => this.collection();
}

const PreviousGoalVaultSchema = CollectionSchema(
  name: r'SavingsVault',
  id: 3318943159278872210,
  properties: {
    r'currency': PropertySchema(
      id: 0,
      name: r'currency',
      type: IsarType.string,
    ),
    r'goalName': PropertySchema(
      id: 1,
      name: r'goalName',
      type: IsarType.string,
    ),
    r'goalTargetMinor': PropertySchema(
      id: 2,
      name: r'goalTargetMinor',
      type: IsarType.long,
    ),
    r'lastSweepYearMonth': PropertySchema(
      id: 3,
      name: r'lastSweepYearMonth',
      type: IsarType.string,
    ),
    r'pauseReason': PropertySchema(
      id: 4,
      name: r'pauseReason',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 5,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'sweepPaused': PropertySchema(
      id: 6,
      name: r'sweepPaused',
      type: IsarType.bool,
    ),
    r'totalAmount': PropertySchema(
      id: 7,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'totalMinor': PropertySchema(
      id: 8,
      name: r'totalMinor',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _previousGoalVaultEstimateSize,
  serialize: _previousGoalVaultSerialize,
  deserialize: _previousGoalVaultDeserialize,
  deserializeProp: _previousGoalVaultDeserializeProp,
  idName: r'id',
  indexes: {
    r'profileId': IndexSchema(
      id: 6052971939042612300,
      name: r'profileId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'profileId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _previousGoalVaultGetId,
  getLinks: _previousGoalVaultGetLinks,
  attach: _previousGoalVaultAttach,
  version: '3.1.0+1',
);

int _previousGoalVaultEstimateSize(
  PreviousGoalVault object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  {
    final value = object.goalName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.lastSweepYearMonth.length * 3;
  {
    final value = object.pauseReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _previousGoalVaultSerialize(
  PreviousGoalVault object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.currency);
  writer.writeString(offsets[1], object.goalName);
  writer.writeLong(offsets[2], object.goalTargetMinor);
  writer.writeString(offsets[3], object.lastSweepYearMonth);
  writer.writeString(offsets[4], object.pauseReason);
  writer.writeLong(offsets[5], object.profileId);
  writer.writeBool(offsets[6], object.sweepPaused);
  writer.writeDouble(offsets[7], object.totalAmount);
  writer.writeLong(offsets[8], object.totalMinor);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

PreviousGoalVault _previousGoalVaultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PreviousGoalVault();
  object.currency = reader.readString(offsets[0]);
  object.goalName = reader.readStringOrNull(offsets[1]);
  object.goalTargetMinor = reader.readLongOrNull(offsets[2]);
  object.id = id;
  object.lastSweepYearMonth = reader.readString(offsets[3]);
  object.pauseReason = reader.readStringOrNull(offsets[4]);
  object.profileId = reader.readLong(offsets[5]);
  object.sweepPaused = reader.readBool(offsets[6]);
  object.totalAmount = reader.readDouble(offsets[7]);
  object.totalMinor = reader.readLong(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _previousGoalVaultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _previousGoalVaultGetId(PreviousGoalVault object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _previousGoalVaultGetLinks(
    PreviousGoalVault object) {
  return [];
}

void _previousGoalVaultAttach(
    IsarCollection<dynamic> col, Id id, PreviousGoalVault object) {
  object.id = id;
}

extension PreviousGoalVaultByIndex on IsarCollection<PreviousGoalVault> {
  Future<PreviousGoalVault?> getByProfileId(int profileId) {
    return getByIndex(r'profileId', [profileId]);
  }

  PreviousGoalVault? getByProfileIdSync(int profileId) {
    return getByIndexSync(r'profileId', [profileId]);
  }

  Future<bool> deleteByProfileId(int profileId) {
    return deleteByIndex(r'profileId', [profileId]);
  }

  bool deleteByProfileIdSync(int profileId) {
    return deleteByIndexSync(r'profileId', [profileId]);
  }

  Future<List<PreviousGoalVault?>> getAllByProfileId(
      List<int> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'profileId', values);
  }

  List<PreviousGoalVault?> getAllByProfileIdSync(List<int> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'profileId', values);
  }

  Future<int> deleteAllByProfileId(List<int> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'profileId', values);
  }

  int deleteAllByProfileIdSync(List<int> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'profileId', values);
  }

  Future<Id> putByProfileId(PreviousGoalVault object) {
    return putByIndex(r'profileId', object);
  }

  Id putByProfileIdSync(PreviousGoalVault object, {bool saveLinks = true}) {
    return putByIndexSync(r'profileId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProfileId(List<PreviousGoalVault> objects) {
    return putAllByIndex(r'profileId', objects);
  }

  List<Id> putAllByProfileIdSync(List<PreviousGoalVault> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'profileId', objects, saveLinks: saveLinks);
  }
}

extension PreviousGoalVaultQueryWhereSort
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QWhere> {
  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension PreviousGoalVaultQueryWhere
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QWhereClause> {
  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      profileIdNotEqualTo(int profileId) {
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      profileIdGreaterThan(
    int profileId, {
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      profileIdLessThan(
    int profileId, {
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterWhereClause>
      profileIdBetween(
    int lowerProfileId,
    int upperProfileId, {
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
}

extension PreviousGoalVaultQueryFilter
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QFilterCondition> {
  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      currencyEqualTo(
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      currencyBetween(
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goalName',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goalName',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'goalName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'goalName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goalName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goalName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalName',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goalName',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalTargetMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goalTargetMinor',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalTargetMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goalTargetMinor',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalTargetMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalTargetMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalTargetMinorGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalTargetMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalTargetMinorLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalTargetMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      goalTargetMinorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalTargetMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSweepYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSweepYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSweepYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSweepYearMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastSweepYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastSweepYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastSweepYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastSweepYearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSweepYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      lastSweepYearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastSweepYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pauseReason',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pauseReason',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pauseReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pauseReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pauseReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pauseReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pauseReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pauseReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pauseReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pauseReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pauseReason',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      pauseReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pauseReason',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      profileIdGreaterThan(
    int value, {
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      profileIdLessThan(
    int value, {
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      profileIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      sweepPausedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sweepPaused',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      totalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      totalMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      totalMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      totalMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      totalMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterFilterCondition>
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

extension PreviousGoalVaultQueryObject
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QFilterCondition> {}

extension PreviousGoalVaultQueryLinks
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QFilterCondition> {}

extension PreviousGoalVaultQuerySortBy
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QSortBy> {
  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByGoalName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByGoalNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByGoalTargetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetMinor', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByGoalTargetMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetMinor', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByLastSweepYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByLastSweepYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByPauseReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseReason', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByPauseReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseReason', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortBySweepPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sweepPaused', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortBySweepPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sweepPaused', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PreviousGoalVaultQuerySortThenBy
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QSortThenBy> {
  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByGoalName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByGoalNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByGoalTargetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetMinor', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByGoalTargetMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetMinor', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByLastSweepYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByLastSweepYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByPauseReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseReason', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByPauseReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseReason', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenBySweepPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sweepPaused', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenBySweepPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sweepPaused', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.desc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PreviousGoalVaultQueryWhereDistinct
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct> {
  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByGoalName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByGoalTargetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalTargetMinor');
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByLastSweepYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSweepYearMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByPauseReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pauseReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctBySweepPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sweepPaused');
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMinor');
    });
  }

  QueryBuilder<PreviousGoalVault, PreviousGoalVault, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PreviousGoalVaultQueryProperty
    on QueryBuilder<PreviousGoalVault, PreviousGoalVault, QQueryProperty> {
  QueryBuilder<PreviousGoalVault, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PreviousGoalVault, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<PreviousGoalVault, String?, QQueryOperations>
      goalNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalName');
    });
  }

  QueryBuilder<PreviousGoalVault, int?, QQueryOperations>
      goalTargetMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalTargetMinor');
    });
  }

  QueryBuilder<PreviousGoalVault, String, QQueryOperations>
      lastSweepYearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSweepYearMonth');
    });
  }

  QueryBuilder<PreviousGoalVault, String?, QQueryOperations>
      pauseReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pauseReason');
    });
  }

  QueryBuilder<PreviousGoalVault, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<PreviousGoalVault, bool, QQueryOperations>
      sweepPausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sweepPaused');
    });
  }

  QueryBuilder<PreviousGoalVault, double, QQueryOperations>
      totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<PreviousGoalVault, int, QQueryOperations> totalMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMinor');
    });
  }

  QueryBuilder<PreviousGoalVault, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
