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
    r'joinedAt': PropertySchema(
      id: 0,
      name: r'joinedAt',
      type: IsarType.dateTime,
    ),
    r'profileId': PropertySchema(
      id: 1,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'role': PropertySchema(
      id: 2,
      name: r'role',
      type: IsarType.byte,
      enumMap: _SharedMemberroleEnumValueMap,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 3,
      name: r'sharedSpaceId',
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
  return bytesCount;
}

void _sharedMemberSerialize(
  SharedMember object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.joinedAt);
  writer.writeLong(offsets[1], object.profileId);
  writer.writeByte(offsets[2], object.role.index);
  writer.writeLong(offsets[3], object.sharedSpaceId);
}

SharedMember _sharedMemberDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SharedMember();
  object.id = id;
  object.joinedAt = reader.readDateTime(offsets[0]);
  object.profileId = reader.readLong(offsets[1]);
  object.role =
      _SharedMemberroleValueEnumMap[reader.readByteOrNull(offsets[2])] ??
          SharedMemberRole.owner;
  object.sharedSpaceId = reader.readLong(offsets[3]);
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
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (_SharedMemberroleValueEnumMap[reader.readByteOrNull(offset)] ??
          SharedMemberRole.owner) as P;
    case 3:
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
}

extension SharedMemberQueryObject
    on QueryBuilder<SharedMember, SharedMember, QFilterCondition> {}

extension SharedMemberQueryLinks
    on QueryBuilder<SharedMember, SharedMember, QFilterCondition> {}

extension SharedMemberQuerySortBy
    on QueryBuilder<SharedMember, SharedMember, QSortBy> {
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
}

extension SharedMemberQuerySortThenBy
    on QueryBuilder<SharedMember, SharedMember, QSortThenBy> {
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
}

extension SharedMemberQueryWhereDistinct
    on QueryBuilder<SharedMember, SharedMember, QDistinct> {
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
}

extension SharedMemberQueryProperty
    on QueryBuilder<SharedMember, SharedMember, QQueryProperty> {
  QueryBuilder<SharedMember, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
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
}
