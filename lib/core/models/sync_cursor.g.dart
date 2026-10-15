// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_cursor.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncCursorCollection on Isar {
  IsarCollection<SyncCursor> get syncCursors => this.collection();
}

const SyncCursorSchema = CollectionSchema(
  name: r'SyncCursor',
  id: 355982195539933157,
  properties: {
    r'conflictCount': PropertySchema(
      id: 0,
      name: r'conflictCount',
      type: IsarType.long,
    ),
    r'contextLocalId': PropertySchema(
      id: 1,
      name: r'contextLocalId',
      type: IsarType.long,
    ),
    r'lastReceivedCounter': PropertySchema(
      id: 2,
      name: r'lastReceivedCounter',
      type: IsarType.long,
    ),
    r'lastReceivedDeviceId': PropertySchema(
      id: 3,
      name: r'lastReceivedDeviceId',
      type: IsarType.string,
    ),
    r'lastReceivedHlcMillis': PropertySchema(
      id: 4,
      name: r'lastReceivedHlcMillis',
      type: IsarType.long,
    ),
    r'lastSentCounter': PropertySchema(
      id: 5,
      name: r'lastSentCounter',
      type: IsarType.long,
    ),
    r'lastSentDeviceId': PropertySchema(
      id: 6,
      name: r'lastSentDeviceId',
      type: IsarType.string,
    ),
    r'lastSentHlcMillis': PropertySchema(
      id: 7,
      name: r'lastSentHlcMillis',
      type: IsarType.long,
    ),
    r'peerId': PropertySchema(
      id: 8,
      name: r'peerId',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _syncCursorEstimateSize,
  serialize: _syncCursorSerialize,
  deserialize: _syncCursorDeserialize,
  deserializeProp: _syncCursorDeserializeProp,
  idName: r'id',
  indexes: {
    r'peerId_contextLocalId': IndexSchema(
      id: 1258368401097303156,
      name: r'peerId_contextLocalId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'peerId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'contextLocalId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncCursorGetId,
  getLinks: _syncCursorGetLinks,
  attach: _syncCursorAttach,
  version: '3.1.0+1',
);

int _syncCursorEstimateSize(
  SyncCursor object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.lastReceivedDeviceId.length * 3;
  bytesCount += 3 + object.lastSentDeviceId.length * 3;
  return bytesCount;
}

void _syncCursorSerialize(
  SyncCursor object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.conflictCount);
  writer.writeLong(offsets[1], object.contextLocalId);
  writer.writeLong(offsets[2], object.lastReceivedCounter);
  writer.writeString(offsets[3], object.lastReceivedDeviceId);
  writer.writeLong(offsets[4], object.lastReceivedHlcMillis);
  writer.writeLong(offsets[5], object.lastSentCounter);
  writer.writeString(offsets[6], object.lastSentDeviceId);
  writer.writeLong(offsets[7], object.lastSentHlcMillis);
  writer.writeLong(offsets[8], object.peerId);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

SyncCursor _syncCursorDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncCursor();
  object.conflictCount = reader.readLong(offsets[0]);
  object.contextLocalId = reader.readLong(offsets[1]);
  object.id = id;
  object.lastReceivedCounter = reader.readLong(offsets[2]);
  object.lastReceivedDeviceId = reader.readString(offsets[3]);
  object.lastReceivedHlcMillis = reader.readLong(offsets[4]);
  object.lastSentCounter = reader.readLong(offsets[5]);
  object.lastSentDeviceId = reader.readString(offsets[6]);
  object.lastSentHlcMillis = reader.readLong(offsets[7]);
  object.peerId = reader.readLong(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _syncCursorDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncCursorGetId(SyncCursor object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncCursorGetLinks(SyncCursor object) {
  return [];
}

void _syncCursorAttach(IsarCollection<dynamic> col, Id id, SyncCursor object) {
  object.id = id;
}

extension SyncCursorByIndex on IsarCollection<SyncCursor> {
  Future<SyncCursor?> getByPeerIdContextLocalId(
      int peerId, int contextLocalId) {
    return getByIndex(r'peerId_contextLocalId', [peerId, contextLocalId]);
  }

  SyncCursor? getByPeerIdContextLocalIdSync(int peerId, int contextLocalId) {
    return getByIndexSync(r'peerId_contextLocalId', [peerId, contextLocalId]);
  }

  Future<bool> deleteByPeerIdContextLocalId(int peerId, int contextLocalId) {
    return deleteByIndex(r'peerId_contextLocalId', [peerId, contextLocalId]);
  }

  bool deleteByPeerIdContextLocalIdSync(int peerId, int contextLocalId) {
    return deleteByIndexSync(
        r'peerId_contextLocalId', [peerId, contextLocalId]);
  }

  Future<List<SyncCursor?>> getAllByPeerIdContextLocalId(
      List<int> peerIdValues, List<int> contextLocalIdValues) {
    final len = peerIdValues.length;
    assert(contextLocalIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([peerIdValues[i], contextLocalIdValues[i]]);
    }

    return getAllByIndex(r'peerId_contextLocalId', values);
  }

  List<SyncCursor?> getAllByPeerIdContextLocalIdSync(
      List<int> peerIdValues, List<int> contextLocalIdValues) {
    final len = peerIdValues.length;
    assert(contextLocalIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([peerIdValues[i], contextLocalIdValues[i]]);
    }

    return getAllByIndexSync(r'peerId_contextLocalId', values);
  }

  Future<int> deleteAllByPeerIdContextLocalId(
      List<int> peerIdValues, List<int> contextLocalIdValues) {
    final len = peerIdValues.length;
    assert(contextLocalIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([peerIdValues[i], contextLocalIdValues[i]]);
    }

    return deleteAllByIndex(r'peerId_contextLocalId', values);
  }

  int deleteAllByPeerIdContextLocalIdSync(
      List<int> peerIdValues, List<int> contextLocalIdValues) {
    final len = peerIdValues.length;
    assert(contextLocalIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([peerIdValues[i], contextLocalIdValues[i]]);
    }

    return deleteAllByIndexSync(r'peerId_contextLocalId', values);
  }

  Future<Id> putByPeerIdContextLocalId(SyncCursor object) {
    return putByIndex(r'peerId_contextLocalId', object);
  }

  Id putByPeerIdContextLocalIdSync(SyncCursor object, {bool saveLinks = true}) {
    return putByIndexSync(r'peerId_contextLocalId', object,
        saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPeerIdContextLocalId(List<SyncCursor> objects) {
    return putAllByIndex(r'peerId_contextLocalId', objects);
  }

  List<Id> putAllByPeerIdContextLocalIdSync(List<SyncCursor> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'peerId_contextLocalId', objects,
        saveLinks: saveLinks);
  }
}

extension SyncCursorQueryWhereSort
    on QueryBuilder<SyncCursor, SyncCursor, QWhere> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhere> anyPeerIdContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'peerId_contextLocalId'),
      );
    });
  }
}

extension SyncCursorQueryWhere
    on QueryBuilder<SyncCursor, SyncCursor, QWhereClause> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idBetween(
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdEqualToAnyContextLocalId(int peerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'peerId_contextLocalId',
        value: [peerId],
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdNotEqualToAnyContextLocalId(int peerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextLocalId',
              lower: [],
              upper: [peerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextLocalId',
              lower: [peerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextLocalId',
              lower: [peerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextLocalId',
              lower: [],
              upper: [peerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdGreaterThanAnyContextLocalId(
    int peerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextLocalId',
        lower: [peerId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdLessThanAnyContextLocalId(
    int peerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextLocalId',
        lower: [],
        upper: [peerId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdBetweenAnyContextLocalId(
    int lowerPeerId,
    int upperPeerId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextLocalId',
        lower: [lowerPeerId],
        includeLower: includeLower,
        upper: [upperPeerId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdContextLocalIdEqualTo(int peerId, int contextLocalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'peerId_contextLocalId',
        value: [peerId, contextLocalId],
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdEqualToContextLocalIdNotEqualTo(int peerId, int contextLocalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextLocalId',
              lower: [peerId],
              upper: [peerId, contextLocalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextLocalId',
              lower: [peerId, contextLocalId],
              includeLower: false,
              upper: [peerId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextLocalId',
              lower: [peerId, contextLocalId],
              includeLower: false,
              upper: [peerId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextLocalId',
              lower: [peerId],
              upper: [peerId, contextLocalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdEqualToContextLocalIdGreaterThan(
    int peerId,
    int contextLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextLocalId',
        lower: [peerId, contextLocalId],
        includeLower: include,
        upper: [peerId],
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdEqualToContextLocalIdLessThan(
    int peerId,
    int contextLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextLocalId',
        lower: [peerId],
        upper: [peerId, contextLocalId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause>
      peerIdEqualToContextLocalIdBetween(
    int peerId,
    int lowerContextLocalId,
    int upperContextLocalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextLocalId',
        lower: [peerId, lowerContextLocalId],
        includeLower: includeLower,
        upper: [peerId, upperContextLocalId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncCursorQueryFilter
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      conflictCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conflictCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      conflictCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conflictCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      conflictCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conflictCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      conflictCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conflictCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      contextLocalIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      contextLocalIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contextLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      contextLocalIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contextLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      contextLocalIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contextLocalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedCounterEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReceivedCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedCounterGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReceivedCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedCounterLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReceivedCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedCounterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReceivedCounter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReceivedDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReceivedDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReceivedDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReceivedDeviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastReceivedDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastReceivedDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastReceivedDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastReceivedDeviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReceivedDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastReceivedDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedHlcMillisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReceivedHlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedHlcMillisGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReceivedHlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedHlcMillisLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReceivedHlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastReceivedHlcMillisBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReceivedHlcMillis',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentCounterEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSentCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentCounterGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSentCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentCounterLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSentCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentCounterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSentCounter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSentDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSentDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSentDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSentDeviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastSentDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastSentDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastSentDeviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastSentDeviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSentDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastSentDeviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentHlcMillisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSentHlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentHlcMillisGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSentHlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentHlcMillisLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSentHlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      lastSentHlcMillisBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSentHlcMillis',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> peerIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> peerIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> peerIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerId',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> peerIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncCursorQueryObject
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {}

extension SyncCursorQueryLinks
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {}

extension SyncCursorQuerySortBy
    on QueryBuilder<SyncCursor, SyncCursor, QSortBy> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByConflictCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conflictCount', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByConflictCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conflictCount', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByContextLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastReceivedCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedCounter', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastReceivedCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedCounter', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastReceivedDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastReceivedDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastReceivedHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedHlcMillis', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastReceivedHlcMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedHlcMillis', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastSentCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentCounter', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastSentCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentCounter', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastSentDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastSentDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByLastSentHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentHlcMillis', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      sortByLastSentHlcMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentHlcMillis', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByPeerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByPeerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SyncCursorQuerySortThenBy
    on QueryBuilder<SyncCursor, SyncCursor, QSortThenBy> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByConflictCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conflictCount', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByConflictCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conflictCount', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByContextLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastReceivedCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedCounter', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastReceivedCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedCounter', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastReceivedDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastReceivedDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastReceivedHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedHlcMillis', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastReceivedHlcMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReceivedHlcMillis', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastSentCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentCounter', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastSentCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentCounter', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastSentDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentDeviceId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastSentDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentDeviceId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByLastSentHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentHlcMillis', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy>
      thenByLastSentHlcMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSentHlcMillis', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByPeerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByPeerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SyncCursorQueryWhereDistinct
    on QueryBuilder<SyncCursor, SyncCursor, QDistinct> {
  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByConflictCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conflictCount');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextLocalId');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct>
      distinctByLastReceivedCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReceivedCounter');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct>
      distinctByLastReceivedDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReceivedDeviceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct>
      distinctByLastReceivedHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReceivedHlcMillis');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastSentCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSentCounter');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByLastSentDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSentDeviceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct>
      distinctByLastSentHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSentHlcMillis');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByPeerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerId');
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SyncCursorQueryProperty
    on QueryBuilder<SyncCursor, SyncCursor, QQueryProperty> {
  QueryBuilder<SyncCursor, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> conflictCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conflictCount');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> contextLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextLocalId');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations>
      lastReceivedCounterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReceivedCounter');
    });
  }

  QueryBuilder<SyncCursor, String, QQueryOperations>
      lastReceivedDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReceivedDeviceId');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations>
      lastReceivedHlcMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReceivedHlcMillis');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastSentCounterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSentCounter');
    });
  }

  QueryBuilder<SyncCursor, String, QQueryOperations>
      lastSentDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSentDeviceId');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> lastSentHlcMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSentHlcMillis');
    });
  }

  QueryBuilder<SyncCursor, int, QQueryOperations> peerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerId');
    });
  }

  QueryBuilder<SyncCursor, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
