// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_checkpoint.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBalanceCheckpointCollection on Isar {
  IsarCollection<BalanceCheckpoint> get balanceCheckpoints => this.collection();
}

const BalanceCheckpointSchema = CollectionSchema(
  name: r'BalanceCheckpoint',
  id: 5237437890430097652,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'adoptionGuid': PropertySchema(
      id: 1,
      name: r'adoptionGuid',
      type: IsarType.string,
    ),
    r'balanceAsOf': PropertySchema(
      id: 2,
      name: r'balanceAsOf',
      type: IsarType.dateTime,
    ),
    r'balanceMinor': PropertySchema(
      id: 3,
      name: r'balanceMinor',
      type: IsarType.long,
    ),
    r'cashPoolDescription': PropertySchema(
      id: 4,
      name: r'cashPoolDescription',
      type: IsarType.string,
    ),
    r'confirmedAt': PropertySchema(
      id: 5,
      name: r'confirmedAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 6,
      name: r'currency',
      type: IsarType.string,
    ),
    r'guid': PropertySchema(
      id: 7,
      name: r'guid',
      type: IsarType.string,
    ),
    r'inputFingerprint': PropertySchema(
      id: 8,
      name: r'inputFingerprint',
      type: IsarType.string,
    ),
    r'localZone': PropertySchema(
      id: 9,
      name: r'localZone',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 10,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'ownerMonth': PropertySchema(
      id: 11,
      name: r'ownerMonth',
      type: IsarType.string,
    ),
    r'previousCheckpointGuid': PropertySchema(
      id: 12,
      name: r'previousCheckpointGuid',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 13,
      name: r'profileId',
      type: IsarType.long,
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
    r'sourceFingerprint': PropertySchema(
      id: 16,
      name: r'sourceFingerprint',
      type: IsarType.string,
    ),
    r'state': PropertySchema(
      id: 17,
      name: r'state',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 18,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _balanceCheckpointEstimateSize,
  serialize: _balanceCheckpointSerialize,
  deserialize: _balanceCheckpointDeserialize,
  deserializeProp: _balanceCheckpointDeserializeProp,
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
    r'ownerMonth': IndexSchema(
      id: 1892218643112373276,
      name: r'ownerMonth',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ownerMonth',
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
  getId: _balanceCheckpointGetId,
  getLinks: _balanceCheckpointGetLinks,
  attach: _balanceCheckpointAttach,
  version: '3.1.0+1',
);

int _balanceCheckpointEstimateSize(
  BalanceCheckpoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.adoptionGuid.length * 3;
  bytesCount += 3 + object.cashPoolDescription.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.guid.length * 3;
  bytesCount += 3 + object.inputFingerprint.length * 3;
  bytesCount += 3 + object.localZone.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  bytesCount += 3 + object.ownerMonth.length * 3;
  {
    final value = object.previousCheckpointGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceFingerprint.length * 3;
  bytesCount += 3 + object.state.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _balanceCheckpointSerialize(
  BalanceCheckpoint object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeString(offsets[1], object.adoptionGuid);
  writer.writeDateTime(offsets[2], object.balanceAsOf);
  writer.writeLong(offsets[3], object.balanceMinor);
  writer.writeString(offsets[4], object.cashPoolDescription);
  writer.writeDateTime(offsets[5], object.confirmedAt);
  writer.writeString(offsets[6], object.currency);
  writer.writeString(offsets[7], object.guid);
  writer.writeString(offsets[8], object.inputFingerprint);
  writer.writeString(offsets[9], object.localZone);
  writer.writeString(offsets[10], object.operationIdentity);
  writer.writeString(offsets[11], object.ownerMonth);
  writer.writeString(offsets[12], object.previousCheckpointGuid);
  writer.writeLong(offsets[13], object.profileId);
  writer.writeLong(offsets[14], object.revision);
  writer.writeLong(offsets[15], object.sharedSpaceId);
  writer.writeString(offsets[16], object.sourceFingerprint);
  writer.writeString(offsets[17], object.state);
  writer.writeString(offsets[18], object.yearMonth);
}

BalanceCheckpoint _balanceCheckpointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BalanceCheckpoint();
  object.actorId = reader.readLong(offsets[0]);
  object.adoptionGuid = reader.readString(offsets[1]);
  object.balanceAsOf = reader.readDateTime(offsets[2]);
  object.balanceMinor = reader.readLong(offsets[3]);
  object.cashPoolDescription = reader.readString(offsets[4]);
  object.confirmedAt = reader.readDateTime(offsets[5]);
  object.currency = reader.readString(offsets[6]);
  object.guid = reader.readString(offsets[7]);
  object.id = id;
  object.inputFingerprint = reader.readString(offsets[8]);
  object.localZone = reader.readString(offsets[9]);
  object.operationIdentity = reader.readString(offsets[10]);
  object.ownerMonth = reader.readString(offsets[11]);
  object.previousCheckpointGuid = reader.readStringOrNull(offsets[12]);
  object.profileId = reader.readLongOrNull(offsets[13]);
  object.revision = reader.readLong(offsets[14]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[15]);
  object.sourceFingerprint = reader.readString(offsets[16]);
  object.state = reader.readString(offsets[17]);
  object.yearMonth = reader.readString(offsets[18]);
  return object;
}

P _balanceCheckpointDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _balanceCheckpointGetId(BalanceCheckpoint object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _balanceCheckpointGetLinks(
    BalanceCheckpoint object) {
  return [];
}

void _balanceCheckpointAttach(
    IsarCollection<dynamic> col, Id id, BalanceCheckpoint object) {
  object.id = id;
}

extension BalanceCheckpointByIndex on IsarCollection<BalanceCheckpoint> {
  Future<BalanceCheckpoint?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  BalanceCheckpoint? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<BalanceCheckpoint?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<BalanceCheckpoint?> getAllByGuidSync(List<String> guidValues) {
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

  Future<Id> putByGuid(BalanceCheckpoint object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(BalanceCheckpoint object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<BalanceCheckpoint> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<BalanceCheckpoint> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }

  Future<BalanceCheckpoint?> getByOperationIdentity(String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  BalanceCheckpoint? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<BalanceCheckpoint?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<BalanceCheckpoint?> getAllByOperationIdentitySync(
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

  Future<Id> putByOperationIdentity(BalanceCheckpoint object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(BalanceCheckpoint object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(List<BalanceCheckpoint> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<BalanceCheckpoint> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension BalanceCheckpointQueryWhereSort
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QWhere> {
  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BalanceCheckpointQueryWhere
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QWhereClause> {
  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
      guidEqualTo(String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
      ownerMonthEqualTo(String ownerMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ownerMonth',
        value: [ownerMonth],
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
      ownerMonthNotEqualTo(String ownerMonth) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerMonth',
              lower: [],
              upper: [ownerMonth],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerMonth',
              lower: [ownerMonth],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerMonth',
              lower: [ownerMonth],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ownerMonth',
              lower: [],
              upper: [ownerMonth],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
      operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterWhereClause>
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

extension BalanceCheckpointQueryFilter
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QFilterCondition> {
  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adoptionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'adoptionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'adoptionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'adoptionGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'adoptionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'adoptionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'adoptionGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'adoptionGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adoptionGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      adoptionGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'adoptionGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      balanceAsOfEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'balanceAsOf',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      balanceAsOfGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'balanceAsOf',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      balanceAsOfLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'balanceAsOf',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      balanceAsOfBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'balanceAsOf',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      balanceMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'balanceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      balanceMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'balanceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      balanceMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'balanceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      balanceMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'balanceMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashPoolDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cashPoolDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cashPoolDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cashPoolDescription',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cashPoolDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cashPoolDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cashPoolDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cashPoolDescription',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cashPoolDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      cashPoolDescriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cashPoolDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      confirmedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      guidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      guidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      inputFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      inputFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inputFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      inputFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      inputFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localZone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localZone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localZone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localZone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localZone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localZone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localZone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localZone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localZone',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      localZoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localZone',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ownerMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ownerMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ownerMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ownerMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ownerMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ownerMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ownerMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      ownerMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ownerMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousCheckpointGuid',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousCheckpointGuid',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousCheckpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousCheckpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousCheckpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousCheckpointGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousCheckpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousCheckpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousCheckpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousCheckpointGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousCheckpointGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      previousCheckpointGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousCheckpointGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      revisionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revision',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceFingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      sourceFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateEqualTo(
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateGreaterThan(
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateLessThan(
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateBetween(
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateStartsWith(
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateEndsWith(
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'state',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      stateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
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

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension BalanceCheckpointQueryObject
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QFilterCondition> {}

extension BalanceCheckpointQueryLinks
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QFilterCondition> {}

extension BalanceCheckpointQuerySortBy
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QSortBy> {
  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByAdoptionGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adoptionGuid', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByAdoptionGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adoptionGuid', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByBalanceAsOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceAsOf', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByBalanceAsOfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceAsOf', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByBalanceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceMinor', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByBalanceMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceMinor', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByCashPoolDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashPoolDescription', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByCashPoolDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashPoolDescription', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByConfirmedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByLocalZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localZone', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByLocalZoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localZone', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByOwnerMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerMonth', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByOwnerMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerMonth', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByPreviousCheckpointGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousCheckpointGuid', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByPreviousCheckpointGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousCheckpointGuid', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortBySourceFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFingerprint', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortBySourceFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFingerprint', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension BalanceCheckpointQuerySortThenBy
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QSortThenBy> {
  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByAdoptionGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adoptionGuid', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByAdoptionGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adoptionGuid', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByBalanceAsOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceAsOf', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByBalanceAsOfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceAsOf', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByBalanceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceMinor', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByBalanceMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balanceMinor', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByCashPoolDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashPoolDescription', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByCashPoolDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cashPoolDescription', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByConfirmedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByLocalZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localZone', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByLocalZoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localZone', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByOwnerMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerMonth', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByOwnerMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerMonth', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByPreviousCheckpointGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousCheckpointGuid', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByPreviousCheckpointGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousCheckpointGuid', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenBySourceFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFingerprint', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenBySourceFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceFingerprint', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension BalanceCheckpointQueryWhereDistinct
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct> {
  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByAdoptionGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'adoptionGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByBalanceAsOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'balanceAsOf');
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByBalanceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'balanceMinor');
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByCashPoolDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cashPoolDescription',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmedAt');
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByInputFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByLocalZone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localZone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByOwnerMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerMonth', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByPreviousCheckpointGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousCheckpointGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revision');
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctBySourceFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct> distinctByState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QDistinct>
      distinctByYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension BalanceCheckpointQueryProperty
    on QueryBuilder<BalanceCheckpoint, BalanceCheckpoint, QQueryProperty> {
  QueryBuilder<BalanceCheckpoint, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BalanceCheckpoint, int, QQueryOperations> actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations>
      adoptionGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'adoptionGuid');
    });
  }

  QueryBuilder<BalanceCheckpoint, DateTime, QQueryOperations>
      balanceAsOfProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'balanceAsOf');
    });
  }

  QueryBuilder<BalanceCheckpoint, int, QQueryOperations>
      balanceMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'balanceMinor');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations>
      cashPoolDescriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cashPoolDescription');
    });
  }

  QueryBuilder<BalanceCheckpoint, DateTime, QQueryOperations>
      confirmedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmedAt');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations>
      inputFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputFingerprint');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations>
      localZoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localZone');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations>
      ownerMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerMonth');
    });
  }

  QueryBuilder<BalanceCheckpoint, String?, QQueryOperations>
      previousCheckpointGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousCheckpointGuid');
    });
  }

  QueryBuilder<BalanceCheckpoint, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<BalanceCheckpoint, int, QQueryOperations> revisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revision');
    });
  }

  QueryBuilder<BalanceCheckpoint, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations>
      sourceFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceFingerprint');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations> stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }

  QueryBuilder<BalanceCheckpoint, String, QQueryOperations>
      yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMovementInclusionCollection on Isar {
  IsarCollection<MovementInclusion> get movementInclusions => this.collection();
}

const MovementInclusionSchema = CollectionSchema(
  name: r'MovementInclusion',
  id: 205214317536555841,
  properties: {
    r'checkpointGuid': PropertySchema(
      id: 0,
      name: r'checkpointGuid',
      type: IsarType.string,
    ),
    r'confirmedAt': PropertySchema(
      id: 1,
      name: r'confirmedAt',
      type: IsarType.dateTime,
    ),
    r'confirmedBy': PropertySchema(
      id: 2,
      name: r'confirmedBy',
      type: IsarType.long,
    ),
    r'identity': PropertySchema(
      id: 3,
      name: r'identity',
      type: IsarType.string,
    ),
    r'movementKey': PropertySchema(
      id: 4,
      name: r'movementKey',
      type: IsarType.string,
    ),
    r'movementRevision': PropertySchema(
      id: 5,
      name: r'movementRevision',
      type: IsarType.string,
    ),
    r'reviewedActualAt': PropertySchema(
      id: 6,
      name: r'reviewedActualAt',
      type: IsarType.dateTime,
    ),
    r'role': PropertySchema(
      id: 7,
      name: r'role',
      type: IsarType.string,
    ),
    r'signedMinor': PropertySchema(
      id: 8,
      name: r'signedMinor',
      type: IsarType.long,
    )
  },
  estimateSize: _movementInclusionEstimateSize,
  serialize: _movementInclusionSerialize,
  deserialize: _movementInclusionDeserialize,
  deserializeProp: _movementInclusionDeserializeProp,
  idName: r'id',
  indexes: {
    r'identity': IndexSchema(
      id: -4484375294813923678,
      name: r'identity',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'identity',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'checkpointGuid': IndexSchema(
      id: 4661281594762026102,
      name: r'checkpointGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'checkpointGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _movementInclusionGetId,
  getLinks: _movementInclusionGetLinks,
  attach: _movementInclusionAttach,
  version: '3.1.0+1',
);

int _movementInclusionEstimateSize(
  MovementInclusion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.checkpointGuid.length * 3;
  bytesCount += 3 + object.identity.length * 3;
  bytesCount += 3 + object.movementKey.length * 3;
  bytesCount += 3 + object.movementRevision.length * 3;
  bytesCount += 3 + object.role.length * 3;
  return bytesCount;
}

void _movementInclusionSerialize(
  MovementInclusion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.checkpointGuid);
  writer.writeDateTime(offsets[1], object.confirmedAt);
  writer.writeLong(offsets[2], object.confirmedBy);
  writer.writeString(offsets[3], object.identity);
  writer.writeString(offsets[4], object.movementKey);
  writer.writeString(offsets[5], object.movementRevision);
  writer.writeDateTime(offsets[6], object.reviewedActualAt);
  writer.writeString(offsets[7], object.role);
  writer.writeLong(offsets[8], object.signedMinor);
}

MovementInclusion _movementInclusionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MovementInclusion();
  object.checkpointGuid = reader.readString(offsets[0]);
  object.confirmedAt = reader.readDateTime(offsets[1]);
  object.confirmedBy = reader.readLong(offsets[2]);
  object.id = id;
  object.identity = reader.readString(offsets[3]);
  object.movementKey = reader.readString(offsets[4]);
  object.movementRevision = reader.readString(offsets[5]);
  object.reviewedActualAt = reader.readDateTimeOrNull(offsets[6]);
  object.role = reader.readString(offsets[7]);
  object.signedMinor = reader.readLong(offsets[8]);
  return object;
}

P _movementInclusionDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _movementInclusionGetId(MovementInclusion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _movementInclusionGetLinks(
    MovementInclusion object) {
  return [];
}

void _movementInclusionAttach(
    IsarCollection<dynamic> col, Id id, MovementInclusion object) {
  object.id = id;
}

extension MovementInclusionByIndex on IsarCollection<MovementInclusion> {
  Future<MovementInclusion?> getByIdentity(String identity) {
    return getByIndex(r'identity', [identity]);
  }

  MovementInclusion? getByIdentitySync(String identity) {
    return getByIndexSync(r'identity', [identity]);
  }

  Future<bool> deleteByIdentity(String identity) {
    return deleteByIndex(r'identity', [identity]);
  }

  bool deleteByIdentitySync(String identity) {
    return deleteByIndexSync(r'identity', [identity]);
  }

  Future<List<MovementInclusion?>> getAllByIdentity(
      List<String> identityValues) {
    final values = identityValues.map((e) => [e]).toList();
    return getAllByIndex(r'identity', values);
  }

  List<MovementInclusion?> getAllByIdentitySync(List<String> identityValues) {
    final values = identityValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'identity', values);
  }

  Future<int> deleteAllByIdentity(List<String> identityValues) {
    final values = identityValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'identity', values);
  }

  int deleteAllByIdentitySync(List<String> identityValues) {
    final values = identityValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'identity', values);
  }

  Future<Id> putByIdentity(MovementInclusion object) {
    return putByIndex(r'identity', object);
  }

  Id putByIdentitySync(MovementInclusion object, {bool saveLinks = true}) {
    return putByIndexSync(r'identity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIdentity(List<MovementInclusion> objects) {
    return putAllByIndex(r'identity', objects);
  }

  List<Id> putAllByIdentitySync(List<MovementInclusion> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'identity', objects, saveLinks: saveLinks);
  }
}

extension MovementInclusionQueryWhereSort
    on QueryBuilder<MovementInclusion, MovementInclusion, QWhere> {
  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MovementInclusionQueryWhere
    on QueryBuilder<MovementInclusion, MovementInclusion, QWhereClause> {
  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
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

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
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

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
      identityEqualTo(String identity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'identity',
        value: [identity],
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
      identityNotEqualTo(String identity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identity',
              lower: [],
              upper: [identity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identity',
              lower: [identity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identity',
              lower: [identity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'identity',
              lower: [],
              upper: [identity],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
      checkpointGuidEqualTo(String checkpointGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'checkpointGuid',
        value: [checkpointGuid],
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterWhereClause>
      checkpointGuidNotEqualTo(String checkpointGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'checkpointGuid',
              lower: [],
              upper: [checkpointGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'checkpointGuid',
              lower: [checkpointGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'checkpointGuid',
              lower: [checkpointGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'checkpointGuid',
              lower: [],
              upper: [checkpointGuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MovementInclusionQueryFilter
    on QueryBuilder<MovementInclusion, MovementInclusion, QFilterCondition> {
  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkpointGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'checkpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'checkpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'checkpointGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'checkpointGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkpointGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      checkpointGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'checkpointGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      confirmedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
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

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
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

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
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

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      confirmedByEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      confirmedByGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confirmedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      confirmedByLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confirmedBy',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      confirmedByBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confirmedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
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

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
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

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
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

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'identity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'identity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'identity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'identity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'identity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'identity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'identity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identity',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      identityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'identity',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movementKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movementKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movementKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movementKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movementKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movementKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movementKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementKey',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movementKey',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movementRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movementRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movementRevision',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movementRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movementRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movementRevision',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movementRevision',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementRevision',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      movementRevisionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movementRevision',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      reviewedActualAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reviewedActualAt',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      reviewedActualAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reviewedActualAt',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      reviewedActualAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewedActualAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      reviewedActualAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewedActualAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      reviewedActualAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewedActualAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      reviewedActualAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewedActualAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'role',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'role',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      roleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      signedMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      signedMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      signedMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterFilterCondition>
      signedMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signedMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MovementInclusionQueryObject
    on QueryBuilder<MovementInclusion, MovementInclusion, QFilterCondition> {}

extension MovementInclusionQueryLinks
    on QueryBuilder<MovementInclusion, MovementInclusion, QFilterCondition> {}

extension MovementInclusionQuerySortBy
    on QueryBuilder<MovementInclusion, MovementInclusion, QSortBy> {
  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByCheckpointGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkpointGuid', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByCheckpointGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkpointGuid', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByConfirmedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByConfirmedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedBy', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByConfirmedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedBy', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identity', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identity', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByMovementKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementKey', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByMovementKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementKey', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByMovementRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementRevision', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByMovementRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementRevision', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByReviewedActualAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewedActualAt', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByReviewedActualAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewedActualAt', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortBySignedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signedMinor', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      sortBySignedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signedMinor', Sort.desc);
    });
  }
}

extension MovementInclusionQuerySortThenBy
    on QueryBuilder<MovementInclusion, MovementInclusion, QSortThenBy> {
  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByCheckpointGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkpointGuid', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByCheckpointGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkpointGuid', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByConfirmedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedAt', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByConfirmedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedBy', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByConfirmedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedBy', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identity', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identity', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByMovementKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementKey', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByMovementKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementKey', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByMovementRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementRevision', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByMovementRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementRevision', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByReviewedActualAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewedActualAt', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByReviewedActualAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewedActualAt', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenBySignedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signedMinor', Sort.asc);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QAfterSortBy>
      thenBySignedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signedMinor', Sort.desc);
    });
  }
}

extension MovementInclusionQueryWhereDistinct
    on QueryBuilder<MovementInclusion, MovementInclusion, QDistinct> {
  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct>
      distinctByCheckpointGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkpointGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct>
      distinctByConfirmedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmedAt');
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct>
      distinctByConfirmedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmedBy');
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct>
      distinctByIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct>
      distinctByMovementKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movementKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct>
      distinctByMovementRevision({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movementRevision',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct>
      distinctByReviewedActualAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewedActualAt');
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct> distinctByRole(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'role', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MovementInclusion, MovementInclusion, QDistinct>
      distinctBySignedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signedMinor');
    });
  }
}

extension MovementInclusionQueryProperty
    on QueryBuilder<MovementInclusion, MovementInclusion, QQueryProperty> {
  QueryBuilder<MovementInclusion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MovementInclusion, String, QQueryOperations>
      checkpointGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkpointGuid');
    });
  }

  QueryBuilder<MovementInclusion, DateTime, QQueryOperations>
      confirmedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmedAt');
    });
  }

  QueryBuilder<MovementInclusion, int, QQueryOperations> confirmedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmedBy');
    });
  }

  QueryBuilder<MovementInclusion, String, QQueryOperations> identityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identity');
    });
  }

  QueryBuilder<MovementInclusion, String, QQueryOperations>
      movementKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movementKey');
    });
  }

  QueryBuilder<MovementInclusion, String, QQueryOperations>
      movementRevisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movementRevision');
    });
  }

  QueryBuilder<MovementInclusion, DateTime?, QQueryOperations>
      reviewedActualAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewedActualAt');
    });
  }

  QueryBuilder<MovementInclusion, String, QQueryOperations> roleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'role');
    });
  }

  QueryBuilder<MovementInclusion, int, QQueryOperations> signedMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signedMinor');
    });
  }
}
