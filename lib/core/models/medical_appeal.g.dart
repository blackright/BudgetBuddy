// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_appeal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicalAppealCollection on Isar {
  IsarCollection<MedicalAppeal> get medicalAppeals => this.collection();
}

const MedicalAppealSchema = CollectionSchema(
  name: r'MedicalAppeal',
  id: 3155541290347759330,
  properties: {
    r'actorId': PropertySchema(
      id: 0,
      name: r'actorId',
      type: IsarType.long,
    ),
    r'billGuid': PropertySchema(
      id: 1,
      name: r'billGuid',
      type: IsarType.string,
    ),
    r'decidedAt': PropertySchema(
      id: 2,
      name: r'decidedAt',
      type: IsarType.dateTime,
    ),
    r'documentPaths': PropertySchema(
      id: 3,
      name: r'documentPaths',
      type: IsarType.stringList,
    ),
    r'expectedResponseAt': PropertySchema(
      id: 4,
      name: r'expectedResponseAt',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 5,
      name: r'notes',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 6,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'outcome': PropertySchema(
      id: 7,
      name: r'outcome',
      type: IsarType.byte,
      enumMap: _MedicalAppealoutcomeEnumValueMap,
    ),
    r'profileId': PropertySchema(
      id: 8,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'recordedAt': PropertySchema(
      id: 9,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'reference': PropertySchema(
      id: 10,
      name: r'reference',
      type: IsarType.string,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 11,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'submittedAt': PropertySchema(
      id: 12,
      name: r'submittedAt',
      type: IsarType.dateTime,
    ),
    r'syncGuid': PropertySchema(
      id: 13,
      name: r'syncGuid',
      type: IsarType.string,
    )
  },
  estimateSize: _medicalAppealEstimateSize,
  serialize: _medicalAppealSerialize,
  deserialize: _medicalAppealDeserialize,
  deserializeProp: _medicalAppealDeserializeProp,
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
  getId: _medicalAppealGetId,
  getLinks: _medicalAppealGetLinks,
  attach: _medicalAppealAttach,
  version: '3.1.0+1',
);

int _medicalAppealEstimateSize(
  MedicalAppeal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.billGuid.length * 3;
  bytesCount += 3 + object.documentPaths.length * 3;
  {
    for (var i = 0; i < object.documentPaths.length; i++) {
      final value = object.documentPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.notes.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  {
    final value = object.reference;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncGuid.length * 3;
  return bytesCount;
}

void _medicalAppealSerialize(
  MedicalAppeal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actorId);
  writer.writeString(offsets[1], object.billGuid);
  writer.writeDateTime(offsets[2], object.decidedAt);
  writer.writeStringList(offsets[3], object.documentPaths);
  writer.writeDateTime(offsets[4], object.expectedResponseAt);
  writer.writeString(offsets[5], object.notes);
  writer.writeString(offsets[6], object.operationIdentity);
  writer.writeByte(offsets[7], object.outcome.index);
  writer.writeLong(offsets[8], object.profileId);
  writer.writeDateTime(offsets[9], object.recordedAt);
  writer.writeString(offsets[10], object.reference);
  writer.writeLong(offsets[11], object.sharedSpaceId);
  writer.writeDateTime(offsets[12], object.submittedAt);
  writer.writeString(offsets[13], object.syncGuid);
}

MedicalAppeal _medicalAppealDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalAppeal();
  object.actorId = reader.readLong(offsets[0]);
  object.billGuid = reader.readString(offsets[1]);
  object.decidedAt = reader.readDateTimeOrNull(offsets[2]);
  object.documentPaths = reader.readStringList(offsets[3]) ?? [];
  object.expectedResponseAt = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.notes = reader.readString(offsets[5]);
  object.operationIdentity = reader.readString(offsets[6]);
  object.outcome =
      _MedicalAppealoutcomeValueEnumMap[reader.readByteOrNull(offsets[7])] ??
          MedicalAppealOutcome.pending;
  object.profileId = reader.readLongOrNull(offsets[8]);
  object.recordedAt = reader.readDateTime(offsets[9]);
  object.reference = reader.readStringOrNull(offsets[10]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[11]);
  object.submittedAt = reader.readDateTime(offsets[12]);
  object.syncGuid = reader.readString(offsets[13]);
  return object;
}

P _medicalAppealDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (_MedicalAppealoutcomeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalAppealOutcome.pending) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MedicalAppealoutcomeEnumValueMap = {
  'pending': 0,
  'approved': 1,
  'rejected': 2,
};
const _MedicalAppealoutcomeValueEnumMap = {
  0: MedicalAppealOutcome.pending,
  1: MedicalAppealOutcome.approved,
  2: MedicalAppealOutcome.rejected,
};

Id _medicalAppealGetId(MedicalAppeal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicalAppealGetLinks(MedicalAppeal object) {
  return [];
}

void _medicalAppealAttach(
    IsarCollection<dynamic> col, Id id, MedicalAppeal object) {
  object.id = id;
}

extension MedicalAppealByIndex on IsarCollection<MedicalAppeal> {
  Future<MedicalAppeal?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  MedicalAppeal? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<MedicalAppeal?>> getAllBySyncGuid(List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<MedicalAppeal?> getAllBySyncGuidSync(List<String> syncGuidValues) {
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

  Future<Id> putBySyncGuid(MedicalAppeal object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(MedicalAppeal object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<MedicalAppeal> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<MedicalAppeal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }

  Future<MedicalAppeal?> getByOperationIdentity(String operationIdentity) {
    return getByIndex(r'operationIdentity', [operationIdentity]);
  }

  MedicalAppeal? getByOperationIdentitySync(String operationIdentity) {
    return getByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<bool> deleteByOperationIdentity(String operationIdentity) {
    return deleteByIndex(r'operationIdentity', [operationIdentity]);
  }

  bool deleteByOperationIdentitySync(String operationIdentity) {
    return deleteByIndexSync(r'operationIdentity', [operationIdentity]);
  }

  Future<List<MedicalAppeal?>> getAllByOperationIdentity(
      List<String> operationIdentityValues) {
    final values = operationIdentityValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationIdentity', values);
  }

  List<MedicalAppeal?> getAllByOperationIdentitySync(
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

  Future<Id> putByOperationIdentity(MedicalAppeal object) {
    return putByIndex(r'operationIdentity', object);
  }

  Id putByOperationIdentitySync(MedicalAppeal object, {bool saveLinks = true}) {
    return putByIndexSync(r'operationIdentity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationIdentity(List<MedicalAppeal> objects) {
    return putAllByIndex(r'operationIdentity', objects);
  }

  List<Id> putAllByOperationIdentitySync(List<MedicalAppeal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationIdentity', objects,
        saveLinks: saveLinks);
  }
}

extension MedicalAppealQueryWhereSort
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QWhere> {
  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhere> anySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId'),
      );
    });
  }
}

extension MedicalAppealQueryWhere
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QWhereClause> {
  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause> idBetween(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause> syncGuidEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause> billGuidEqualTo(
      String billGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'billGuid',
        value: [billGuid],
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
      profileIdEqualTo(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
      sharedSpaceIdEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
      operationIdentityEqualTo(String operationIdentity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationIdentity',
        value: [operationIdentity],
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterWhereClause>
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

extension MedicalAppealQueryFilter
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QFilterCondition> {
  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      actorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      billGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'billGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      billGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'billGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      billGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      billGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      decidedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'decidedAt',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      decidedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'decidedAt',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      decidedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      decidedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'decidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      decidedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'decidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      decidedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'decidedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementEqualTo(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementGreaterThan(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementLessThan(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementBetween(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementStartsWith(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementEndsWith(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsLengthEqualTo(int length) {
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsIsEmpty() {
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsIsNotEmpty() {
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsLengthLessThan(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsLengthGreaterThan(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      documentPathsLengthBetween(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      expectedResponseAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedResponseAt',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      expectedResponseAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedResponseAt',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      expectedResponseAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedResponseAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      expectedResponseAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedResponseAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      expectedResponseAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedResponseAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      expectedResponseAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedResponseAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      outcomeEqualTo(MedicalAppealOutcome value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outcome',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      outcomeGreaterThan(
    MedicalAppealOutcome value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outcome',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      outcomeLessThan(
    MedicalAppealOutcome value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outcome',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      outcomeBetween(
    MedicalAppealOutcome lower,
    MedicalAppealOutcome upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outcome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reference',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reference',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceEqualTo(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceGreaterThan(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceLessThan(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceBetween(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceStartsWith(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceEndsWith(
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reference',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      referenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reference',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      submittedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      submittedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      submittedAtLessThan(
    DateTime value, {
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      submittedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
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

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }
}

extension MedicalAppealQueryObject
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QFilterCondition> {}

extension MedicalAppealQueryLinks
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QFilterCondition> {}

extension MedicalAppealQuerySortBy
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QSortBy> {
  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByDecidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decidedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByDecidedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decidedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByExpectedResponseAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedResponseAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByExpectedResponseAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedResponseAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortByReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reference', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortByReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reference', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }
}

extension MedicalAppealQuerySortThenBy
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QSortThenBy> {
  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByDecidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decidedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByDecidedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decidedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByExpectedResponseAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedResponseAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByExpectedResponseAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedResponseAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenByReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reference', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenByReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reference', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy> thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }
}

extension MedicalAppealQueryWhereDistinct
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> {
  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctByBillGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctByDecidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decidedAt');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct>
      distinctByDocumentPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentPaths');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct>
      distinctByExpectedResponseAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedResponseAt');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outcome');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctByReference(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reference', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct>
      distinctBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submittedAt');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppeal, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }
}

extension MedicalAppealQueryProperty
    on QueryBuilder<MedicalAppeal, MedicalAppeal, QQueryProperty> {
  QueryBuilder<MedicalAppeal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicalAppeal, int, QQueryOperations> actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<MedicalAppeal, String, QQueryOperations> billGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billGuid');
    });
  }

  QueryBuilder<MedicalAppeal, DateTime?, QQueryOperations> decidedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decidedAt');
    });
  }

  QueryBuilder<MedicalAppeal, List<String>, QQueryOperations>
      documentPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentPaths');
    });
  }

  QueryBuilder<MedicalAppeal, DateTime?, QQueryOperations>
      expectedResponseAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedResponseAt');
    });
  }

  QueryBuilder<MedicalAppeal, String, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<MedicalAppeal, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<MedicalAppeal, MedicalAppealOutcome, QQueryOperations>
      outcomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outcome');
    });
  }

  QueryBuilder<MedicalAppeal, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MedicalAppeal, DateTime, QQueryOperations> recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<MedicalAppeal, String?, QQueryOperations> referenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reference');
    });
  }

  QueryBuilder<MedicalAppeal, int?, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalAppeal, DateTime, QQueryOperations>
      submittedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submittedAt');
    });
  }

  QueryBuilder<MedicalAppeal, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }
}
