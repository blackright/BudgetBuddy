// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'previous_purchase_expense.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreviousPurchaseExpenseCollection on Isar {
  IsarCollection<PreviousPurchaseExpense> get previousPurchaseExpenses =>
      this.collection();
}

const PreviousPurchaseExpenseSchema = CollectionSchema(
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
      enumMap: _PreviousPurchaseExpenseguiltLevelEnumValueMap,
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
    r'paymentEvidenceJson': PropertySchema(
      id: 14,
      name: r'paymentEvidenceJson',
      type: IsarType.string,
    ),
    r'paymentMethod': PropertySchema(
      id: 15,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 16,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'receiptPath': PropertySchema(
      id: 17,
      name: r'receiptPath',
      type: IsarType.string,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 18,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 19,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PreviousPurchaseExpensestatusEnumValueMap,
    ),
    r'syncGuid': PropertySchema(
      id: 20,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 21,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 22,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 23,
      name: r'type',
      type: IsarType.byte,
      enumMap: _PreviousPurchaseExpensetypeEnumValueMap,
    ),
    r'yearMonth': PropertySchema(
      id: 24,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _previousPurchaseExpenseEstimateSize,
  serialize: _previousPurchaseExpenseSerialize,
  deserialize: _previousPurchaseExpenseDeserialize,
  deserializeProp: _previousPurchaseExpenseDeserializeProp,
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
  getId: _previousPurchaseExpenseGetId,
  getLinks: _previousPurchaseExpenseGetLinks,
  attach: _previousPurchaseExpenseAttach,
  version: '3.1.0+1',
);

int _previousPurchaseExpenseEstimateSize(
  PreviousPurchaseExpense object,
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
    final value = object.paymentEvidenceJson;
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

void _previousPurchaseExpenseSerialize(
  PreviousPurchaseExpense object,
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
  writer.writeString(offsets[14], object.paymentEvidenceJson);
  writer.writeString(offsets[15], object.paymentMethod);
  writer.writeLong(offsets[16], object.profileId);
  writer.writeString(offsets[17], object.receiptPath);
  writer.writeLong(offsets[18], object.sharedSpaceId);
  writer.writeByte(offsets[19], object.status.index);
  writer.writeString(offsets[20], object.syncGuid);
  writer.writeStringList(offsets[21], object.tags);
  writer.writeString(offsets[22], object.title);
  writer.writeByte(offsets[23], object.type.index);
  writer.writeString(offsets[24], object.yearMonth);
}

PreviousPurchaseExpense _previousPurchaseExpenseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PreviousPurchaseExpense(
    amount: reader.readLong(offsets[0]),
    budgetId: reader.readLong(offsets[1]),
    budgetProfileId: reader.readLongOrNull(offsets[2]),
    categoryId: reader.readString(offsets[3]),
    currency: reader.readString(offsets[4]),
    date: reader.readDateTime(offsets[5]),
    financialProfileSyncGuid: reader.readStringOrNull(offsets[6]),
    financialProfileType: reader.readStringOrNull(offsets[7]),
    guiltLevel: _PreviousPurchaseExpenseguiltLevelValueEnumMap[
            reader.readByteOrNull(offsets[8])] ??
        GuiltLevel.essential,
    id: id,
    isReimbursable: reader.readBoolOrNull(offsets[9]) ?? false,
    merchantName: reader.readStringOrNull(offsets[10]),
    merchantSyncGuid: reader.readStringOrNull(offsets[11]),
    notes: reader.readStringOrNull(offsets[12]),
    paidAt: reader.readDateTimeOrNull(offsets[13]),
    paymentEvidenceJson: reader.readStringOrNull(offsets[14]),
    paymentMethod: reader.readStringOrNull(offsets[15]),
    profileId: reader.readLong(offsets[16]),
    receiptPath: reader.readStringOrNull(offsets[17]),
    sharedSpaceId: reader.readLongOrNull(offsets[18]),
    status: _PreviousPurchaseExpensestatusValueEnumMap[
            reader.readByteOrNull(offsets[19])] ??
        ExpenseStatus.paid,
    title: reader.readString(offsets[22]),
    type: _PreviousPurchaseExpensetypeValueEnumMap[
            reader.readByteOrNull(offsets[23])] ??
        ExpenseType.standard,
    yearMonth: reader.readString(offsets[24]),
  );
  object.syncGuid = reader.readString(offsets[20]);
  object.tags = reader.readStringList(offsets[21]) ?? [];
  return object;
}

P _previousPurchaseExpenseDeserializeProp<P>(
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
      return (_PreviousPurchaseExpenseguiltLevelValueEnumMap[
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
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (_PreviousPurchaseExpensestatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ExpenseStatus.paid) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readStringList(offset) ?? []) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (_PreviousPurchaseExpensetypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ExpenseType.standard) as P;
    case 24:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PreviousPurchaseExpenseguiltLevelEnumValueMap = {
  'essential': 0,
  'guiltFree': 1,
  'oops': 2,
};
const _PreviousPurchaseExpenseguiltLevelValueEnumMap = {
  0: GuiltLevel.essential,
  1: GuiltLevel.guiltFree,
  2: GuiltLevel.oops,
};
const _PreviousPurchaseExpensestatusEnumValueMap = {
  'planned': 0,
  'paid': 1,
  'cancelled': 2,
  'reimbursed': 3,
  'partiallyReimbursed': 4,
};
const _PreviousPurchaseExpensestatusValueEnumMap = {
  0: ExpenseStatus.planned,
  1: ExpenseStatus.paid,
  2: ExpenseStatus.cancelled,
  3: ExpenseStatus.reimbursed,
  4: ExpenseStatus.partiallyReimbursed,
};
const _PreviousPurchaseExpensetypeEnumValueMap = {
  'standard': 0,
  'medical': 1,
};
const _PreviousPurchaseExpensetypeValueEnumMap = {
  0: ExpenseType.standard,
  1: ExpenseType.medical,
};

Id _previousPurchaseExpenseGetId(PreviousPurchaseExpense object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _previousPurchaseExpenseGetLinks(
    PreviousPurchaseExpense object) {
  return [];
}

void _previousPurchaseExpenseAttach(
    IsarCollection<dynamic> col, Id id, PreviousPurchaseExpense object) {
  object.id = id;
}

extension PreviousPurchaseExpenseQueryWhereSort
    on QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QWhere> {
  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterWhere>
      anySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId'),
      );
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterWhere>
      anyBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'budgetProfileId'),
      );
    });
  }
}

extension PreviousPurchaseExpenseQueryWhere on QueryBuilder<
    PreviousPurchaseExpense, PreviousPurchaseExpense, QWhereClause> {
  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> sharedSpaceIdEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> yearMonthEqualTo(String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'yearMonth',
        value: [yearMonth],
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> budgetProfileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'budgetProfileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterWhereClause> budgetProfileIdEqualTo(int? budgetProfileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'budgetProfileId',
        value: [budgetProfileId],
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

extension PreviousPurchaseExpenseQueryFilter on QueryBuilder<
    PreviousPurchaseExpense, PreviousPurchaseExpense, QFilterCondition> {
  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> amountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> budgetIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> budgetProfileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'budgetProfileId',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> budgetProfileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'budgetProfileId',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> budgetProfileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetProfileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financialProfileSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financialProfileSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialProfileSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> financialProfileSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'financialProfileSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> financialProfileTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'financialProfileType',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> financialProfileTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'financialProfileType',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> financialProfileTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialProfileType',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> financialProfileTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'financialProfileType',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> guiltLevelEqualTo(GuiltLevel value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guiltLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> isReimbursableEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isReimbursable',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> merchantNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'merchantName',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> merchantNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'merchantName',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> merchantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantName',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> merchantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantName',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> merchantSyncGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'merchantSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> merchantSyncGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'merchantSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> merchantSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> merchantSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paidAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paidAt',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paidAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paidAt',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paidAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentEvidenceJson',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentEvidenceJson',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentEvidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentEvidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentEvidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentEvidenceJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentEvidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentEvidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
          QAfterFilterCondition>
      paymentEvidenceJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentEvidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
          QAfterFilterCondition>
      paymentEvidenceJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentEvidenceJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentEvidenceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentEvidenceJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentEvidenceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentMethod',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentMethod',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> receiptPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receiptPath',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> receiptPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receiptPath',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> receiptPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> receiptPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receiptPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> statusEqualTo(ExpenseStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> typeEqualTo(ExpenseType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
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

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense,
      QAfterFilterCondition> yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension PreviousPurchaseExpenseQueryObject on QueryBuilder<
    PreviousPurchaseExpense, PreviousPurchaseExpense, QFilterCondition> {}

extension PreviousPurchaseExpenseQueryLinks on QueryBuilder<
    PreviousPurchaseExpense, PreviousPurchaseExpense, QFilterCondition> {}

extension PreviousPurchaseExpenseQuerySortBy
    on QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QSortBy> {
  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByBudgetProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByFinancialProfileSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByFinancialProfileSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByFinancialProfileType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByFinancialProfileTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByGuiltLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByIsReimbursableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByMerchantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByMerchantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByMerchantSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByMerchantSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByPaymentEvidenceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentEvidenceJson', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByPaymentEvidenceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentEvidenceJson', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByReceiptPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByReceiptPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension PreviousPurchaseExpenseQuerySortThenBy on QueryBuilder<
    PreviousPurchaseExpense, PreviousPurchaseExpense, QSortThenBy> {
  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByBudgetProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetProfileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByFinancialProfileSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByFinancialProfileSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByFinancialProfileType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByFinancialProfileTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialProfileType', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByGuiltLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guiltLevel', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByIsReimbursableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReimbursable', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByMerchantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByMerchantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByMerchantSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByMerchantSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByPaymentEvidenceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentEvidenceJson', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByPaymentEvidenceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentEvidenceJson', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByReceiptPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByReceiptPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptPath', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension PreviousPurchaseExpenseQueryWhereDistinct on QueryBuilder<
    PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct> {
  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByBudgetProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetProfileId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByFinancialProfileSyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financialProfileSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByFinancialProfileType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financialProfileType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByGuiltLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guiltLevel');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByIsReimbursable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReimbursable');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByMerchantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByMerchantSyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAt');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByPaymentEvidenceJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentEvidenceJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByPaymentMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByReceiptPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctBySyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, PreviousPurchaseExpense, QDistinct>
      distinctByYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension PreviousPurchaseExpenseQueryProperty on QueryBuilder<
    PreviousPurchaseExpense, PreviousPurchaseExpense, QQueryProperty> {
  QueryBuilder<PreviousPurchaseExpense, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, int, QQueryOperations>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, int, QQueryOperations>
      budgetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, int?, QQueryOperations>
      budgetProfileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetProfileId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String, QQueryOperations>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String?, QQueryOperations>
      financialProfileSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financialProfileSyncGuid');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String?, QQueryOperations>
      financialProfileTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financialProfileType');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, GuiltLevel, QQueryOperations>
      guiltLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guiltLevel');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, bool, QQueryOperations>
      isReimbursableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReimbursable');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String?, QQueryOperations>
      merchantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantName');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String?, QQueryOperations>
      merchantSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantSyncGuid');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, DateTime?, QQueryOperations>
      paidAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAt');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String?, QQueryOperations>
      paymentEvidenceJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentEvidenceJson');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String?, QQueryOperations>
      paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, int, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String?, QQueryOperations>
      receiptPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptPath');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, ExpenseStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String, QQueryOperations>
      syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, List<String>, QQueryOperations>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String, QQueryOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, ExpenseType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<PreviousPurchaseExpense, String, QQueryOperations>
      yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
