// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVaultEntryCollection on Isar {
  IsarCollection<VaultEntry> get vaultEntrys => this.collection();
}

const VaultEntrySchema = CollectionSchema(
  name: r'VaultEntry',
  id: 2380021720914536519,
  properties: {
    r'amountMinor': PropertySchema(
      id: 0,
      name: r'amountMinor',
      type: IsarType.long,
    ),
    r'balanceAfterMinor': PropertySchema(
      id: 1,
      name: r'balanceAfterMinor',
      type: IsarType.long,
    ),
    r'breakdownJson': PropertySchema(
      id: 2,
      name: r'breakdownJson',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 4,
      name: r'currency',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 5,
      name: r'kind',
      type: IsarType.string,
    ),
    r'operationKey': PropertySchema(
      id: 6,
      name: r'operationKey',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 7,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(
      id: 8,
      name: r'reason',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 9,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _vaultEntryEstimateSize,
  serialize: _vaultEntrySerialize,
  deserialize: _vaultEntryDeserialize,
  deserializeProp: _vaultEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'operationKey': IndexSchema(
      id: 1009902635771944155,
      name: r'operationKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'operationKey',
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _vaultEntryGetId,
  getLinks: _vaultEntryGetLinks,
  attach: _vaultEntryAttach,
  version: '3.1.0+1',
);

int _vaultEntryEstimateSize(
  VaultEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.breakdownJson.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.operationKey.length * 3;
  {
    final value = object.reason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.yearMonth;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _vaultEntrySerialize(
  VaultEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amountMinor);
  writer.writeLong(offsets[1], object.balanceAfterMinor);
  writer.writeString(offsets[2], object.breakdownJson);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.currency);
  writer.writeString(offsets[5], object.kind);
  writer.writeString(offsets[6], object.operationKey);
  writer.writeLong(offsets[7], object.profileId);
  writer.writeString(offsets[8], object.reason);
  writer.writeString(offsets[9], object.yearMonth);
}

VaultEntry _vaultEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VaultEntry();
  object.amountMinor = reader.readLong(offsets[0]);
  object.balanceAfterMinor = reader.readLong(offsets[1]);
  object.breakdownJson = reader.readString(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.currency = reader.readString(offsets[4]);
  object.id = id;
  object.kind = reader.readString(offsets[5]);
  object.operationKey = reader.readString(offsets[6]);
  object.profileId = reader.readLong(offsets[7]);
  object.reason = reader.readStringOrNull(offsets[8]);
  object.yearMonth = reader.readStringOrNull(offsets[9]);
  return object;
}

P _vaultEntryDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vaultEntryGetId(VaultEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vaultEntryGetLinks(VaultEntry object) {
  return [];
}

void _vaultEntryAttach(IsarCollection<dynamic> col, Id id, VaultEntry object) {
  object.id = id;
}

extension VaultEntryByIndex on IsarCollection<VaultEntry> {
  Future<VaultEntry?> getByOperationKey(String operationKey) {
    return getByIndex(r'operationKey', [operationKey]);
  }

  VaultEntry? getByOperationKeySync(String operationKey) {
    return getByIndexSync(r'operationKey', [operationKey]);
  }

  Future<bool> deleteByOperationKey(String operationKey) {
    return deleteByIndex(r'operationKey', [operationKey]);
  }

  bool deleteByOperationKeySync(String operationKey) {
    return deleteByIndexSync(r'operationKey', [operationKey]);
  }

  Future<List<VaultEntry?>> getAllByOperationKey(
      List<String> operationKeyValues) {
    final values = operationKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationKey', values);
  }

  List<VaultEntry?> getAllByOperationKeySync(List<String> operationKeyValues) {
    final values = operationKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'operationKey', values);
  }

  Future<int> deleteAllByOperationKey(List<String> operationKeyValues) {
    final values = operationKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'operationKey', values);
  }

  int deleteAllByOperationKeySync(List<String> operationKeyValues) {
    final values = operationKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'operationKey', values);
  }

  Future<Id> putByOperationKey(VaultEntry object) {
    return putByIndex(r'operationKey', object);
  }

  Id putByOperationKeySync(VaultEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'operationKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationKey(List<VaultEntry> objects) {
    return putAllByIndex(r'operationKey', objects);
  }

  List<Id> putAllByOperationKeySync(List<VaultEntry> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationKey', objects, saveLinks: saveLinks);
  }
}

extension VaultEntryQueryWhereSort
    on QueryBuilder<VaultEntry, VaultEntry, QWhere> {
  QueryBuilder<VaultEntry, VaultEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension VaultEntryQueryWhere
    on QueryBuilder<VaultEntry, VaultEntry, QWhereClause> {
  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> operationKeyEqualTo(
      String operationKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationKey',
        value: [operationKey],
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause>
      operationKeyNotEqualTo(String operationKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationKey',
              lower: [],
              upper: [operationKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationKey',
              lower: [operationKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationKey',
              lower: [operationKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationKey',
              lower: [],
              upper: [operationKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> profileIdEqualTo(
      int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> profileIdNotEqualTo(
      int profileId) {
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> profileIdGreaterThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> profileIdLessThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterWhereClause> profileIdBetween(
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
}

extension VaultEntryQueryFilter
    on QueryBuilder<VaultEntry, VaultEntry, QFilterCondition> {
  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      amountMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      amountMinorGreaterThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      amountMinorLessThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      amountMinorBetween(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      balanceAfterMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'balanceAfterMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      balanceAfterMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'balanceAfterMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      balanceAfterMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'balanceAfterMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      balanceAfterMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'balanceAfterMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breakdownJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'breakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'breakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'breakdownJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'breakdownJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakdownJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      breakdownJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'breakdownJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> currencyEqualTo(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> currencyLessThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> currencyBetween(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> currencyEndsWith(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> currencyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> currencyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindEqualTo(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindGreaterThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindLessThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindBetween(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindStartsWith(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindEndsWith(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindContains(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindMatches(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationKey',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      operationKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationKey',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> profileIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> profileIdLessThan(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> profileIdBetween(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reason',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      reasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reason',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      yearMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'yearMonth',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      yearMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'yearMonth',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> yearMonthEqualTo(
    String? value, {
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      yearMonthGreaterThan(
    String? value, {
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> yearMonthLessThan(
    String? value, {
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> yearMonthBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> yearMonthEndsWith(
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

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> yearMonthContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition> yearMonthMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension VaultEntryQueryObject
    on QueryBuilder<VaultEntry, VaultEntry, QFilterCondition> {}

extension VaultEntryQueryLinks
    on QueryBuilder<VaultEntry, VaultEntry, QFilterCondition> {}

extension VaultEntryQuerySortBy
    on QueryBuilder<VaultEntry, VaultEntry, QSortBy> {
  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByBalanceAfterMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceAfterMinor', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy>
      sortByBalanceAfterMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceAfterMinor', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByBreakdownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakdownJson', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByBreakdownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakdownJson', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByOperationKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationKey', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByOperationKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationKey', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension VaultEntryQuerySortThenBy
    on QueryBuilder<VaultEntry, VaultEntry, QSortThenBy> {
  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByBalanceAfterMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceAfterMinor', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy>
      thenByBalanceAfterMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceAfterMinor', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByBreakdownJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakdownJson', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByBreakdownJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakdownJson', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByOperationKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationKey', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByOperationKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationKey', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QAfterSortBy> thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension VaultEntryQueryWhereDistinct
    on QueryBuilder<VaultEntry, VaultEntry, QDistinct> {
  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountMinor');
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct>
      distinctByBalanceAfterMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'balanceAfterMinor');
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByBreakdownJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breakdownJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByKind(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByOperationKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VaultEntry, VaultEntry, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension VaultEntryQueryProperty
    on QueryBuilder<VaultEntry, VaultEntry, QQueryProperty> {
  QueryBuilder<VaultEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VaultEntry, int, QQueryOperations> amountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountMinor');
    });
  }

  QueryBuilder<VaultEntry, int, QQueryOperations> balanceAfterMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'balanceAfterMinor');
    });
  }

  QueryBuilder<VaultEntry, String, QQueryOperations> breakdownJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breakdownJson');
    });
  }

  QueryBuilder<VaultEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<VaultEntry, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<VaultEntry, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<VaultEntry, String, QQueryOperations> operationKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationKey');
    });
  }

  QueryBuilder<VaultEntry, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<VaultEntry, String?, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<VaultEntry, String?, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
