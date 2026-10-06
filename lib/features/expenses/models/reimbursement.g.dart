// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reimbursement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReimbursementCollection on Isar {
  IsarCollection<Reimbursement> get reimbursements => this.collection();
}

const ReimbursementSchema = CollectionSchema(
  name: r'Reimbursement',
  id: 9128122904462381366,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'currency': PropertySchema(
      id: 1,
      name: r'currency',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'exchangeRateToPrimary': PropertySchema(
      id: 3,
      name: r'exchangeRateToPrimary',
      type: IsarType.double,
    ),
    r'expenseId': PropertySchema(
      id: 4,
      name: r'expenseId',
      type: IsarType.long,
    ),
    r'note': PropertySchema(
      id: 5,
      name: r'note',
      type: IsarType.string,
    ),
    r'originYearMonth': PropertySchema(
      id: 6,
      name: r'originYearMonth',
      type: IsarType.string,
    ),
    r'orphaned': PropertySchema(
      id: 7,
      name: r'orphaned',
      type: IsarType.bool,
    ),
    r'profileId': PropertySchema(
      id: 8,
      name: r'profileId',
      type: IsarType.long,
    )
  },
  estimateSize: _reimbursementEstimateSize,
  serialize: _reimbursementSerialize,
  deserialize: _reimbursementDeserialize,
  deserializeProp: _reimbursementDeserializeProp,
  idName: r'id',
  indexes: {
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
    r'expenseId': IndexSchema(
      id: -8289172275633362361,
      name: r'expenseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'expenseId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'originYearMonth': IndexSchema(
      id: 5724684252273102723,
      name: r'originYearMonth',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'originYearMonth',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'orphaned': IndexSchema(
      id: 6907391274945051414,
      name: r'orphaned',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'orphaned',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _reimbursementGetId,
  getLinks: _reimbursementGetLinks,
  attach: _reimbursementAttach,
  version: '3.1.0+1',
);

int _reimbursementEstimateSize(
  Reimbursement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.originYearMonth.length * 3;
  return bytesCount;
}

void _reimbursementSerialize(
  Reimbursement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.currency);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeDouble(offsets[3], object.exchangeRateToPrimary);
  writer.writeLong(offsets[4], object.expenseId);
  writer.writeString(offsets[5], object.note);
  writer.writeString(offsets[6], object.originYearMonth);
  writer.writeBool(offsets[7], object.orphaned);
  writer.writeLong(offsets[8], object.profileId);
}

Reimbursement _reimbursementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Reimbursement(
    amount: reader.readDouble(offsets[0]),
    currency: reader.readString(offsets[1]),
    date: reader.readDateTime(offsets[2]),
    exchangeRateToPrimary: reader.readDoubleOrNull(offsets[3]) ?? 1.0,
    expenseId: reader.readLongOrNull(offsets[4]),
    id: id,
    note: reader.readStringOrNull(offsets[5]),
    originYearMonth: reader.readString(offsets[6]),
    orphaned: reader.readBoolOrNull(offsets[7]) ?? false,
    profileId: reader.readLong(offsets[8]),
  );
  return object;
}

P _reimbursementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset) ?? 1.0) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reimbursementGetId(Reimbursement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reimbursementGetLinks(Reimbursement object) {
  return [];
}

void _reimbursementAttach(
    IsarCollection<dynamic> col, Id id, Reimbursement object) {
  object.id = id;
}

extension ReimbursementQueryWhereSort
    on QueryBuilder<Reimbursement, Reimbursement, QWhere> {
  QueryBuilder<Reimbursement, Reimbursement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhere> anyExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'expenseId'),
      );
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhere> anyOrphaned() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'orphaned'),
      );
    });
  }
}

extension ReimbursementQueryWhere
    on QueryBuilder<Reimbursement, Reimbursement, QWhereClause> {
  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause> idBetween(
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      expenseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'expenseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      expenseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'expenseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      expenseIdEqualTo(int? expenseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'expenseId',
        value: [expenseId],
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      expenseIdNotEqualTo(int? expenseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseId',
              lower: [],
              upper: [expenseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseId',
              lower: [expenseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseId',
              lower: [expenseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseId',
              lower: [],
              upper: [expenseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      expenseIdGreaterThan(
    int? expenseId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'expenseId',
        lower: [expenseId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      expenseIdLessThan(
    int? expenseId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'expenseId',
        lower: [],
        upper: [expenseId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      expenseIdBetween(
    int? lowerExpenseId,
    int? upperExpenseId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'expenseId',
        lower: [lowerExpenseId],
        includeLower: includeLower,
        upper: [upperExpenseId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      originYearMonthEqualTo(String originYearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'originYearMonth',
        value: [originYearMonth],
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      originYearMonthNotEqualTo(String originYearMonth) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originYearMonth',
              lower: [],
              upper: [originYearMonth],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originYearMonth',
              lower: [originYearMonth],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originYearMonth',
              lower: [originYearMonth],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originYearMonth',
              lower: [],
              upper: [originYearMonth],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause> orphanedEqualTo(
      bool orphaned) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'orphaned',
        value: [orphaned],
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterWhereClause>
      orphanedNotEqualTo(bool orphaned) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orphaned',
              lower: [],
              upper: [orphaned],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orphaned',
              lower: [orphaned],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orphaned',
              lower: [orphaned],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'orphaned',
              lower: [],
              upper: [orphaned],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ReimbursementQueryFilter
    on QueryBuilder<Reimbursement, Reimbursement, QFilterCondition> {
  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      exchangeRateToPrimaryEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exchangeRateToPrimary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      exchangeRateToPrimaryGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exchangeRateToPrimary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      exchangeRateToPrimaryLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exchangeRateToPrimary',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      exchangeRateToPrimaryBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exchangeRateToPrimary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      expenseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expenseId',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      expenseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expenseId',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      expenseIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      expenseIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      expenseIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      expenseIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expenseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originYearMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originYearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      originYearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      orphanedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orphaned',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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

  QueryBuilder<Reimbursement, Reimbursement, QAfterFilterCondition>
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
}

extension ReimbursementQueryObject
    on QueryBuilder<Reimbursement, Reimbursement, QFilterCondition> {}

extension ReimbursementQueryLinks
    on QueryBuilder<Reimbursement, Reimbursement, QFilterCondition> {}

extension ReimbursementQuerySortBy
    on QueryBuilder<Reimbursement, Reimbursement, QSortBy> {
  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      sortByExchangeRateToPrimary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exchangeRateToPrimary', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      sortByExchangeRateToPrimaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exchangeRateToPrimary', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      sortByExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      sortByOriginYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originYearMonth', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      sortByOriginYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originYearMonth', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByOrphaned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orphaned', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      sortByOrphanedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orphaned', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }
}

extension ReimbursementQuerySortThenBy
    on QueryBuilder<Reimbursement, Reimbursement, QSortThenBy> {
  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      thenByExchangeRateToPrimary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exchangeRateToPrimary', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      thenByExchangeRateToPrimaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exchangeRateToPrimary', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      thenByExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      thenByOriginYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originYearMonth', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      thenByOriginYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originYearMonth', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByOrphaned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orphaned', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      thenByOrphanedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orphaned', Sort.desc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }
}

extension ReimbursementQueryWhereDistinct
    on QueryBuilder<Reimbursement, Reimbursement, QDistinct> {
  QueryBuilder<Reimbursement, Reimbursement, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QDistinct>
      distinctByExchangeRateToPrimary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exchangeRateToPrimary');
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QDistinct> distinctByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expenseId');
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QDistinct>
      distinctByOriginYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originYearMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QDistinct> distinctByOrphaned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orphaned');
    });
  }

  QueryBuilder<Reimbursement, Reimbursement, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }
}

extension ReimbursementQueryProperty
    on QueryBuilder<Reimbursement, Reimbursement, QQueryProperty> {
  QueryBuilder<Reimbursement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Reimbursement, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<Reimbursement, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<Reimbursement, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<Reimbursement, double, QQueryOperations>
      exchangeRateToPrimaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exchangeRateToPrimary');
    });
  }

  QueryBuilder<Reimbursement, int?, QQueryOperations> expenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expenseId');
    });
  }

  QueryBuilder<Reimbursement, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<Reimbursement, String, QQueryOperations>
      originYearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originYearMonth');
    });
  }

  QueryBuilder<Reimbursement, bool, QQueryOperations> orphanedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orphaned');
    });
  }

  QueryBuilder<Reimbursement, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }
}
