// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_purchase.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExpensePurchaseCollection on Isar {
  IsarCollection<ExpensePurchase> get expensePurchases => this.collection();
}

const ExpensePurchaseSchema = CollectionSchema(
  name: r'ExpensePurchase',
  id: 5368906308265677862,
  properties: {
    r'budgetId': PropertySchema(
      id: 0,
      name: r'budgetId',
      type: IsarType.long,
    ),
    r'currency': PropertySchema(
      id: 1,
      name: r'currency',
      type: IsarType.string,
    ),
    r'itemGuids': PropertySchema(
      id: 2,
      name: r'itemGuids',
      type: IsarType.stringList,
    ),
    r'merchantName': PropertySchema(
      id: 3,
      name: r'merchantName',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 4,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'receiptTotalMinor': PropertySchema(
      id: 5,
      name: r'receiptTotalMinor',
      type: IsarType.long,
    ),
    r'revision': PropertySchema(
      id: 6,
      name: r'revision',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 7,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'syncGuid': PropertySchema(
      id: 8,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'versionToken': PropertySchema(
      id: 9,
      name: r'versionToken',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 10,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _expensePurchaseEstimateSize,
  serialize: _expensePurchaseSerialize,
  deserialize: _expensePurchaseDeserialize,
  deserializeProp: _expensePurchaseDeserializeProp,
  idName: r'id',
  indexes: {
    r'syncGuid': IndexSchema(
      id: 6159741003405035971,
      name: r'syncGuid',
      unique: true,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _expensePurchaseGetId,
  getLinks: _expensePurchaseGetLinks,
  attach: _expensePurchaseAttach,
  version: '3.1.0+1',
);

int _expensePurchaseEstimateSize(
  ExpensePurchase object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.itemGuids.length * 3;
  {
    for (var i = 0; i < object.itemGuids.length; i++) {
      final value = object.itemGuids[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.merchantName.length * 3;
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.versionToken.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _expensePurchaseSerialize(
  ExpensePurchase object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.budgetId);
  writer.writeString(offsets[1], object.currency);
  writer.writeStringList(offsets[2], object.itemGuids);
  writer.writeString(offsets[3], object.merchantName);
  writer.writeLong(offsets[4], object.profileId);
  writer.writeLong(offsets[5], object.receiptTotalMinor);
  writer.writeLong(offsets[6], object.revision);
  writer.writeLong(offsets[7], object.sharedSpaceId);
  writer.writeString(offsets[8], object.syncGuid);
  writer.writeString(offsets[9], object.versionToken);
  writer.writeString(offsets[10], object.yearMonth);
}

ExpensePurchase _expensePurchaseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExpensePurchase();
  object.budgetId = reader.readLong(offsets[0]);
  object.currency = reader.readString(offsets[1]);
  object.id = id;
  object.itemGuids = reader.readStringList(offsets[2]) ?? [];
  object.merchantName = reader.readString(offsets[3]);
  object.profileId = reader.readLong(offsets[4]);
  object.receiptTotalMinor = reader.readLong(offsets[5]);
  object.revision = reader.readLong(offsets[6]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[7]);
  object.syncGuid = reader.readString(offsets[8]);
  object.versionToken = reader.readString(offsets[9]);
  object.yearMonth = reader.readString(offsets[10]);
  return object;
}

P _expensePurchaseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _expensePurchaseGetId(ExpensePurchase object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _expensePurchaseGetLinks(ExpensePurchase object) {
  return [];
}

void _expensePurchaseAttach(
    IsarCollection<dynamic> col, Id id, ExpensePurchase object) {
  object.id = id;
}

extension ExpensePurchaseByIndex on IsarCollection<ExpensePurchase> {
  Future<ExpensePurchase?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  ExpensePurchase? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<ExpensePurchase?>> getAllBySyncGuid(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<ExpensePurchase?> getAllBySyncGuidSync(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'syncGuid', values);
  }

  Future<int> deleteAllBySyncGuid(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'syncGuid', values);
  }

  int deleteAllBySyncGuidSync(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'syncGuid', values);
  }

  Future<Id> putBySyncGuid(ExpensePurchase object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(ExpensePurchase object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<ExpensePurchase> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<ExpensePurchase> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }
}

extension ExpensePurchaseQueryWhereSort
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QWhere> {
  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhere>
      anySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId'),
      );
    });
  }
}

extension ExpensePurchaseQueryWhere
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QWhereClause> {
  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause> idBetween(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
      syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
      sharedSpaceIdEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterWhereClause>
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
}

extension ExpensePurchaseQueryFilter
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QFilterCondition> {
  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      budgetIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'budgetId',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      budgetIdGreaterThan(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      budgetIdLessThan(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      budgetIdBetween(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemGuids',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemGuids',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemGuids',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemGuids',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemGuids',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemGuids',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemGuids',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemGuids',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemGuids',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      itemGuidsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemGuids',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameEqualTo(
    String value, {
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameGreaterThan(
    String value, {
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameLessThan(
    String value, {
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameStartsWith(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameEndsWith(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'merchantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'merchantName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantName',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      merchantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantName',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      receiptTotalMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptTotalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      receiptTotalMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptTotalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      receiptTotalMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptTotalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      receiptTotalMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptTotalMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      revisionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revision',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      revisionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'revision',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      revisionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'revision',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      revisionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'revision',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      sharedSpaceIdGreaterThan(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      sharedSpaceIdLessThan(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      sharedSpaceIdBetween(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidEqualTo(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidGreaterThan(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidLessThan(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidBetween(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidStartsWith(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidEndsWith(
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'versionToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'versionToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'versionToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'versionToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'versionToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'versionToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'versionToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'versionToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'versionToken',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      versionTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'versionToken',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
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

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension ExpensePurchaseQueryObject
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QFilterCondition> {}

extension ExpensePurchaseQueryLinks
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QFilterCondition> {}

extension ExpensePurchaseQuerySortBy
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QSortBy> {
  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByMerchantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByMerchantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByReceiptTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptTotalMinor', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByReceiptTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptTotalMinor', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByVersionToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'versionToken', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByVersionTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'versionToken', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension ExpensePurchaseQuerySortThenBy
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QSortThenBy> {
  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByBudgetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budgetId', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByMerchantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByMerchantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantName', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByReceiptTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptTotalMinor', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByReceiptTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptTotalMinor', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByVersionToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'versionToken', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByVersionTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'versionToken', Sort.desc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension ExpensePurchaseQueryWhereDistinct
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct> {
  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct>
      distinctByBudgetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budgetId');
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct>
      distinctByItemGuids() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemGuids');
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct>
      distinctByMerchantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct>
      distinctByReceiptTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptTotalMinor');
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct>
      distinctByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revision');
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct>
      distinctByVersionToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'versionToken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpensePurchase, ExpensePurchase, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension ExpensePurchaseQueryProperty
    on QueryBuilder<ExpensePurchase, ExpensePurchase, QQueryProperty> {
  QueryBuilder<ExpensePurchase, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExpensePurchase, int, QQueryOperations> budgetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budgetId');
    });
  }

  QueryBuilder<ExpensePurchase, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<ExpensePurchase, List<String>, QQueryOperations>
      itemGuidsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemGuids');
    });
  }

  QueryBuilder<ExpensePurchase, String, QQueryOperations>
      merchantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantName');
    });
  }

  QueryBuilder<ExpensePurchase, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<ExpensePurchase, int, QQueryOperations>
      receiptTotalMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptTotalMinor');
    });
  }

  QueryBuilder<ExpensePurchase, int, QQueryOperations> revisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revision');
    });
  }

  QueryBuilder<ExpensePurchase, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<ExpensePurchase, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<ExpensePurchase, String, QQueryOperations>
      versionTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'versionToken');
    });
  }

  QueryBuilder<ExpensePurchase, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
