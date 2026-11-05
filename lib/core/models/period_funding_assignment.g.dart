// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_funding_assignment.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPeriodFundingAssignmentCollection on Isar {
  IsarCollection<PeriodFundingAssignment> get periodFundingAssignments =>
      this.collection();
}

const PeriodFundingAssignmentSchema = CollectionSchema(
  name: r'PeriodFundingAssignment',
  id: -9069004257846972866,
  properties: {
    r'amountMinor': PropertySchema(
      id: 0,
      name: r'amountMinor',
      type: IsarType.long,
    ),
    r'availabilityBoundary': PropertySchema(
      id: 1,
      name: r'availabilityBoundary',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 2,
      name: r'currency',
      type: IsarType.string,
    ),
    r'destinationMonth': PropertySchema(
      id: 3,
      name: r'destinationMonth',
      type: IsarType.string,
    ),
    r'guid': PropertySchema(
      id: 4,
      name: r'guid',
      type: IsarType.string,
    ),
    r'inclusionReviewRef': PropertySchema(
      id: 5,
      name: r'inclusionReviewRef',
      type: IsarType.string,
    ),
    r'ownerKey': PropertySchema(
      id: 6,
      name: r'ownerKey',
      type: IsarType.string,
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
    r'sharedSpaceId': PropertySchema(
      id: 9,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'sourceFactGuid': PropertySchema(
      id: 10,
      name: r'sourceFactGuid',
      type: IsarType.string,
    ),
    r'sourceRevision': PropertySchema(
      id: 11,
      name: r'sourceRevision',
      type: IsarType.string,
    ),
    r'state': PropertySchema(
      id: 12,
      name: r'state',
      type: IsarType.string,
    )
  },
  estimateSize: _periodFundingAssignmentEstimateSize,
  serialize: _periodFundingAssignmentSerialize,
  deserialize: _periodFundingAssignmentDeserialize,
  deserializeProp: _periodFundingAssignmentDeserializeProp,
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
    r'ownerKey': IndexSchema(
      id: -688544438286220026,
      name: r'ownerKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ownerKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _periodFundingAssignmentGetId,
  getLinks: _periodFundingAssignmentGetLinks,
  attach: _periodFundingAssignmentAttach,
  version: '3.1.0+1',
);

int _periodFundingAssignmentEstimateSize(
  PeriodFundingAssignment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.destinationMonth.length * 3;
  bytesCount += 3 + object.guid.length * 3;
  bytesCount += 3 + object.inclusionReviewRef.length * 3;
  bytesCount += 3 + object.ownerKey.length * 3;
  bytesCount += 3 + object.sourceFactGuid.length * 3;
  bytesCount += 3 + object.sourceRevision.length * 3;
  bytesCount += 3 + object.state.length * 3;
  return bytesCount;
}

void _periodFundingAssignmentSerialize(
  PeriodFundingAssignment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amountMinor);
  writer.writeDateTime(offsets[1], object.availabilityBoundary);
  writer.writeString(offsets[2], object.currency);
  writer.writeString(offsets[3], object.destinationMonth);
  writer.writeString(offsets[4], object.guid);
  writer.writeString(offsets[5], object.inclusionReviewRef);
  writer.writeString(offsets[6], object.ownerKey);
  writer.writeLong(offsets[7], object.policyRevision);
  writer.writeLong(offsets[8], object.profileId);
  writer.writeLong(offsets[9], object.sharedSpaceId);
  writer.writeString(offsets[10], object.sourceFactGuid);
  writer.writeString(offsets[11], object.sourceRevision);
  writer.writeString(offsets[12], object.state);
}

PeriodFundingAssignment _periodFundingAssignmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PeriodFundingAssignment();
  object.amountMinor = reader.readLong(offsets[0]);
  object.availabilityBoundary = reader.readDateTime(offsets[1]);
  object.currency = reader.readString(offsets[2]);
  object.destinationMonth = reader.readString(offsets[3]);
  object.guid = reader.readString(offsets[4]);
  object.id = id;
  object.inclusionReviewRef = reader.readString(offsets[5]);
  object.ownerKey = reader.readString(offsets[6]);
  object.policyRevision = reader.readLong(offsets[7]);
  object.profileId = reader.readLongOrNull(offsets[8]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[9]);
  object.sourceFactGuid = reader.readString(offsets[10]);
  object.sourceRevision = reader.readString(offsets[11]);
  object.state = reader.readString(offsets[12]);
  return object;
}

P _periodFundingAssignmentDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _periodFundingAssignmentGetId(PeriodFundingAssignment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _periodFundingAssignmentGetLinks(
    PeriodFundingAssignment object) {
  return [];
}

void _periodFundingAssignmentAttach(
    IsarCollection<dynamic> col, Id id, PeriodFundingAssignment object) {
  object.id = id;
}

extension PeriodFundingAssignmentByIndex
    on IsarCollection<PeriodFundingAssignment> {
  Future<PeriodFundingAssignment?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  PeriodFundingAssignment? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<PeriodFundingAssignment?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<PeriodFundingAssignment?> getAllByGuidSync(List<String> guidValues) {
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

  Future<Id> putByGuid(PeriodFundingAssignment object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(PeriodFundingAssignment object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<PeriodFundingAssignment> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<PeriodFundingAssignment> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }
}

extension PeriodFundingAssignmentQueryWhereSort
    on QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QWhere> {
  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PeriodFundingAssignmentQueryWhere on QueryBuilder<
    PeriodFundingAssignment, PeriodFundingAssignment, QWhereClause> {
  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterWhereClause> guidEqualTo(String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterWhereClause> ownerKeyEqualTo(String ownerKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ownerKey',
        value: [ownerKey],
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterWhereClause> ownerKeyNotEqualTo(String ownerKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerKey',
              lower: [],
              upper: [ownerKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerKey',
              lower: [ownerKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerKey',
              lower: [ownerKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerKey',
              lower: [],
              upper: [ownerKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PeriodFundingAssignmentQueryFilter on QueryBuilder<
    PeriodFundingAssignment, PeriodFundingAssignment, QFilterCondition> {
  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> amountMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> amountMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> amountMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> amountMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amountMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> availabilityBoundaryEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availabilityBoundary',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> availabilityBoundaryGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'availabilityBoundary',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> availabilityBoundaryLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'availabilityBoundary',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> availabilityBoundaryBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'availabilityBoundary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> currencyEqualTo(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> currencyGreaterThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> currencyLessThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> currencyBetween(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> currencyStartsWith(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> currencyEndsWith(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> destinationMonthEqualTo(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> destinationMonthGreaterThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> destinationMonthLessThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> destinationMonthBetween(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> destinationMonthStartsWith(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> destinationMonthEndsWith(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      destinationMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      destinationMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'destinationMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> destinationMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'destinationMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> destinationMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'destinationMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> inclusionReviewRefEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inclusionReviewRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> inclusionReviewRefGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inclusionReviewRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> inclusionReviewRefLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inclusionReviewRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> inclusionReviewRefBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inclusionReviewRef',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> inclusionReviewRefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inclusionReviewRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> inclusionReviewRefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inclusionReviewRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      inclusionReviewRefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inclusionReviewRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      inclusionReviewRefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inclusionReviewRef',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> inclusionReviewRefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inclusionReviewRef',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> inclusionReviewRefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inclusionReviewRef',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> ownerKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> ownerKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ownerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> ownerKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ownerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> ownerKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ownerKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> ownerKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ownerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> ownerKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ownerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      ownerKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ownerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      ownerKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ownerKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> ownerKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> ownerKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ownerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> policyRevisionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyRevision',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> policyRevisionGreaterThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> policyRevisionLessThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> policyRevisionBetween(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> profileIdGreaterThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> profileIdLessThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> profileIdBetween(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sharedSpaceIdGreaterThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sharedSpaceIdLessThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sharedSpaceIdBetween(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceFactGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceFactGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceFactGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceFactGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceFactGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceFactGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceFactGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceFactGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceFactGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceFactGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceFactGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceFactGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      sourceFactGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceFactGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      sourceFactGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceFactGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceFactGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceFactGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceFactGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceFactGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceRevisionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceRevisionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceRevisionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceRevisionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceRevision',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceRevisionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceRevisionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      sourceRevisionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      sourceRevisionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceRevision',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceRevisionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceRevision',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> sourceRevisionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceRevision',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> stateEqualTo(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> stateGreaterThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> stateLessThan(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> stateBetween(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> stateStartsWith(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> stateEndsWith(
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

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      stateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
          QAfterFilterCondition>
      stateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'state',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> stateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment,
      QAfterFilterCondition> stateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'state',
        value: '',
      ));
    });
  }
}

extension PeriodFundingAssignmentQueryObject on QueryBuilder<
    PeriodFundingAssignment, PeriodFundingAssignment, QFilterCondition> {}

extension PeriodFundingAssignmentQueryLinks on QueryBuilder<
    PeriodFundingAssignment, PeriodFundingAssignment, QFilterCondition> {}

extension PeriodFundingAssignmentQuerySortBy
    on QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QSortBy> {
  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByAvailabilityBoundary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availabilityBoundary', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByAvailabilityBoundaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availabilityBoundary', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByDestinationMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByDestinationMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByInclusionReviewRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inclusionReviewRef', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByInclusionReviewRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inclusionReviewRef', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByOwnerKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerKey', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByOwnerKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerKey', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByPolicyRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyRevision', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByPolicyRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyRevision', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortBySourceFactGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFactGuid', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortBySourceFactGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFactGuid', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortBySourceRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRevision', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortBySourceRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRevision', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }
}

extension PeriodFundingAssignmentQuerySortThenBy on QueryBuilder<
    PeriodFundingAssignment, PeriodFundingAssignment, QSortThenBy> {
  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByAvailabilityBoundary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availabilityBoundary', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByAvailabilityBoundaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availabilityBoundary', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByDestinationMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByDestinationMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByInclusionReviewRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inclusionReviewRef', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByInclusionReviewRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inclusionReviewRef', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByOwnerKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerKey', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByOwnerKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerKey', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByPolicyRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyRevision', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByPolicyRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyRevision', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenBySourceFactGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFactGuid', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenBySourceFactGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFactGuid', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenBySourceRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRevision', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenBySourceRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceRevision', Sort.desc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QAfterSortBy>
      thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }
}

extension PeriodFundingAssignmentQueryWhereDistinct on QueryBuilder<
    PeriodFundingAssignment, PeriodFundingAssignment, QDistinct> {
  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountMinor');
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByAvailabilityBoundary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availabilityBoundary');
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByDestinationMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'destinationMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByInclusionReviewRef({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inclusionReviewRef',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByOwnerKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByPolicyRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'policyRevision');
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctBySourceFactGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceFactGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctBySourceRevision({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceRevision',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodFundingAssignment, PeriodFundingAssignment, QDistinct>
      distinctByState({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state', caseSensitive: caseSensitive);
    });
  }
}

extension PeriodFundingAssignmentQueryProperty on QueryBuilder<
    PeriodFundingAssignment, PeriodFundingAssignment, QQueryProperty> {
  QueryBuilder<PeriodFundingAssignment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PeriodFundingAssignment, int, QQueryOperations>
      amountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountMinor');
    });
  }

  QueryBuilder<PeriodFundingAssignment, DateTime, QQueryOperations>
      availabilityBoundaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availabilityBoundary');
    });
  }

  QueryBuilder<PeriodFundingAssignment, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<PeriodFundingAssignment, String, QQueryOperations>
      destinationMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'destinationMonth');
    });
  }

  QueryBuilder<PeriodFundingAssignment, String, QQueryOperations>
      guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<PeriodFundingAssignment, String, QQueryOperations>
      inclusionReviewRefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inclusionReviewRef');
    });
  }

  QueryBuilder<PeriodFundingAssignment, String, QQueryOperations>
      ownerKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerKey');
    });
  }

  QueryBuilder<PeriodFundingAssignment, int, QQueryOperations>
      policyRevisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'policyRevision');
    });
  }

  QueryBuilder<PeriodFundingAssignment, int?, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<PeriodFundingAssignment, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<PeriodFundingAssignment, String, QQueryOperations>
      sourceFactGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceFactGuid');
    });
  }

  QueryBuilder<PeriodFundingAssignment, String, QQueryOperations>
      sourceRevisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceRevision');
    });
  }

  QueryBuilder<PeriodFundingAssignment, String, QQueryOperations>
      stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }
}
