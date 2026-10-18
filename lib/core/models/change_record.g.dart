// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChangeRecordCollection on Isar {
  IsarCollection<ChangeRecord> get changeRecords => this.collection();
}

const ChangeRecordSchema = CollectionSchema(
  name: r'ChangeRecord',
  id: 1752918784657965321,
  properties: {
    r'authorIdentityId': PropertySchema(
      id: 0,
      name: r'authorIdentityId',
      type: IsarType.string,
    ),
    r'contextKind': PropertySchema(
      id: 1,
      name: r'contextKind',
      type: IsarType.byte,
      enumMap: _ChangeRecordcontextKindEnumValueMap,
    ),
    r'contextLocalId': PropertySchema(
      id: 2,
      name: r'contextLocalId',
      type: IsarType.long,
    ),
    r'contextSyncGuid': PropertySchema(
      id: 3,
      name: r'contextSyncGuid',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deviceId': PropertySchema(
      id: 5,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'entityLocalId': PropertySchema(
      id: 6,
      name: r'entityLocalId',
      type: IsarType.long,
    ),
    r'entitySyncGuid': PropertySchema(
      id: 7,
      name: r'entitySyncGuid',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 8,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'hlcCounter': PropertySchema(
      id: 9,
      name: r'hlcCounter',
      type: IsarType.long,
    ),
    r'hlcMillis': PropertySchema(
      id: 10,
      name: r'hlcMillis',
      type: IsarType.long,
    ),
    r'op': PropertySchema(
      id: 11,
      name: r'op',
      type: IsarType.string,
    ),
    r'payload': PropertySchema(
      id: 12,
      name: r'payload',
      type: IsarType.string,
    ),
    r'signature': PropertySchema(
      id: 13,
      name: r'signature',
      type: IsarType.string,
    )
  },
  estimateSize: _changeRecordEstimateSize,
  serialize: _changeRecordSerialize,
  deserialize: _changeRecordDeserialize,
  deserializeProp: _changeRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'contextSyncGuid': IndexSchema(
      id: -6068982201345244215,
      name: r'contextSyncGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'contextSyncGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'contextLocalId_entityType_entityLocalId': IndexSchema(
      id: 5691460144188255998,
      name: r'contextLocalId_entityType_entityLocalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'contextLocalId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'entityType',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'entityLocalId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'entitySyncGuid': IndexSchema(
      id: 498820119685140544,
      name: r'entitySyncGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entitySyncGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'authorIdentityId': IndexSchema(
      id: -3411162072408951154,
      name: r'authorIdentityId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'authorIdentityId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _changeRecordGetId,
  getLinks: _changeRecordGetLinks,
  attach: _changeRecordAttach,
  version: '3.1.0+1',
);

int _changeRecordEstimateSize(
  ChangeRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authorIdentityId.length * 3;
  bytesCount += 3 + object.contextSyncGuid.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.entitySyncGuid.length * 3;
  bytesCount += 3 + object.entityType.length * 3;
  bytesCount += 3 + object.op.length * 3;
  bytesCount += 3 + object.payload.length * 3;
  bytesCount += 3 + object.signature.length * 3;
  return bytesCount;
}

void _changeRecordSerialize(
  ChangeRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authorIdentityId);
  writer.writeByte(offsets[1], object.contextKind.index);
  writer.writeLong(offsets[2], object.contextLocalId);
  writer.writeString(offsets[3], object.contextSyncGuid);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.deviceId);
  writer.writeLong(offsets[6], object.entityLocalId);
  writer.writeString(offsets[7], object.entitySyncGuid);
  writer.writeString(offsets[8], object.entityType);
  writer.writeLong(offsets[9], object.hlcCounter);
  writer.writeLong(offsets[10], object.hlcMillis);
  writer.writeString(offsets[11], object.op);
  writer.writeString(offsets[12], object.payload);
  writer.writeString(offsets[13], object.signature);
}

ChangeRecord _changeRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChangeRecord();
  object.authorIdentityId = reader.readString(offsets[0]);
  object.contextKind =
      _ChangeRecordcontextKindValueEnumMap[reader.readByteOrNull(offsets[1])] ??
          ContextKind.personal;
  object.contextLocalId = reader.readLong(offsets[2]);
  object.contextSyncGuid = reader.readString(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.deviceId = reader.readString(offsets[5]);
  object.entityLocalId = reader.readLong(offsets[6]);
  object.entitySyncGuid = reader.readString(offsets[7]);
  object.entityType = reader.readString(offsets[8]);
  object.hlcCounter = reader.readLong(offsets[9]);
  object.hlcMillis = reader.readLong(offsets[10]);
  object.id = id;
  object.op = reader.readString(offsets[11]);
  object.payload = reader.readString(offsets[12]);
  object.signature = reader.readString(offsets[13]);
  return object;
}

P _changeRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_ChangeRecordcontextKindValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ContextKind.personal) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ChangeRecordcontextKindEnumValueMap = {
  'personal': 0,
  'shared': 1,
};
const _ChangeRecordcontextKindValueEnumMap = {
  0: ContextKind.personal,
  1: ContextKind.shared,
};

Id _changeRecordGetId(ChangeRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _changeRecordGetLinks(ChangeRecord object) {
  return [];
}

void _changeRecordAttach(
    IsarCollection<dynamic> col, Id id, ChangeRecord object) {
  object.id = id;
}

extension ChangeRecordQueryWhereSort
    on QueryBuilder<ChangeRecord, ChangeRecord, QWhere> {
  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChangeRecordQueryWhere
    on QueryBuilder<ChangeRecord, ChangeRecord, QWhereClause> {
  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextSyncGuidEqualTo(String contextSyncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'contextSyncGuid',
        value: [contextSyncGuid],
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextSyncGuidNotEqualTo(String contextSyncGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextSyncGuid',
              lower: [],
              upper: [contextSyncGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextSyncGuid',
              lower: [contextSyncGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextSyncGuid',
              lower: [contextSyncGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextSyncGuid',
              lower: [],
              upper: [contextSyncGuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdEqualToAnyEntityTypeEntityLocalId(int contextLocalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'contextLocalId_entityType_entityLocalId',
        value: [contextLocalId],
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdNotEqualToAnyEntityTypeEntityLocalId(int contextLocalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [],
              upper: [contextLocalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [],
              upper: [contextLocalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdGreaterThanAnyEntityTypeEntityLocalId(
    int contextLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'contextLocalId_entityType_entityLocalId',
        lower: [contextLocalId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdLessThanAnyEntityTypeEntityLocalId(
    int contextLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'contextLocalId_entityType_entityLocalId',
        lower: [],
        upper: [contextLocalId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdBetweenAnyEntityTypeEntityLocalId(
    int lowerContextLocalId,
    int upperContextLocalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'contextLocalId_entityType_entityLocalId',
        lower: [lowerContextLocalId],
        includeLower: includeLower,
        upper: [upperContextLocalId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdEntityTypeEqualToAnyEntityLocalId(
          int contextLocalId, String entityType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'contextLocalId_entityType_entityLocalId',
        value: [contextLocalId, entityType],
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdEqualToEntityTypeNotEqualToAnyEntityLocalId(
          int contextLocalId, String entityType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId],
              upper: [contextLocalId, entityType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId, entityType],
              includeLower: false,
              upper: [contextLocalId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId, entityType],
              includeLower: false,
              upper: [contextLocalId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId],
              upper: [contextLocalId, entityType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdEntityTypeEntityLocalIdEqualTo(
          int contextLocalId, String entityType, int entityLocalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'contextLocalId_entityType_entityLocalId',
        value: [contextLocalId, entityType, entityLocalId],
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdEntityTypeEqualToEntityLocalIdNotEqualTo(
          int contextLocalId, String entityType, int entityLocalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId, entityType],
              upper: [contextLocalId, entityType, entityLocalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId, entityType, entityLocalId],
              includeLower: false,
              upper: [contextLocalId, entityType],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId, entityType, entityLocalId],
              includeLower: false,
              upper: [contextLocalId, entityType],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contextLocalId_entityType_entityLocalId',
              lower: [contextLocalId, entityType],
              upper: [contextLocalId, entityType, entityLocalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdEntityTypeEqualToEntityLocalIdGreaterThan(
    int contextLocalId,
    String entityType,
    int entityLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'contextLocalId_entityType_entityLocalId',
        lower: [contextLocalId, entityType, entityLocalId],
        includeLower: include,
        upper: [contextLocalId, entityType],
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdEntityTypeEqualToEntityLocalIdLessThan(
    int contextLocalId,
    String entityType,
    int entityLocalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'contextLocalId_entityType_entityLocalId',
        lower: [contextLocalId, entityType],
        upper: [contextLocalId, entityType, entityLocalId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      contextLocalIdEntityTypeEqualToEntityLocalIdBetween(
    int contextLocalId,
    String entityType,
    int lowerEntityLocalId,
    int upperEntityLocalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'contextLocalId_entityType_entityLocalId',
        lower: [contextLocalId, entityType, lowerEntityLocalId],
        includeLower: includeLower,
        upper: [contextLocalId, entityType, upperEntityLocalId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      entitySyncGuidEqualTo(String entitySyncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entitySyncGuid',
        value: [entitySyncGuid],
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      entitySyncGuidNotEqualTo(String entitySyncGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entitySyncGuid',
              lower: [],
              upper: [entitySyncGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entitySyncGuid',
              lower: [entitySyncGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entitySyncGuid',
              lower: [entitySyncGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entitySyncGuid',
              lower: [],
              upper: [entitySyncGuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      authorIdentityIdEqualTo(String authorIdentityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'authorIdentityId',
        value: [authorIdentityId],
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterWhereClause>
      authorIdentityIdNotEqualTo(String authorIdentityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorIdentityId',
              lower: [],
              upper: [authorIdentityId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorIdentityId',
              lower: [authorIdentityId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorIdentityId',
              lower: [authorIdentityId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorIdentityId',
              lower: [],
              upper: [authorIdentityId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ChangeRecordQueryFilter
    on QueryBuilder<ChangeRecord, ChangeRecord, QFilterCondition> {
  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authorIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authorIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authorIdentityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authorIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authorIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authorIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authorIdentityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorIdentityId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      authorIdentityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authorIdentityId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextKindEqualTo(ContextKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextKind',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextLocalIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contextSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contextSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contextSyncGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contextSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contextSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contextSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contextSyncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      contextSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contextSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityLocalIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityLocalIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityLocalIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityLocalIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityLocalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entitySyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entitySyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entitySyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entitySyncGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entitySyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entitySyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entitySyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entitySyncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entitySyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entitySyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entitySyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      hlcCounterEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hlcCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      hlcCounterGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hlcCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      hlcCounterLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hlcCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      hlcCounterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hlcCounter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      hlcMillisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      hlcMillisGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      hlcMillisLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hlcMillis',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      hlcMillisBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hlcMillis',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'op',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'op',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'op',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'op',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'op',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'op',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'op',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'op',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition> opIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'op',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      opIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'op',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterFilterCondition>
      signatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signature',
        value: '',
      ));
    });
  }
}

extension ChangeRecordQueryObject
    on QueryBuilder<ChangeRecord, ChangeRecord, QFilterCondition> {}

extension ChangeRecordQueryLinks
    on QueryBuilder<ChangeRecord, ChangeRecord, QFilterCondition> {}

extension ChangeRecordQuerySortBy
    on QueryBuilder<ChangeRecord, ChangeRecord, QSortBy> {
  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByAuthorIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorIdentityId', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByAuthorIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorIdentityId', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByContextKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextKind', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByContextKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextKind', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByContextLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByContextSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByContextSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByEntityLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityLocalId', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByEntityLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityLocalId', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByEntitySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entitySyncGuid', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByEntitySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entitySyncGuid', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByHlcCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlcCounter', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      sortByHlcCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlcCounter', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlcMillis', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByHlcMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlcMillis', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByOp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByOpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> sortBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }
}

extension ChangeRecordQuerySortThenBy
    on QueryBuilder<ChangeRecord, ChangeRecord, QSortThenBy> {
  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByAuthorIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorIdentityId', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByAuthorIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorIdentityId', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByContextKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextKind', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByContextKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextKind', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByContextLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextLocalId', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByContextSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByContextSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByEntityLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityLocalId', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByEntityLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityLocalId', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByEntitySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entitySyncGuid', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByEntitySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entitySyncGuid', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByHlcCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlcCounter', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy>
      thenByHlcCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlcCounter', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlcMillis', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByHlcMillisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hlcMillis', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByOp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByOpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QAfterSortBy> thenBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }
}

extension ChangeRecordQueryWhereDistinct
    on QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> {
  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct>
      distinctByAuthorIdentityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorIdentityId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByContextKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextKind');
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct>
      distinctByContextLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextLocalId');
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByContextSyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct>
      distinctByEntityLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityLocalId');
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByEntitySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entitySyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByEntityType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByHlcCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hlcCounter');
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByHlcMillis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hlcMillis');
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByOp(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'op', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChangeRecord, ChangeRecord, QDistinct> distinctBySignature(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signature', caseSensitive: caseSensitive);
    });
  }
}

extension ChangeRecordQueryProperty
    on QueryBuilder<ChangeRecord, ChangeRecord, QQueryProperty> {
  QueryBuilder<ChangeRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChangeRecord, String, QQueryOperations>
      authorIdentityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorIdentityId');
    });
  }

  QueryBuilder<ChangeRecord, ContextKind, QQueryOperations>
      contextKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextKind');
    });
  }

  QueryBuilder<ChangeRecord, int, QQueryOperations> contextLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextLocalId');
    });
  }

  QueryBuilder<ChangeRecord, String, QQueryOperations>
      contextSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextSyncGuid');
    });
  }

  QueryBuilder<ChangeRecord, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ChangeRecord, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<ChangeRecord, int, QQueryOperations> entityLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityLocalId');
    });
  }

  QueryBuilder<ChangeRecord, String, QQueryOperations>
      entitySyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entitySyncGuid');
    });
  }

  QueryBuilder<ChangeRecord, String, QQueryOperations> entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<ChangeRecord, int, QQueryOperations> hlcCounterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hlcCounter');
    });
  }

  QueryBuilder<ChangeRecord, int, QQueryOperations> hlcMillisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hlcMillis');
    });
  }

  QueryBuilder<ChangeRecord, String, QQueryOperations> opProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'op');
    });
  }

  QueryBuilder<ChangeRecord, String, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<ChangeRecord, String, QQueryOperations> signatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signature');
    });
  }
}
