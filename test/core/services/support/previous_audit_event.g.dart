// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'previous_audit_event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreviousAuditEventCollection on Isar {
  IsarCollection<PreviousAuditEvent> get previousAuditEvents =>
      this.collection();
}

const PreviousAuditEventSchema = CollectionSchema(
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
    r'hash': PropertySchema(
      id: 3,
      name: r'hash',
      type: IsarType.string,
    ),
    r'newValue': PropertySchema(
      id: 4,
      name: r'newValue',
      type: IsarType.string,
    ),
    r'objectId': PropertySchema(
      id: 5,
      name: r'objectId',
      type: IsarType.long,
    ),
    r'objectType': PropertySchema(
      id: 6,
      name: r'objectType',
      type: IsarType.string,
    ),
    r'previousHash': PropertySchema(
      id: 7,
      name: r'previousHash',
      type: IsarType.string,
    ),
    r'previousValue': PropertySchema(
      id: 8,
      name: r'previousValue',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 9,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 10,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'signature': PropertySchema(
      id: 11,
      name: r'signature',
      type: IsarType.string,
    ),
    r'syncGuid': PropertySchema(
      id: 12,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 13,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'userIdentity': PropertySchema(
      id: 14,
      name: r'userIdentity',
      type: IsarType.string,
    )
  },
  estimateSize: _previousAuditEventEstimateSize,
  serialize: _previousAuditEventSerialize,
  deserialize: _previousAuditEventDeserialize,
  deserializeProp: _previousAuditEventDeserializeProp,
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
  getId: _previousAuditEventGetId,
  getLinks: _previousAuditEventGetLinks,
  attach: _previousAuditEventAttach,
  version: '3.1.0+1',
);

int _previousAuditEventEstimateSize(
  PreviousAuditEvent object,
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

void _previousAuditEventSerialize(
  PreviousAuditEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.action);
  writer.writeString(offsets[1], object.contextSyncGuid);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.hash);
  writer.writeString(offsets[4], object.newValue);
  writer.writeLong(offsets[5], object.objectId);
  writer.writeString(offsets[6], object.objectType);
  writer.writeString(offsets[7], object.previousHash);
  writer.writeString(offsets[8], object.previousValue);
  writer.writeLong(offsets[9], object.profileId);
  writer.writeLong(offsets[10], object.sharedSpaceId);
  writer.writeString(offsets[11], object.signature);
  writer.writeString(offsets[12], object.syncGuid);
  writer.writeDateTime(offsets[13], object.timestamp);
  writer.writeString(offsets[14], object.userIdentity);
}

PreviousAuditEvent _previousAuditEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PreviousAuditEvent();
  object.action = reader.readString(offsets[0]);
  object.contextSyncGuid = reader.readStringOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.hash = reader.readString(offsets[3]);
  object.id = id;
  object.newValue = reader.readStringOrNull(offsets[4]);
  object.objectId = reader.readLongOrNull(offsets[5]);
  object.objectType = reader.readString(offsets[6]);
  object.previousHash = reader.readString(offsets[7]);
  object.previousValue = reader.readStringOrNull(offsets[8]);
  object.profileId = reader.readLongOrNull(offsets[9]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[10]);
  object.signature = reader.readStringOrNull(offsets[11]);
  object.syncGuid = reader.readString(offsets[12]);
  object.timestamp = reader.readDateTime(offsets[13]);
  object.userIdentity = reader.readString(offsets[14]);
  return object;
}

P _previousAuditEventDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _previousAuditEventGetId(PreviousAuditEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _previousAuditEventGetLinks(
    PreviousAuditEvent object) {
  return [];
}

void _previousAuditEventAttach(
    IsarCollection<dynamic> col, Id id, PreviousAuditEvent object) {
  object.id = id;
}

extension PreviousAuditEventQueryWhereSort
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QWhere> {
  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PreviousAuditEventQueryWhere
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QWhereClause> {
  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterWhereClause>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterWhereClause>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterWhereClause>
      syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterWhereClause>
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
}

extension PreviousAuditEventQueryFilter
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QFilterCondition> {
  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionEqualTo(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionGreaterThan(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionLessThan(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionBetween(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionStartsWith(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionEndsWith(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'action',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      actionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      contextSyncGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contextSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      contextSyncGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contextSyncGuid',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      contextSyncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contextSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      contextSyncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contextSyncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      contextSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      contextSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contextSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashEqualTo(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashGreaterThan(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashLessThan(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashBetween(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashStartsWith(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashEndsWith(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      hashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hash',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'newValue',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'newValue',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueEqualTo(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueLessThan(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueBetween(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueEndsWith(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'newValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newValue',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      newValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'newValue',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'objectId',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'objectId',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objectId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectIdLessThan(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectIdBetween(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectTypeEqualTo(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectTypeBetween(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'objectType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'objectType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objectType',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      objectTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'objectType',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousHash',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousHash',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousValue',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousValue',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousValue',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      previousValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousValue',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signature',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signature',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureEqualTo(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureLessThan(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureBetween(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      signatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      timestampLessThan(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      timestampBetween(
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
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

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      userIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      userIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      userIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterFilterCondition>
      userIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userIdentity',
        value: '',
      ));
    });
  }
}

extension PreviousAuditEventQueryObject
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QFilterCondition> {}

extension PreviousAuditEventQueryLinks
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QFilterCondition> {}

extension PreviousAuditEventQuerySortBy
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QSortBy> {
  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByContextSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByContextSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByNewValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByNewValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByObjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectId', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByObjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectId', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByObjectType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectType', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByObjectTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectType', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByPreviousHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousHash', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByPreviousHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousHash', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByPreviousValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousValue', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByPreviousValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousValue', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByUserIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userIdentity', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      sortByUserIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userIdentity', Sort.desc);
    });
  }
}

extension PreviousAuditEventQuerySortThenBy
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QSortThenBy> {
  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByContextSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByContextSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByNewValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByNewValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByObjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectId', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByObjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectId', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByObjectType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectType', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByObjectTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objectType', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByPreviousHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousHash', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByPreviousHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousHash', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByPreviousValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousValue', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByPreviousValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousValue', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByUserIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userIdentity', Sort.asc);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QAfterSortBy>
      thenByUserIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userIdentity', Sort.desc);
    });
  }
}

extension PreviousAuditEventQueryWhereDistinct
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct> {
  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByAction({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByContextSyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByNewValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByObjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objectId');
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByObjectType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objectType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByPreviousHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByPreviousValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousValue',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctBySignature({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signature', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctBySyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QDistinct>
      distinctByUserIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userIdentity', caseSensitive: caseSensitive);
    });
  }
}

extension PreviousAuditEventQueryProperty
    on QueryBuilder<PreviousAuditEvent, PreviousAuditEvent, QQueryProperty> {
  QueryBuilder<PreviousAuditEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PreviousAuditEvent, String, QQueryOperations> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<PreviousAuditEvent, String?, QQueryOperations>
      contextSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextSyncGuid');
    });
  }

  QueryBuilder<PreviousAuditEvent, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PreviousAuditEvent, String, QQueryOperations> hashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hash');
    });
  }

  QueryBuilder<PreviousAuditEvent, String?, QQueryOperations>
      newValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newValue');
    });
  }

  QueryBuilder<PreviousAuditEvent, int?, QQueryOperations> objectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objectId');
    });
  }

  QueryBuilder<PreviousAuditEvent, String, QQueryOperations>
      objectTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objectType');
    });
  }

  QueryBuilder<PreviousAuditEvent, String, QQueryOperations>
      previousHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousHash');
    });
  }

  QueryBuilder<PreviousAuditEvent, String?, QQueryOperations>
      previousValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousValue');
    });
  }

  QueryBuilder<PreviousAuditEvent, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<PreviousAuditEvent, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<PreviousAuditEvent, String?, QQueryOperations>
      signatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signature');
    });
  }

  QueryBuilder<PreviousAuditEvent, String, QQueryOperations>
      syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<PreviousAuditEvent, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<PreviousAuditEvent, String, QQueryOperations>
      userIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userIdentity');
    });
  }
}
