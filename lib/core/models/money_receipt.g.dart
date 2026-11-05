// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_receipt.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMoneyReceiptCollection on Isar {
  IsarCollection<MoneyReceipt> get moneyReceipts => this.collection();
}

const MoneyReceiptSchema = CollectionSchema(
  name: r'MoneyReceipt',
  id: 3349334543729824733,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'billGuid': PropertySchema(
      id: 1,
      name: r'billGuid',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'inputFingerprint': PropertySchema(
      id: 3,
      name: r'inputFingerprint',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 4,
      name: r'kind',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 5,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 6,
      name: r'profileId',
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
    )
  },
  estimateSize: _moneyReceiptEstimateSize,
  serialize: _moneyReceiptSerialize,
  deserialize: _moneyReceiptDeserialize,
  deserializeProp: _moneyReceiptDeserializeProp,
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
    r'billGuid': IndexSchema(
      id: 7820085104166478755,
      name: r'billGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'billGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'operationIdentity': IndexSchema(
      id: -4216402992424952868,
      name: r'operationIdentity',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'operationIdentity',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _moneyReceiptGetId,
  getLinks: _moneyReceiptGetLinks,
  attach: _moneyReceiptAttach,
  version: '3.1.0+1',
);

int _moneyReceiptEstimateSize(
  MoneyReceipt object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.billGuid.length * 3;
  bytesCount += 3 + object.inputFingerprint.length * 3;
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  bytesCount += 3 + object.syncGuid.length * 3;
  return bytesCount;
}

void _moneyReceiptSerialize(
  MoneyReceipt object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeString(offsets[1], object.billGuid);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.inputFingerprint);
  writer.writeString(offsets[4], object.kind);
  writer.writeString(offsets[5], object.operationIdentity);
  writer.writeLong(offsets[6], object.profileId);
  writer.writeLong(offsets[7], object.sharedSpaceId);
  writer.writeString(offsets[8], object.syncGuid);
}

MoneyReceipt _moneyReceiptDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MoneyReceipt();
  object.actorId = reader.readLong(offsets[0]);
  object.billGuid = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.inputFingerprint = reader.readString(offsets[3]);
  object.kind = reader.readString(offsets[4]);
  object.operationIdentity = reader.readString(offsets[5]);
  object.profileId = reader.readLongOrNull(offsets[6]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[7]);
  object.syncGuid = reader.readString(offsets[8]);
  return object;
}

P _moneyReceiptDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _moneyReceiptGetId(MoneyReceipt object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _moneyReceiptGetLinks(MoneyReceipt object) {
  return [];
}

void _moneyReceiptAttach(
    IsarCollection<dynamic> col, Id id, MoneyReceipt object) {
  object.id = id;
}

extension MoneyReceiptByIndex on IsarCollection<MoneyReceipt> {
  Future<MoneyReceipt?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  MoneyReceipt? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<MoneyReceipt?>> getAllBySyncGuid(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<MoneyReceipt?> getAllBySyncGuidSync(List<String> syncGuidValues) {
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

  Future<Id> putBySyncGuid(MoneyReceipt object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(MoneyReceipt object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<MoneyReceipt> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<MoneyReceipt> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }

  Future<MoneyReceipt?> getByOperationIdentity(String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  MoneyReceipt? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<MoneyReceipt?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<MoneyReceipt?> getAllByOperationIdentitySync(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'operationIdentity', values);
  }

  Future<int> deleteAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'operationIdentity', values);
  }

  int deleteAllByOperationIdentitySync(List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'operationIdentity', values);
  }

  Future<Id> putByOperationIdentity(MoneyReceipt object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(MoneyReceipt object, {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(List<MoneyReceipt> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<MoneyReceipt> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension MoneyReceiptQueryWhereSort
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QWhere> {
  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MoneyReceiptQueryWhere
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QWhereClause> {
  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause> idBetween(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause> syncGuidEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause> billGuidEqualTo(
      String billGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'billGuid',
        value: [billGuid],
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause>
      billGuidNotEqualTo(String billGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'billGuid',
              lower: [],
              upper: [billGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'billGuid',
              lower: [billGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'billGuid',
              lower: [billGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'billGuid',
              lower: [],
              upper: [billGuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause>
      operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterWhereClause>
      operationIdentityNotEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationIdentity',
              lower: [],
              upper: [operationIdentity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationIdentity',
              lower: [operationIdentity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationIdentity',
              lower: [operationIdentity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationIdentity',
              lower: [],
              upper: [operationIdentity],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MoneyReceiptQueryFilter
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QFilterCondition> {
  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      actorIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      actorIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      actorIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'billGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'billGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      billGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inputFingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inputFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      inputFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> kindContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition> kindMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationIdentity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      profileIdGreaterThan(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      profileIdLessThan(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      profileIdBetween(
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
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

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }
}

extension MoneyReceiptQueryObject
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QFilterCondition> {}

extension MoneyReceiptQueryLinks
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QFilterCondition> {}

extension MoneyReceiptQuerySortBy
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QSortBy> {
  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      sortByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      sortByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }
}

extension MoneyReceiptQuerySortThenBy
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QSortThenBy> {
  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      thenByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      thenByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QAfterSortBy> thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }
}

extension MoneyReceiptQueryWhereDistinct
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct> {
  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct> distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct> distinctByBillGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct>
      distinctByInputFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct> distinctByKind(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<MoneyReceipt, MoneyReceipt, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }
}

extension MoneyReceiptQueryProperty
    on QueryBuilder<MoneyReceipt, MoneyReceipt, QQueryProperty> {
  QueryBuilder<MoneyReceipt, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MoneyReceipt, int, QQueryOperations> actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<MoneyReceipt, String, QQueryOperations> billGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billGuid');
    });
  }

  QueryBuilder<MoneyReceipt, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MoneyReceipt, String, QQueryOperations>
      inputFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputFingerprint');
    });
  }

  QueryBuilder<MoneyReceipt, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<MoneyReceipt, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<MoneyReceipt, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MoneyReceipt, int?, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<MoneyReceipt, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReceiptRevisionCollection on Isar {
  IsarCollection<ReceiptRevision> get receiptRevisions => this.collection();
}

const ReceiptRevisionSchema = CollectionSchema(
  name: r'ReceiptRevision',
  id: -4296697044169034063,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'billGuid': PropertySchema(
      id: 1,
      name: r'billGuid',
      type: IsarType.string,
    ),
    r'evidenceJson': PropertySchema(
      id: 2,
      name: r'evidenceJson',
      type: IsarType.string,
    ),
    r'inputFingerprint': PropertySchema(
      id: 3,
      name: r'inputFingerprint',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 4,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'previousGuid': PropertySchema(
      id: 5,
      name: r'previousGuid',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 6,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'receiptGuid': PropertySchema(
      id: 7,
      name: r'receiptGuid',
      type: IsarType.string,
    ),
    r'recordedAt': PropertySchema(
      id: 8,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'revision': PropertySchema(
      id: 9,
      name: r'revision',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 10,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'syncGuid': PropertySchema(
      id: 11,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 12,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _receiptRevisionEstimateSize,
  serialize: _receiptRevisionSerialize,
  deserialize: _receiptRevisionDeserialize,
  deserializeProp: _receiptRevisionDeserializeProp,
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
    r'receiptGuid': IndexSchema(
      id: 7929485400263885226,
      name: r'receiptGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'receiptGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'operationIdentity': IndexSchema(
      id: -4216402992424952868,
      name: r'operationIdentity',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'operationIdentity',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _receiptRevisionGetId,
  getLinks: _receiptRevisionGetLinks,
  attach: _receiptRevisionAttach,
  version: '3.1.0+1',
);

int _receiptRevisionEstimateSize(
  ReceiptRevision object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.billGuid.length * 3;
  bytesCount += 3 + object.evidenceJson.length * 3;
  bytesCount += 3 + object.inputFingerprint.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  {
    final value = object.previousGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.receiptGuid.length * 3;
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _receiptRevisionSerialize(
  ReceiptRevision object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeString(offsets[1], object.billGuid);
  writer.writeString(offsets[2], object.evidenceJson);
  writer.writeString(offsets[3], object.inputFingerprint);
  writer.writeString(offsets[4], object.operationIdentity);
  writer.writeString(offsets[5], object.previousGuid);
  writer.writeLong(offsets[6], object.profileId);
  writer.writeString(offsets[7], object.receiptGuid);
  writer.writeDateTime(offsets[8], object.recordedAt);
  writer.writeLong(offsets[9], object.revision);
  writer.writeLong(offsets[10], object.sharedSpaceId);
  writer.writeString(offsets[11], object.syncGuid);
  writer.writeString(offsets[12], object.yearMonth);
}

ReceiptRevision _receiptRevisionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReceiptRevision();
  object.actorId = reader.readLong(offsets[0]);
  object.billGuid = reader.readString(offsets[1]);
  object.evidenceJson = reader.readString(offsets[2]);
  object.id = id;
  object.inputFingerprint = reader.readString(offsets[3]);
  object.operationIdentity = reader.readString(offsets[4]);
  object.previousGuid = reader.readStringOrNull(offsets[5]);
  object.profileId = reader.readLongOrNull(offsets[6]);
  object.receiptGuid = reader.readString(offsets[7]);
  object.recordedAt = reader.readDateTime(offsets[8]);
  object.revision = reader.readLong(offsets[9]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[10]);
  object.syncGuid = reader.readString(offsets[11]);
  object.yearMonth = reader.readString(offsets[12]);
  return object;
}

P _receiptRevisionDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _receiptRevisionGetId(ReceiptRevision object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _receiptRevisionGetLinks(ReceiptRevision object) {
  return [];
}

void _receiptRevisionAttach(
    IsarCollection<dynamic> col, Id id, ReceiptRevision object) {
  object.id = id;
}

extension ReceiptRevisionByIndex on IsarCollection<ReceiptRevision> {
  Future<ReceiptRevision?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  ReceiptRevision? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<ReceiptRevision?>> getAllBySyncGuid(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<ReceiptRevision?> getAllBySyncGuidSync(List<String> syncGuidValues) {
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

  Future<Id> putBySyncGuid(ReceiptRevision object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(ReceiptRevision object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<ReceiptRevision> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<ReceiptRevision> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }

  Future<ReceiptRevision?> getByOperationIdentity(String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  ReceiptRevision? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<ReceiptRevision?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<ReceiptRevision?> getAllByOperationIdentitySync(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'operationIdentity', values);
  }

  Future<int> deleteAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'operationIdentity', values);
  }

  int deleteAllByOperationIdentitySync(List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'operationIdentity', values);
  }

  Future<Id> putByOperationIdentity(ReceiptRevision object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(ReceiptRevision object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(List<ReceiptRevision> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<ReceiptRevision> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension ReceiptRevisionQueryWhereSort
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QWhere> {
  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReceiptRevisionQueryWhere
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QWhereClause> {
  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause> idBetween(
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause>
      syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause>
      receiptGuidEqualTo(String receiptGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'receiptGuid',
        value: [receiptGuid],
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause>
      receiptGuidNotEqualTo(String receiptGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'receiptGuid',
              lower: [],
              upper: [receiptGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'receiptGuid',
              lower: [receiptGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'receiptGuid',
              lower: [receiptGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'receiptGuid',
              lower: [],
              upper: [receiptGuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause>
      operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterWhereClause>
      operationIdentityNotEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationIdentity',
              lower: [],
              upper: [operationIdentity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationIdentity',
              lower: [operationIdentity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationIdentity',
              lower: [operationIdentity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationIdentity',
              lower: [],
              upper: [operationIdentity],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ReceiptRevisionQueryFilter
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QFilterCondition> {
  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      actorIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      actorIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      actorIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'billGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'billGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      billGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'evidenceJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'evidenceJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evidenceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      evidenceJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'evidenceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inputFingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inputFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      inputFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationIdentity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousGuid',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousGuid',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      previousGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      profileIdGreaterThan(
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      profileIdLessThan(
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      profileIdBetween(
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'receiptGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'receiptGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'receiptGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'receiptGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      receiptGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receiptGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      recordedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      recordedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      recordedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      revisionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revision',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
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

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension ReceiptRevisionQueryObject
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QFilterCondition> {}

extension ReceiptRevisionQueryLinks
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QFilterCondition> {}

extension ReceiptRevisionQuerySortBy
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QSortBy> {
  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy> sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByEvidenceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evidenceJson', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByEvidenceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evidenceJson', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByPreviousGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousGuid', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByPreviousGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousGuid', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByReceiptGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGuid', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByReceiptGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGuid', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension ReceiptRevisionQuerySortThenBy
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QSortThenBy> {
  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy> thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByEvidenceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evidenceJson', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByEvidenceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evidenceJson', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByPreviousGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousGuid', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByPreviousGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousGuid', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByReceiptGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGuid', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByReceiptGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptGuid', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension ReceiptRevisionQueryWhereDistinct
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct> {
  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct> distinctByBillGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByEvidenceJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'evidenceJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByInputFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByPreviousGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByReceiptGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revision');
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReceiptRevision, ReceiptRevision, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension ReceiptRevisionQueryProperty
    on QueryBuilder<ReceiptRevision, ReceiptRevision, QQueryProperty> {
  QueryBuilder<ReceiptRevision, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReceiptRevision, int, QQueryOperations> actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<ReceiptRevision, String, QQueryOperations> billGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billGuid');
    });
  }

  QueryBuilder<ReceiptRevision, String, QQueryOperations>
      evidenceJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'evidenceJson');
    });
  }

  QueryBuilder<ReceiptRevision, String, QQueryOperations>
      inputFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputFingerprint');
    });
  }

  QueryBuilder<ReceiptRevision, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<ReceiptRevision, String?, QQueryOperations>
      previousGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousGuid');
    });
  }

  QueryBuilder<ReceiptRevision, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<ReceiptRevision, String, QQueryOperations>
      receiptGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptGuid');
    });
  }

  QueryBuilder<ReceiptRevision, DateTime, QQueryOperations>
      recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<ReceiptRevision, int, QQueryOperations> revisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revision');
    });
  }

  QueryBuilder<ReceiptRevision, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<ReceiptRevision, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<ReceiptRevision, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
