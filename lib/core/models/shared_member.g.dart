// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_member.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSharedMemberCollection on Isar {
  IsarCollection<SharedMember> get sharedMembers => this.collection();
}

const SharedMemberSchema = CollectionSchema(
  name: r'SharedMember',
  id: 5412717623268973280,
  properties: {
    r'authorIdentityId': PropertySchema(
      id: 0,
      name: r'authorIdentityId',
      type: IsarType.string,
    ),
    r'joinedAt': PropertySchema(
      id: 1,
      name: r'joinedAt',
      type: IsarType.dateTime,
    ),
    r'profileId': PropertySchema(
      id: 2,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'revokedAt': PropertySchema(
      id: 3,
      name: r'revokedAt',
      type: IsarType.dateTime,
    ),
    r'role': PropertySchema(
      id: 4,
      name: r'role',
      type: IsarType.byte,
      enumMap: _SharedMemberroleEnumValueMap,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 5,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'signature': PropertySchema(
      id: 6,
      name: r'signature',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 8,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _sharedMemberEstimateSize,
  serialize: _sharedMemberSerialize,
  deserialize: _sharedMemberDeserialize,
  deserializeProp: _sharedMemberDeserializeProp,
  idName: r'id',
  indexes: {
    r'sharedSpaceId_profileId': IndexSchema(
      id: -7402731138731410276,
      name: r'sharedSpaceId_profileId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sharedSpaceId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'profileId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _sharedMemberGetId,
  getLinks: _sharedMemberGetLinks,
  attach: _sharedMemberAttach,
  version: '3.1.0+1',
);

int _sharedMemberEstimateSize(
  SharedMember object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.authorIdentityId;
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
  return bytesCount;
}

void _sharedMemberSerialize(
  SharedMember object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authorIdentityId);
  writer.writeDateTime(offsets[1], object.joinedAt);
  writer.writeLong(offsets[2], object.profileId);
  writer.writeDateTime(offsets[3], object.revokedAt);
  writer.writeByte(offsets[4], object.role.index);
  writer.writeLong(offsets[5], object.sharedSpaceId);
  writer.writeString(offsets[6], object.signature);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeLong(offsets[8], object.version);
}

SharedMember _sharedMemberDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SharedMember();
  object.authorIdentityId = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.joinedAt = reader.readDateTime(offsets[1]);
  object.profileId = reader.readLong(offsets[2]);
  object.revokedAt = reader.readDateTimeOrNull(offsets[3]);
  object.role =
      _SharedMemberroleValueEnumMap[reader.readByteOrNull(offsets[4])] ??
          SharedMemberRole.owner;
  object.sharedSpaceId = reader.readLong(offsets[5]);
  object.signature = reader.readStringOrNull(offsets[6]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[7]);
  object.version = reader.readLong(offsets[8]);
  return object;
}

P _sharedMemberDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (_SharedMemberroleValueEnumMap[reader.readByteOrNull(offset)] ??
          SharedMemberRole.owner) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SharedMemberroleEnumValueMap = {
  'owner': 0,
  'editor': 1,
  'viewer': 2,
};
const _SharedMemberroleValueEnumMap = {
  0: SharedMemberRole.owner,
  1: SharedMemberRole.editor,
  2: SharedMemberRole.viewer,
};

Id _sharedMemberGetId(SharedMember object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sharedMemberGetLinks(SharedMember object) {
  return [];
}

void _sharedMemberAttach(
    IsarCollection<dynamic> col, Id id, SharedMember object) {
  object.id = id;
}

extension SharedMemberByIndex on IsarCollection<SharedMember> {
  Future<SharedMember?> getBySharedSpaceIdProfileId(
      int sharedSpaceId, int profileId) {
    return getByIndex(r'sharedSpaceId_profileId', [sharedSpaceId, profileId]);
  }

  SharedMember? getBySharedSpaceIdProfileIdSync(
      int sharedSpaceId, int profileId) {
    return getByIndexSync(
        r'sharedSpaceId_profileId', [sharedSpaceId, profileId]);
  }

  Future<bool> deleteBySharedSpaceIdProfileId(
      int sharedSpaceId, int profileId) {
    return deleteByIndex(
        r'sharedSpaceId_profileId', [sharedSpaceId, profileId]);
  }

  bool deleteBySharedSpaceIdProfileIdSync(int sharedSpaceId, int profileId) {
    return deleteByIndexSync(
        r'sharedSpaceId_profileId', [sharedSpaceId, profileId]);
  }

  Future<List<SharedMember?>> getAllBySharedSpaceIdProfileId(
      List<int> sharedSpaceIdValues, List<int> profileIdValues) {
    final len = sharedSpaceIdValues.length;
    assert(profileIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([sharedSpaceIdValues[i], profileIdValues[i]]);
    }

    return getAllByIndex(r'sharedSpaceId_profileId', values);
  }

  List<SharedMember?> getAllBySharedSpaceIdProfileIdSync(
      List<int> sharedSpaceIdValues, List<int> profileIdValues) {
    final len = sharedSpaceIdValues.length;
    assert(profileIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([sharedSpaceIdValues[i], profileIdValues[i]]);
    }

    return getAllByIndexSync(r'sharedSpaceId_profileId', values);
  }

  Future<int> deleteAllBySharedSpaceIdProfileId(
      List<int> sharedSpaceIdValues, List<int> profileIdValues) {
    final len = sharedSpaceIdValues.length;
    assert(profileIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([sharedSpaceIdValues[i], profileIdValues[i]]);
    }

    return deleteAllByIndex(r'sharedSpaceId_profileId', values);
  }

  int deleteAllBySharedSpaceIdProfileIdSync(
      List<int> sharedSpaceIdValues, List<int> profileIdValues) {
    final len = sharedSpaceIdValues.length;
    assert(profileIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([sharedSpaceIdValues[i], profileIdValues[i]]);
    }

    return deleteAllByIndexSync(r'sharedSpaceId_profileId', values);
  }

  Future<Id> putBySharedSpaceIdProfileId(SharedMember object) {
    return putByIndex(r'sharedSpaceId_profileId', object);
  }

  Id putBySharedSpaceIdProfileIdSync(SharedMember object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'sharedSpaceId_profileId', object,
        saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySharedSpaceIdProfileId(List<SharedMember> objects) {
    return putAllByIndex(r'sharedSpaceId_profileId', objects);
  }

  List<Id> putAllBySharedSpaceIdProfileIdSync(List<SharedMember> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sharedSpaceId_profileId', objects,
        saveLinks: saveLinks);
  }
}

extension SharedMemberQueryWhereSort
    on QueryBuilder<SharedMember, SharedMember, QWhere> {
  QueryBuilder<SharedMember, SharedMember, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhere>
      anySharedSpaceIdProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId_profileId'),
      );
    });
  }
}

extension SharedMemberQueryWhere
    on QueryBuilder<SharedMember, SharedMember, QWhereClause> {
  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause> idBetween(
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

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdEqualToAnyProfileId(int sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId_profileId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdNotEqualToAnyProfileId(int sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId_profileId',
              lower: [],
              upper: [sharedSpaceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId_profileId',
              lower: [sharedSpaceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId_profileId',
              lower: [sharedSpaceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId_profileId',
              lower: [],
              upper: [sharedSpaceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdGreaterThanAnyProfileId(
    int sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId_profileId',
        lower: [sharedSpaceId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdLessThanAnyProfileId(
    int sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId_profileId',
        lower: [],
        upper: [sharedSpaceId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdBetweenAnyProfileId(
    int lowerSharedSpaceId,
    int upperSharedSpaceId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId_profileId',
        lower: [lowerSharedSpaceId],
        includeLower: includeLower,
        upper: [upperSharedSpaceId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdProfileIdEqualTo(int sharedSpaceId, int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId_profileId',
        value: [sharedSpaceId, profileId],
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdEqualToProfileIdNotEqualTo(
          int sharedSpaceId, int profileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId_profileId',
              lower: [sharedSpaceId],
              upper: [sharedSpaceId, profileId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId_profileId',
              lower: [sharedSpaceId, profileId],
              includeLower: false,
              upper: [sharedSpaceId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId_profileId',
              lower: [sharedSpaceId, profileId],
              includeLower: false,
              upper: [sharedSpaceId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId_profileId',
              lower: [sharedSpaceId],
              upper: [sharedSpaceId, profileId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdEqualToProfileIdGreaterThan(
    int sharedSpaceId,
    int profileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId_profileId',
        lower: [sharedSpaceId, profileId],
        includeLower: include,
        upper: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdEqualToProfileIdLessThan(
    int sharedSpaceId,
    int profileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId_profileId',
        lower: [sharedSpaceId],
        upper: [sharedSpaceId, profileId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterWhereClause>
      sharedSpaceIdEqualToProfileIdBetween(
    int sharedSpaceId,
    int lowerProfileId,
    int upperProfileId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId_profileId',
        lower: [sharedSpaceId, lowerProfileId],
        includeLower: includeLower,
        upper: [sharedSpaceId, upperProfileId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SharedMemberQueryFilter
    on QueryBuilder<SharedMember, SharedMember, QFilterCondition> {
  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'authorIdentityId',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'authorIdentityId',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdEqualTo(
    String? value, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdGreaterThan(
    String? value, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdLessThan(
    String? value, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authorIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authorIdentityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorIdentityId',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      authorIdentityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authorIdentityId',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      joinedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      joinedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      joinedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      joinedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'joinedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      profileIdGreaterThan(
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      profileIdLessThan(
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      profileIdBetween(
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      revokedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'revokedAt',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      revokedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'revokedAt',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      revokedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revokedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      revokedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'revokedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      revokedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'revokedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      revokedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'revokedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition> roleEqualTo(
      SharedMemberRole value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      roleGreaterThan(
    SharedMemberRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition> roleLessThan(
    SharedMemberRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition> roleBetween(
    SharedMemberRole lower,
    SharedMemberRole upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'role',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      sharedSpaceIdGreaterThan(
    int value, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      sharedSpaceIdLessThan(
    int value, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      sharedSpaceIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      signatureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signature',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      signatureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signature',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      signatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      signatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      signatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      signatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterFilterCondition>
      versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SharedMemberQueryObject
    on QueryBuilder<SharedMember, SharedMember, QFilterCondition> {}

extension SharedMemberQueryLinks
    on QueryBuilder<SharedMember, SharedMember, QFilterCondition> {}

extension SharedMemberQuerySortBy
    on QueryBuilder<SharedMember, SharedMember, QSortBy> {
  QueryBuilder<SharedMember, SharedMember, QAfterSortBy>
      sortByAuthorIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorIdentityId', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy>
      sortByAuthorIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorIdentityId', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByJoinedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joinedAt', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByJoinedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joinedAt', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByRevokedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension SharedMemberQuerySortThenBy
    on QueryBuilder<SharedMember, SharedMember, QSortThenBy> {
  QueryBuilder<SharedMember, SharedMember, QAfterSortBy>
      thenByAuthorIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorIdentityId', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy>
      thenByAuthorIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorIdentityId', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByJoinedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joinedAt', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByJoinedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joinedAt', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByRevokedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension SharedMemberQueryWhereDistinct
    on QueryBuilder<SharedMember, SharedMember, QDistinct> {
  QueryBuilder<SharedMember, SharedMember, QDistinct>
      distinctByAuthorIdentityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorIdentityId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QDistinct> distinctByJoinedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'joinedAt');
    });
  }

  QueryBuilder<SharedMember, SharedMember, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<SharedMember, SharedMember, QDistinct> distinctByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revokedAt');
    });
  }

  QueryBuilder<SharedMember, SharedMember, QDistinct> distinctByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'role');
    });
  }

  QueryBuilder<SharedMember, SharedMember, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<SharedMember, SharedMember, QDistinct> distinctBySignature(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signature', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SharedMember, SharedMember, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SharedMember, SharedMember, QDistinct> distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension SharedMemberQueryProperty
    on QueryBuilder<SharedMember, SharedMember, QQueryProperty> {
  QueryBuilder<SharedMember, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SharedMember, String?, QQueryOperations>
      authorIdentityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorIdentityId');
    });
  }

  QueryBuilder<SharedMember, DateTime, QQueryOperations> joinedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'joinedAt');
    });
  }

  QueryBuilder<SharedMember, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<SharedMember, DateTime?, QQueryOperations> revokedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revokedAt');
    });
  }

  QueryBuilder<SharedMember, SharedMemberRole, QQueryOperations>
      roleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'role');
    });
  }

  QueryBuilder<SharedMember, int, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<SharedMember, String?, QQueryOperations> signatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signature');
    });
  }

  QueryBuilder<SharedMember, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SharedMember, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
