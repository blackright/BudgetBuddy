// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_evidence_chunk.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExpenseEvidenceChunkCollection on Isar {
  IsarCollection<ExpenseEvidenceChunk> get expenseEvidenceChunks =>
      this.collection();
}

const ExpenseEvidenceChunkSchema = CollectionSchema(
  name: r'ExpenseEvidenceChunk',
  id: 6391400486044484449,
  properties: {
    r'byteLength': PropertySchema(
      id: 0,
      name: r'byteLength',
      type: IsarType.long,
    ),
    r'bytes': PropertySchema(
      id: 1,
      name: r'bytes',
      type: IsarType.byteList,
    ),
    r'chunkCount': PropertySchema(
      id: 2,
      name: r'chunkCount',
      type: IsarType.long,
    ),
    r'chunkIndex': PropertySchema(
      id: 3,
      name: r'chunkIndex',
      type: IsarType.long,
    ),
    r'documentGuid': PropertySchema(
      id: 4,
      name: r'documentGuid',
      type: IsarType.string,
    ),
    r'expenseSyncGuid': PropertySchema(
      id: 5,
      name: r'expenseSyncGuid',
      type: IsarType.string,
    ),
    r'fileName': PropertySchema(
      id: 6,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'mediaType': PropertySchema(
      id: 7,
      name: r'mediaType',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 8,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'role': PropertySchema(
      id: 9,
      name: r'role',
      type: IsarType.string,
    ),
    r'sha256': PropertySchema(
      id: 10,
      name: r'sha256',
      type: IsarType.string,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 11,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'syncGuid': PropertySchema(
      id: 12,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 13,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _expenseEvidenceChunkEstimateSize,
  serialize: _expenseEvidenceChunkSerialize,
  deserialize: _expenseEvidenceChunkDeserialize,
  deserializeProp: _expenseEvidenceChunkDeserializeProp,
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
    r'documentGuid': IndexSchema(
      id: 4239097252357399204,
      name: r'documentGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'expenseSyncGuid': IndexSchema(
      id: 2159571954537220751,
      name: r'expenseSyncGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'expenseSyncGuid',
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _expenseEvidenceChunkGetId,
  getLinks: _expenseEvidenceChunkGetLinks,
  attach: _expenseEvidenceChunkAttach,
  version: '3.1.0+1',
);

int _expenseEvidenceChunkEstimateSize(
  ExpenseEvidenceChunk object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bytes.length;
  bytesCount += 3 + object.documentGuid.length * 3;
  bytesCount += 3 + object.expenseSyncGuid.length * 3;
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.mediaType.length * 3;
  bytesCount += 3 + object.role.length * 3;
  bytesCount += 3 + object.sha256.length * 3;
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _expenseEvidenceChunkSerialize(
  ExpenseEvidenceChunk object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.byteLength);
  writer.writeByteList(offsets[1], object.bytes);
  writer.writeLong(offsets[2], object.chunkCount);
  writer.writeLong(offsets[3], object.chunkIndex);
  writer.writeString(offsets[4], object.documentGuid);
  writer.writeString(offsets[5], object.expenseSyncGuid);
  writer.writeString(offsets[6], object.fileName);
  writer.writeString(offsets[7], object.mediaType);
  writer.writeLong(offsets[8], object.profileId);
  writer.writeString(offsets[9], object.role);
  writer.writeString(offsets[10], object.sha256);
  writer.writeLong(offsets[11], object.sharedSpaceId);
  writer.writeString(offsets[12], object.syncGuid);
  writer.writeString(offsets[13], object.yearMonth);
}

ExpenseEvidenceChunk _expenseEvidenceChunkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExpenseEvidenceChunk();
  object.byteLength = reader.readLong(offsets[0]);
  object.bytes = reader.readByteList(offsets[1]) ?? [];
  object.chunkCount = reader.readLong(offsets[2]);
  object.chunkIndex = reader.readLong(offsets[3]);
  object.documentGuid = reader.readString(offsets[4]);
  object.expenseSyncGuid = reader.readString(offsets[5]);
  object.fileName = reader.readString(offsets[6]);
  object.id = id;
  object.mediaType = reader.readString(offsets[7]);
  object.profileId = reader.readLong(offsets[8]);
  object.role = reader.readString(offsets[9]);
  object.sha256 = reader.readString(offsets[10]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[11]);
  object.syncGuid = reader.readString(offsets[12]);
  object.yearMonth = reader.readString(offsets[13]);
  return object;
}

P _expenseEvidenceChunkDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readByteList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _expenseEvidenceChunkGetId(ExpenseEvidenceChunk object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _expenseEvidenceChunkGetLinks(
    ExpenseEvidenceChunk object) {
  return [];
}

void _expenseEvidenceChunkAttach(
    IsarCollection<dynamic> col, Id id, ExpenseEvidenceChunk object) {
  object.id = id;
}

extension ExpenseEvidenceChunkByIndex on IsarCollection<ExpenseEvidenceChunk> {
  Future<ExpenseEvidenceChunk?> getBySyncGuid(String syncGuid) {
    return getByIndex(r'syncGuid', [syncGuid]);
  }

  ExpenseEvidenceChunk? getBySyncGuidSync(String syncGuid) {
    return getByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<bool> deleteBySyncGuid(String syncGuid) {
    return deleteByIndex(r'syncGuid', [syncGuid]);
  }

  bool deleteBySyncGuidSync(String syncGuid) {
    return deleteByIndexSync(r'syncGuid', [syncGuid]);
  }

  Future<List<ExpenseEvidenceChunk?>> getAllBySyncGuid(
      List<String> syncGuidValues) {
    final values = syncGuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncGuid', values);
  }

  List<ExpenseEvidenceChunk?> getAllBySyncGuidSync(
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

  Future<Id> putBySyncGuid(ExpenseEvidenceChunk object) {
    return putByIndex(r'syncGuid', object);
  }

  Id putBySyncGuidSync(ExpenseEvidenceChunk object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncGuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncGuid(List<ExpenseEvidenceChunk> objects) {
    return putAllByIndex(r'syncGuid', objects);
  }

  List<Id> putAllBySyncGuidSync(List<ExpenseEvidenceChunk> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncGuid', objects, saveLinks: saveLinks);
  }
}

extension ExpenseEvidenceChunkQueryWhereSort
    on QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QWhere> {
  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhere>
      anySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId'),
      );
    });
  }
}

extension ExpenseEvidenceChunkQueryWhere
    on QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QWhereClause> {
  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      syncGuidEqualTo(String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      documentGuidEqualTo(String documentGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentGuid',
        value: [documentGuid],
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      documentGuidNotEqualTo(String documentGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentGuid',
              lower: [],
              upper: [documentGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentGuid',
              lower: [documentGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentGuid',
              lower: [documentGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentGuid',
              lower: [],
              upper: [documentGuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      expenseSyncGuidEqualTo(String expenseSyncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'expenseSyncGuid',
        value: [expenseSyncGuid],
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      expenseSyncGuidNotEqualTo(String expenseSyncGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseSyncGuid',
              lower: [],
              upper: [expenseSyncGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseSyncGuid',
              lower: [expenseSyncGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseSyncGuid',
              lower: [expenseSyncGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'expenseSyncGuid',
              lower: [],
              upper: [expenseSyncGuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      profileIdNotEqualTo(int profileId) {
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      profileIdGreaterThan(
    int profileId, {
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      profileIdLessThan(
    int profileId, {
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      profileIdBetween(
    int lowerProfileId,
    int upperProfileId, {
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
      sharedSpaceIdEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterWhereClause>
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
}

extension ExpenseEvidenceChunkQueryFilter on QueryBuilder<ExpenseEvidenceChunk,
    ExpenseEvidenceChunk, QFilterCondition> {
  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> byteLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'byteLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> byteLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'byteLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> byteLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'byteLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> byteLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'byteLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bytes',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bytes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bytes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bytes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bytes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bytes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> bytesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bytes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> chunkCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chunkCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> chunkCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chunkCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> chunkCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chunkCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> chunkCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chunkCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> chunkIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chunkIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> chunkIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chunkIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> chunkIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chunkIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> chunkIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chunkIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> documentGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> documentGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> documentGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> documentGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> documentGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> documentGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      documentGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      documentGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> documentGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> documentGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> expenseSyncGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> expenseSyncGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expenseSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> expenseSyncGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expenseSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> expenseSyncGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expenseSyncGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> expenseSyncGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'expenseSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> expenseSyncGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'expenseSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      expenseSyncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'expenseSyncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      expenseSyncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'expenseSyncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> expenseSyncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expenseSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> expenseSyncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'expenseSyncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> fileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> mediaTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> mediaTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> mediaTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> mediaTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> mediaTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> mediaTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      mediaTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      mediaTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> mediaTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaType',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> mediaTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaType',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> roleEqualTo(
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> roleGreaterThan(
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> roleLessThan(
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> roleBetween(
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> roleStartsWith(
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> roleEndsWith(
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      roleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      roleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'role',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> roleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> roleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sha256EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sha256GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sha256LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sha256Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sha256',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sha256StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sha256EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      sha256Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
          QAfterFilterCondition>
      sha256Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sha256',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sha256IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sha256',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sha256IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sha256',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
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

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk,
      QAfterFilterCondition> yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension ExpenseEvidenceChunkQueryObject on QueryBuilder<ExpenseEvidenceChunk,
    ExpenseEvidenceChunk, QFilterCondition> {}

extension ExpenseEvidenceChunkQueryLinks on QueryBuilder<ExpenseEvidenceChunk,
    ExpenseEvidenceChunk, QFilterCondition> {}

extension ExpenseEvidenceChunkQuerySortBy
    on QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QSortBy> {
  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByByteLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byteLength', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByByteLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byteLength', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByChunkCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkCount', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByChunkCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkCount', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByChunkIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkIndex', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByChunkIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkIndex', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByDocumentGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentGuid', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByDocumentGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentGuid', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByExpenseSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByExpenseSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortBySha256() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sha256', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortBySha256Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sha256', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension ExpenseEvidenceChunkQuerySortThenBy
    on QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QSortThenBy> {
  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByByteLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byteLength', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByByteLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byteLength', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByChunkCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkCount', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByChunkCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkCount', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByChunkIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkIndex', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByChunkIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkIndex', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByDocumentGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentGuid', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByDocumentGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentGuid', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByExpenseSyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseSyncGuid', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByExpenseSyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expenseSyncGuid', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenBySha256() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sha256', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenBySha256Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sha256', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension ExpenseEvidenceChunkQueryWhereDistinct
    on QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct> {
  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByByteLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'byteLength');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bytes');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByChunkCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chunkCount');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByChunkIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chunkIndex');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByDocumentGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByExpenseSyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expenseSyncGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByMediaType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByRole({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'role', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctBySha256({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sha256', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctBySyncGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, ExpenseEvidenceChunk, QDistinct>
      distinctByYearMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension ExpenseEvidenceChunkQueryProperty on QueryBuilder<
    ExpenseEvidenceChunk, ExpenseEvidenceChunk, QQueryProperty> {
  QueryBuilder<ExpenseEvidenceChunk, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, int, QQueryOperations>
      byteLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'byteLength');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, List<int>, QQueryOperations>
      bytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bytes');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, int, QQueryOperations>
      chunkCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chunkCount');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, int, QQueryOperations>
      chunkIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chunkIndex');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, String, QQueryOperations>
      documentGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentGuid');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, String, QQueryOperations>
      expenseSyncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expenseSyncGuid');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, String, QQueryOperations>
      fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, String, QQueryOperations>
      mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, int, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, String, QQueryOperations> roleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'role');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, String, QQueryOperations>
      sha256Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sha256');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, int?, QQueryOperations>
      sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, String, QQueryOperations>
      syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<ExpenseEvidenceChunk, String, QQueryOperations>
      yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
