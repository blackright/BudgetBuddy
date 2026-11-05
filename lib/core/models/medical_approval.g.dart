// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_approval.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicalApprovalCollection on Isar {
  IsarCollection<MedicalApproval> get medicalApprovals => this.collection();
}

const MedicalApprovalSchema = CollectionSchema(
  name: r'MedicalApproval',
  id: 1618267117561791312,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'appealGuid': PropertySchema(
      id: 1,
      name: r'appealGuid',
      type: IsarType.string,
    ),
    r'approvedBillMinor': PropertySchema(
      id: 2,
      name: r'approvedBillMinor',
      type: IsarType.long,
    ),
    r'approvedInsuranceMinor': PropertySchema(
      id: 3,
      name: r'approvedInsuranceMinor',
      type: IsarType.long,
    ),
    r'approvedMinor': PropertySchema(
      id: 4,
      name: r'approvedMinor',
      type: IsarType.long,
    ),
    r'approvedShareMinor': PropertySchema(
      id: 5,
      name: r'approvedShareMinor',
      type: IsarType.long,
    ),
    r'basisJson': PropertySchema(
      id: 6,
      name: r'basisJson',
      type: IsarType.string,
    ),
    r'billGuid': PropertySchema(
      id: 7,
      name: r'billGuid',
      type: IsarType.string,
    ),
    r'currency': PropertySchema(
      id: 8,
      name: r'currency',
      type: IsarType.string,
    ),
    r'decisionDate': PropertySchema(
      id: 9,
      name: r'decisionDate',
      type: IsarType.dateTime,
    ),
    r'expectedBillMinor': PropertySchema(
      id: 10,
      name: r'expectedBillMinor',
      type: IsarType.long,
    ),
    r'expectedInsuranceMinor': PropertySchema(
      id: 11,
      name: r'expectedInsuranceMinor',
      type: IsarType.long,
    ),
    r'expectedShareMinor': PropertySchema(
      id: 12,
      name: r'expectedShareMinor',
      type: IsarType.long,
    ),
    r'inputFingerprint': PropertySchema(
      id: 13,
      name: r'inputFingerprint',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 14,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'previousGuid': PropertySchema(
      id: 15,
      name: r'previousGuid',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 16,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'recordedAt': PropertySchema(
      id: 17,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'revision': PropertySchema(
      id: 18,
      name: r'revision',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 19,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'syncGuid': PropertySchema(
      id: 20,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 21,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _medicalApprovalEstimateSize,
  serialize: _medicalApprovalSerialize,
  deserialize: _medicalApprovalDeserialize,
  deserializeProp: _medicalApprovalDeserializeProp,
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
  getId: _medicalApprovalGetId,
  getLinks: _medicalApprovalGetLinks,
  attach: _medicalApprovalAttach,
  version: '3.1.0+1',
);

int _medicalApprovalEstimateSize(
  MedicalApproval object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.appealGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.basisJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.billGuid.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.inputFingerprint.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  {
    final value = object.previousGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _medicalApprovalSerialize(
  MedicalApproval object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeString(offsets[1], object.appealGuid);
  writer.writeLong(offsets[2], object.approvedBillMinor);
  writer.writeLong(offsets[3], object.approvedInsuranceMinor);
  writer.writeLong(offsets[4], object.approvedMinor);
  writer.writeLong(offsets[5], object.approvedShareMinor);
  writer.writeString(offsets[6], object.basisJson);
  writer.writeString(offsets[7], object.billGuid);
  writer.writeString(offsets[8], object.currency);
  writer.writeDateTime(offsets[9], object.decisionDate);
  writer.writeLong(offsets[10], object.expectedBillMinor);
  writer.writeLong(offsets[11], object.expectedInsuranceMinor);
  writer.writeLong(offsets[12], object.expectedShareMinor);
  writer.writeString(offsets[13], object.inputFingerprint);
  writer.writeString(offsets[14], object.operationIdentity);
  writer.writeString(offsets[15], object.previousGuid);
  writer.writeLong(offsets[16], object.profileId);
  writer.writeDateTime(offsets[17], object.recordedAt);
  writer.writeLong(offsets[18], object.revision);
  writer.writeLong(offsets[19], object.sharedSpaceId);
  writer.writeString(offsets[20], object.syncGuid);
  writer.writeString(offsets[21], object.yearMonth);
}

MedicalApproval _medicalApprovalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalApproval();
  object.actorId = reader.readLong(offsets[0]);
  object.appealGuid = reader.readStringOrNull(offsets[1]);
  object.approvedBillMinor = reader.readLong(offsets[2]);
  object.approvedInsuranceMinor = reader.readLong(offsets[3]);
  object.approvedMinor = reader.readLong(offsets[4]);
  object.approvedShareMinor = reader.readLong(offsets[5]);
  object.basisJson = reader.readStringOrNull(offsets[6]);
  object.billGuid = reader.readString(offsets[7]);
  object.currency = reader.readString(offsets[8]);
  object.decisionDate = reader.readDateTime(offsets[9]);
  object.expectedBillMinor = reader.readLong(offsets[10]);
  object.expectedInsuranceMinor = reader.readLong(offsets[11]);
  object.expectedShareMinor = reader.readLong(offsets[12]);
  object.id = id;
  object.inputFingerprint = reader.readString(offsets[13]);
  object.operationIdentity = reader.readString(offsets[14]);
  object.previousGuid = reader.readStringOrNull(offsets[15]);
  object.profileId = reader.readLongOrNull(offsets[16]);
  object.recordedAt = reader.readDateTime(offsets[17]);
  object.revision = reader.readLong(offsets[18]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[19]);
  object.syncGuid = reader.readString(offsets[20]);
  object.yearMonth = reader.readString(offsets[21]);
  return object;
}

P _medicalApprovalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicalApprovalGetId(MedicalApproval object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicalApprovalGetLinks(MedicalApproval object) {
  return [];
}

void _medicalApprovalAttach(
    IsarCollection<dynamic> col, Id id, MedicalApproval object) {
  object.id = id;
}

extension MedicalApprovalByIndex on IsarCollection<MedicalApproval> {
  Future<MedicalApproval?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  MedicalApproval? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<MedicalApproval?>> getAllBySyncGuid(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<MedicalApproval?> getAllBySyncGuidSync(List<String> syncGuidValues) {
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

  Future<Id> putBySyncGuid(MedicalApproval object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(MedicalApproval object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<MedicalApproval> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<MedicalApproval> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }

  Future<MedicalApproval?> getByOperationIdentity(String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  MedicalApproval? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<MedicalApproval?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<MedicalApproval?> getAllByOperationIdentitySync(
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

  Future<Id> putByOperationIdentity(MedicalApproval object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(MedicalApproval object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(List<MedicalApproval> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<MedicalApproval> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension MedicalApprovalQueryWhereSort
    on QueryBuilder<MedicalApproval, MedicalApproval, QWhere> {
  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MedicalApprovalQueryWhere
    on QueryBuilder<MedicalApproval, MedicalApproval, QWhereClause> {
  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause> idBetween(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause>
      syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause>
      billGuidEqualTo(String billGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'billGuid',
        value: [billGuid],
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause>
      billGuidNotEqualTo(String billGuid) {
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause>
      operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterWhereClause>
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

extension MedicalApprovalQueryFilter
    on QueryBuilder<MedicalApproval, MedicalApproval, QFilterCondition> {
  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'appealGuid',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'appealGuid',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appealGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appealGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appealGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appealGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appealGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appealGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appealGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appealGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appealGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      appealGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appealGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedBillMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedBillMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedBillMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedBillMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedBillMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedBillMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedBillMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedBillMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedInsuranceMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedInsuranceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedInsuranceMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedInsuranceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedInsuranceMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedInsuranceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedInsuranceMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedInsuranceMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedShareMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedShareMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedShareMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedShareMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedShareMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedShareMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      approvedShareMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedShareMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'basisJson',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'basisJson',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonEqualTo(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonGreaterThan(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonLessThan(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonBetween(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonStartsWith(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonEndsWith(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'basisJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'basisJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'basisJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      basisJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'basisJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidEqualTo(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidGreaterThan(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidLessThan(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidBetween(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidStartsWith(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidEndsWith(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'billGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      billGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      decisionDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decisionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      decisionDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'decisionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      decisionDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'decisionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      decisionDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'decisionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedBillMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedBillMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedBillMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedBillMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedBillMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedBillMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedBillMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedBillMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedInsuranceMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedInsuranceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedInsuranceMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedInsuranceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedInsuranceMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedInsuranceMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedInsuranceMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedInsuranceMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedShareMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedShareMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedShareMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedShareMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedShareMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedShareMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      expectedShareMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedShareMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      inputFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inputFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      inputFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inputFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      inputFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      inputFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousGuid',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousGuid',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      previousGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      recordedAtGreaterThan(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      recordedAtLessThan(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      recordedAtBetween(
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      revisionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revision',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
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

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension MedicalApprovalQueryObject
    on QueryBuilder<MedicalApproval, MedicalApproval, QFilterCondition> {}

extension MedicalApprovalQueryLinks
    on QueryBuilder<MedicalApproval, MedicalApproval, QFilterCondition> {}

extension MedicalApprovalQuerySortBy
    on QueryBuilder<MedicalApproval, MedicalApproval, QSortBy> {
  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy> sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByAppealGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appealGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByAppealGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appealGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByApprovedBillMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBillMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByApprovedBillMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBillMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByApprovedInsuranceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedInsuranceMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByApprovedInsuranceMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedInsuranceMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByApprovedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByApprovedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByApprovedShareMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedShareMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByApprovedShareMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedShareMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByBasisJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'basisJson', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByBasisJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'basisJson', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByDecisionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decisionDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByDecisionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decisionDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByExpectedBillMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedBillMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByExpectedBillMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedBillMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByExpectedInsuranceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedInsuranceMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByExpectedInsuranceMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedInsuranceMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByExpectedShareMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedShareMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByExpectedShareMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedShareMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByPreviousGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByPreviousGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MedicalApprovalQuerySortThenBy
    on QueryBuilder<MedicalApproval, MedicalApproval, QSortThenBy> {
  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy> thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByAppealGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appealGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByAppealGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appealGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByApprovedBillMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBillMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByApprovedBillMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBillMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByApprovedInsuranceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedInsuranceMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByApprovedInsuranceMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedInsuranceMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByApprovedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByApprovedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByApprovedShareMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedShareMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByApprovedShareMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedShareMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByBasisJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'basisJson', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByBasisJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'basisJson', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByDecisionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decisionDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByDecisionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decisionDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByExpectedBillMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedBillMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByExpectedBillMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedBillMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByExpectedInsuranceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedInsuranceMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByExpectedInsuranceMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedInsuranceMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByExpectedShareMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedShareMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByExpectedShareMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedShareMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByPreviousGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByPreviousGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revision', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MedicalApprovalQueryWhereDistinct
    on QueryBuilder<MedicalApproval, MedicalApproval, QDistinct> {
  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByAppealGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appealGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByApprovedBillMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedBillMinor');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByApprovedInsuranceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedInsuranceMinor');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByApprovedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedMinor');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByApprovedShareMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedShareMinor');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct> distinctByBasisJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'basisJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct> distinctByBillGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByDecisionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decisionDate');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByExpectedBillMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedBillMinor');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByExpectedInsuranceMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedInsuranceMinor');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByExpectedShareMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedShareMinor');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByInputFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByPreviousGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctByRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revision');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalApproval, MedicalApproval, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension MedicalApprovalQueryProperty
    on QueryBuilder<MedicalApproval, MedicalApproval, QQueryProperty> {
  QueryBuilder<MedicalApproval, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations> actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<MedicalApproval, String?, QQueryOperations>
      appealGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appealGuid');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations>
      approvedBillMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedBillMinor');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations>
      approvedInsuranceMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedInsuranceMinor');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations> approvedMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedMinor');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations>
      approvedShareMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedShareMinor');
    });
  }

  QueryBuilder<MedicalApproval, String?, QQueryOperations> basisJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'basisJson');
    });
  }

  QueryBuilder<MedicalApproval, String, QQueryOperations> billGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billGuid');
    });
  }

  QueryBuilder<MedicalApproval, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MedicalApproval, DateTime, QQueryOperations>
      decisionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decisionDate');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations>
      expectedBillMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedBillMinor');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations>
      expectedInsuranceMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedInsuranceMinor');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations>
      expectedShareMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedShareMinor');
    });
  }

  QueryBuilder<MedicalApproval, String, QQueryOperations>
      inputFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputFingerprint');
    });
  }

  QueryBuilder<MedicalApproval, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<MedicalApproval, String?, QQueryOperations>
      previousGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousGuid');
    });
  }

  QueryBuilder<MedicalApproval, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MedicalApproval, DateTime, QQueryOperations>
      recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<MedicalApproval, int, QQueryOperations> revisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revision');
    });
  }

  QueryBuilder<MedicalApproval, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalApproval, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<MedicalApproval, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicalClaimClosureCollection on Isar {
  IsarCollection<MedicalClaimClosure> get medicalClaimClosures =>
      this.collection();
}

const MedicalClaimClosureSchema = CollectionSchema(
  name: r'MedicalClaimClosure',
  id: 8410748775550302044,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'approvalGuid': PropertySchema(
      id: 1,
      name: r'approvalGuid',
      type: IsarType.string,
    ),
    r'billGuid': PropertySchema(
      id: 2,
      name: r'billGuid',
      type: IsarType.string,
    ),
    r'currency': PropertySchema(
      id: 3,
      name: r'currency',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 4,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 5,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(
      id: 6,
      name: r'reason',
      type: IsarType.string,
    ),
    r'receivedMinor': PropertySchema(
      id: 7,
      name: r'receivedMinor',
      type: IsarType.long,
    ),
    r'recordedAt': PropertySchema(
      id: 8,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 9,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'shortfallMinor': PropertySchema(
      id: 10,
      name: r'shortfallMinor',
      type: IsarType.long,
    ),
    r'syncGuid': PropertySchema(
      id: 11,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 12,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _medicalClaimClosureEstimateSize,
  serialize: _medicalClaimClosureSerialize,
  deserialize: _medicalClaimClosureDeserialize,
  deserializeProp: _medicalClaimClosureDeserializeProp,
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
  getId: _medicalClaimClosureGetId,
  getLinks: _medicalClaimClosureGetLinks,
  attach: _medicalClaimClosureAttach,
  version: '3.1.0+1',
);

int _medicalClaimClosureEstimateSize(
  MedicalClaimClosure object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.approvalGuid.length * 3;
  bytesCount += 3 + object.billGuid.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _medicalClaimClosureSerialize(
  MedicalClaimClosure object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeString(offsets[1], object.approvalGuid);
  writer.writeString(offsets[2], object.billGuid);
  writer.writeString(offsets[3], object.currency);
  writer.writeString(offsets[4], object.operationIdentity);
  writer.writeLong(offsets[5], object.profileId);
  writer.writeString(offsets[6], object.reason);
  writer.writeLong(offsets[7], object.receivedMinor);
  writer.writeDateTime(offsets[8], object.recordedAt);
  writer.writeLong(offsets[9], object.sharedSpaceId);
  writer.writeLong(offsets[10], object.shortfallMinor);
  writer.writeString(offsets[11], object.syncGuid);
  writer.writeString(offsets[12], object.yearMonth);
}

MedicalClaimClosure _medicalClaimClosureDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalClaimClosure();
  object.actorId = reader.readLong(offsets[0]);
  object.approvalGuid = reader.readString(offsets[1]);
  object.billGuid = reader.readString(offsets[2]);
  object.currency = reader.readString(offsets[3]);
  object.id = id;
  object.operationIdentity = reader.readString(offsets[4]);
  object.profileId = reader.readLongOrNull(offsets[5]);
  object.reason = reader.readString(offsets[6]);
  object.receivedMinor = reader.readLong(offsets[7]);
  object.recordedAt = reader.readDateTime(offsets[8]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[9]);
  object.shortfallMinor = reader.readLong(offsets[10]);
  object.syncGuid = reader.readString(offsets[11]);
  object.yearMonth = reader.readString(offsets[12]);
  return object;
}

P _medicalClaimClosureDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicalClaimClosureGetId(MedicalClaimClosure object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicalClaimClosureGetLinks(
    MedicalClaimClosure object) {
  return [];
}

void _medicalClaimClosureAttach(
    IsarCollection<dynamic> col, Id id, MedicalClaimClosure object) {
  object.id = id;
}

extension MedicalClaimClosureByIndex on IsarCollection<MedicalClaimClosure> {
  Future<MedicalClaimClosure?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  MedicalClaimClosure? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<MedicalClaimClosure?>> getAllBySyncGuid(
      List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<MedicalClaimClosure?> getAllBySyncGuidSync(List<String> syncGuidValues) {
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

  Future<Id> putBySyncGuid(MedicalClaimClosure object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(MedicalClaimClosure object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<MedicalClaimClosure> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<MedicalClaimClosure> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }

  Future<MedicalClaimClosure?> getByOperationIdentity(
      String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  MedicalClaimClosure? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<MedicalClaimClosure?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<MedicalClaimClosure?> getAllByOperationIdentitySync(
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

  Future<Id> putByOperationIdentity(MedicalClaimClosure object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(MedicalClaimClosure object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(
      List<MedicalClaimClosure> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<MedicalClaimClosure> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension MedicalClaimClosureQueryWhereSort
    on QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QWhere> {
  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MedicalClaimClosureQueryWhere
    on QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QWhereClause> {
  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
      syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
      billGuidEqualTo(String billGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'billGuid',
        value: [billGuid],
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
      billGuidNotEqualTo(String billGuid) {
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
      operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterWhereClause>
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

extension MedicalClaimClosureQueryFilter on QueryBuilder<MedicalClaimClosure,
    MedicalClaimClosure, QFilterCondition> {
  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvalGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'approvalGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvalGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      approvalGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'approvalGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidEqualTo(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidGreaterThan(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidLessThan(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidBetween(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidStartsWith(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidEndsWith(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'billGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      billGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonEqualTo(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonGreaterThan(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonLessThan(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonBetween(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonStartsWith(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonEndsWith(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      receivedMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receivedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      receivedMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receivedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      receivedMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receivedMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      receivedMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receivedMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      recordedAtGreaterThan(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      recordedAtLessThan(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      recordedAtBetween(
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      shortfallMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortfallMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      shortfallMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shortfallMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      shortfallMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shortfallMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      shortfallMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shortfallMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
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

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension MedicalClaimClosureQueryObject on QueryBuilder<MedicalClaimClosure,
    MedicalClaimClosure, QFilterCondition> {}

extension MedicalClaimClosureQueryLinks on QueryBuilder<MedicalClaimClosure,
    MedicalClaimClosure, QFilterCondition> {}

extension MedicalClaimClosureQuerySortBy
    on QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QSortBy> {
  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByApprovalGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByApprovalGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByReceivedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByReceivedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByShortfallMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortfallMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByShortfallMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortfallMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MedicalClaimClosureQuerySortThenBy
    on QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QSortThenBy> {
  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByApprovalGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByApprovalGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByReceivedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByReceivedMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByShortfallMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortfallMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByShortfallMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortfallMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MedicalClaimClosureQueryWhereDistinct
    on QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct> {
  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByApprovalGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvalGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByBillGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByReceivedMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedMinor');
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByShortfallMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shortfallMinor');
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctBySyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QDistinct>
      distinctByYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension MedicalClaimClosureQueryProperty
    on QueryBuilder<MedicalClaimClosure, MedicalClaimClosure, QQueryProperty> {
  QueryBuilder<MedicalClaimClosure, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicalClaimClosure, int, QQueryOperations> actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<MedicalClaimClosure, String, QQueryOperations>
      approvalGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvalGuid');
    });
  }

  QueryBuilder<MedicalClaimClosure, String, QQueryOperations>
      billGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billGuid');
    });
  }

  QueryBuilder<MedicalClaimClosure, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MedicalClaimClosure, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<MedicalClaimClosure, int?, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MedicalClaimClosure, String, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<MedicalClaimClosure, int, QQueryOperations>
      receivedMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedMinor');
    });
  }

  QueryBuilder<MedicalClaimClosure, DateTime, QQueryOperations>
      recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<MedicalClaimClosure, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalClaimClosure, int, QQueryOperations>
      shortfallMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shortfallMinor');
    });
  }

  QueryBuilder<MedicalClaimClosure, String, QQueryOperations>
      syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<MedicalClaimClosure, String, QQueryOperations>
      yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicalClaimActivityCollection on Isar {
  IsarCollection<MedicalClaimActivity> get medicalClaimActivitys =>
      this.collection();
}

const MedicalClaimActivitySchema = CollectionSchema(
  name: r'MedicalClaimActivity',
  id: 1107381398161748059,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'afterJson': PropertySchema(
      id: 1,
      name: r'afterJson',
      type: IsarType.string,
    ),
    r'afterMinor': PropertySchema(
      id: 2,
      name: r'afterMinor',
      type: IsarType.long,
    ),
    r'approvalGuid': PropertySchema(
      id: 3,
      name: r'approvalGuid',
      type: IsarType.string,
    ),
    r'beforeJson': PropertySchema(
      id: 4,
      name: r'beforeJson',
      type: IsarType.string,
    ),
    r'beforeMinor': PropertySchema(
      id: 5,
      name: r'beforeMinor',
      type: IsarType.long,
    ),
    r'billGuid': PropertySchema(
      id: 6,
      name: r'billGuid',
      type: IsarType.string,
    ),
    r'correctedByGuid': PropertySchema(
      id: 7,
      name: r'correctedByGuid',
      type: IsarType.string,
    ),
    r'currency': PropertySchema(
      id: 8,
      name: r'currency',
      type: IsarType.string,
    ),
    r'documentPaths': PropertySchema(
      id: 9,
      name: r'documentPaths',
      type: IsarType.stringList,
    ),
    r'inputFingerprint': PropertySchema(
      id: 10,
      name: r'inputFingerprint',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 11,
      name: r'kind',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 12,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 13,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(
      id: 14,
      name: r'reason',
      type: IsarType.string,
    ),
    r'recordedAt': PropertySchema(
      id: 15,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'reference': PropertySchema(
      id: 16,
      name: r'reference',
      type: IsarType.string,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 17,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'submittedAt': PropertySchema(
      id: 18,
      name: r'submittedAt',
      type: IsarType.dateTime,
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
    r'yearMonth': PropertySchema(
      id: 21,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _medicalClaimActivityEstimateSize,
  serialize: _medicalClaimActivitySerialize,
  deserialize: _medicalClaimActivityDeserialize,
  deserializeProp: _medicalClaimActivityDeserializeProp,
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
    r'sharedSpaceId': IndexSchema(
      id: 9187801792503633945,
      name: r'sharedSpaceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sharedSpaceId',
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
  getId: _medicalClaimActivityGetId,
  getLinks: _medicalClaimActivityGetLinks,
  attach: _medicalClaimActivityAttach,
  version: '3.1.0+1',
);

int _medicalClaimActivityEstimateSize(
  MedicalClaimActivity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.afterJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.approvalGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.beforeJson;
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
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.documentPaths.length * 3;
  {
    for (var i = 0; i < object.documentPaths.length; i++) {
      final value = object.documentPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.inputFingerprint.length * 3;
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  {
    final value = object.reference;
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
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _medicalClaimActivitySerialize(
  MedicalClaimActivity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeString(offsets[1], object.afterJson);
  writer.writeLong(offsets[2], object.afterMinor);
  writer.writeString(offsets[3], object.approvalGuid);
  writer.writeString(offsets[4], object.beforeJson);
  writer.writeLong(offsets[5], object.beforeMinor);
  writer.writeString(offsets[6], object.billGuid);
  writer.writeString(offsets[7], object.correctedByGuid);
  writer.writeString(offsets[8], object.currency);
  writer.writeStringList(offsets[9], object.documentPaths);
  writer.writeString(offsets[10], object.inputFingerprint);
  writer.writeString(offsets[11], object.kind);
  writer.writeString(offsets[12], object.operationIdentity);
  writer.writeLong(offsets[13], object.profileId);
  writer.writeString(offsets[14], object.reason);
  writer.writeDateTime(offsets[15], object.recordedAt);
  writer.writeString(offsets[16], object.reference);
  writer.writeLong(offsets[17], object.sharedSpaceId);
  writer.writeDateTime(offsets[18], object.submittedAt);
  writer.writeString(offsets[19], object.syncGuid);
  writer.writeString(offsets[20], object.transactionMonth);
  writer.writeString(offsets[21], object.yearMonth);
}

MedicalClaimActivity _medicalClaimActivityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalClaimActivity();
  object.actorId = reader.readLong(offsets[0]);
  object.afterJson = reader.readStringOrNull(offsets[1]);
  object.afterMinor = reader.readLong(offsets[2]);
  object.approvalGuid = reader.readStringOrNull(offsets[3]);
  object.beforeJson = reader.readStringOrNull(offsets[4]);
  object.beforeMinor = reader.readLong(offsets[5]);
  object.billGuid = reader.readString(offsets[6]);
  object.correctedByGuid = reader.readStringOrNull(offsets[7]);
  object.currency = reader.readString(offsets[8]);
  object.documentPaths = reader.readStringList(offsets[9]) ?? [];
  object.id = id;
  object.inputFingerprint = reader.readString(offsets[10]);
  object.kind = reader.readString(offsets[11]);
  object.operationIdentity = reader.readString(offsets[12]);
  object.profileId = reader.readLong(offsets[13]);
  object.reason = reader.readString(offsets[14]);
  object.recordedAt = reader.readDateTime(offsets[15]);
  object.reference = reader.readStringOrNull(offsets[16]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[17]);
  object.submittedAt = reader.readDateTimeOrNull(offsets[18]);
  object.syncGuid = reader.readString(offsets[19]);
  object.transactionMonth = reader.readStringOrNull(offsets[20]);
  object.yearMonth = reader.readString(offsets[21]);
  return object;
}

P _medicalClaimActivityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicalClaimActivityGetId(MedicalClaimActivity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicalClaimActivityGetLinks(
    MedicalClaimActivity object) {
  return [];
}

void _medicalClaimActivityAttach(
    IsarCollection<dynamic> col, Id id, MedicalClaimActivity object) {
  object.id = id;
}

extension MedicalClaimActivityByIndex on IsarCollection<MedicalClaimActivity> {
  Future<MedicalClaimActivity?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  MedicalClaimActivity? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<MedicalClaimActivity?>> getAllBySyncGuid(
      List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<MedicalClaimActivity?> getAllBySyncGuidSync(
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

  Future<Id> putBySyncGuid(MedicalClaimActivity object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(MedicalClaimActivity object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<MedicalClaimActivity> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<MedicalClaimActivity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }

  Future<MedicalClaimActivity?> getByOperationIdentity(
      String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  MedicalClaimActivity? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<MedicalClaimActivity?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<MedicalClaimActivity?> getAllByOperationIdentitySync(
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

  Future<Id> putByOperationIdentity(MedicalClaimActivity object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(MedicalClaimActivity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(
      List<MedicalClaimActivity> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<MedicalClaimActivity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension MedicalClaimActivityQueryWhereSort
    on QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QWhere> {
  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhere>
      anySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId'),
      );
    });
  }
}

extension MedicalClaimActivityQueryWhere
    on QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QWhereClause> {
  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      billGuidEqualTo(String billGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'billGuid',
        value: [billGuid],
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      billGuidNotEqualTo(String billGuid) {
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      sharedSpaceIdEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      sharedSpaceIdNotEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [],
              upper: [sharedSpaceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [sharedSpaceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [sharedSpaceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [],
              upper: [sharedSpaceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      sharedSpaceIdGreaterThan(
    int? sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [sharedSpaceId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      sharedSpaceIdLessThan(
    int? sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [],
        upper: [sharedSpaceId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      sharedSpaceIdBetween(
    int? lowerSharedSpaceId,
    int? upperSharedSpaceId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [lowerSharedSpaceId],
        includeLower: includeLower,
        upper: [upperSharedSpaceId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
      operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterWhereClause>
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

extension MedicalClaimActivityQueryFilter on QueryBuilder<MedicalClaimActivity,
    MedicalClaimActivity, QFilterCondition> {
  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'afterJson',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'afterJson',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'afterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'afterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'afterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'afterJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'afterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'afterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      afterJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'afterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      afterJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'afterJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'afterJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'afterJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'afterMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'afterMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'afterMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> afterMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'afterMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approvalGuid',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approvalGuid',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvalGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      approvalGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'approvalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      approvalGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'approvalGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvalGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> approvalGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'approvalGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'beforeJson',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'beforeJson',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beforeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'beforeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'beforeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'beforeJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'beforeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'beforeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      beforeJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'beforeJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      beforeJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'beforeJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beforeJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'beforeJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beforeMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'beforeMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'beforeMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> beforeMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'beforeMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> billGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> billGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> correctedByGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'correctedByGuid',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> correctedByGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'correctedByGuid',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> correctedByGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctedByGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> correctedByGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correctedByGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> currencyEqualTo(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> currencyGreaterThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> currencyLessThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> currencyBetween(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> documentPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> documentPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> inputFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> inputFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inputFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> kindEqualTo(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> kindGreaterThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> kindLessThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> kindBetween(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> kindStartsWith(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> kindEndsWith(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> profileIdGreaterThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> profileIdLessThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> profileIdBetween(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reference',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reference',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      referenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      referenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reference',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> referenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reference',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> sharedSpaceIdGreaterThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> sharedSpaceIdLessThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> sharedSpaceIdBetween(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> submittedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> submittedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> submittedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> submittedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> submittedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> submittedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'submittedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> transactionMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'transactionMonth',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> transactionMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'transactionMonth',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> transactionMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> transactionMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'transactionMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> yearMonthEqualTo(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> yearMonthGreaterThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> yearMonthLessThan(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> yearMonthBetween(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> yearMonthStartsWith(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> yearMonthEndsWith(
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

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
          QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity,
      QAfterFilterCondition> yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension MedicalClaimActivityQueryObject on QueryBuilder<MedicalClaimActivity,
    MedicalClaimActivity, QFilterCondition> {}

extension MedicalClaimActivityQueryLinks on QueryBuilder<MedicalClaimActivity,
    MedicalClaimActivity, QFilterCondition> {}

extension MedicalClaimActivityQuerySortBy
    on QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QSortBy> {
  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByAfterJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterJson', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByAfterJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterJson', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByAfterMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByAfterMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByApprovalGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByApprovalGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByBeforeJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeJson', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByBeforeJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeJson', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByBeforeMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByBeforeMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByCorrectedByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedByGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByCorrectedByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedByGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reference', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reference', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByTransactionMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByTransactionMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionMonth', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MedicalClaimActivityQuerySortThenBy
    on QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QSortThenBy> {
  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByAfterJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterJson', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByAfterJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterJson', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByAfterMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByAfterMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByApprovalGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByApprovalGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByBeforeJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeJson', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByBeforeJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeJson', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByBeforeMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByBeforeMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforeMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByCorrectedByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedByGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByCorrectedByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedByGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByInputFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByInputFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputFingerprint', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reference', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reference', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByTransactionMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByTransactionMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionMonth', Sort.desc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MedicalClaimActivityQueryWhereDistinct
    on QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct> {
  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByAfterJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'afterJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByAfterMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'afterMinor');
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByApprovalGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvalGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByBeforeJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'beforeJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByBeforeMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'beforeMinor');
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByBillGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByCorrectedByGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctedByGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByDocumentPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentPaths');
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByInputFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByReference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reference', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submittedAt');
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctBySyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByTransactionMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalClaimActivity, MedicalClaimActivity, QDistinct>
      distinctByYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension MedicalClaimActivityQueryProperty on QueryBuilder<
    MedicalClaimActivity, MedicalClaimActivity, QQueryProperty> {
  QueryBuilder<MedicalClaimActivity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicalClaimActivity, int, QQueryOperations> actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<MedicalClaimActivity, String?, QQueryOperations>
      afterJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'afterJson');
    });
  }

  QueryBuilder<MedicalClaimActivity, int, QQueryOperations>
      afterMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'afterMinor');
    });
  }

  QueryBuilder<MedicalClaimActivity, String?, QQueryOperations>
      approvalGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvalGuid');
    });
  }

  QueryBuilder<MedicalClaimActivity, String?, QQueryOperations>
      beforeJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beforeJson');
    });
  }

  QueryBuilder<MedicalClaimActivity, int, QQueryOperations>
      beforeMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beforeMinor');
    });
  }

  QueryBuilder<MedicalClaimActivity, String, QQueryOperations>
      billGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billGuid');
    });
  }

  QueryBuilder<MedicalClaimActivity, String?, QQueryOperations>
      correctedByGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctedByGuid');
    });
  }

  QueryBuilder<MedicalClaimActivity, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MedicalClaimActivity, List<String>, QQueryOperations>
      documentPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentPaths');
    });
  }

  QueryBuilder<MedicalClaimActivity, String, QQueryOperations>
      inputFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputFingerprint');
    });
  }

  QueryBuilder<MedicalClaimActivity, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<MedicalClaimActivity, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<MedicalClaimActivity, int, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MedicalClaimActivity, String, QQueryOperations>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<MedicalClaimActivity, DateTime, QQueryOperations>
      recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<MedicalClaimActivity, String?, QQueryOperations>
      referenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reference');
    });
  }

  QueryBuilder<MedicalClaimActivity, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalClaimActivity, DateTime?, QQueryOperations>
      submittedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submittedAt');
    });
  }

  QueryBuilder<MedicalClaimActivity, String, QQueryOperations>
      syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<MedicalClaimActivity, String?, QQueryOperations>
      transactionMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionMonth');
    });
  }

  QueryBuilder<MedicalClaimActivity, String, QQueryOperations>
      yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
