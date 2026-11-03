// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banking_calendar_coverage.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBankingCalendarCoverageCollection on Isar {
  IsarCollection<BankingCalendarCoverage> get bankingCalendarCoverages =>
      this.collection();
}

const BankingCalendarCoverageSchema = CollectionSchema(
  name: r'BankingCalendarCoverage',
  id: 7832568465929207327,
  properties: {
    r'countryCode': PropertySchema(
      id: 0,
      name: r'countryCode',
      type: IsarType.string,
    ),
    r'coverageEnd': PropertySchema(
      id: 1,
      name: r'coverageEnd',
      type: IsarType.dateTime,
    ),
    r'coverageStart': PropertySchema(
      id: 2,
      name: r'coverageStart',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'guid': PropertySchema(
      id: 4,
      name: r'guid',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 5,
      name: r'notes',
      type: IsarType.string,
    ),
    r'regionCode': PropertySchema(
      id: 6,
      name: r'regionCode',
      type: IsarType.string,
    ),
    r'sourceName': PropertySchema(
      id: 7,
      name: r'sourceName',
      type: IsarType.string,
    ),
    r'sourceRef': PropertySchema(
      id: 8,
      name: r'sourceRef',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'verified': PropertySchema(
      id: 11,
      name: r'verified',
      type: IsarType.bool,
    )
  },
  estimateSize: _bankingCalendarCoverageEstimateSize,
  serialize: _bankingCalendarCoverageSerialize,
  deserialize: _bankingCalendarCoverageDeserialize,
  deserializeProp: _bankingCalendarCoverageDeserializeProp,
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
    r'countryCode': IndexSchema(
      id: -6124957146481819559,
      name: r'countryCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'countryCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bankingCalendarCoverageGetId,
  getLinks: _bankingCalendarCoverageGetLinks,
  attach: _bankingCalendarCoverageAttach,
  version: '3.1.0+1',
);

int _bankingCalendarCoverageEstimateSize(
  BankingCalendarCoverage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.countryCode.length * 3;
  bytesCount += 3 + object.guid.length * 3;
  bytesCount += 3 + object.notes.length * 3;
  {
    final value = object.regionCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceName.length * 3;
  bytesCount += 3 + object.sourceRef.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _bankingCalendarCoverageSerialize(
  BankingCalendarCoverage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.countryCode);
  writer.writeDateTime(offsets[1], object.coverageEnd);
  writer.writeDateTime(offsets[2], object.coverageStart);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.guid);
  writer.writeString(offsets[5], object.notes);
  writer.writeString(offsets[6], object.regionCode);
  writer.writeString(offsets[7], object.sourceName);
  writer.writeString(offsets[8], object.sourceRef);
  writer.writeString(offsets[9], object.status);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeBool(offsets[11], object.verified);
}

BankingCalendarCoverage _bankingCalendarCoverageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BankingCalendarCoverage();
  object.countryCode = reader.readString(offsets[0]);
  object.coverageEnd = reader.readDateTime(offsets[1]);
  object.coverageStart = reader.readDateTime(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.guid = reader.readString(offsets[4]);
  object.id = id;
  object.notes = reader.readString(offsets[5]);
  object.regionCode = reader.readStringOrNull(offsets[6]);
  object.sourceName = reader.readString(offsets[7]);
  object.sourceRef = reader.readString(offsets[8]);
  object.status = reader.readString(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  object.verified = reader.readBool(offsets[11]);
  return object;
}

P _bankingCalendarCoverageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bankingCalendarCoverageGetId(BankingCalendarCoverage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bankingCalendarCoverageGetLinks(
    BankingCalendarCoverage object) {
  return [];
}

void _bankingCalendarCoverageAttach(
    IsarCollection<dynamic> col, Id id, BankingCalendarCoverage object) {
  object.id = id;
}

extension BankingCalendarCoverageByIndex
    on IsarCollection<BankingCalendarCoverage> {
  Future<BankingCalendarCoverage?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  BankingCalendarCoverage? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<BankingCalendarCoverage?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<BankingCalendarCoverage?> getAllByGuidSync(List<String> guidValues) {
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

  Future<Id> putByGuid(BankingCalendarCoverage object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(BankingCalendarCoverage object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<BankingCalendarCoverage> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<BankingCalendarCoverage> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }
}

extension BankingCalendarCoverageQueryWhereSort
    on QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QWhere> {
  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BankingCalendarCoverageQueryWhere on QueryBuilder<
    BankingCalendarCoverage, BankingCalendarCoverage, QWhereClause> {
  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> guidEqualTo(String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> guidNotEqualTo(String guid) {
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> countryCodeEqualTo(String countryCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'countryCode',
        value: [countryCode],
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterWhereClause> countryCodeNotEqualTo(String countryCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'countryCode',
              lower: [],
              upper: [countryCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'countryCode',
              lower: [countryCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'countryCode',
              lower: [countryCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'countryCode',
              lower: [],
              upper: [countryCode],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BankingCalendarCoverageQueryFilter on QueryBuilder<
    BankingCalendarCoverage, BankingCalendarCoverage, QFilterCondition> {
  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> countryCodeEqualTo(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> countryCodeGreaterThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> countryCodeLessThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> countryCodeBetween(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> countryCodeStartsWith(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> countryCodeEndsWith(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      countryCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      countryCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'countryCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> countryCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countryCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> countryCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'countryCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> coverageEndEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverageEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> coverageEndGreaterThan(
    DateTime value, {
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> coverageEndLessThan(
    DateTime value, {
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> coverageEndBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> coverageStartEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coverageStart',
        value: value,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> coverageStartGreaterThan(
    DateTime value, {
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> coverageStartLessThan(
    DateTime value, {
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> coverageStartBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> guidEqualTo(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> guidGreaterThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> guidLessThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> guidBetween(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> guidStartsWith(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> guidEndsWith(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      guidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      guidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> notesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> notesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> notesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> notesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'regionCode',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'regionCode',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeEqualTo(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeGreaterThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeLessThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeBetween(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeStartsWith(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeEndsWith(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      regionCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'regionCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      regionCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'regionCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regionCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> regionCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'regionCode',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      sourceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      sourceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceName',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceName',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceRefEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceRefGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceRefLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceRefBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceRef',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceRefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceRefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      sourceRefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      sourceRefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceRef',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceRefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceRef',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> sourceRefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceRef',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage,
      QAfterFilterCondition> verifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verified',
        value: value,
      ));
    });
  }
}

extension BankingCalendarCoverageQueryObject on QueryBuilder<
    BankingCalendarCoverage, BankingCalendarCoverage, QFilterCondition> {}

extension BankingCalendarCoverageQueryLinks on QueryBuilder<
    BankingCalendarCoverage, BankingCalendarCoverage, QFilterCondition> {}

extension BankingCalendarCoverageQuerySortBy
    on QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QSortBy> {
  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByCoverageEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageEnd', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByCoverageEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageEnd', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByCoverageStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageStart', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByCoverageStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageStart', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByRegionCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionCode', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByRegionCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionCode', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortBySourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortBySourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortBySourceRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRef', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortBySourceRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRef', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      sortByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension BankingCalendarCoverageQuerySortThenBy on QueryBuilder<
    BankingCalendarCoverage, BankingCalendarCoverage, QSortThenBy> {
  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByCoverageEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageEnd', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByCoverageEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageEnd', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByCoverageStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageStart', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByCoverageStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverageStart', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByRegionCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionCode', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByRegionCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionCode', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenBySourceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenBySourceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceName', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenBySourceRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRef', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenBySourceRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRef', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QAfterSortBy>
      thenByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension BankingCalendarCoverageQueryWhereDistinct on QueryBuilder<
    BankingCalendarCoverage, BankingCalendarCoverage, QDistinct> {
  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByCountryCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countryCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByCoverageEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverageEnd');
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByCoverageStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coverageStart');
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByRegionCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'regionCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctBySourceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctBySourceRef({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceRef', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BankingCalendarCoverage, BankingCalendarCoverage, QDistinct>
      distinctByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verified');
    });
  }
}

extension BankingCalendarCoverageQueryProperty on QueryBuilder<
    BankingCalendarCoverage, BankingCalendarCoverage, QQueryProperty> {
  QueryBuilder<BankingCalendarCoverage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BankingCalendarCoverage, String, QQueryOperations>
      countryCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countryCode');
    });
  }

  QueryBuilder<BankingCalendarCoverage, DateTime, QQueryOperations>
      coverageEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverageEnd');
    });
  }

  QueryBuilder<BankingCalendarCoverage, DateTime, QQueryOperations>
      coverageStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverageStart');
    });
  }

  QueryBuilder<BankingCalendarCoverage, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BankingCalendarCoverage, String, QQueryOperations>
      guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<BankingCalendarCoverage, String, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<BankingCalendarCoverage, String?, QQueryOperations>
      regionCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'regionCode');
    });
  }

  QueryBuilder<BankingCalendarCoverage, String, QQueryOperations>
      sourceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceName');
    });
  }

  QueryBuilder<BankingCalendarCoverage, String, QQueryOperations>
      sourceRefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceRef');
    });
  }

  QueryBuilder<BankingCalendarCoverage, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<BankingCalendarCoverage, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BankingCalendarCoverage, bool, QQueryOperations>
      verifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verified');
    });
  }
}
