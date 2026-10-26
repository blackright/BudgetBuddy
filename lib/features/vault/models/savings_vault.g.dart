// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_vault.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSavingsVaultCollection on Isar {
  IsarCollection<SavingsVault> get savingsVaults => this.collection();
}

const SavingsVaultSchema = CollectionSchema(
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
    r'goalTargetYearMonth': PropertySchema(
      id: 3,
      name: r'goalTargetYearMonth',
      type: IsarType.string,
    ),
    r'lastSweepYearMonth': PropertySchema(
      id: 4,
      name: r'lastSweepYearMonth',
      type: IsarType.string,
    ),
    r'pauseReason': PropertySchema(
      id: 5,
      name: r'pauseReason',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 6,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'sweepPaused': PropertySchema(
      id: 7,
      name: r'sweepPaused',
      type: IsarType.bool,
    ),
    r'totalAmount': PropertySchema(
      id: 8,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'totalMinor': PropertySchema(
      id: 9,
      name: r'totalMinor',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _savingsVaultEstimateSize,
  serialize: _savingsVaultSerialize,
  deserialize: _savingsVaultDeserialize,
  deserializeProp: _savingsVaultDeserializeProp,
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
  getId: _savingsVaultGetId,
  getLinks: _savingsVaultGetLinks,
  attach: _savingsVaultAttach,
  version: '3.1.0+1',
);

int _savingsVaultEstimateSize(
  SavingsVault object,
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
  {
    final value = object.goalTargetYearMonth;
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

void _savingsVaultSerialize(
  SavingsVault object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.currency);
  writer.writeString(offsets[1], object.goalName);
  writer.writeLong(offsets[2], object.goalTargetMinor);
  writer.writeString(offsets[3], object.goalTargetYearMonth);
  writer.writeString(offsets[4], object.lastSweepYearMonth);
  writer.writeString(offsets[5], object.pauseReason);
  writer.writeLong(offsets[6], object.profileId);
  writer.writeBool(offsets[7], object.sweepPaused);
  writer.writeDouble(offsets[8], object.totalAmount);
  writer.writeLong(offsets[9], object.totalMinor);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

SavingsVault _savingsVaultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavingsVault();
  object.currency = reader.readString(offsets[0]);
  object.goalName = reader.readStringOrNull(offsets[1]);
  object.goalTargetMinor = reader.readLongOrNull(offsets[2]);
  object.goalTargetYearMonth = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.lastSweepYearMonth = reader.readString(offsets[4]);
  object.pauseReason = reader.readStringOrNull(offsets[5]);
  object.profileId = reader.readLong(offsets[6]);
  object.sweepPaused = reader.readBool(offsets[7]);
  object.totalAmount = reader.readDouble(offsets[8]);
  object.totalMinor = reader.readLong(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _savingsVaultDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _savingsVaultGetId(SavingsVault object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _savingsVaultGetLinks(SavingsVault object) {
  return [];
}

void _savingsVaultAttach(
    IsarCollection<dynamic> col, Id id, SavingsVault object) {
  object.id = id;
}

extension SavingsVaultByIndex on IsarCollection<SavingsVault> {
  Future<SavingsVault?> getByProfileId(int profileId) {
    return getByIndex(r'profileId', [profileId]);
  }

  SavingsVault? getByProfileIdSync(int profileId) {
    return getByIndexSync(r'profileId', [profileId]);
  }

  Future<bool> deleteByProfileId(int profileId) {
    return deleteByIndex(r'profileId', [profileId]);
  }

  bool deleteByProfileIdSync(int profileId) {
    return deleteByIndexSync(r'profileId', [profileId]);
  }

  Future<List<SavingsVault?>> getAllByProfileId(List<int> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'profileId', values);
  }

  List<SavingsVault?> getAllByProfileIdSync(List<int> profileIdValues) {
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

  Future<Id> putByProfileId(SavingsVault object) {
    return putByIndex(r'profileId', object);
  }

  Id putByProfileIdSync(SavingsVault object, {bool saveLinks = true}) {
    return putByIndexSync(r'profileId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProfileId(List<SavingsVault> objects) {
    return putAllByIndex(r'profileId', objects);
  }

  List<Id> putAllByProfileIdSync(List<SavingsVault> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'profileId', objects, saveLinks: saveLinks);
  }
}

extension SavingsVaultQueryWhereSort
    on QueryBuilder<SavingsVault, SavingsVault, QWhere> {
  QueryBuilder<SavingsVault, SavingsVault, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension SavingsVaultQueryWhere
    on QueryBuilder<SavingsVault, SavingsVault, QWhereClause> {
  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause> idBetween(
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause> profileIdEqualTo(
      int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause> profileIdLessThan(
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterWhereClause> profileIdBetween(
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

extension SavingsVaultQueryFilter
    on QueryBuilder<SavingsVault, SavingsVault, QFilterCondition> {
  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goalName',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goalName',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goalName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goalName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalName',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goalName',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goalTargetMinor',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goalTargetMinor',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalTargetMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goalTargetYearMonth',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goalTargetYearMonth',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalTargetYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalTargetYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalTargetYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalTargetYearMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'goalTargetYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'goalTargetYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goalTargetYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goalTargetYearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalTargetYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      goalTargetYearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goalTargetYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      lastSweepYearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastSweepYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      lastSweepYearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastSweepYearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      lastSweepYearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSweepYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      lastSweepYearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastSweepYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      pauseReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pauseReason',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      pauseReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pauseReason',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      pauseReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pauseReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      pauseReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pauseReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      pauseReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pauseReason',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      pauseReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pauseReason',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      sweepPausedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sweepPaused',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      totalMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

  QueryBuilder<SavingsVault, SavingsVault, QAfterFilterCondition>
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

extension SavingsVaultQueryObject
    on QueryBuilder<SavingsVault, SavingsVault, QFilterCondition> {}

extension SavingsVaultQueryLinks
    on QueryBuilder<SavingsVault, SavingsVault, QFilterCondition> {}

extension SavingsVaultQuerySortBy
    on QueryBuilder<SavingsVault, SavingsVault, QSortBy> {
  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByGoalName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByGoalNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByGoalTargetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetMinor', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByGoalTargetMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetMinor', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByGoalTargetYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetYearMonth', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByGoalTargetYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetYearMonth', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByLastSweepYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByLastSweepYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByPauseReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseReason', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByPauseReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseReason', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortBySweepPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sweepPaused', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortBySweepPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sweepPaused', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      sortByTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SavingsVaultQuerySortThenBy
    on QueryBuilder<SavingsVault, SavingsVault, QSortThenBy> {
  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByGoalName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByGoalNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByGoalTargetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetMinor', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByGoalTargetMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetMinor', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByGoalTargetYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetYearMonth', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByGoalTargetYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalTargetYearMonth', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByLastSweepYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByLastSweepYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByPauseReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseReason', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByPauseReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pauseReason', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenBySweepPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sweepPaused', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenBySweepPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sweepPaused', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy>
      thenByTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.desc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SavingsVaultQueryWhereDistinct
    on QueryBuilder<SavingsVault, SavingsVault, QDistinct> {
  QueryBuilder<SavingsVault, SavingsVault, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct> distinctByGoalName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct>
      distinctByGoalTargetMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalTargetMinor');
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct>
      distinctByGoalTargetYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalTargetYearMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct>
      distinctByLastSweepYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSweepYearMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct> distinctByPauseReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pauseReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct> distinctBySweepPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sweepPaused');
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct> distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct> distinctByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMinor');
    });
  }

  QueryBuilder<SavingsVault, SavingsVault, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SavingsVaultQueryProperty
    on QueryBuilder<SavingsVault, SavingsVault, QQueryProperty> {
  QueryBuilder<SavingsVault, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SavingsVault, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<SavingsVault, String?, QQueryOperations> goalNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalName');
    });
  }

  QueryBuilder<SavingsVault, int?, QQueryOperations> goalTargetMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalTargetMinor');
    });
  }

  QueryBuilder<SavingsVault, String?, QQueryOperations>
      goalTargetYearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalTargetYearMonth');
    });
  }

  QueryBuilder<SavingsVault, String, QQueryOperations>
      lastSweepYearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSweepYearMonth');
    });
  }

  QueryBuilder<SavingsVault, String?, QQueryOperations> pauseReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pauseReason');
    });
  }

  QueryBuilder<SavingsVault, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<SavingsVault, bool, QQueryOperations> sweepPausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sweepPaused');
    });
  }

  QueryBuilder<SavingsVault, double, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<SavingsVault, int, QQueryOperations> totalMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMinor');
    });
  }

  QueryBuilder<SavingsVault, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
