// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_action.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPendingActionCollection on Isar {
  IsarCollection<PendingAction> get pendingActions => this.collection();
}

const PendingActionSchema = CollectionSchema(
  name: r'PendingAction',
  id: 4776148611406905690,
  properties: {
    r'actionType': PropertySchema(
      id: 0,
      name: r'actionType',
      type: IsarType.string,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 3,
      name: r'currency',
      type: IsarType.string,
    ),
    r'dedupeKey': PropertySchema(
      id: 4,
      name: r'dedupeKey',
      type: IsarType.string,
    ),
    r'deepLink': PropertySchema(
      id: 5,
      name: r'deepLink',
      type: IsarType.string,
    ),
    r'dismissedReason': PropertySchema(
      id: 6,
      name: r'dismissedReason',
      type: IsarType.string,
    ),
    r'expectedAmountMinor': PropertySchema(
      id: 7,
      name: r'expectedAmountMinor',
      type: IsarType.long,
    ),
    r'expectedAt': PropertySchema(
      id: 8,
      name: r'expectedAt',
      type: IsarType.dateTime,
    ),
    r'expectedMonth': PropertySchema(
      id: 9,
      name: r'expectedMonth',
      type: IsarType.string,
    ),
    r'feature': PropertySchema(
      id: 10,
      name: r'feature',
      type: IsarType.string,
    ),
    r'guid': PropertySchema(
      id: 11,
      name: r'guid',
      type: IsarType.string,
    ),
    r'lastNotifiedAt': PropertySchema(
      id: 12,
      name: r'lastNotifiedAt',
      type: IsarType.dateTime,
    ),
    r'nextAction': PropertySchema(
      id: 13,
      name: r'nextAction',
      type: IsarType.string,
    ),
    r'notificationCount': PropertySchema(
      id: 14,
      name: r'notificationCount',
      type: IsarType.long,
    ),
    r'notificationReadAt': PropertySchema(
      id: 15,
      name: r'notificationReadAt',
      type: IsarType.dateTime,
    ),
    r'priority': PropertySchema(
      id: 16,
      name: r'priority',
      type: IsarType.long,
    ),
    r'profileId': PropertySchema(
      id: 17,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'recordRef': PropertySchema(
      id: 18,
      name: r'recordRef',
      type: IsarType.string,
    ),
    r'relatedGuid': PropertySchema(
      id: 19,
      name: r'relatedGuid',
      type: IsarType.string,
    ),
    r'reminderAt': PropertySchema(
      id: 20,
      name: r'reminderAt',
      type: IsarType.dateTime,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 21,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 22,
      name: r'status',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 23,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 24,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _pendingActionEstimateSize,
  serialize: _pendingActionSerialize,
  deserialize: _pendingActionDeserialize,
  deserializeProp: _pendingActionDeserializeProp,
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
    r'actionType': IndexSchema(
      id: -3643111368705296474,
      name: r'actionType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'actionType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dedupeKey': IndexSchema(
      id: -6620796718844543204,
      name: r'dedupeKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dedupeKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pendingActionGetId,
  getLinks: _pendingActionGetLinks,
  attach: _pendingActionAttach,
  version: '3.1.0+1',
);

int _pendingActionEstimateSize(
  PendingAction object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actionType.length * 3;
  {
    final value = object.currency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.dedupeKey.length * 3;
  {
    final value = object.deepLink;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dismissedReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.expectedMonth;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.feature.length * 3;
  bytesCount += 3 + object.guid.length * 3;
  bytesCount += 3 + object.nextAction.length * 3;
  bytesCount += 3 + object.recordRef.length * 3;
  {
    final value = object.relatedGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _pendingActionSerialize(
  PendingAction object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionType);
  writer.writeDateTime(offsets[1], object.completedAt);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.currency);
  writer.writeString(offsets[4], object.dedupeKey);
  writer.writeString(offsets[5], object.deepLink);
  writer.writeString(offsets[6], object.dismissedReason);
  writer.writeLong(offsets[7], object.expectedAmountMinor);
  writer.writeDateTime(offsets[8], object.expectedAt);
  writer.writeString(offsets[9], object.expectedMonth);
  writer.writeString(offsets[10], object.feature);
  writer.writeString(offsets[11], object.guid);
  writer.writeDateTime(offsets[12], object.lastNotifiedAt);
  writer.writeString(offsets[13], object.nextAction);
  writer.writeLong(offsets[14], object.notificationCount);
  writer.writeDateTime(offsets[15], object.notificationReadAt);
  writer.writeLong(offsets[16], object.priority);
  writer.writeLong(offsets[17], object.profileId);
  writer.writeString(offsets[18], object.recordRef);
  writer.writeString(offsets[19], object.relatedGuid);
  writer.writeDateTime(offsets[20], object.reminderAt);
  writer.writeLong(offsets[21], object.sharedSpaceId);
  writer.writeString(offsets[22], object.status);
  writer.writeString(offsets[23], object.title);
  writer.writeDateTime(offsets[24], object.updatedAt);
}

PendingAction _pendingActionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PendingAction();
  object.actionType = reader.readString(offsets[0]);
  object.completedAt = reader.readDateTimeOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.currency = reader.readStringOrNull(offsets[3]);
  object.dedupeKey = reader.readString(offsets[4]);
  object.deepLink = reader.readStringOrNull(offsets[5]);
  object.dismissedReason = reader.readStringOrNull(offsets[6]);
  object.expectedAmountMinor = reader.readLongOrNull(offsets[7]);
  object.expectedAt = reader.readDateTimeOrNull(offsets[8]);
  object.expectedMonth = reader.readStringOrNull(offsets[9]);
  object.feature = reader.readString(offsets[10]);
  object.guid = reader.readString(offsets[11]);
  object.id = id;
  object.lastNotifiedAt = reader.readDateTimeOrNull(offsets[12]);
  object.nextAction = reader.readString(offsets[13]);
  object.notificationCount = reader.readLong(offsets[14]);
  object.notificationReadAt = reader.readDateTimeOrNull(offsets[15]);
  object.priority = reader.readLong(offsets[16]);
  object.profileId = reader.readLongOrNull(offsets[17]);
  object.recordRef = reader.readString(offsets[18]);
  object.relatedGuid = reader.readStringOrNull(offsets[19]);
  object.reminderAt = reader.readDateTimeOrNull(offsets[20]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[21]);
  object.status = reader.readString(offsets[22]);
  object.title = reader.readString(offsets[23]);
  object.updatedAt = reader.readDateTime(offsets[24]);
  return object;
}

P _pendingActionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 21:
      return (reader.readLongOrNull(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pendingActionGetId(PendingAction object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pendingActionGetLinks(PendingAction object) {
  return [];
}

void _pendingActionAttach(
    IsarCollection<dynamic> col, Id id, PendingAction object) {
  object.id = id;
}

extension PendingActionByIndex on IsarCollection<PendingAction> {
  Future<PendingAction?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  PendingAction? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<PendingAction?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<PendingAction?> getAllByGuidSync(List<String> guidValues) {
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

  Future<Id> putByGuid(PendingAction object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(PendingAction object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<PendingAction> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<PendingAction> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }

  Future<PendingAction?> getByDedupeKey(String dedupeKey) {
    return getByIndex(r'dedupeKey', [dedupeKey]);
  }

  PendingAction? getByDedupeKeySync(String dedupeKey) {
    return getByIndexSync(r'dedupeKey', [dedupeKey]);
  }

  Future<bool> deleteByDedupeKey(String dedupeKey) {
    return deleteByIndex(r'dedupeKey', [dedupeKey]);
  }

  bool deleteByDedupeKeySync(String dedupeKey) {
    return deleteByIndexSync(r'dedupeKey', [dedupeKey]);
  }

  Future<List<PendingAction?>> getAllByDedupeKey(List<String> dedupeKeyValues) {
    final values = dedupeKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'dedupeKey', values);
  }

  List<PendingAction?> getAllByDedupeKeySync(List<String> dedupeKeyValues) {
    final values = dedupeKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'dedupeKey', values);
  }

  Future<int> deleteAllByDedupeKey(List<String> dedupeKeyValues) {
    final values = dedupeKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'dedupeKey', values);
  }

  int deleteAllByDedupeKeySync(List<String> dedupeKeyValues) {
    final values = dedupeKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'dedupeKey', values);
  }

  Future<Id> putByDedupeKey(PendingAction object) {
    return putByIndex(r'dedupeKey', object);
  }

  Id putByDedupeKeySync(PendingAction object, {bool saveLinks = true}) {
    return putByIndexSync(r'dedupeKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDedupeKey(List<PendingAction> objects) {
    return putAllByIndex(r'dedupeKey', objects);
  }

  List<Id> putAllByDedupeKeySync(List<PendingAction> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'dedupeKey', objects, saveLinks: saveLinks);
  }
}

extension PendingActionQueryWhereSort
    on QueryBuilder<PendingAction, PendingAction, QWhere> {
  QueryBuilder<PendingAction, PendingAction, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension PendingActionQueryWhere
    on QueryBuilder<PendingAction, PendingAction, QWhereClause> {
  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause> idBetween(
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

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause> guidEqualTo(
      String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause> guidNotEqualTo(
      String guid) {
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

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      profileIdEqualTo(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      profileIdNotEqualTo(int? profileId) {
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

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      profileIdGreaterThan(
    int? profileId, {
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

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      profileIdLessThan(
    int? profileId, {
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

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      profileIdBetween(
    int? lowerProfileId,
    int? upperProfileId, {
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

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      actionTypeEqualTo(String actionType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'actionType',
        value: [actionType],
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      actionTypeNotEqualTo(String actionType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actionType',
              lower: [],
              upper: [actionType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actionType',
              lower: [actionType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actionType',
              lower: [actionType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actionType',
              lower: [],
              upper: [actionType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause> statusEqualTo(
      String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      dedupeKeyEqualTo(String dedupeKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dedupeKey',
        value: [dedupeKey],
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterWhereClause>
      dedupeKeyNotEqualTo(String dedupeKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dedupeKey',
              lower: [],
              upper: [dedupeKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dedupeKey',
              lower: [dedupeKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dedupeKey',
              lower: [dedupeKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dedupeKey',
              lower: [],
              upper: [dedupeKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PendingActionQueryFilter
    on QueryBuilder<PendingAction, PendingAction, QFilterCondition> {
  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionType',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      actionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionType',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currency',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currency',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyEqualTo(
    String? value, {
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyGreaterThan(
    String? value, {
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyLessThan(
    String? value, {
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dedupeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dedupeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dedupeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dedupeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dedupeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dedupeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dedupeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dedupeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dedupeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dedupeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dedupeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deepLink',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deepLink',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deepLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deepLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deepLink',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deepLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deepLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deepLink',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deepLink',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLink',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      deepLinkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deepLink',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dismissedReason',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dismissedReason',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dismissedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dismissedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dismissedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dismissedReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dismissedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dismissedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dismissedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dismissedReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dismissedReason',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      dismissedReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dismissedReason',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAmountMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedAmountMinor',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAmountMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedAmountMinor',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAmountMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAmountMinorGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAmountMinorLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAmountMinorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedAmountMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedMonth',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedMonth',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'expectedMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'expectedMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'expectedMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'expectedMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      expectedMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'expectedMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'feature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'feature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'feature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'feature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'feature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'feature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'feature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'feature',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      featureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'feature',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition> guidEqualTo(
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition> guidBetween(
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      guidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition> guidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      lastNotifiedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastNotifiedAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      lastNotifiedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastNotifiedAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      lastNotifiedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastNotifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      lastNotifiedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastNotifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      lastNotifiedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastNotifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      lastNotifiedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastNotifiedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextAction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nextAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nextAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nextAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nextAction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextAction',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      nextActionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nextAction',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationCount',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationCount',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationCount',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationReadAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notificationReadAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationReadAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notificationReadAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationReadAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationReadAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationReadAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      notificationReadAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationReadAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordRef',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordRef',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordRef',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      recordRefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordRef',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relatedGuid',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relatedGuid',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      relatedGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      reminderAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reminderAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      reminderAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reminderAt',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      reminderAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      reminderAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      reminderAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      reminderAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<PendingAction, PendingAction, QAfterFilterCondition>
      updatedAtBetween(
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

extension PendingActionQueryObject
    on QueryBuilder<PendingAction, PendingAction, QFilterCondition> {}

extension PendingActionQueryLinks
    on QueryBuilder<PendingAction, PendingAction, QFilterCondition> {}

extension PendingActionQuerySortBy
    on QueryBuilder<PendingAction, PendingAction, QSortBy> {
  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByDedupeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupeKey', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByDedupeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupeKey', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByDeepLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepLink', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByDeepLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepLink', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByDismissedReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissedReason', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByDismissedReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissedReason', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByExpectedAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByExpectedAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByExpectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByExpectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByExpectedMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedMonth', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByExpectedMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedMonth', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByFeature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feature', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByFeatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feature', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByLastNotifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNotifiedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByLastNotifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNotifiedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByNextAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAction', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByNextActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAction', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByNotificationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationCount', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByNotificationCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationCount', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByNotificationReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationReadAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByNotificationReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationReadAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByRecordRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordRef', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByRecordRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordRef', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByRelatedGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedGuid', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByRelatedGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedGuid', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByReminderAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByReminderAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PendingActionQuerySortThenBy
    on QueryBuilder<PendingAction, PendingAction, QSortThenBy> {
  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByDedupeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupeKey', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByDedupeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dedupeKey', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByDeepLink() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepLink', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByDeepLinkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepLink', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByDismissedReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissedReason', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByDismissedReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dismissedReason', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByExpectedAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByExpectedAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByExpectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByExpectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByExpectedMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedMonth', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByExpectedMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedMonth', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByFeature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feature', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByFeatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feature', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByLastNotifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNotifiedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByLastNotifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNotifiedAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByNextAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAction', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByNextActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAction', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByNotificationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationCount', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByNotificationCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationCount', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByNotificationReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationReadAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByNotificationReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationReadAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByRecordRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordRef', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByRecordRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordRef', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByRelatedGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedGuid', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByRelatedGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedGuid', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByReminderAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByReminderAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderAt', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PendingActionQueryWhereDistinct
    on QueryBuilder<PendingAction, PendingAction, QDistinct> {
  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByActionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByDedupeKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dedupeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByDeepLink(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deepLink', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct>
      distinctByDismissedReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dismissedReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct>
      distinctByExpectedAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedAmountMinor');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByExpectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedAt');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByExpectedMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByFeature(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feature', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct>
      distinctByLastNotifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastNotifiedAt');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByNextAction(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextAction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct>
      distinctByNotificationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationCount');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct>
      distinctByNotificationReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationReadAt');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByRecordRef(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordRef', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByRelatedGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByReminderAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderAt');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingAction, PendingAction, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PendingActionQueryProperty
    on QueryBuilder<PendingAction, PendingAction, QQueryProperty> {
  QueryBuilder<PendingAction, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PendingAction, String, QQueryOperations> actionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionType');
    });
  }

  QueryBuilder<PendingAction, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<PendingAction, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PendingAction, String?, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<PendingAction, String, QQueryOperations> dedupeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dedupeKey');
    });
  }

  QueryBuilder<PendingAction, String?, QQueryOperations> deepLinkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deepLink');
    });
  }

  QueryBuilder<PendingAction, String?, QQueryOperations>
      dismissedReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dismissedReason');
    });
  }

  QueryBuilder<PendingAction, int?, QQueryOperations>
      expectedAmountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedAmountMinor');
    });
  }

  QueryBuilder<PendingAction, DateTime?, QQueryOperations>
      expectedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedAt');
    });
  }

  QueryBuilder<PendingAction, String?, QQueryOperations>
      expectedMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedMonth');
    });
  }

  QueryBuilder<PendingAction, String, QQueryOperations> featureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feature');
    });
  }

  QueryBuilder<PendingAction, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<PendingAction, DateTime?, QQueryOperations>
      lastNotifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastNotifiedAt');
    });
  }

  QueryBuilder<PendingAction, String, QQueryOperations> nextActionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextAction');
    });
  }

  QueryBuilder<PendingAction, int, QQueryOperations>
      notificationCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationCount');
    });
  }

  QueryBuilder<PendingAction, DateTime?, QQueryOperations>
      notificationReadAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationReadAt');
    });
  }

  QueryBuilder<PendingAction, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<PendingAction, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<PendingAction, String, QQueryOperations> recordRefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordRef');
    });
  }

  QueryBuilder<PendingAction, String?, QQueryOperations> relatedGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedGuid');
    });
  }

  QueryBuilder<PendingAction, DateTime?, QQueryOperations>
      reminderAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderAt');
    });
  }

  QueryBuilder<PendingAction, int?, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<PendingAction, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PendingAction, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<PendingAction, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
