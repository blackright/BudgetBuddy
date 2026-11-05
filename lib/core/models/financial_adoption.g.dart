// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_adoption.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFinancialAdoptionCollection on Isar {
  IsarCollection<FinancialAdoption> get financialAdoptions => this.collection();
}

const FinancialAdoptionSchema = CollectionSchema(
  name: r'FinancialAdoption',
  id: 5340328290360990685,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'chosenAccountingCurrency': PropertySchema(
      id: 1,
      name: r'chosenAccountingCurrency',
      type: IsarType.string,
    ),
    r'confirmedAt': PropertySchema(
      id: 2,
      name: r'confirmedAt',
      type: IsarType.dateTime,
    ),
    r'effectiveYearMonth': PropertySchema(
      id: 3,
      name: r'effectiveYearMonth',
      type: IsarType.string,
    ),
    r'enabledCapabilities': PropertySchema(
      id: 4,
      name: r'enabledCapabilities',
      type: IsarType.stringList,
    ),
    r'guid': PropertySchema(
      id: 5,
      name: r'guid',
      type: IsarType.string,
    ),
    r'inputFingerprint': PropertySchema(
      id: 6,
      name: r'inputFingerprint',
      type: IsarType.string,
    ),
    r'legacySourceFingerprint': PropertySchema(
      id: 7,
      name: r'legacySourceFingerprint',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 8,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'ownerKey': PropertySchema(
      id: 9,
      name: r'ownerKey',
      type: IsarType.string,
    ),
    r'policyVersion': PropertySchema(
      id: 10,
      name: r'policyVersion',
      type: IsarType.long,
    ),
    r'previousRevisionGuid': PropertySchema(
      id: 11,
      name: r'previousRevisionGuid',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 12,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'reviewedFundingJson': PropertySchema(
      id: 13,
      name: r'reviewedFundingJson',
      type: IsarType.string,
    ),
    r'revision': PropertySchema(
      id: 14,
      name: r'revision',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 15,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 16,
      name: r'status',
      type: IsarType.string,
    )
  },
  estimateSize: _financialAdoptionEstimateSize,
  serialize: _financialAdoptionSerialize,
  deserialize: _financialAdoptionDeserialize,
  deserializeProp: _financialAdoptionDeserializeProp,
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
  getId: _financialAdoptionGetId,
  getLinks: _financialAdoptionGetLinks,
  attach: _financialAdoptionAttach,
  version: '3.1.0+1',
);

int _financialAdoptionEstimateSize(
  FinancialAdoption object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chosenAccountingCurrency.length * 3;
  bytesCount += 3 + object.effectiveYearMonth.length * 3;
  bytesCount += 3 + object.enabledCapabilities.length * 3;
  {
    for (var i = 0; i < object.enabledCapabilities.length; i++) {
      final value = object.enabledCapabilities[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.guid.length * 3;
  bytesCount += 3 + object.inputFingerprint.length * 3;
  bytesCount += 3 + object.legacySourceFingerprint.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  bytesCount += 3 + object.ownerKey.length * 3;
  {
    final value = object.previousRevisionGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reviewedFundingJson.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _financialAdoptionSerialize(
  FinancialAdoption object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeString(offsets[1], object.chosenAccountingCurrency);
  writer.writeDateTime(offsets[2], object.confirmedAt);
  writer.writeString(offsets[3], object.effectiveYearMonth);
  writer.writeStringList(offsets[4], object.enabledCapabilities);
  writer.writeString(offsets[5], object.guid);
  writer.writeString(offsets[6], object.inputFingerprint);
  writer.writeString(offsets[7], object.legacySourceFingerprint);
  writer.writeString(offsets[8], object.operationIdentity);
  writer.writeString(offsets[9], object.ownerKey);
  writer.writeLong(offsets[10], object.policyVersion);
  writer.writeString(offsets[11], object.previousRevisionGuid);
  writer.writeLong(offsets[12], object.profileId);
  writer.writeString(offsets[13], object.reviewedFundingJson);
  writer.writeLong(offsets[14], object.revision);
  writer.writeLong(offsets[15], object.sharedSpaceId);
  writer.writeString(offsets[16], object.status);
}

FinancialAdoption _financialAdoptionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinancialAdoption();
  object.actorId = reader.readLong(offsets[0]);
  object.chosenAccountingCurrency = reader.readString(offsets[1]);
  object.confirmedAt = reader.readDateTime(offsets[2]);
  object.effectiveYearMonth = reader.readString(offsets[3]);
  object.enabledCapabilities = reader.readStringList(offsets[4]) ?? [];
  object.guid = reader.readString(offsets[5]);
  object.id = id;
  object.inputFingerprint = reader.readString(offsets[6]);
  object.legacySourceFingerprint = reader.readString(offsets[7]);
  object.operationIdentity = reader.readString(offsets[8]);
  object.ownerKey = reader.readString(offsets[9]);
  object.policyVersion = reader.readLong(offsets[10]);
  object.previousRevisionGuid = reader.readStringOrNull(offsets[11]);
  object.profileId = reader.readLongOrNull(offsets[12]);
  object.reviewedFundingJson = reader.readString(offsets[13]);
  object.revision = reader.readLong(offsets[14]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[15]);
  object.status = reader.readString(offsets[16]);
  return object;
}

P _financialAdoptionDeserializeProp<P>(
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
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _financialAdoptionGetId(FinancialAdoption object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _financialAdoptionGetLinks(
    FinancialAdoption object) {
  return [];
}

void _financialAdoptionAttach(
    IsarCollection<dynamic> col, Id id, FinancialAdoption object) {
  object.id = id;
}

extension FinancialAdoptionByIndex on IsarCollection<FinancialAdoption> {
  Future<FinancialAdoption?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  FinancialAdoption? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<FinancialAdoption?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<FinancialAdoption?> getAllByGuidSync(List<String> guidValues) {
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

  Future<Id> putByGuid(FinancialAdoption object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(FinancialAdoption object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<FinancialAdoption> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<FinancialAdoption> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }

  Future<FinancialAdoption?> getByOperationIdentity(String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  FinancialAdoption? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<FinancialAdoption?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<FinancialAdoption?> getAllByOperationIdentitySync(
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

  Future<Id> putByOperationIdentity(FinancialAdoption object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(FinancialAdoption object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(List<FinancialAdoption> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<FinancialAdoption> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension FinancialAdoptionQueryWhereSort
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QWhere> {
  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FinancialAdoptionQueryWhere
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QWhereClause> {
  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
      guidEqualTo(String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
      guidNotEqualTo(String guid) {
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
      ownerKeyEqualTo(String ownerKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ownerKey',
        value: [ownerKey],
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
      ownerKeyNotEqualTo(String ownerKey) {
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
      operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterWhereClause>
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

extension FinancialAdoptionQueryFilter
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QFilterCondition> {
  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chosenAccountingCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chosenAccountingCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chosenAccountingCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chosenAccountingCurrency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chosenAccountingCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chosenAccountingCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chosenAccountingCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chosenAccountingCurrency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chosenAccountingCurrency',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      chosenAccountingCurrencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chosenAccountingCurrency',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      confirmedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      confirmedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confirmedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      confirmedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confirmedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      confirmedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confirmedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveYearMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'effectiveYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'effectiveYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'effectiveYearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'effectiveYearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      effectiveYearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'effectiveYearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabledCapabilities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enabledCapabilities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enabledCapabilities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enabledCapabilities',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'enabledCapabilities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'enabledCapabilities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'enabledCapabilities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'enabledCapabilities',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabledCapabilities',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'enabledCapabilities',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledCapabilities',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledCapabilities',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledCapabilities',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledCapabilities',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledCapabilities',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      enabledCapabilitiesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'enabledCapabilities',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidEqualTo(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidGreaterThan(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidLessThan(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidBetween(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidStartsWith(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidEndsWith(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      inputFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      inputFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inputFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      inputFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      inputFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'legacySourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'legacySourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'legacySourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'legacySourceFingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'legacySourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'legacySourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'legacySourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'legacySourceFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'legacySourceFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      legacySourceFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'legacySourceFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyEqualTo(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyGreaterThan(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyLessThan(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyBetween(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyStartsWith(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyEndsWith(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ownerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ownerKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      ownerKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ownerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      policyVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'policyVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      policyVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'policyVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      policyVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'policyVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      policyVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'policyVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousRevisionGuid',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousRevisionGuid',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousRevisionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousRevisionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousRevisionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousRevisionGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousRevisionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousRevisionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousRevisionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousRevisionGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousRevisionGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      previousRevisionGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousRevisionGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewedFundingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewedFundingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewedFundingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewedFundingJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewedFundingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewedFundingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewedFundingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewedFundingJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewedFundingJson',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      reviewedFundingJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewedFundingJson',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      revisionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revision',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusEqualTo(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusGreaterThan(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusLessThan(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusBetween(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusStartsWith(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusEndsWith(
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

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension FinancialAdoptionQueryObject
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QFilterCondition> {}

extension FinancialAdoptionQueryLinks
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QFilterCondition> {}

extension FinancialAdoptionQuerySortBy
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QSortBy> {
  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByChosenAccountingCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chosenAccountingCurrency', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByChosenAccountingCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chosenAccountingCurrency', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByConfirmedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByEffectiveYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveYearMonth', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByEffectiveYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveYearMonth', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByLegacySourceFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'legacySourceFingerprint', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByLegacySourceFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'legacySourceFingerprint', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByOwnerKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerKey', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByOwnerKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerKey', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByPolicyVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyVersion', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByPolicyVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyVersion', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByPreviousRevisionGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousRevisionGuid', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByPreviousRevisionGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousRevisionGuid', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByReviewedFundingJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewedFundingJson', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByReviewedFundingJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewedFundingJson', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension FinancialAdoptionQuerySortThenBy
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QSortThenBy> {
  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByChosenAccountingCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chosenAccountingCurrency', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByChosenAccountingCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chosenAccountingCurrency', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByConfirmedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByEffectiveYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveYearMonth', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByEffectiveYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveYearMonth', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByLegacySourceFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'legacySourceFingerprint', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByLegacySourceFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'legacySourceFingerprint', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByOwnerKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerKey', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByOwnerKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerKey', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByPolicyVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyVersion', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByPolicyVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'policyVersion', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByPreviousRevisionGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousRevisionGuid', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByPreviousRevisionGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousRevisionGuid', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByReviewedFundingJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewedFundingJson', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByReviewedFundingJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewedFundingJson', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension FinancialAdoptionQueryWhereDistinct
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct> {
  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByChosenAccountingCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chosenAccountingCurrency',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmedAt');
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByEffectiveYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveYearMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByEnabledCapabilities() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabledCapabilities');
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByInputFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByLegacySourceFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'legacySourceFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByOwnerKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByPolicyVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'policyVersion');
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByPreviousRevisionGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousRevisionGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByReviewedFundingJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewedFundingJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revision');
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<FinancialAdoption, FinancialAdoption, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension FinancialAdoptionQueryProperty
    on QueryBuilder<FinancialAdoption, FinancialAdoption, QQueryProperty> {
  QueryBuilder<FinancialAdoption, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinancialAdoption, int, QQueryOperations> actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations>
      chosenAccountingCurrencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chosenAccountingCurrency');
    });
  }

  QueryBuilder<FinancialAdoption, DateTime, QQueryOperations>
      confirmedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmedAt');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations>
      effectiveYearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveYearMonth');
    });
  }

  QueryBuilder<FinancialAdoption, List<String>, QQueryOperations>
      enabledCapabilitiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabledCapabilities');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations>
      inputFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputFingerprint');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations>
      legacySourceFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'legacySourceFingerprint');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations> ownerKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerKey');
    });
  }

  QueryBuilder<FinancialAdoption, int, QQueryOperations>
      policyVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'policyVersion');
    });
  }

  QueryBuilder<FinancialAdoption, String?, QQueryOperations>
      previousRevisionGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousRevisionGuid');
    });
  }

  QueryBuilder<FinancialAdoption, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations>
      reviewedFundingJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewedFundingJson');
    });
  }

  QueryBuilder<FinancialAdoption, int, QQueryOperations> revisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revision');
    });
  }

  QueryBuilder<FinancialAdoption, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<FinancialAdoption, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
