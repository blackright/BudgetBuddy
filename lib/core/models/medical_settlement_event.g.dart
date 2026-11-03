// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_settlement_event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicalSettlementEventCollection on Isar {
  IsarCollection<MedicalSettlementEvent> get medicalSettlementEvents =>
      this.collection();
}

const MedicalSettlementEventSchema = CollectionSchema(
  name: r'MedicalSettlementEvent',
  id: -1077645506944903882,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'amountMinor': PropertySchema(
      id: 1,
      name: r'amountMinor',
      type: IsarType.long,
    ),
    r'basisJson': PropertySchema(
      id: 2,
      name: r'basisJson',
      type: IsarType.string,
    ),
    r'billGuid': PropertySchema(
      id: 3,
      name: r'billGuid',
      type: IsarType.string,
    ),
    r'confirmed': PropertySchema(
      id: 4,
      name: r'confirmed',
      type: IsarType.bool,
    ),
    r'correctedByGuid': PropertySchema(
      id: 5,
      name: r'correctedByGuid',
      type: IsarType.string,
    ),
    r'currency': PropertySchema(
      id: 6,
      name: r'currency',
      type: IsarType.string,
    ),
    r'documentPaths': PropertySchema(
      id: 7,
      name: r'documentPaths',
      type: IsarType.stringList,
    ),
    r'effectiveDate': PropertySchema(
      id: 8,
      name: r'effectiveDate',
      type: IsarType.dateTime,
    ),
    r'expenseGuid': PropertySchema(
      id: 9,
      name: r'expenseGuid',
      type: IsarType.string,
    ),
    r'expenseId': PropertySchema(
      id: 10,
      name: r'expenseId',
      type: IsarType.long,
    ),
    r'inputFingerprint': PropertySchema(
      id: 11,
      name: r'inputFingerprint',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 12,
      name: r'kind',
      type: IsarType.byte,
      enumMap: _MedicalSettlementEventkindEnumValueMap,
    ),
    r'note': PropertySchema(
      id: 13,
      name: r'note',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 14,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 15,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(
      id: 16,
      name: r'reason',
      type: IsarType.string,
    ),
    r'recordedAt': PropertySchema(
      id: 17,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'supersedesGuid': PropertySchema(
      id: 18,
      name: r'supersedesGuid',
      type: IsarType.string,
    ),
    r'syncGuid': PropertySchema(
      id: 19,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'transactionMonth': PropertySchema(
      id: 20,
      name: r'transactionMonth',
      type: IsarType.string,
    ),
    r'withholdingMatchGuid': PropertySchema(
      id: 21,
      name: r'withholdingMatchGuid',
      type: IsarType.string,
    )
  },
  estimateSize: _medicalSettlementEventEstimateSize,
  serialize: _medicalSettlementEventSerialize,
  deserialize: _medicalSettlementEventDeserialize,
  deserializeProp: _medicalSettlementEventDeserializeProp,
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
    r'kind': IndexSchema(
      id: 1484550194077596484,
      name: r'kind',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'kind',
          type: IndexType.value,
          caseSensitive: false,
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
  getId: _medicalSettlementEventGetId,
  getLinks: _medicalSettlementEventGetLinks,
  attach: _medicalSettlementEventAttach,
  version: '3.1.0+1',
);

int _medicalSettlementEventEstimateSize(
  MedicalSettlementEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.basisJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.billGuid.length * 3;
  {
    final value = object.correctedByGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.documentPaths.length * 3;
  {
    for (var i = 0; i < object.documentPaths.length; i++) {
      final value = object.documentPaths[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.expenseGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.inputFingerprint.length * 3;
  bytesCount += 3 + object.note.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  {
    final value = object.supersedesGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncGuid.length * 3;
  {
    final value = object.transactionMonth;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.withholdingMatchGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _medicalSettlementEventSerialize(
  MedicalSettlementEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeLong(offsets[1], object.amountMinor);
  writer.writeString(offsets[2], object.basisJson);
  writer.writeString(offsets[3], object.billGuid);
  writer.writeBool(offsets[4], object.confirmed);
  writer.writeString(offsets[5], object.correctedByGuid);
  writer.writeString(offsets[6], object.currency);
  writer.writeStringList(offsets[7], object.documentPaths);
  writer.writeDateTime(offsets[8], object.effectiveDate);
  writer.writeString(offsets[9], object.expenseGuid);
  writer.writeLong(offsets[10], object.expenseId);
  writer.writeString(offsets[11], object.inputFingerprint);
  writer.writeByte(offsets[12], object.kind.index);
  writer.writeString(offsets[13], object.note);
  writer.writeString(offsets[14], object.operationIdentity);
  writer.writeLong(offsets[15], object.profileId);
  writer.writeString(offsets[16], object.reason);
  writer.writeDateTime(offsets[17], object.recordedAt);
  writer.writeString(offsets[18], object.supersedesGuid);
  writer.writeString(offsets[19], object.syncGuid);
  writer.writeString(offsets[20], object.transactionMonth);
  writer.writeString(offsets[21], object.withholdingMatchGuid);
}

MedicalSettlementEvent _medicalSettlementEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalSettlementEvent();
  object.actorId = reader.readLong(offsets[0]);
  object.amountMinor = reader.readLong(offsets[1]);
  object.basisJson = reader.readStringOrNull(offsets[2]);
  object.billGuid = reader.readString(offsets[3]);
  object.confirmed = reader.readBool(offsets[4]);
  object.correctedByGuid = reader.readStringOrNull(offsets[5]);
  object.currency = reader.readStringOrNull(offsets[6]);
  object.documentPaths = reader.readStringList(offsets[7]) ?? [];
  object.effectiveDate = reader.readDateTime(offsets[8]);
  object.expenseGuid = reader.readStringOrNull(offsets[9]);
  object.expenseId = reader.readLongOrNull(offsets[10]);
  object.id = id;
  object.inputFingerprint = reader.readString(offsets[11]);
  object.kind = _MedicalSettlementEventkindValueEnumMap[
          reader.readByteOrNull(offsets[12])] ??
      MedicalSettlementKind.insurerProviderSettlement;
  object.note = reader.readString(offsets[13]);
  object.operationIdentity = reader.readString(offsets[14]);
  object.profileId = reader.readLongOrNull(offsets[15]);
  object.reason = reader.readString(offsets[16]);
  object.recordedAt = reader.readDateTime(offsets[17]);
  object.supersedesGuid = reader.readStringOrNull(offsets[18]);
  object.syncGuid = reader.readString(offsets[19]);
  object.transactionMonth = reader.readStringOrNull(offsets[20]);
  object.withholdingMatchGuid = reader.readStringOrNull(offsets[21]);
  return object;
}

P _medicalSettlementEventDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (_MedicalSettlementEventkindValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalSettlementKind.insurerProviderSettlement) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MedicalSettlementEventkindEnumValueMap = {
  'insurerProviderSettlement': 0,
  'shareSettlement': 1,
  'closure': 2,
  'correction': 3,
  'reversal': 4,
  'userProviderPayment': 5,
  'insuranceRefund': 6,
  'salaryDeduction': 7,
  'providerRefund': 8,
};
const _MedicalSettlementEventkindValueEnumMap = {
  0: MedicalSettlementKind.insurerProviderSettlement,
  1: MedicalSettlementKind.shareSettlement,
  2: MedicalSettlementKind.closure,
  3: MedicalSettlementKind.correction,
  4: MedicalSettlementKind.reversal,
  5: MedicalSettlementKind.userProviderPayment,
  6: MedicalSettlementKind.insuranceRefund,
  7: MedicalSettlementKind.salaryDeduction,
  8: MedicalSettlementKind.providerRefund,
};

Id _medicalSettlementEventGetId(MedicalSettlementEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicalSettlementEventGetLinks(
    MedicalSettlementEvent object) {
  return [];
}

void _medicalSettlementEventAttach(
    IsarCollection<dynamic> col, Id id, MedicalSettlementEvent object) {
  object.id = id;
}

extension MedicalSettlementEventByIndex
    on IsarCollection<MedicalSettlementEvent> {
  Future<MedicalSettlementEvent?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  MedicalSettlementEvent? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<MedicalSettlementEvent?>> getAllBySyncGuid(
      List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<MedicalSettlementEvent?> getAllBySyncGuidSync(
      List<String> syncGuidValues) {
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

  Future<Id> putBySyncGuid(MedicalSettlementEvent object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(MedicalSettlementEvent object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<MedicalSettlementEvent> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<MedicalSettlementEvent> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }

  Future<MedicalSettlementEvent?> getByOperationIdentity(
      String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  MedicalSettlementEvent? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<MedicalSettlementEvent?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<MedicalSettlementEvent?> getAllByOperationIdentitySync(
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

  Future<Id> putByOperationIdentity(MedicalSettlementEvent object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(MedicalSettlementEvent object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(
      List<MedicalSettlementEvent> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<MedicalSettlementEvent> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension MedicalSettlementEventQueryWhereSort
    on QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QWhere> {
  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterWhere>
      anyKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'kind'),
      );
    });
  }
}

extension MedicalSettlementEventQueryWhere on QueryBuilder<
    MedicalSettlementEvent, MedicalSettlementEvent, QWhereClause> {
  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> syncGuidNotEqualTo(String syncGuid) {
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> profileIdEqualTo(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> profileIdNotEqualTo(int? profileId) {
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> profileIdGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> profileIdLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> profileIdBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> billGuidEqualTo(String billGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'billGuid',
        value: [billGuid],
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> billGuidNotEqualTo(String billGuid) {
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> kindEqualTo(MedicalSettlementKind kind) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'kind',
        value: [kind],
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> kindNotEqualTo(MedicalSettlementKind kind) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'kind',
              lower: [],
              upper: [kind],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'kind',
              lower: [kind],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'kind',
              lower: [kind],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'kind',
              lower: [],
              upper: [kind],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> kindGreaterThan(
    MedicalSettlementKind kind, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'kind',
        lower: [kind],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> kindLessThan(
    MedicalSettlementKind kind, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'kind',
        lower: [],
        upper: [kind],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> kindBetween(
    MedicalSettlementKind lowerKind,
    MedicalSettlementKind upperKind, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'kind',
        lower: [lowerKind],
        includeLower: includeLower,
        upper: [upperKind],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterWhereClause> operationIdentityNotEqualTo(String operationIdentity) {
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

extension MedicalSettlementEventQueryFilter on QueryBuilder<
    MedicalSettlementEvent, MedicalSettlementEvent, QFilterCondition> {
  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> actorIdGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> actorIdLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> actorIdBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> amountMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> amountMinorGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> amountMinorLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> amountMinorBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'basisJson',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'basisJson',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'basisJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'basisJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'basisJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'basisJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'basisJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'basisJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      basisJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'basisJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      basisJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'basisJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'basisJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> basisJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'basisJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> billGuidEqualTo(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> billGuidGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> billGuidLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> billGuidBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> billGuidStartsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> billGuidEndsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      billGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      billGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'billGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> billGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> billGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> confirmedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmed',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'correctedByGuid',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'correctedByGuid',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctedByGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctedByGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctedByGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctedByGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'correctedByGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'correctedByGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      correctedByGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correctedByGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      correctedByGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'correctedByGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctedByGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> correctedByGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correctedByGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currency',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currency',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyEqualTo(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyStartsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyEndsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      documentPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      documentPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> documentPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documentPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> effectiveDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> effectiveDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> effectiveDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> effectiveDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expenseGuid',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expenseGuid',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expenseGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expenseGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expenseGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'expenseGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'expenseGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      expenseGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'expenseGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      expenseGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'expenseGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'expenseGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expenseId',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expenseId',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> expenseIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expenseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> inputFingerprintEqualTo(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> inputFingerprintGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> inputFingerprintLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> inputFingerprintBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> inputFingerprintStartsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> inputFingerprintEndsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      inputFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      inputFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inputFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> inputFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> inputFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> kindEqualTo(MedicalSettlementKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> kindGreaterThan(
    MedicalSettlementKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> kindLessThan(
    MedicalSettlementKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> kindBetween(
    MedicalSettlementKind lower,
    MedicalSettlementKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> operationIdentityEqualTo(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> operationIdentityGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> operationIdentityLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> operationIdentityBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> operationIdentityStartsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> operationIdentityEndsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> profileIdGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> profileIdLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> profileIdBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> reasonEqualTo(
    String value, {
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> reasonGreaterThan(
    String value, {
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> reasonLessThan(
    String value, {
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> reasonBetween(
    String lower,
    String upper, {
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> reasonStartsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> reasonEndsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> recordedAtGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> recordedAtLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> recordedAtBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supersedesGuid',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supersedesGuid',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supersedesGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supersedesGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supersedesGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supersedesGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supersedesGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supersedesGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      supersedesGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supersedesGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      supersedesGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supersedesGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supersedesGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> supersedesGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supersedesGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> syncGuidEqualTo(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> syncGuidGreaterThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> syncGuidLessThan(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> syncGuidBetween(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> syncGuidStartsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> syncGuidEndsWith(
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

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'transactionMonth',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'transactionMonth',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transactionMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transactionMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transactionMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'transactionMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'transactionMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      transactionMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'transactionMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      transactionMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'transactionMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> transactionMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'transactionMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'withholdingMatchGuid',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'withholdingMatchGuid',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'withholdingMatchGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'withholdingMatchGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'withholdingMatchGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'withholdingMatchGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'withholdingMatchGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'withholdingMatchGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      withholdingMatchGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'withholdingMatchGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
          QAfterFilterCondition>
      withholdingMatchGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'withholdingMatchGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'withholdingMatchGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent,
      QAfterFilterCondition> withholdingMatchGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'withholdingMatchGuid',
        value: '',
      ));
    });
  }
}

extension MedicalSettlementEventQueryObject on QueryBuilder<
    MedicalSettlementEvent, MedicalSettlementEvent, QFilterCondition> {}

extension MedicalSettlementEventQueryLinks on QueryBuilder<
    MedicalSettlementEvent, MedicalSettlementEvent, QFilterCondition> {}

extension MedicalSettlementEventQuerySortBy
    on QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QSortBy> {
  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByBasisJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'basisJson', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByBasisJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'basisJson', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByCorrectedByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedByGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByCorrectedByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedByGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByEffectiveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByEffectiveDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByExpenseGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByExpenseGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortBySupersedesGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersedesGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortBySupersedesGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersedesGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByTransactionMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByTransactionMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionMonth', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByWithholdingMatchGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withholdingMatchGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      sortByWithholdingMatchGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withholdingMatchGuid', Sort.desc);
    });
  }
}

extension MedicalSettlementEventQuerySortThenBy on QueryBuilder<
    MedicalSettlementEvent, MedicalSettlementEvent, QSortThenBy> {
  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByBasisJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'basisJson', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByBasisJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'basisJson', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByCorrectedByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedByGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByCorrectedByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedByGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByEffectiveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByEffectiveDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByExpenseGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByExpenseGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseId', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenBySupersedesGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersedesGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenBySupersedesGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersedesGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByTransactionMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByTransactionMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionMonth', Sort.desc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByWithholdingMatchGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withholdingMatchGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QAfterSortBy>
      thenByWithholdingMatchGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withholdingMatchGuid', Sort.desc);
    });
  }
}

extension MedicalSettlementEventQueryWhereDistinct
    on QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct> {
  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountMinor');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByBasisJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'basisJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByBillGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmed');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByCorrectedByGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctedByGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByDocumentPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentPaths');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByEffectiveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveDate');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByExpenseGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expenseGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expenseId');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByInputFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctBySupersedesGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supersedesGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctBySyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByTransactionMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementEvent, QDistinct>
      distinctByWithholdingMatchGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'withholdingMatchGuid',
          caseSensitive: caseSensitive);
    });
  }
}

extension MedicalSettlementEventQueryProperty on QueryBuilder<
    MedicalSettlementEvent, MedicalSettlementEvent, QQueryProperty> {
  QueryBuilder<MedicalSettlementEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicalSettlementEvent, int, QQueryOperations>
      actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<MedicalSettlementEvent, int, QQueryOperations>
      amountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountMinor');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String?, QQueryOperations>
      basisJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'basisJson');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String, QQueryOperations>
      billGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billGuid');
    });
  }

  QueryBuilder<MedicalSettlementEvent, bool, QQueryOperations>
      confirmedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmed');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String?, QQueryOperations>
      correctedByGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctedByGuid');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String?, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MedicalSettlementEvent, List<String>, QQueryOperations>
      documentPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentPaths');
    });
  }

  QueryBuilder<MedicalSettlementEvent, DateTime, QQueryOperations>
      effectiveDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveDate');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String?, QQueryOperations>
      expenseGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expenseGuid');
    });
  }

  QueryBuilder<MedicalSettlementEvent, int?, QQueryOperations>
      expenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expenseId');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String, QQueryOperations>
      inputFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputFingerprint');
    });
  }

  QueryBuilder<MedicalSettlementEvent, MedicalSettlementKind, QQueryOperations>
      kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String, QQueryOperations>
      noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<MedicalSettlementEvent, int?, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String, QQueryOperations>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<MedicalSettlementEvent, DateTime, QQueryOperations>
      recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String?, QQueryOperations>
      supersedesGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supersedesGuid');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String, QQueryOperations>
      syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String?, QQueryOperations>
      transactionMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionMonth');
    });
  }

  QueryBuilder<MedicalSettlementEvent, String?, QQueryOperations>
      withholdingMatchGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'withholdingMatchGuid');
    });
  }
}
