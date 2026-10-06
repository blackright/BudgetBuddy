// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_rate_set.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLiveRateSetCollection on Isar {
  IsarCollection<LiveRateSet> get liveRateSets => this.collection();
}

const LiveRateSetSchema = CollectionSchema(
  name: r'LiveRateSet',
  id: 7417444720526567966,
  properties: {
    r'fetchedAt': PropertySchema(
      id: 0,
      name: r'fetchedAt',
      type: IsarType.dateTime,
    ),
    r'ratesCad': PropertySchema(
      id: 1,
      name: r'ratesCad',
      type: IsarType.double,
    ),
    r'ratesEur': PropertySchema(
      id: 2,
      name: r'ratesEur',
      type: IsarType.double,
    ),
    r'ratesHuf': PropertySchema(
      id: 3,
      name: r'ratesHuf',
      type: IsarType.double,
    ),
    r'ratesUsd': PropertySchema(
      id: 4,
      name: r'ratesUsd',
      type: IsarType.double,
    ),
    r'source': PropertySchema(
      id: 5,
      name: r'source',
      type: IsarType.byte,
      enumMap: _LiveRateSetsourceEnumValueMap,
    ),
    r'stale': PropertySchema(
      id: 6,
      name: r'stale',
      type: IsarType.bool,
    )
  },
  estimateSize: _liveRateSetEstimateSize,
  serialize: _liveRateSetSerialize,
  deserialize: _liveRateSetDeserialize,
  deserializeProp: _liveRateSetDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _liveRateSetGetId,
  getLinks: _liveRateSetGetLinks,
  attach: _liveRateSetAttach,
  version: '3.1.0+1',
);

int _liveRateSetEstimateSize(
  LiveRateSet object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _liveRateSetSerialize(
  LiveRateSet object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.fetchedAt);
  writer.writeDouble(offsets[1], object.ratesCad);
  writer.writeDouble(offsets[2], object.ratesEur);
  writer.writeDouble(offsets[3], object.ratesHuf);
  writer.writeDouble(offsets[4], object.ratesUsd);
  writer.writeByte(offsets[5], object.source.index);
  writer.writeBool(offsets[6], object.stale);
}

LiveRateSet _liveRateSetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LiveRateSet();
  object.fetchedAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.ratesCad = reader.readDouble(offsets[1]);
  object.ratesEur = reader.readDouble(offsets[2]);
  object.ratesHuf = reader.readDouble(offsets[3]);
  object.ratesUsd = reader.readDouble(offsets[4]);
  object.source =
      _LiveRateSetsourceValueEnumMap[reader.readByteOrNull(offsets[5])] ??
          RateSource.live;
  object.stale = reader.readBool(offsets[6]);
  return object;
}

P _liveRateSetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (_LiveRateSetsourceValueEnumMap[reader.readByteOrNull(offset)] ??
          RateSource.live) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LiveRateSetsourceEnumValueMap = {
  'live': 0,
  'historical': 1,
  'lastKnown': 2,
  'bundled': 3,
};
const _LiveRateSetsourceValueEnumMap = {
  0: RateSource.live,
  1: RateSource.historical,
  2: RateSource.lastKnown,
  3: RateSource.bundled,
};

Id _liveRateSetGetId(LiveRateSet object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _liveRateSetGetLinks(LiveRateSet object) {
  return [];
}

void _liveRateSetAttach(
    IsarCollection<dynamic> col, Id id, LiveRateSet object) {
  object.id = id;
}

extension LiveRateSetQueryWhereSort
    on QueryBuilder<LiveRateSet, LiveRateSet, QWhere> {
  QueryBuilder<LiveRateSet, LiveRateSet, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LiveRateSetQueryWhere
    on QueryBuilder<LiveRateSet, LiveRateSet, QWhereClause> {
  QueryBuilder<LiveRateSet, LiveRateSet, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterWhereClause> idBetween(
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
}

extension LiveRateSetQueryFilter
    on QueryBuilder<LiveRateSet, LiveRateSet, QFilterCondition> {
  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      fetchedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fetchedAt',
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      fetchedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fetchedAt',
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      fetchedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fetchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      fetchedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fetchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      fetchedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fetchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      fetchedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fetchedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> ratesCadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ratesCad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      ratesCadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ratesCad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      ratesCadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ratesCad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> ratesCadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ratesCad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> ratesEurEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ratesEur',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      ratesEurGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ratesEur',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      ratesEurLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ratesEur',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> ratesEurBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ratesEur',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> ratesHufEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ratesHuf',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      ratesHufGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ratesHuf',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      ratesHufLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ratesHuf',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> ratesHufBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ratesHuf',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> ratesUsdEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ratesUsd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      ratesUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ratesUsd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      ratesUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ratesUsd',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> ratesUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ratesUsd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> sourceEqualTo(
      RateSource value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition>
      sourceGreaterThan(
    RateSource value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> sourceLessThan(
    RateSource value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> sourceBetween(
    RateSource lower,
    RateSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterFilterCondition> staleEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stale',
        value: value,
      ));
    });
  }
}

extension LiveRateSetQueryObject
    on QueryBuilder<LiveRateSet, LiveRateSet, QFilterCondition> {}

extension LiveRateSetQueryLinks
    on QueryBuilder<LiveRateSet, LiveRateSet, QFilterCondition> {}

extension LiveRateSetQuerySortBy
    on QueryBuilder<LiveRateSet, LiveRateSet, QSortBy> {
  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByFetchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByRatesCad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesCad', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByRatesCadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesCad', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByRatesEur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesEur', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByRatesEurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesEur', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByRatesHuf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesHuf', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByRatesHufDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesHuf', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByRatesUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesUsd', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByRatesUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesUsd', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stale', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> sortByStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stale', Sort.desc);
    });
  }
}

extension LiveRateSetQuerySortThenBy
    on QueryBuilder<LiveRateSet, LiveRateSet, QSortThenBy> {
  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByFetchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByRatesCad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesCad', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByRatesCadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesCad', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByRatesEur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesEur', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByRatesEurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesEur', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByRatesHuf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesHuf', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByRatesHufDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesHuf', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByRatesUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesUsd', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByRatesUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesUsd', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stale', Sort.asc);
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QAfterSortBy> thenByStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stale', Sort.desc);
    });
  }
}

extension LiveRateSetQueryWhereDistinct
    on QueryBuilder<LiveRateSet, LiveRateSet, QDistinct> {
  QueryBuilder<LiveRateSet, LiveRateSet, QDistinct> distinctByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fetchedAt');
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QDistinct> distinctByRatesCad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesCad');
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QDistinct> distinctByRatesEur() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesEur');
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QDistinct> distinctByRatesHuf() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesHuf');
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QDistinct> distinctByRatesUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesUsd');
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QDistinct> distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source');
    });
  }

  QueryBuilder<LiveRateSet, LiveRateSet, QDistinct> distinctByStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stale');
    });
  }
}

extension LiveRateSetQueryProperty
    on QueryBuilder<LiveRateSet, LiveRateSet, QQueryProperty> {
  QueryBuilder<LiveRateSet, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LiveRateSet, DateTime?, QQueryOperations> fetchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fetchedAt');
    });
  }

  QueryBuilder<LiveRateSet, double, QQueryOperations> ratesCadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesCad');
    });
  }

  QueryBuilder<LiveRateSet, double, QQueryOperations> ratesEurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesEur');
    });
  }

  QueryBuilder<LiveRateSet, double, QQueryOperations> ratesHufProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesHuf');
    });
  }

  QueryBuilder<LiveRateSet, double, QQueryOperations> ratesUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesUsd');
    });
  }

  QueryBuilder<LiveRateSet, RateSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<LiveRateSet, bool, QQueryOperations> staleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stale');
    });
  }
}
