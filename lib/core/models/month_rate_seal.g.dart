// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_rate_seal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMonthRateSealCollection on Isar {
  IsarCollection<MonthRateSeal> get monthRateSeals => this.collection();
}

const MonthRateSealSchema = CollectionSchema(
  name: r'MonthRateSeal',
  id: -6540986685470357757,
  properties: {
    r'asOf': PropertySchema(
      id: 0,
      name: r'asOf',
      type: IsarType.dateTime,
    ),
    r'attemptCount': PropertySchema(
      id: 1,
      name: r'attemptCount',
      type: IsarType.long,
    ),
    r'closedAt': PropertySchema(
      id: 2,
      name: r'closedAt',
      type: IsarType.dateTime,
    ),
    r'fetchedAt': PropertySchema(
      id: 3,
      name: r'fetchedAt',
      type: IsarType.dateTime,
    ),
    r'ratesCad': PropertySchema(
      id: 4,
      name: r'ratesCad',
      type: IsarType.double,
    ),
    r'ratesEur': PropertySchema(
      id: 5,
      name: r'ratesEur',
      type: IsarType.double,
    ),
    r'ratesHuf': PropertySchema(
      id: 6,
      name: r'ratesHuf',
      type: IsarType.double,
    ),
    r'ratesUsd': PropertySchema(
      id: 7,
      name: r'ratesUsd',
      type: IsarType.double,
    ),
    r'source': PropertySchema(
      id: 8,
      name: r'source',
      type: IsarType.byte,
      enumMap: _MonthRateSealsourceEnumValueMap,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.byte,
      enumMap: _MonthRateSealstatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'yearMonth': PropertySchema(
      id: 11,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _monthRateSealEstimateSize,
  serialize: _monthRateSealSerialize,
  deserialize: _monthRateSealDeserialize,
  deserializeProp: _monthRateSealDeserializeProp,
  idName: r'id',
  indexes: {
    r'yearMonth': IndexSchema(
      id: 5465596700411800841,
      name: r'yearMonth',
      unique: true,
      replace: true,
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
  getId: _monthRateSealGetId,
  getLinks: _monthRateSealGetLinks,
  attach: _monthRateSealAttach,
  version: '3.1.0+1',
);

int _monthRateSealEstimateSize(
  MonthRateSeal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _monthRateSealSerialize(
  MonthRateSeal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.asOf);
  writer.writeLong(offsets[1], object.attemptCount);
  writer.writeDateTime(offsets[2], object.closedAt);
  writer.writeDateTime(offsets[3], object.fetchedAt);
  writer.writeDouble(offsets[4], object.ratesCad);
  writer.writeDouble(offsets[5], object.ratesEur);
  writer.writeDouble(offsets[6], object.ratesHuf);
  writer.writeDouble(offsets[7], object.ratesUsd);
  writer.writeByte(offsets[8], object.source.index);
  writer.writeByte(offsets[9], object.status.index);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeString(offsets[11], object.yearMonth);
}

MonthRateSeal _monthRateSealDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MonthRateSeal();
  object.asOf = reader.readDateTime(offsets[0]);
  object.attemptCount = reader.readLong(offsets[1]);
  object.closedAt = reader.readDateTimeOrNull(offsets[2]);
  object.fetchedAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.ratesCad = reader.readDouble(offsets[4]);
  object.ratesEur = reader.readDouble(offsets[5]);
  object.ratesHuf = reader.readDouble(offsets[6]);
  object.ratesUsd = reader.readDouble(offsets[7]);
  object.source =
      _MonthRateSealsourceValueEnumMap[reader.readByteOrNull(offsets[8])] ??
          RateSource.live;
  object.status =
      _MonthRateSealstatusValueEnumMap[reader.readByteOrNull(offsets[9])] ??
          SealStatus.open;
  object.updatedAt = reader.readDateTime(offsets[10]);
  object.yearMonth = reader.readString(offsets[11]);
  return object;
}

P _monthRateSealDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (_MonthRateSealsourceValueEnumMap[reader.readByteOrNull(offset)] ??
          RateSource.live) as P;
    case 9:
      return (_MonthRateSealstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          SealStatus.open) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MonthRateSealsourceEnumValueMap = {
  'live': 0,
  'historical': 1,
  'lastKnown': 2,
  'bundled': 3,
};
const _MonthRateSealsourceValueEnumMap = {
  0: RateSource.live,
  1: RateSource.historical,
  2: RateSource.lastKnown,
  3: RateSource.bundled,
};
const _MonthRateSealstatusEnumValueMap = {
  'open': 0,
  'provisional': 1,
  'sealed': 2,
  'approximate': 3,
};
const _MonthRateSealstatusValueEnumMap = {
  0: SealStatus.open,
  1: SealStatus.provisional,
  2: SealStatus.sealed,
  3: SealStatus.approximate,
};

Id _monthRateSealGetId(MonthRateSeal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _monthRateSealGetLinks(MonthRateSeal object) {
  return [];
}

void _monthRateSealAttach(
    IsarCollection<dynamic> col, Id id, MonthRateSeal object) {
  object.id = id;
}

extension MonthRateSealByIndex on IsarCollection<MonthRateSeal> {
  Future<MonthRateSeal?> getByYearMonth(String yearMonth) {
    return getByIndex(r'yearMonth', [yearMonth]);
  }

  MonthRateSeal? getByYearMonthSync(String yearMonth) {
    return getByIndexSync(r'yearMonth', [yearMonth]);
  }

  Future<bool> deleteByYearMonth(String yearMonth) {
    return deleteByIndex(r'yearMonth', [yearMonth]);
  }

  bool deleteByYearMonthSync(String yearMonth) {
    return deleteByIndexSync(r'yearMonth', [yearMonth]);
  }

  Future<List<MonthRateSeal?>> getAllByYearMonth(List<String> yearMonthValues) {
    final values = yearMonthValues.map((e) => [e]).toList();
    return getAllByIndex(r'yearMonth', values);
  }

  List<MonthRateSeal?> getAllByYearMonthSync(List<String> yearMonthValues) {
    final values = yearMonthValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'yearMonth', values);
  }

  Future<int> deleteAllByYearMonth(List<String> yearMonthValues) {
    final values = yearMonthValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'yearMonth', values);
  }

  int deleteAllByYearMonthSync(List<String> yearMonthValues) {
    final values = yearMonthValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'yearMonth', values);
  }

  Future<Id> putByYearMonth(MonthRateSeal object) {
    return putByIndex(r'yearMonth', object);
  }

  Id putByYearMonthSync(MonthRateSeal object, {bool saveLinks = true}) {
    return putByIndexSync(r'yearMonth', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByYearMonth(List<MonthRateSeal> objects) {
    return putAllByIndex(r'yearMonth', objects);
  }

  List<Id> putAllByYearMonthSync(List<MonthRateSeal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'yearMonth', objects, saveLinks: saveLinks);
  }
}

extension MonthRateSealQueryWhereSort
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QWhere> {
  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MonthRateSealQueryWhere
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QWhereClause> {
  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterWhereClause> idBetween(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterWhereClause>
      yearMonthEqualTo(String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'yearMonth',
        value: [yearMonth],
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterWhereClause>
      yearMonthNotEqualTo(String yearMonth) {
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

extension MonthRateSealQueryFilter
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QFilterCondition> {
  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition> asOfEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'asOf',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      asOfGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'asOf',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      asOfLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'asOf',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition> asOfBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'asOf',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      attemptCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      attemptCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      attemptCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      attemptCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attemptCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      closedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'closedAt',
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      closedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'closedAt',
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      closedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      closedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      closedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      closedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'closedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      fetchedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fetchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      fetchedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      fetchedAtLessThan(
    DateTime value, {
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      fetchedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      ratesCadEqualTo(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      ratesCadBetween(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      ratesEurEqualTo(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      ratesEurBetween(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      ratesHufEqualTo(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      ratesHufBetween(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      ratesUsdEqualTo(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      ratesUsdBetween(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      sourceEqualTo(RateSource value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      sourceLessThan(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      sourceBetween(
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      statusEqualTo(SealStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      statusGreaterThan(
    SealStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      statusLessThan(
    SealStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      statusBetween(
    SealStatus lower,
    SealStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
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

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension MonthRateSealQueryObject
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QFilterCondition> {}

extension MonthRateSealQueryLinks
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QFilterCondition> {}

extension MonthRateSealQuerySortBy
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QSortBy> {
  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByAsOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asOf', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByAsOfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asOf', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByFetchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByRatesCad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesCad', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByRatesCadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesCad', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByRatesEur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesEur', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByRatesEurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesEur', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByRatesHuf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesHuf', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByRatesHufDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesHuf', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByRatesUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesUsd', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByRatesUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesUsd', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MonthRateSealQuerySortThenBy
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QSortThenBy> {
  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByAsOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asOf', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByAsOfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asOf', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByFetchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByRatesCad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesCad', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByRatesCadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesCad', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByRatesEur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesEur', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByRatesEurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesEur', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByRatesHuf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesHuf', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByRatesHufDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesHuf', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByRatesUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesUsd', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByRatesUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesUsd', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy> thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MonthRateSealQueryWhereDistinct
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> {
  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByAsOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'asOf');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct>
      distinctByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attemptCount');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closedAt');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fetchedAt');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByRatesCad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesCad');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByRatesEur() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesEur');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByRatesHuf() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesHuf');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByRatesUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesUsd');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MonthRateSeal, MonthRateSeal, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension MonthRateSealQueryProperty
    on QueryBuilder<MonthRateSeal, MonthRateSeal, QQueryProperty> {
  QueryBuilder<MonthRateSeal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MonthRateSeal, DateTime, QQueryOperations> asOfProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'asOf');
    });
  }

  QueryBuilder<MonthRateSeal, int, QQueryOperations> attemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attemptCount');
    });
  }

  QueryBuilder<MonthRateSeal, DateTime?, QQueryOperations> closedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closedAt');
    });
  }

  QueryBuilder<MonthRateSeal, DateTime, QQueryOperations> fetchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fetchedAt');
    });
  }

  QueryBuilder<MonthRateSeal, double, QQueryOperations> ratesCadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesCad');
    });
  }

  QueryBuilder<MonthRateSeal, double, QQueryOperations> ratesEurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesEur');
    });
  }

  QueryBuilder<MonthRateSeal, double, QQueryOperations> ratesHufProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesHuf');
    });
  }

  QueryBuilder<MonthRateSeal, double, QQueryOperations> ratesUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesUsd');
    });
  }

  QueryBuilder<MonthRateSeal, RateSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<MonthRateSeal, SealStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<MonthRateSeal, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MonthRateSeal, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
