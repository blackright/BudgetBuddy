// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'previous_search_expense.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreviousSearchExpenseCollection on Isar {
  IsarCollection<PreviousSearchExpense> get previousSearchExpenses =>
      this.collection();
}

const PreviousSearchExpenseSchema = CollectionSchema(
  name: r'Expense',
  id: -4604318666888508206,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.long,
    ),
    r'budgetId': PropertySchema(
      id: 1,
      name: r'budgetId',
      type: IsarType.long,
    ),
    r'budgetProfileId': PropertySchema(
      id: 2,
      name: r'budgetProfileId',
      type: IsarType.long,
    ),
    r'categoryId': PropertySchema(
      id: 3,
      name: r'categoryId',
      type: IsarType.string,
    ),
    r'currency': PropertySchema(
      id: 4,
      name: r'currency',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 5,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'financialProfileSyncGuid': PropertySchema(
      id: 6,
      name: r'financialProfileSyncGuid',
      type: IsarType.string,
    ),
    r'financialProfileType': PropertySchema(
      id: 7,
      name: r'financialProfileType',
      type: IsarType.string,
    ),
    r'guiltLevel': PropertySchema(
      id: 8,
      name: r'guiltLevel',
      type: IsarType.byte,
      enumMap: _PreviousSearchExpenseguiltLevelEnumValueMap,
    ),
    r'isReimbursable': PropertySchema(
      id: 9,
      name: r'isReimbursable',
      type: IsarType.bool,
    ),
    r'notes': PropertySchema(
      id: 10,
      name: r'notes',
      type: IsarType.string,
    ),
    r'paidAt': PropertySchema(
      id: 11,
      name: r'paidAt',
      type: IsarType.dateTime,
    ),
    r'profileId': PropertySchema(
      id: 12,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'receiptPath': PropertySchema(
      id: 13,
      name: r'receiptPath',
      type: IsarType.string,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 14,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 15,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PreviousSearchExpensestatusEnumValueMap,
    ),
    r'syncGuid': PropertySchema(
      id: 16,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 17,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 18,
      name: r'type',
      type: IsarType.byte,
      enumMap: _PreviousSearchExpensetypeEnumValueMap,
    ),
    r'yearMonth': PropertySchema(
      id: 19,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _previousSearchExpenseEstimateSize,
  serialize: _previousSearchExpenseSerialize,
  deserialize: _previousSearchExpenseDeserialize,
  deserializeProp: _previousSearchExpenseDeserializeProp,
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
    r'sharedSpaceId': IndexSchema(
      id: 9187801792503633945,
      name: r'sharedSpaceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sharedSpaceId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'yearMonth': IndexSchema(
      id: 5465596700411800841,
      name: r'yearMonth',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'yearMonth',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'budgetProfileId': IndexSchema(
      id: 3559811101051514649,
      name: r'budgetProfileId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'budgetProfileId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _previousSearchExpenseGetId,
  getLinks: _previousSearchExpenseGetLinks,
  attach: _previousSearchExpenseAttach,
  version: '3.1.0+1',
);

int _previousSearchExpenseEstimateSize(
  PreviousSearchExpense object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.categoryId.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  {
    final value = object.financialProfileSyncGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.financialProfileType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.receiptPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _previousSearchExpenseSerialize(
  PreviousSearchExpense object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amount);
  writer.writeLong(offsets[1], object.budgetId);
  writer.writeLong(offsets[2], object.budgetProfileId);
  writer.writeString(offsets[3], object.categoryId);
  writer.writeString(offsets[4], object.currency);
  writer.writeDateTime(offsets[5], object.date);
  writer.writeString(offsets[6], object.financialProfileSyncGuid);
  writer.writeString(offsets[7], object.financialProfileType);
  writer.writeByte(offsets[8], object.guiltLevel.index);
  writer.writeBool(offsets[9], object.isReimbursable);
  writer.writeString(offsets[10], object.notes);
  writer.writeDateTime(offsets[11], object.paidAt);
  writer.writeLong(offsets[12], object.profileId);
  writer.writeString(offsets[13], object.receiptPath);
  writer.writeLong(offsets[14], object.sharedSpaceId);
  writer.writeByte(offsets[15], object.status.index);
  writer.writeString(offsets[16], object.syncGuid);
  writer.writeString(offsets[17], object.title);
  writer.writeByte(offsets[18], object.type.index);
  writer.writeString(offsets[19], object.yearMonth);
}

PreviousSearchExpense _previousSearchExpenseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PreviousSearchExpense(
    amount: reader.readLong(offsets[0]),
    budgetId: reader.readLong(offsets[1]),
    budgetProfileId: reader.readLongOrNull(offsets[2]),
    categoryId: reader.readString(offsets[3]),
    currency: reader.readString(offsets[4]),
    date: reader.readDateTime(offsets[5]),
    financialProfileSyncGuid: reader.readStringOrNull(offsets[6]),
    financialProfileType: reader.readStringOrNull(offsets[7]),
    guiltLevel: _PreviousSearchExpenseguiltLevelValueEnumMap[
            reader.readByteOrNull(offsets[8])] ??
        GuiltLevel.essential,
    id: id,
    isReimbursable: reader.readBoolOrNull(offsets[9]) ?? false,
    notes: reader.readStringOrNull(offsets[10]),
    paidAt: reader.readDateTimeOrNull(offsets[11]),
    profileId: reader.readLong(offsets[12]),
    receiptPath: reader.readStringOrNull(offsets[13]),
    sharedSpaceId: reader.readLongOrNull(offsets[14]),
    status: _PreviousSearchExpensestatusValueEnumMap[
            reader.readByteOrNull(offsets[15])] ??
        ExpenseStatus.paid,
    title: reader.readString(offsets[17]),
    type: _PreviousSearchExpensetypeValueEnumMap[
            reader.readByteOrNull(offsets[18])] ??
        ExpenseType.standard,
    yearMonth: reader.readString(offsets[19]),
  );
  object.syncGuid = reader.readString(offsets[16]);
  return object;
}

P _previousSearchExpenseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (_PreviousSearchExpenseguiltLevelValueEnumMap[
              reader.readByteOrNull(offset)] ??
          GuiltLevel.essential) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (_PreviousSearchExpensestatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ExpenseStatus.paid) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (_PreviousSearchExpensetypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ExpenseType.standard) as P;
    case 19:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PreviousSearchExpenseguiltLevelEnumValueMap = {
  'essential': 0,
  'guiltFree': 1,
  'oops': 2,
};
const _PreviousSearchExpenseguiltLevelValueEnumMap = {
  0: GuiltLevel.essential,
  1: GuiltLevel.guiltFree,
  2: GuiltLevel.oops,
};
const _PreviousSearchExpensestatusEnumValueMap = {
  'planned': 0,
  'paid': 1,
  'cancelled': 2,
  'reimbursed': 3,
  'partiallyReimbursed': 4,
};
const _PreviousSearchExpensestatusValueEnumMap = {
  0: ExpenseStatus.planned,
  1: ExpenseStatus.paid,
  2: ExpenseStatus.cancelled,
  3: ExpenseStatus.reimbursed,
  4: ExpenseStatus.partiallyReimbursed,
};
const _PreviousSearchExpensetypeEnumValueMap = {
  'standard': 0,
  'medical': 1,
};
const _PreviousSearchExpensetypeValueEnumMap = {
  0: ExpenseType.standard,
  1: ExpenseType.medical,
};

Id _previousSearchExpenseGetId(PreviousSearchExpense object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _previousSearchExpenseGetLinks(
    PreviousSearchExpense object) {
  return [];
}

void _previousSearchExpenseAttach(
    IsarCollection<dynamic> col, Id id, PreviousSearchExpense object) {
  object.id = id;
}

extension PreviousSearchExpenseQueryWhereSort
    on QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QWhere> {
  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhere>
      anySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId'),
      );
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhere>
      anyBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'budgetProfileId'),
      );
    });
  }
}

extension PreviousSearchExpenseQueryWhere on QueryBuilder<PreviousSearchExpense,
    PreviousSearchExpense, QWhereClause> {
  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      sharedSpaceIdEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      sharedSpaceIdNotEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [],
              upper: [sharedSpaceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [sharedSpaceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [sharedSpaceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [],
              upper: [sharedSpaceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      sharedSpaceIdGreaterThan(
    int? sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [sharedSpaceId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      sharedSpaceIdLessThan(
    int? sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [],
        upper: [sharedSpaceId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      sharedSpaceIdBetween(
    int? lowerSharedSpaceId,
    int? upperSharedSpaceId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [lowerSharedSpaceId],
        includeLower: includeLower,
        upper: [upperSharedSpaceId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      yearMonthEqualTo(String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'yearMonth',
        value: [yearMonth],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      budgetProfileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'budgetProfileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      budgetProfileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'budgetProfileId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      budgetProfileIdEqualTo(int? budgetProfileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'budgetProfileId',
        value: [budgetProfileId],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      budgetProfileIdNotEqualTo(int? budgetProfileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'budgetProfileId',
              lower: [],
              upper: [budgetProfileId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'budgetProfileId',
              lower: [budgetProfileId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'budgetProfileId',
              lower: [budgetProfileId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'budgetProfileId',
              lower: [],
              upper: [budgetProfileId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      budgetProfileIdGreaterThan(
    int? budgetProfileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'budgetProfileId',
        lower: [budgetProfileId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      budgetProfileIdLessThan(
    int? budgetProfileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'budgetProfileId',
        lower: [],
        upper: [budgetProfileId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterWhereClause>
      budgetProfileIdBetween(
    int? lowerBudgetProfileId,
    int? upperBudgetProfileId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'budgetProfileId',
        lower: [lowerBudgetProfileId],
        includeLower: includeLower,
        upper: [upperBudgetProfileId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PreviousSearchExpenseQueryFilter on QueryBuilder<
    PreviousSearchExpense, PreviousSearchExpense, QFilterCondition> {
  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> amountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> amountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> amountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> amountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'budgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'budgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'budgetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetProfileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'budgetProfileId',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetProfileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'budgetProfileId',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetProfileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetProfileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetProfileIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'budgetProfileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetProfileIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'budgetProfileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> budgetProfileIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'budgetProfileId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> categoryIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> categoryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> categoryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> categoryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> categoryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> categoryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      categoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      categoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> dateGreaterThan(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> dateLessThan(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> dateBetween(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financialProfileSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financialProfileSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialProfileSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'financialProfileSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'financialProfileSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'financialProfileSyncGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'financialProfileSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'financialProfileSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      financialProfileSyncGuidContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'financialProfileSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      financialProfileSyncGuidMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'financialProfileSyncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialProfileSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'financialProfileSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financialProfileType',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financialProfileType',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialProfileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'financialProfileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'financialProfileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'financialProfileType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'financialProfileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'financialProfileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      financialProfileTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'financialProfileType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      financialProfileTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'financialProfileType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialProfileType',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> financialProfileTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'financialProfileType',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> guiltLevelEqualTo(GuiltLevel value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guiltLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> guiltLevelGreaterThan(
    GuiltLevel value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'guiltLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> guiltLevelLessThan(
    GuiltLevel value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'guiltLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> guiltLevelBetween(
    GuiltLevel lower,
    GuiltLevel upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'guiltLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> isReimbursableEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isReimbursable',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> notesEqualTo(
    String? value, {
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> notesGreaterThan(
    String? value, {
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> notesLessThan(
    String? value, {
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> paidAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paidAt',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> paidAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paidAt',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> paidAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> paidAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paidAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> paidAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paidAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> paidAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paidAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> profileIdGreaterThan(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> profileIdLessThan(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> profileIdBetween(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receiptPath',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receiptPath',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'receiptPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'receiptPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      receiptPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'receiptPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      receiptPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'receiptPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> receiptPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receiptPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> statusEqualTo(ExpenseStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> statusGreaterThan(
    ExpenseStatus value, {
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> statusLessThan(
    ExpenseStatus value, {
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> statusBetween(
    ExpenseStatus lower,
    ExpenseStatus upper, {
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> syncGuidEqualTo(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> syncGuidGreaterThan(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> syncGuidLessThan(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> syncGuidBetween(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> syncGuidStartsWith(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> syncGuidEndsWith(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> typeEqualTo(ExpenseType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> typeGreaterThan(
    ExpenseType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> typeLessThan(
    ExpenseType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> typeBetween(
    ExpenseType lower,
    ExpenseType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> yearMonthEqualTo(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> yearMonthGreaterThan(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> yearMonthLessThan(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> yearMonthBetween(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> yearMonthStartsWith(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> yearMonthEndsWith(
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

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
          QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense,
      QAfterFilterCondition> yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension PreviousSearchExpenseQueryObject on QueryBuilder<
    PreviousSearchExpense, PreviousSearchExpense, QFilterCondition> {}

extension PreviousSearchExpenseQueryLinks on QueryBuilder<PreviousSearchExpense,
    PreviousSearchExpense, QFilterCondition> {}

extension PreviousSearchExpenseQuerySortBy
    on QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QSortBy> {
  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByBudgetProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByFinancialProfileSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByFinancialProfileSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByFinancialProfileType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByFinancialProfileTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByGuiltLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByIsReimbursableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByReceiptPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByReceiptPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension PreviousSearchExpenseQuerySortThenBy
    on QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QSortThenBy> {
  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByBudgetProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByFinancialProfileSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByFinancialProfileSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByFinancialProfileType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByFinancialProfileTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByGuiltLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByIsReimbursableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByReceiptPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByReceiptPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension PreviousSearchExpenseQueryWhereDistinct
    on QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct> {
  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetId');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetProfileId');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByFinancialProfileSyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financialProfileSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByFinancialProfileType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financialProfileType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guiltLevel');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReimbursable');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAt');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByReceiptPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctBySyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<PreviousSearchExpense, PreviousSearchExpense, QDistinct>
      distinctByYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension PreviousSearchExpenseQueryProperty on QueryBuilder<
    PreviousSearchExpense, PreviousSearchExpense, QQueryProperty> {
  QueryBuilder<PreviousSearchExpense, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PreviousSearchExpense, int, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<PreviousSearchExpense, int, QQueryOperations>
      budgetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetId');
    });
  }

  QueryBuilder<PreviousSearchExpense, int?, QQueryOperations>
      budgetProfileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetProfileId');
    });
  }

  QueryBuilder<PreviousSearchExpense, String, QQueryOperations>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<PreviousSearchExpense, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<PreviousSearchExpense, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PreviousSearchExpense, String?, QQueryOperations>
      financialProfileSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financialProfileSyncGuid');
    });
  }

  QueryBuilder<PreviousSearchExpense, String?, QQueryOperations>
      financialProfileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financialProfileType');
    });
  }

  QueryBuilder<PreviousSearchExpense, GuiltLevel, QQueryOperations>
      guiltLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guiltLevel');
    });
  }

  QueryBuilder<PreviousSearchExpense, bool, QQueryOperations>
      isReimbursableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReimbursable');
    });
  }

  QueryBuilder<PreviousSearchExpense, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<PreviousSearchExpense, DateTime?, QQueryOperations>
      paidAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAt');
    });
  }

  QueryBuilder<PreviousSearchExpense, int, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<PreviousSearchExpense, String?, QQueryOperations>
      receiptPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptPath');
    });
  }

  QueryBuilder<PreviousSearchExpense, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<PreviousSearchExpense, ExpenseStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PreviousSearchExpense, String, QQueryOperations>
      syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<PreviousSearchExpense, String, QQueryOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<PreviousSearchExpense, ExpenseType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<PreviousSearchExpense, String, QQueryOperations>
      yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
