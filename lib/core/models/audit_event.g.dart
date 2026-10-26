// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAuditEventCollection on Isar {
  IsarCollection<AuditEvent> get auditEvents => this.collection();
}

const AuditEventSchema = CollectionSchema(
  name: r'AuditEvent',
  id: -228283108298215510,
  properties: {
    r'action': PropertySchema(
      id: 0,
      name: r'action',
      type: IsarType.string,
    ),
    r'contextSyncGuid': PropertySchema(
      id: 1,
      name: r'contextSyncGuid',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'evidenceJson': PropertySchema(
      id: 3,
      name: r'evidenceJson',
      type: IsarType.string,
    ),
    r'hash': PropertySchema(
      id: 4,
      name: r'hash',
      type: IsarType.string,
    ),
    r'newValue': PropertySchema(
      id: 5,
      name: r'newValue',
      type: IsarType.string,
    ),
    r'objectId': PropertySchema(
      id: 6,
      name: r'objectId',
      type: IsarType.long,
    ),
    r'objectType': PropertySchema(
      id: 7,
      name: r'objectType',
      type: IsarType.string,
    ),
    r'previousHash': PropertySchema(
      id: 8,
      name: r'previousHash',
      type: IsarType.string,
    ),
    r'previousValue': PropertySchema(
      id: 9,
      name: r'previousValue',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 10,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 11,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'signature': PropertySchema(
      id: 12,
      name: r'signature',
      type: IsarType.string,
    ),
    r'syncGuid': PropertySchema(
      id: 13,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 14,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'userIdentity': PropertySchema(
      id: 15,
      name: r'userIdentity',
      type: IsarType.string,
    )
  },
  estimateSize: _auditEventEstimateSize,
  serialize: _auditEventSerialize,
  deserialize: _auditEventDeserialize,
  deserializeProp: _auditEventDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _auditEventGetId,
  getLinks: _auditEventGetLinks,
  attach: _auditEventAttach,
  version: '3.1.0+1',
);

int _auditEventEstimateSize(
  AuditEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.action.length * 3;
  {
    final value = object.contextSyncGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.evidenceJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.hash.length * 3;
  {
    final value = object.newValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.objectType.length * 3;
  bytesCount += 3 + object.previousHash.length * 3;
  {
    final value = object.previousValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.signature;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.userIdentity.length * 3;
  return bytesCount;
}

void _auditEventSerialize(
  AuditEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.action);
  writer.writeString(offsets[1], object.contextSyncGuid);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.evidenceJson);
  writer.writeString(offsets[4], object.hash);
  writer.writeString(offsets[5], object.newValue);
  writer.writeLong(offsets[6], object.objectId);
  writer.writeString(offsets[7], object.objectType);
  writer.writeString(offsets[8], object.previousHash);
  writer.writeString(offsets[9], object.previousValue);
  writer.writeLong(offsets[10], object.profileId);
  writer.writeLong(offsets[11], object.sharedSpaceId);
  writer.writeString(offsets[12], object.signature);
  writer.writeString(offsets[13], object.syncGuid);
  writer.writeDateTime(offsets[14], object.timestamp);
  writer.writeString(offsets[15], object.userIdentity);
}

AuditEvent _auditEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AuditEvent();
  object.action = reader.readString(offsets[0]);
  object.contextSyncGuid = reader.readStringOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.evidenceJson = reader.readStringOrNull(offsets[3]);
  object.hash = reader.readString(offsets[4]);
  object.id = id;
  object.newValue = reader.readStringOrNull(offsets[5]);
  object.objectId = reader.readLongOrNull(offsets[6]);
  object.objectType = reader.readString(offsets[7]);
  object.previousHash = reader.readString(offsets[8]);
  object.previousValue = reader.readStringOrNull(offsets[9]);
  object.profileId = reader.readLongOrNull(offsets[10]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[11]);
  object.signature = reader.readStringOrNull(offsets[12]);
  object.syncGuid = reader.readString(offsets[13]);
  object.timestamp = reader.readDateTime(offsets[14]);
  object.userIdentity = reader.readString(offsets[15]);
  return object;
}

P _auditEventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _auditEventGetId(AuditEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _auditEventGetLinks(AuditEvent object) {
  return [];
}

void _auditEventAttach(IsarCollection<dynamic> col, Id id, AuditEvent object) {
  object.id = id;
}

extension AuditEventQueryWhereSort
    on QueryBuilder<AuditEvent, AuditEvent, QWhere> {
  QueryBuilder<AuditEvent, AuditEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AuditEventQueryWhere
    on QueryBuilder<AuditEvent, AuditEvent, QWhereClause> {
  QueryBuilder<AuditEvent, AuditEvent, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterWhereClause> idBetween(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterWhereClause> syncGuidEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterWhereClause> syncGuidNotEqualTo(
      String syncGuid) {
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
}

extension AuditEventQueryFilter
    on QueryBuilder<AuditEvent, AuditEvent, QFilterCondition> {
  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'action',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'action',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> actionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      actionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contextSyncGuid',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contextSyncGuid',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidEqualTo(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidGreaterThan(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidLessThan(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contextSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contextSyncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      contextSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contextSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'evidenceJson',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'evidenceJson',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonEqualTo(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonGreaterThan(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonLessThan(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'evidenceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'evidenceJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'evidenceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      evidenceJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'evidenceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> hashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> newValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'newValue',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      newValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'newValue',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> newValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      newValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> newValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> newValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      newValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> newValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> newValueContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> newValueMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'newValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      newValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      newValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'newValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> objectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'objectId',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'objectId',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> objectIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objectId',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'objectId',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> objectIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'objectId',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> objectIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'objectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> objectTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objectType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'objectType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'objectType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> objectTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'objectType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'objectType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'objectType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'objectType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> objectTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'objectType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objectType',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      objectTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'objectType',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousHash',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousHash',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousValue',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousValue',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      previousValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> profileIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> profileIdLessThan(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> profileIdBetween(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      signatureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signature',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      signatureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signature',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> signatureEqualTo(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      signatureGreaterThan(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> signatureLessThan(
    String? value, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> signatureBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> signatureEndsWith(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> signatureContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> signatureMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      signatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      signatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> syncGuidEqualTo(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> syncGuidLessThan(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> syncGuidBetween(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> syncGuidEndsWith(
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

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> syncGuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> syncGuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userIdentity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterFilterCondition>
      userIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userIdentity',
        value: '',
      ));
    });
  }
}

extension AuditEventQueryObject
    on QueryBuilder<AuditEvent, AuditEvent, QFilterCondition> {}

extension AuditEventQueryLinks
    on QueryBuilder<AuditEvent, AuditEvent, QFilterCondition> {}

extension AuditEventQuerySortBy
    on QueryBuilder<AuditEvent, AuditEvent, QSortBy> {
  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByContextSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy>
      sortByContextSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByEvidenceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evidenceJson', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByEvidenceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evidenceJson', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByNewValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByNewValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByObjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectId', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByObjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectId', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByObjectType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectType', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByObjectTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectType', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByPreviousHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousHash', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByPreviousHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousHash', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByPreviousValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousValue', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByPreviousValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousValue', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByUserIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userIdentity', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> sortByUserIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userIdentity', Sort.desc);
    });
  }
}

extension AuditEventQuerySortThenBy
    on QueryBuilder<AuditEvent, AuditEvent, QSortThenBy> {
  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByContextSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy>
      thenByContextSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByEvidenceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evidenceJson', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByEvidenceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'evidenceJson', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByNewValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByNewValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByObjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectId', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByObjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectId', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByObjectType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectType', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByObjectTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectType', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByPreviousHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousHash', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByPreviousHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousHash', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByPreviousValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousValue', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByPreviousValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousValue', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByUserIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userIdentity', Sort.asc);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QAfterSortBy> thenByUserIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userIdentity', Sort.desc);
    });
  }
}

extension AuditEventQueryWhereDistinct
    on QueryBuilder<AuditEvent, AuditEvent, QDistinct> {
  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByAction(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByContextSyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByEvidenceJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'evidenceJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByNewValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByObjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objectId');
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByObjectType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objectType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByPreviousHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByPreviousValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousValue',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctBySignature(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signature', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<AuditEvent, AuditEvent, QDistinct> distinctByUserIdentity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userIdentity', caseSensitive: caseSensitive);
    });
  }
}

extension AuditEventQueryProperty
    on QueryBuilder<AuditEvent, AuditEvent, QQueryProperty> {
  QueryBuilder<AuditEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AuditEvent, String, QQueryOperations> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<AuditEvent, String?, QQueryOperations>
      contextSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextSyncGuid');
    });
  }

  QueryBuilder<AuditEvent, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AuditEvent, String?, QQueryOperations> evidenceJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'evidenceJson');
    });
  }

  QueryBuilder<AuditEvent, String, QQueryOperations> hashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hash');
    });
  }

  QueryBuilder<AuditEvent, String?, QQueryOperations> newValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newValue');
    });
  }

  QueryBuilder<AuditEvent, int?, QQueryOperations> objectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objectId');
    });
  }

  QueryBuilder<AuditEvent, String, QQueryOperations> objectTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objectType');
    });
  }

  QueryBuilder<AuditEvent, String, QQueryOperations> previousHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousHash');
    });
  }

  QueryBuilder<AuditEvent, String?, QQueryOperations> previousValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousValue');
    });
  }

  QueryBuilder<AuditEvent, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<AuditEvent, int?, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<AuditEvent, String?, QQueryOperations> signatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signature');
    });
  }

  QueryBuilder<AuditEvent, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<AuditEvent, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<AuditEvent, String, QQueryOperations> userIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userIdentity');
    });
  }
}
