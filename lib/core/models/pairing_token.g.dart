// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_token.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPairingTokenCollection on Isar {
  IsarCollection<PairingToken> get pairingTokens => this.collection();
}

const PairingTokenSchema = CollectionSchema(
  name: r'PairingToken',
  id: -967673778590087494,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'direction': PropertySchema(
      id: 1,
      name: r'direction',
      type: IsarType.byte,
      enumMap: _PairingTokendirectionEnumValueMap,
    ),
    r'expiresAt': PropertySchema(
      id: 2,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'offeredRole': PropertySchema(
      id: 3,
      name: r'offeredRole',
      type: IsarType.byte,
      enumMap: _PairingTokenofferedRoleEnumValueMap,
    ),
    r'peerFingerprint': PropertySchema(
      id: 4,
      name: r'peerFingerprint',
      type: IsarType.string,
    ),
    r'spaceId': PropertySchema(
      id: 5,
      name: r'spaceId',
      type: IsarType.long,
    ),
    r'token': PropertySchema(
      id: 6,
      name: r'token',
      type: IsarType.string,
    ),
    r'usedAt': PropertySchema(
      id: 7,
      name: r'usedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _pairingTokenEstimateSize,
  serialize: _pairingTokenSerialize,
  deserialize: _pairingTokenDeserialize,
  deserializeProp: _pairingTokenDeserializeProp,
  idName: r'id',
  indexes: {
    r'token': IndexSchema(
      id: -5898650166254967271,
      name: r'token',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'token',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pairingTokenGetId,
  getLinks: _pairingTokenGetLinks,
  attach: _pairingTokenAttach,
  version: '3.1.0+1',
);

int _pairingTokenEstimateSize(
  PairingToken object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.peerFingerprint;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.token.length * 3;
  return bytesCount;
}

void _pairingTokenSerialize(
  PairingToken object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeByte(offsets[1], object.direction.index);
  writer.writeDateTime(offsets[2], object.expiresAt);
  writer.writeByte(offsets[3], object.offeredRole.index);
  writer.writeString(offsets[4], object.peerFingerprint);
  writer.writeLong(offsets[5], object.spaceId);
  writer.writeString(offsets[6], object.token);
  writer.writeDateTime(offsets[7], object.usedAt);
}

PairingToken _pairingTokenDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PairingToken();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.direction =
      _PairingTokendirectionValueEnumMap[reader.readByteOrNull(offsets[1])] ??
          PairingDirection.presented;
  object.expiresAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.offeredRole =
      _PairingTokenofferedRoleValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          SharedMemberRole.owner;
  object.peerFingerprint = reader.readStringOrNull(offsets[4]);
  object.spaceId = reader.readLong(offsets[5]);
  object.token = reader.readString(offsets[6]);
  object.usedAt = reader.readDateTimeOrNull(offsets[7]);
  return object;
}

P _pairingTokenDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (_PairingTokendirectionValueEnumMap[
              reader.readByteOrNull(offset)] ??
          PairingDirection.presented) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (_PairingTokenofferedRoleValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SharedMemberRole.owner) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PairingTokendirectionEnumValueMap = {
  'presented': 0,
  'claimed': 1,
};
const _PairingTokendirectionValueEnumMap = {
  0: PairingDirection.presented,
  1: PairingDirection.claimed,
};
const _PairingTokenofferedRoleEnumValueMap = {
  'owner': 0,
  'editor': 1,
  'viewer': 2,
};
const _PairingTokenofferedRoleValueEnumMap = {
  0: SharedMemberRole.owner,
  1: SharedMemberRole.editor,
  2: SharedMemberRole.viewer,
};

Id _pairingTokenGetId(PairingToken object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pairingTokenGetLinks(PairingToken object) {
  return [];
}

void _pairingTokenAttach(
    IsarCollection<dynamic> col, Id id, PairingToken object) {
  object.id = id;
}

extension PairingTokenByIndex on IsarCollection<PairingToken> {
  Future<PairingToken?> getByToken(String token) {
    return getByIndex(r'token', [token]);
  }

  PairingToken? getByTokenSync(String token) {
    return getByIndexSync(r'token', [token]);
  }

  Future<bool> deleteByToken(String token) {
    return deleteByIndex(r'token', [token]);
  }

  bool deleteByTokenSync(String token) {
    return deleteByIndexSync(r'token', [token]);
  }

  Future<List<PairingToken?>> getAllByToken(List<String> tokenValues) {
    final values = tokenValues.map((e) => [e]).toList();
    return getAllByIndex(r'token', values);
  }

  List<PairingToken?> getAllByTokenSync(List<String> tokenValues) {
    final values = tokenValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'token', values);
  }

  Future<int> deleteAllByToken(List<String> tokenValues) {
    final values = tokenValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'token', values);
  }

  int deleteAllByTokenSync(List<String> tokenValues) {
    final values = tokenValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'token', values);
  }

  Future<Id> putByToken(PairingToken object) {
    return putByIndex(r'token', object);
  }

  Id putByTokenSync(PairingToken object, {bool saveLinks = true}) {
    return putByIndexSync(r'token', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByToken(List<PairingToken> objects) {
    return putAllByIndex(r'token', objects);
  }

  List<Id> putAllByTokenSync(List<PairingToken> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'token', objects, saveLinks: saveLinks);
  }
}

extension PairingTokenQueryWhereSort
    on QueryBuilder<PairingToken, PairingToken, QWhere> {
  QueryBuilder<PairingToken, PairingToken, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PairingTokenQueryWhere
    on QueryBuilder<PairingToken, PairingToken, QWhereClause> {
  QueryBuilder<PairingToken, PairingToken, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PairingToken, PairingToken, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterWhereClause> idBetween(
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

  QueryBuilder<PairingToken, PairingToken, QAfterWhereClause> tokenEqualTo(
      String token) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'token',
        value: [token],
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterWhereClause> tokenNotEqualTo(
      String token) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token',
              lower: [],
              upper: [token],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token',
              lower: [token],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token',
              lower: [token],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token',
              lower: [],
              upper: [token],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PairingTokenQueryFilter
    on QueryBuilder<PairingToken, PairingToken, QFilterCondition> {
  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
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

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
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

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
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

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      directionEqualTo(PairingDirection value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direction',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      directionGreaterThan(
    PairingDirection value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'direction',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      directionLessThan(
    PairingDirection value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'direction',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      directionBetween(
    PairingDirection lower,
    PairingDirection upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'direction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      expiresAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      expiresAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      expiresAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      expiresAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expiresAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      offeredRoleEqualTo(SharedMemberRole value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offeredRole',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      offeredRoleGreaterThan(
    SharedMemberRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offeredRole',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      offeredRoleLessThan(
    SharedMemberRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offeredRole',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      offeredRoleBetween(
    SharedMemberRole lower,
    SharedMemberRole upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offeredRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'peerFingerprint',
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'peerFingerprint',
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerFingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'peerFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'peerFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      peerFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      spaceIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      spaceIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      spaceIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      spaceIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spaceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> tokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      tokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> tokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> tokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'token',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      tokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> tokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> tokenContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> tokenMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'token',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      tokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      tokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      usedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usedAt',
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      usedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usedAt',
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> usedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      usedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition>
      usedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterFilterCondition> usedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PairingTokenQueryObject
    on QueryBuilder<PairingToken, PairingToken, QFilterCondition> {}

extension PairingTokenQueryLinks
    on QueryBuilder<PairingToken, PairingToken, QFilterCondition> {}

extension PairingTokenQuerySortBy
    on QueryBuilder<PairingToken, PairingToken, QSortBy> {
  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByOfferedRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offeredRole', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy>
      sortByOfferedRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offeredRole', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy>
      sortByPeerFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerFingerprint', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy>
      sortByPeerFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerFingerprint', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortBySpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spaceId', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortBySpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spaceId', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usedAt', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> sortByUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usedAt', Sort.desc);
    });
  }
}

extension PairingTokenQuerySortThenBy
    on QueryBuilder<PairingToken, PairingToken, QSortThenBy> {
  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByOfferedRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offeredRole', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy>
      thenByOfferedRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offeredRole', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy>
      thenByPeerFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerFingerprint', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy>
      thenByPeerFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerFingerprint', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenBySpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spaceId', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenBySpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spaceId', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usedAt', Sort.asc);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QAfterSortBy> thenByUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usedAt', Sort.desc);
    });
  }
}

extension PairingTokenQueryWhereDistinct
    on QueryBuilder<PairingToken, PairingToken, QDistinct> {
  QueryBuilder<PairingToken, PairingToken, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PairingToken, PairingToken, QDistinct> distinctByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction');
    });
  }

  QueryBuilder<PairingToken, PairingToken, QDistinct> distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<PairingToken, PairingToken, QDistinct> distinctByOfferedRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offeredRole');
    });
  }

  QueryBuilder<PairingToken, PairingToken, QDistinct> distinctByPeerFingerprint(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QDistinct> distinctBySpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spaceId');
    });
  }

  QueryBuilder<PairingToken, PairingToken, QDistinct> distinctByToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairingToken, PairingToken, QDistinct> distinctByUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usedAt');
    });
  }
}

extension PairingTokenQueryProperty
    on QueryBuilder<PairingToken, PairingToken, QQueryProperty> {
  QueryBuilder<PairingToken, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PairingToken, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PairingToken, PairingDirection, QQueryOperations>
      directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<PairingToken, DateTime, QQueryOperations> expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<PairingToken, SharedMemberRole, QQueryOperations>
      offeredRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offeredRole');
    });
  }

  QueryBuilder<PairingToken, String?, QQueryOperations>
      peerFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerFingerprint');
    });
  }

  QueryBuilder<PairingToken, int, QQueryOperations> spaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spaceId');
    });
  }

  QueryBuilder<PairingToken, String, QQueryOperations> tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token');
    });
  }

  QueryBuilder<PairingToken, DateTime?, QQueryOperations> usedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usedAt');
    });
  }
}
