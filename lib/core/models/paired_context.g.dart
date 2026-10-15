// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paired_context.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPairedContextCollection on Isar {
  IsarCollection<PairedContext> get pairedContexts => this.collection();
}

const PairedContextSchema = CollectionSchema(
  name: r'PairedContext',
  id: 3954200407109713572,
  properties: {
    r'active': PropertySchema(
      id: 0,
      name: r'active',
      type: IsarType.bool,
    ),
    r'contextKind': PropertySchema(
      id: 1,
      name: r'contextKind',
      type: IsarType.byte,
      enumMap: _PairedContextcontextKindEnumValueMap,
    ),
    r'contextLocalId': PropertySchema(
      id: 2,
      name: r'contextLocalId',
      type: IsarType.long,
    ),
    r'pairedAt': PropertySchema(
      id: 3,
      name: r'pairedAt',
      type: IsarType.dateTime,
    ),
    r'peerId': PropertySchema(
      id: 4,
      name: r'peerId',
      type: IsarType.long,
    ),
    r'peerRole': PropertySchema(
      id: 5,
      name: r'peerRole',
      type: IsarType.byte,
      enumMap: _PairedContextpeerRoleEnumValueMap,
    )
  },
  estimateSize: _pairedContextEstimateSize,
  serialize: _pairedContextSerialize,
  deserialize: _pairedContextDeserialize,
  deserializeProp: _pairedContextDeserializeProp,
  idName: r'id',
  indexes: {
    r'peerId_contextKind_contextLocalId': IndexSchema(
      id: 3820527269082832402,
      name: r'peerId_contextKind_contextLocalId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'peerId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'contextKind',
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
  getId: _pairedContextGetId,
  getLinks: _pairedContextGetLinks,
  attach: _pairedContextAttach,
  version: '3.1.0+1',
);

int _pairedContextEstimateSize(
  PairedContext object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _pairedContextSerialize(
  PairedContext object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.active);
  writer.writeByte(offsets[1], object.contextKind.index);
  writer.writeLong(offsets[2], object.contextLocalId);
  writer.writeDateTime(offsets[3], object.pairedAt);
  writer.writeLong(offsets[4], object.peerId);
  writer.writeByte(offsets[5], object.peerRole.index);
}

PairedContext _pairedContextDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PairedContext();
  object.active = reader.readBool(offsets[0]);
  object.contextKind = _PairedContextcontextKindValueEnumMap[
          reader.readByteOrNull(offsets[1])] ??
      ContextKind.personal;
  object.contextLocalId = reader.readLong(offsets[2]);
  object.id = id;
  object.pairedAt = reader.readDateTime(offsets[3]);
  object.peerId = reader.readLong(offsets[4]);
  object.peerRole =
      _PairedContextpeerRoleValueEnumMap[reader.readByteOrNull(offsets[5])] ??
          SharedMemberRole.owner;
  return object;
}

P _pairedContextDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (_PairedContextcontextKindValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ContextKind.personal) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (_PairedContextpeerRoleValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SharedMemberRole.owner) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PairedContextcontextKindEnumValueMap = {
  'personal': 0,
  'shared': 1,
};
const _PairedContextcontextKindValueEnumMap = {
  0: ContextKind.personal,
  1: ContextKind.shared,
};
const _PairedContextpeerRoleEnumValueMap = {
  'owner': 0,
  'editor': 1,
  'viewer': 2,
};
const _PairedContextpeerRoleValueEnumMap = {
  0: SharedMemberRole.owner,
  1: SharedMemberRole.editor,
  2: SharedMemberRole.viewer,
};

Id _pairedContextGetId(PairedContext object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pairedContextGetLinks(PairedContext object) {
  return [];
}

void _pairedContextAttach(
    IsarCollection<dynamic> col, Id id, PairedContext object) {
  object.id = id;
}

extension PairedContextByIndex on IsarCollection<PairedContext> {
  Future<PairedContext?> getByPeerIdContextKindContextLocalId(
      int peerId, ContextKind contextKind, int contextLocalId) {
    return getByIndex(r'peerId_contextKind_contextLocalId',
        [peerId, contextKind, contextLocalId]);
  }

  PairedContext? getByPeerIdContextKindContextLocalIdSync(
      int peerId, ContextKind contextKind, int contextLocalId) {
    return getByIndexSync(r'peerId_contextKind_contextLocalId',
        [peerId, contextKind, contextLocalId]);
  }

  Future<bool> deleteByPeerIdContextKindContextLocalId(
      int peerId, ContextKind contextKind, int contextLocalId) {
    return deleteByIndex(r'peerId_contextKind_contextLocalId',
        [peerId, contextKind, contextLocalId]);
  }

  bool deleteByPeerIdContextKindContextLocalIdSync(
      int peerId, ContextKind contextKind, int contextLocalId) {
    return deleteByIndexSync(r'peerId_contextKind_contextLocalId',
        [peerId, contextKind, contextLocalId]);
  }

  Future<List<PairedContext?>> getAllByPeerIdContextKindContextLocalId(
      List<int> peerIdValues,
      List<ContextKind> contextKindValues,
      List<int> contextLocalIdValues) {
    final len = peerIdValues.length;
    assert(
        contextKindValues.length == len && contextLocalIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add(
          [peerIdValues[i], contextKindValues[i], contextLocalIdValues[i]]);
    }

    return getAllByIndex(r'peerId_contextKind_contextLocalId', values);
  }

  List<PairedContext?> getAllByPeerIdContextKindContextLocalIdSync(
      List<int> peerIdValues,
      List<ContextKind> contextKindValues,
      List<int> contextLocalIdValues) {
    final len = peerIdValues.length;
    assert(
        contextKindValues.length == len && contextLocalIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add(
          [peerIdValues[i], contextKindValues[i], contextLocalIdValues[i]]);
    }

    return getAllByIndexSync(r'peerId_contextKind_contextLocalId', values);
  }

  Future<int> deleteAllByPeerIdContextKindContextLocalId(List<int> peerIdValues,
      List<ContextKind> contextKindValues, List<int> contextLocalIdValues) {
    final len = peerIdValues.length;
    assert(
        contextKindValues.length == len && contextLocalIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add(
          [peerIdValues[i], contextKindValues[i], contextLocalIdValues[i]]);
    }

    return deleteAllByIndex(r'peerId_contextKind_contextLocalId', values);
  }

  int deleteAllByPeerIdContextKindContextLocalIdSync(List<int> peerIdValues,
      List<ContextKind> contextKindValues, List<int> contextLocalIdValues) {
    final len = peerIdValues.length;
    assert(
        contextKindValues.length == len && contextLocalIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add(
          [peerIdValues[i], contextKindValues[i], contextLocalIdValues[i]]);
    }

    return deleteAllByIndexSync(r'peerId_contextKind_contextLocalId', values);
  }

  Future<Id> putByPeerIdContextKindContextLocalId(PairedContext object) {
    return putByIndex(r'peerId_contextKind_contextLocalId', object);
  }

  Id putByPeerIdContextKindContextLocalIdSync(PairedContext object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'peerId_contextKind_contextLocalId', object,
        saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPeerIdContextKindContextLocalId(
      List<PairedContext> objects) {
    return putAllByIndex(r'peerId_contextKind_contextLocalId', objects);
  }

  List<Id> putAllByPeerIdContextKindContextLocalIdSync(
      List<PairedContext> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'peerId_contextKind_contextLocalId', objects,
        saveLinks: saveLinks);
  }
}

extension PairedContextQueryWhereSort
    on QueryBuilder<PairedContext, PairedContext, QWhere> {
  QueryBuilder<PairedContext, PairedContext, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhere>
      anyPeerIdContextKindContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(
            indexName: r'peerId_contextKind_contextLocalId'),
      );
    });
  }
}

extension PairedContextQueryWhere
    on QueryBuilder<PairedContext, PairedContext, QWhereClause> {
  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause> idBetween(
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

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdEqualToAnyContextKindContextLocalId(int peerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'peerId_contextKind_contextLocalId',
        value: [peerId],
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdNotEqualToAnyContextKindContextLocalId(int peerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [],
              upper: [peerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [],
              upper: [peerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdGreaterThanAnyContextKindContextLocalId(
    int peerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [peerId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdLessThanAnyContextKindContextLocalId(
    int peerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [],
        upper: [peerId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdBetweenAnyContextKindContextLocalId(
    int lowerPeerId,
    int upperPeerId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [lowerPeerId],
        includeLower: includeLower,
        upper: [upperPeerId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdContextKindEqualToAnyContextLocalId(
          int peerId, ContextKind contextKind) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'peerId_contextKind_contextLocalId',
        value: [peerId, contextKind],
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdEqualToContextKindNotEqualToAnyContextLocalId(
          int peerId, ContextKind contextKind) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId],
              upper: [peerId, contextKind],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId, contextKind],
              includeLower: false,
              upper: [peerId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId, contextKind],
              includeLower: false,
              upper: [peerId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId],
              upper: [peerId, contextKind],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdEqualToContextKindGreaterThanAnyContextLocalId(
    int peerId,
    ContextKind contextKind, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [peerId, contextKind],
        includeLower: include,
        upper: [peerId],
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdEqualToContextKindLessThanAnyContextLocalId(
    int peerId,
    ContextKind contextKind, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [peerId],
        upper: [peerId, contextKind],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdEqualToContextKindBetweenAnyContextLocalId(
    int peerId,
    ContextKind lowerContextKind,
    ContextKind upperContextKind, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [peerId, lowerContextKind],
        includeLower: includeLower,
        upper: [peerId, upperContextKind],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdContextKindContextLocalIdEqualTo(
          int peerId, ContextKind contextKind, int contextLocalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'peerId_contextKind_contextLocalId',
        value: [peerId, contextKind, contextLocalId],
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdContextKindEqualToContextLocalIdNotEqualTo(
          int peerId, ContextKind contextKind, int contextLocalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId, contextKind],
              upper: [peerId, contextKind, contextLocalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId, contextKind, contextLocalId],
              includeLower: false,
              upper: [peerId, contextKind],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId, contextKind, contextLocalId],
              includeLower: false,
              upper: [peerId, contextKind],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerId_contextKind_contextLocalId',
              lower: [peerId, contextKind],
              upper: [peerId, contextKind, contextLocalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdContextKindEqualToContextLocalIdGreaterThan(
    int peerId,
    ContextKind contextKind,
    int contextLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [peerId, contextKind, contextLocalId],
        includeLower: include,
        upper: [peerId, contextKind],
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdContextKindEqualToContextLocalIdLessThan(
    int peerId,
    ContextKind contextKind,
    int contextLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [peerId, contextKind],
        upper: [peerId, contextKind, contextLocalId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterWhereClause>
      peerIdContextKindEqualToContextLocalIdBetween(
    int peerId,
    ContextKind contextKind,
    int lowerContextLocalId,
    int upperContextLocalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'peerId_contextKind_contextLocalId',
        lower: [peerId, contextKind, lowerContextLocalId],
        includeLower: includeLower,
        upper: [peerId, contextKind, upperContextLocalId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PairedContextQueryFilter
    on QueryBuilder<PairedContext, PairedContext, QFilterCondition> {
  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      activeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'active',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      contextKindEqualTo(ContextKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextKind',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      contextKindGreaterThan(
    ContextKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contextKind',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      contextKindLessThan(
    ContextKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contextKind',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      contextKindBetween(
    ContextKind lower,
    ContextKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contextKind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      contextLocalIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      pairedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      pairedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      pairedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      pairedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pairedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      peerIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerId',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      peerIdGreaterThan(
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      peerIdLessThan(
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      peerIdBetween(
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

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      peerRoleEqualTo(SharedMemberRole value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerRole',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      peerRoleGreaterThan(
    SharedMemberRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerRole',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      peerRoleLessThan(
    SharedMemberRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerRole',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterFilterCondition>
      peerRoleBetween(
    SharedMemberRole lower,
    SharedMemberRole upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PairedContextQueryObject
    on QueryBuilder<PairedContext, PairedContext, QFilterCondition> {}

extension PairedContextQueryLinks
    on QueryBuilder<PairedContext, PairedContext, QFilterCondition> {}

extension PairedContextQuerySortBy
    on QueryBuilder<PairedContext, PairedContext, QSortBy> {
  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> sortByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> sortByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> sortByContextKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextKind', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      sortByContextKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextKind', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      sortByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      sortByContextLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> sortByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      sortByPairedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> sortByPeerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> sortByPeerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> sortByPeerRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerRole', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      sortByPeerRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerRole', Sort.desc);
    });
  }
}

extension PairedContextQuerySortThenBy
    on QueryBuilder<PairedContext, PairedContext, QSortThenBy> {
  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenByContextKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextKind', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      thenByContextKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextKind', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      thenByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      thenByContextLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      thenByPairedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenByPeerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenByPeerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerId', Sort.desc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy> thenByPeerRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerRole', Sort.asc);
    });
  }

  QueryBuilder<PairedContext, PairedContext, QAfterSortBy>
      thenByPeerRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerRole', Sort.desc);
    });
  }
}

extension PairedContextQueryWhereDistinct
    on QueryBuilder<PairedContext, PairedContext, QDistinct> {
  QueryBuilder<PairedContext, PairedContext, QDistinct> distinctByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'active');
    });
  }

  QueryBuilder<PairedContext, PairedContext, QDistinct>
      distinctByContextKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextKind');
    });
  }

  QueryBuilder<PairedContext, PairedContext, QDistinct>
      distinctByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextLocalId');
    });
  }

  QueryBuilder<PairedContext, PairedContext, QDistinct> distinctByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pairedAt');
    });
  }

  QueryBuilder<PairedContext, PairedContext, QDistinct> distinctByPeerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerId');
    });
  }

  QueryBuilder<PairedContext, PairedContext, QDistinct> distinctByPeerRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerRole');
    });
  }
}

extension PairedContextQueryProperty
    on QueryBuilder<PairedContext, PairedContext, QQueryProperty> {
  QueryBuilder<PairedContext, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PairedContext, bool, QQueryOperations> activeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'active');
    });
  }

  QueryBuilder<PairedContext, ContextKind, QQueryOperations>
      contextKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextKind');
    });
  }

  QueryBuilder<PairedContext, int, QQueryOperations> contextLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextLocalId');
    });
  }

  QueryBuilder<PairedContext, DateTime, QQueryOperations> pairedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pairedAt');
    });
  }

  QueryBuilder<PairedContext, int, QQueryOperations> peerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerId');
    });
  }

  QueryBuilder<PairedContext, SharedMemberRole, QQueryOperations>
      peerRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerRole');
    });
  }
}
