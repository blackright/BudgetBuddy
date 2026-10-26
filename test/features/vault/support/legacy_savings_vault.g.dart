// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legacy_savings_vault.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLegacySavingsVaultCollection on Isar {
  IsarCollection<LegacySavingsVault> get legacyVaults => this.collection();
}

const LegacySavingsVaultSchema = CollectionSchema(
  name: r'SavingsVault',
  id: 3318943159278872210,
  properties: {
    r'lastSweepYearMonth': PropertySchema(
      id: 0,
      name: r'lastSweepYearMonth',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 1,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'totalAmount': PropertySchema(
      id: 2,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _legacySavingsVaultEstimateSize,
  serialize: _legacySavingsVaultSerialize,
  deserialize: _legacySavingsVaultDeserialize,
  deserializeProp: _legacySavingsVaultDeserializeProp,
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
  getId: _legacySavingsVaultGetId,
  getLinks: _legacySavingsVaultGetLinks,
  attach: _legacySavingsVaultAttach,
  version: '3.1.0+1',
);

int _legacySavingsVaultEstimateSize(
  LegacySavingsVault object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.lastSweepYearMonth.length * 3;
  return bytesCount;
}

void _legacySavingsVaultSerialize(
  LegacySavingsVault object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.lastSweepYearMonth);
  writer.writeLong(offsets[1], object.profileId);
  writer.writeDouble(offsets[2], object.totalAmount);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

LegacySavingsVault _legacySavingsVaultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LegacySavingsVault();
  object.id = id;
  object.lastSweepYearMonth = reader.readString(offsets[0]);
  object.profileId = reader.readLong(offsets[1]);
  object.totalAmount = reader.readDouble(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _legacySavingsVaultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _legacySavingsVaultGetId(LegacySavingsVault object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _legacySavingsVaultGetLinks(
    LegacySavingsVault object) {
  return [];
}

void _legacySavingsVaultAttach(
    IsarCollection<dynamic> col, Id id, LegacySavingsVault object) {
  object.id = id;
}

extension LegacySavingsVaultByIndex on IsarCollection<LegacySavingsVault> {
  Future<LegacySavingsVault?> getByProfileId(int profileId) {
    return getByIndex(r'profileId', [profileId]);
  }

  LegacySavingsVault? getByProfileIdSync(int profileId) {
    return getByIndexSync(r'profileId', [profileId]);
  }

  Future<bool> deleteByProfileId(int profileId) {
    return deleteByIndex(r'profileId', [profileId]);
  }

  bool deleteByProfileIdSync(int profileId) {
    return deleteByIndexSync(r'profileId', [profileId]);
  }

  Future<List<LegacySavingsVault?>> getAllByProfileId(
      List<int> profileIdValues) {
    final values = profileIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'profileId', values);
  }

  List<LegacySavingsVault?> getAllByProfileIdSync(List<int> profileIdValues) {
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

  Future<Id> putByProfileId(LegacySavingsVault object) {
    return putByIndex(r'profileId', object);
  }

  Id putByProfileIdSync(LegacySavingsVault object, {bool saveLinks = true}) {
    return putByIndexSync(r'profileId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProfileId(List<LegacySavingsVault> objects) {
    return putAllByIndex(r'profileId', objects);
  }

  List<Id> putAllByProfileIdSync(List<LegacySavingsVault> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'profileId', objects, saveLinks: saveLinks);
  }
}

extension LegacySavingsVaultQueryWhereSort
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QWhere> {
  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension LegacySavingsVaultQueryWhere
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QWhereClause> {
  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterWhereClause>
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

extension LegacySavingsVaultQueryFilter
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QFilterCondition> {
  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
      lastSweepYearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastSweepYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
      lastSweepYearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastSweepYearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
      lastSweepYearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSweepYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
      lastSweepYearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastSweepYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterFilterCondition>
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

extension LegacySavingsVaultQueryObject
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QFilterCondition> {}

extension LegacySavingsVaultQueryLinks
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QFilterCondition> {}

extension LegacySavingsVaultQuerySortBy
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QSortBy> {
  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      sortByLastSweepYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      sortByLastSweepYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.desc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LegacySavingsVaultQuerySortThenBy
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QSortThenBy> {
  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByLastSweepYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByLastSweepYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSweepYearMonth', Sort.desc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LegacySavingsVaultQueryWhereDistinct
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QDistinct> {
  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QDistinct>
      distinctByLastSweepYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSweepYearMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QDistinct>
      distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<LegacySavingsVault, LegacySavingsVault, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LegacySavingsVaultQueryProperty
    on QueryBuilder<LegacySavingsVault, LegacySavingsVault, QQueryProperty> {
  QueryBuilder<LegacySavingsVault, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LegacySavingsVault, String, QQueryOperations>
      lastSweepYearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSweepYearMonth');
    });
  }

  QueryBuilder<LegacySavingsVault, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<LegacySavingsVault, double, QQueryOperations>
      totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<LegacySavingsVault, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
