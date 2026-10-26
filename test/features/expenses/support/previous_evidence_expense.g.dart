// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'previous_evidence_expense.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreviousEvidenceExpenseCollection on Isar {
  IsarCollection<PreviousEvidenceExpense> get previousEvidenceExpenses =>
      this.collection();
}

const PreviousEvidenceExpenseSchema = CollectionSchema(
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
      enumMap: _PreviousEvidenceExpenseguiltLevelEnumValueMap,
    ),
    r'isReimbursable': PropertySchema(
      id: 9,
      name: r'isReimbursable',
      type: IsarType.bool,
    ),
    r'merchantName': PropertySchema(
      id: 10,
      name: r'merchantName',
      type: IsarType.string,
    ),
    r'merchantSyncGuid': PropertySchema(
      id: 11,
      name: r'merchantSyncGuid',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 12,
      name: r'notes',
      type: IsarType.string,
    ),
    r'paidAt': PropertySchema(
      id: 13,
      name: r'paidAt',
      type: IsarType.dateTime,
    ),
    r'paymentMethod': PropertySchema(
      id: 14,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 15,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'receiptPath': PropertySchema(
      id: 16,
      name: r'receiptPath',
      type: IsarType.string,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 17,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 18,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PreviousEvidenceExpensestatusEnumValueMap,
    ),
    r'syncGuid': PropertySchema(
      id: 19,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 20,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 21,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 22,
      name: r'type',
      type: IsarType.byte,
      enumMap: _PreviousEvidenceExpensetypeEnumValueMap,
    ),
    r'yearMonth': PropertySchema(
      id: 23,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _previousEvidenceExpenseEstimateSize,
  serialize: _previousEvidenceExpenseSerialize,
  deserialize: _previousEvidenceExpenseDeserialize,
  deserializeProp: _previousEvidenceExpenseDeserializeProp,
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
  getId: _previousEvidenceExpenseGetId,
  getLinks: _previousEvidenceExpenseGetLinks,
  attach: _previousEvidenceExpenseAttach,
  version: '3.1.0+1',
);

int _previousEvidenceExpenseEstimateSize(
  PreviousEvidenceExpense object,
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
    final value = object.merchantName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.merchantSyncGuid;
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
    final value = object.paymentMethod;
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
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _previousEvidenceExpenseSerialize(
  PreviousEvidenceExpense object,
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
  writer.writeString(offsets[10], object.merchantName);
  writer.writeString(offsets[11], object.merchantSyncGuid);
  writer.writeString(offsets[12], object.notes);
  writer.writeDateTime(offsets[13], object.paidAt);
  writer.writeString(offsets[14], object.paymentMethod);
  writer.writeLong(offsets[15], object.profileId);
  writer.writeString(offsets[16], object.receiptPath);
  writer.writeLong(offsets[17], object.sharedSpaceId);
  writer.writeByte(offsets[18], object.status.index);
  writer.writeString(offsets[19], object.syncGuid);
  writer.writeStringList(offsets[20], object.tags);
  writer.writeString(offsets[21], object.title);
  writer.writeByte(offsets[22], object.type.index);
  writer.writeString(offsets[23], object.yearMonth);
}

PreviousEvidenceExpense _previousEvidenceExpenseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PreviousEvidenceExpense(
    amount: reader.readLong(offsets[0]),
    budgetId: reader.readLong(offsets[1]),
    budgetProfileId: reader.readLongOrNull(offsets[2]),
    categoryId: reader.readString(offsets[3]),
    currency: reader.readString(offsets[4]),
    date: reader.readDateTime(offsets[5]),
    financialProfileSyncGuid: reader.readStringOrNull(offsets[6]),
    financialProfileType: reader.readStringOrNull(offsets[7]),
    guiltLevel: _PreviousEvidenceExpenseguiltLevelValueEnumMap[
            reader.readByteOrNull(offsets[8])] ??
        GuiltLevel.essential,
    id: id,
    isReimbursable: reader.readBoolOrNull(offsets[9]) ?? false,
    notes: reader.readStringOrNull(offsets[12]),
    paidAt: reader.readDateTimeOrNull(offsets[13]),
    profileId: reader.readLong(offsets[15]),
    receiptPath: reader.readStringOrNull(offsets[16]),
    sharedSpaceId: reader.readLongOrNull(offsets[17]),
    status: _PreviousEvidenceExpensestatusValueEnumMap[
            reader.readByteOrNull(offsets[18])] ??
        ExpenseStatus.paid,
    title: reader.readString(offsets[21]),
    type: _PreviousEvidenceExpensetypeValueEnumMap[
            reader.readByteOrNull(offsets[22])] ??
        ExpenseType.standard,
    yearMonth: reader.readString(offsets[23]),
  );
  object.merchantName = reader.readStringOrNull(offsets[10]);
  object.merchantSyncGuid = reader.readStringOrNull(offsets[11]);
  object.paymentMethod = reader.readStringOrNull(offsets[14]);
  object.syncGuid = reader.readString(offsets[19]);
  object.tags = reader.readStringList(offsets[20]) ?? [];
  return object;
}

P _previousEvidenceExpenseDeserializeProp<P>(
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
      return (_PreviousEvidenceExpenseguiltLevelValueEnumMap[
              reader.readByteOrNull(offset)] ??
          GuiltLevel.essential) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (_PreviousEvidenceExpensestatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ExpenseStatus.paid) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readStringList(offset) ?? []) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (_PreviousEvidenceExpensetypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ExpenseType.standard) as P;
    case 23:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PreviousEvidenceExpenseguiltLevelEnumValueMap = {
  'essential': 0,
  'guiltFree': 1,
  'oops': 2,
};
const _PreviousEvidenceExpenseguiltLevelValueEnumMap = {
  0: GuiltLevel.essential,
  1: GuiltLevel.guiltFree,
  2: GuiltLevel.oops,
};
const _PreviousEvidenceExpensestatusEnumValueMap = {
  'planned': 0,
  'paid': 1,
  'cancelled': 2,
  'reimbursed': 3,
  'partiallyReimbursed': 4,
};
const _PreviousEvidenceExpensestatusValueEnumMap = {
  0: ExpenseStatus.planned,
  1: ExpenseStatus.paid,
  2: ExpenseStatus.cancelled,
  3: ExpenseStatus.reimbursed,
  4: ExpenseStatus.partiallyReimbursed,
};
const _PreviousEvidenceExpensetypeEnumValueMap = {
  'standard': 0,
  'medical': 1,
};
const _PreviousEvidenceExpensetypeValueEnumMap = {
  0: ExpenseType.standard,
  1: ExpenseType.medical,
};

Id _previousEvidenceExpenseGetId(PreviousEvidenceExpense object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _previousEvidenceExpenseGetLinks(
    PreviousEvidenceExpense object) {
  return [];
}

void _previousEvidenceExpenseAttach(
    IsarCollection<dynamic> col, Id id, PreviousEvidenceExpense object) {
  object.id = id;
}

extension PreviousEvidenceExpenseQueryWhereSort
    on QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QWhere> {
  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterWhere>
      anySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId'),
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterWhere>
      anyBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'budgetProfileId'),
      );
    });
  }
}

extension PreviousEvidenceExpenseQueryWhere on QueryBuilder<
    PreviousEvidenceExpense, PreviousEvidenceExpense, QWhereClause> {
  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> syncGuidNotEqualTo(String syncGuid) {
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> profileIdNotEqualTo(int profileId) {
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> profileIdGreaterThan(
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> profileIdLessThan(
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> profileIdBetween(
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> sharedSpaceIdEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> sharedSpaceIdNotEqualTo(int? sharedSpaceId) {
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> sharedSpaceIdGreaterThan(
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> sharedSpaceIdLessThan(
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> sharedSpaceIdBetween(
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> yearMonthEqualTo(String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'yearMonth',
        value: [yearMonth],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> yearMonthNotEqualTo(String yearMonth) {
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> budgetProfileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'budgetProfileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> budgetProfileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'budgetProfileId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> budgetProfileIdEqualTo(int? budgetProfileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'budgetProfileId',
        value: [budgetProfileId],
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> budgetProfileIdNotEqualTo(int? budgetProfileId) {
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> budgetProfileIdGreaterThan(
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> budgetProfileIdLessThan(
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterWhereClause> budgetProfileIdBetween(
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

extension PreviousEvidenceExpenseQueryFilter on QueryBuilder<
    PreviousEvidenceExpense, PreviousEvidenceExpense, QFilterCondition> {
  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> amountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> budgetIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> budgetProfileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'budgetProfileId',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> budgetProfileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'budgetProfileId',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> budgetProfileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetProfileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financialProfileSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financialProfileSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialProfileSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'financialProfileSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> financialProfileTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financialProfileType',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> financialProfileTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financialProfileType',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> financialProfileTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialProfileType',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> financialProfileTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'financialProfileType',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> guiltLevelEqualTo(GuiltLevel value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guiltLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> isReimbursableEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isReimbursable',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'merchantName',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'merchantName',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'merchantName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
          QAfterFilterCondition>
      merchantNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
          QAfterFilterCondition>
      merchantNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'merchantName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantName',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantName',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'merchantSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'merchantSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'merchantSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'merchantSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'merchantSyncGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'merchantSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'merchantSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
          QAfterFilterCondition>
      merchantSyncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'merchantSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
          QAfterFilterCondition>
      merchantSyncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'merchantSyncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> merchantSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paidAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paidAt',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paidAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paidAt',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paidAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentMethod',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentMethod',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
          QAfterFilterCondition>
      paymentMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
          QAfterFilterCondition>
      paymentMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> receiptPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receiptPath',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> receiptPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receiptPath',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> receiptPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> receiptPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receiptPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> statusEqualTo(ExpenseStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
          QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
          QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> typeEqualTo(ExpenseType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
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

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense,
      QAfterFilterCondition> yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension PreviousEvidenceExpenseQueryObject on QueryBuilder<
    PreviousEvidenceExpense, PreviousEvidenceExpense, QFilterCondition> {}

extension PreviousEvidenceExpenseQueryLinks on QueryBuilder<
    PreviousEvidenceExpense, PreviousEvidenceExpense, QFilterCondition> {}

extension PreviousEvidenceExpenseQuerySortBy
    on QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QSortBy> {
  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByBudgetProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByFinancialProfileSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByFinancialProfileSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByFinancialProfileType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByFinancialProfileTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByGuiltLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByIsReimbursableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByMerchantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByMerchantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByMerchantSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByMerchantSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByReceiptPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByReceiptPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension PreviousEvidenceExpenseQuerySortThenBy on QueryBuilder<
    PreviousEvidenceExpense, PreviousEvidenceExpense, QSortThenBy> {
  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByBudgetProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByFinancialProfileSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByFinancialProfileSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByFinancialProfileType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByFinancialProfileTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByGuiltLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByIsReimbursableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByMerchantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByMerchantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByMerchantSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByMerchantSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByReceiptPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByReceiptPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension PreviousEvidenceExpenseQueryWhereDistinct on QueryBuilder<
    PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct> {
  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetProfileId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByFinancialProfileSyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financialProfileSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByFinancialProfileType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financialProfileType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guiltLevel');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReimbursable');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByMerchantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByMerchantSyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAt');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByPaymentMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByReceiptPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctBySyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, PreviousEvidenceExpense, QDistinct>
      distinctByYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension PreviousEvidenceExpenseQueryProperty on QueryBuilder<
    PreviousEvidenceExpense, PreviousEvidenceExpense, QQueryProperty> {
  QueryBuilder<PreviousEvidenceExpense, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, int, QQueryOperations>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, int, QQueryOperations>
      budgetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, int?, QQueryOperations>
      budgetProfileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetProfileId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String, QQueryOperations>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String?, QQueryOperations>
      financialProfileSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financialProfileSyncGuid');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String?, QQueryOperations>
      financialProfileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financialProfileType');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, GuiltLevel, QQueryOperations>
      guiltLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guiltLevel');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, bool, QQueryOperations>
      isReimbursableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReimbursable');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String?, QQueryOperations>
      merchantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantName');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String?, QQueryOperations>
      merchantSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantSyncGuid');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, DateTime?, QQueryOperations>
      paidAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAt');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String?, QQueryOperations>
      paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, int, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String?, QQueryOperations>
      receiptPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptPath');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, ExpenseStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String, QQueryOperations>
      syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, List<String>, QQueryOperations>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String, QQueryOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, ExpenseType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<PreviousEvidenceExpense, String, QQueryOperations>
      yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
