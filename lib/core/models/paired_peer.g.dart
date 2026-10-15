// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paired_peer.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPairedPeerCollection on Isar {
  IsarCollection<PairedPeer> get pairedPeers => this.collection();
}

const PairedPeerSchema = CollectionSchema(
  name: r'PairedPeer',
  id: 2334392444408764357,
  properties: {
    r'lastSeenAt': PropertySchema(
      id: 0,
      name: r'lastSeenAt',
      type: IsarType.dateTime,
    ),
    r'pairedAt': PropertySchema(
      id: 1,
      name: r'pairedAt',
      type: IsarType.dateTime,
    ),
    r'peerFingerprint': PropertySchema(
      id: 2,
      name: r'peerFingerprint',
      type: IsarType.string,
    ),
    r'peerIdentityId': PropertySchema(
      id: 3,
      name: r'peerIdentityId',
      type: IsarType.string,
    ),
    r'peerPublicKey': PropertySchema(
      id: 4,
      name: r'peerPublicKey',
      type: IsarType.string,
    ),
    r'peerUsername': PropertySchema(
      id: 5,
      name: r'peerUsername',
      type: IsarType.string,
    )
  },
  estimateSize: _pairedPeerEstimateSize,
  serialize: _pairedPeerSerialize,
  deserialize: _pairedPeerDeserialize,
  deserializeProp: _pairedPeerDeserializeProp,
  idName: r'id',
  indexes: {
    r'peerIdentityId': IndexSchema(
      id: -261579929836686320,
      name: r'peerIdentityId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'peerIdentityId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pairedPeerGetId,
  getLinks: _pairedPeerGetLinks,
  attach: _pairedPeerAttach,
  version: '3.1.0+1',
);

int _pairedPeerEstimateSize(
  PairedPeer object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.peerFingerprint.length * 3;
  bytesCount += 3 + object.peerIdentityId.length * 3;
  bytesCount += 3 + object.peerPublicKey.length * 3;
  bytesCount += 3 + object.peerUsername.length * 3;
  return bytesCount;
}

void _pairedPeerSerialize(
  PairedPeer object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastSeenAt);
  writer.writeDateTime(offsets[1], object.pairedAt);
  writer.writeString(offsets[2], object.peerFingerprint);
  writer.writeString(offsets[3], object.peerIdentityId);
  writer.writeString(offsets[4], object.peerPublicKey);
  writer.writeString(offsets[5], object.peerUsername);
}

PairedPeer _pairedPeerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PairedPeer();
  object.id = id;
  object.lastSeenAt = reader.readDateTimeOrNull(offsets[0]);
  object.pairedAt = reader.readDateTime(offsets[1]);
  object.peerFingerprint = reader.readString(offsets[2]);
  object.peerIdentityId = reader.readString(offsets[3]);
  object.peerPublicKey = reader.readString(offsets[4]);
  object.peerUsername = reader.readString(offsets[5]);
  return object;
}

P _pairedPeerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pairedPeerGetId(PairedPeer object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pairedPeerGetLinks(PairedPeer object) {
  return [];
}

void _pairedPeerAttach(IsarCollection<dynamic> col, Id id, PairedPeer object) {
  object.id = id;
}

extension PairedPeerByIndex on IsarCollection<PairedPeer> {
  Future<PairedPeer?> getByPeerIdentityId(String peerIdentityId) {
    return getByIndex(r'peerIdentityId', [peerIdentityId]);
  }

  PairedPeer? getByPeerIdentityIdSync(String peerIdentityId) {
    return getByIndexSync(r'peerIdentityId', [peerIdentityId]);
  }

  Future<bool> deleteByPeerIdentityId(String peerIdentityId) {
    return deleteByIndex(r'peerIdentityId', [peerIdentityId]);
  }

  bool deleteByPeerIdentityIdSync(String peerIdentityId) {
    return deleteByIndexSync(r'peerIdentityId', [peerIdentityId]);
  }

  Future<List<PairedPeer?>> getAllByPeerIdentityId(
      List<String> peerIdentityIdValues) {
    final values = peerIdentityIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'peerIdentityId', values);
  }

  List<PairedPeer?> getAllByPeerIdentityIdSync(
      List<String> peerIdentityIdValues) {
    final values = peerIdentityIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'peerIdentityId', values);
  }

  Future<int> deleteAllByPeerIdentityId(List<String> peerIdentityIdValues) {
    final values = peerIdentityIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'peerIdentityId', values);
  }

  int deleteAllByPeerIdentityIdSync(List<String> peerIdentityIdValues) {
    final values = peerIdentityIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'peerIdentityId', values);
  }

  Future<Id> putByPeerIdentityId(PairedPeer object) {
    return putByIndex(r'peerIdentityId', object);
  }

  Id putByPeerIdentityIdSync(PairedPeer object, {bool saveLinks = true}) {
    return putByIndexSync(r'peerIdentityId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPeerIdentityId(List<PairedPeer> objects) {
    return putAllByIndex(r'peerIdentityId', objects);
  }

  List<Id> putAllByPeerIdentityIdSync(List<PairedPeer> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'peerIdentityId', objects, saveLinks: saveLinks);
  }
}

extension PairedPeerQueryWhereSort
    on QueryBuilder<PairedPeer, PairedPeer, QWhere> {
  QueryBuilder<PairedPeer, PairedPeer, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PairedPeerQueryWhere
    on QueryBuilder<PairedPeer, PairedPeer, QWhereClause> {
  QueryBuilder<PairedPeer, PairedPeer, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterWhereClause> idBetween(
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterWhereClause> peerIdentityIdEqualTo(
      String peerIdentityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'peerIdentityId',
        value: [peerIdentityId],
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterWhereClause>
      peerIdentityIdNotEqualTo(String peerIdentityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerIdentityId',
              lower: [],
              upper: [peerIdentityId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerIdentityId',
              lower: [peerIdentityId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerIdentityId',
              lower: [peerIdentityId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'peerIdentityId',
              lower: [],
              upper: [peerIdentityId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PairedPeerQueryFilter
    on QueryBuilder<PairedPeer, PairedPeer, QFilterCondition> {
  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      lastSeenAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSeenAt',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      lastSeenAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSeenAt',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> lastSeenAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      lastSeenAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      lastSeenAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> lastSeenAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeenAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> pairedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      pairedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> pairedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pairedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition> pairedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pairedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerFingerprintEqualTo(
    String value, {
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerFingerprintGreaterThan(
    String value, {
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerFingerprintLessThan(
    String value, {
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerFingerprintBetween(
    String lower,
    String upper, {
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
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

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerFingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerFingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerFingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerFingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerFingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerFingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerFingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerIdentityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'peerIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'peerIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerIdentityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerIdentityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerIdentityId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerIdentityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerIdentityId',
        value: '',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerPublicKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'peerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'peerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerPublicKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerPublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerPublicKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerPublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'peerUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'peerUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'peerUsername',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'peerUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'peerUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'peerUsername',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'peerUsername',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'peerUsername',
        value: '',
      ));
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterFilterCondition>
      peerUsernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'peerUsername',
        value: '',
      ));
    });
  }
}

extension PairedPeerQueryObject
    on QueryBuilder<PairedPeer, PairedPeer, QFilterCondition> {}

extension PairedPeerQueryLinks
    on QueryBuilder<PairedPeer, PairedPeer, QFilterCondition> {}

extension PairedPeerQuerySortBy
    on QueryBuilder<PairedPeer, PairedPeer, QSortBy> {
  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByPairedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByPeerFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerFingerprint', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy>
      sortByPeerFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerFingerprint', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByPeerIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerIdentityId', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy>
      sortByPeerIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerIdentityId', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByPeerPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerPublicKey', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByPeerPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerPublicKey', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByPeerUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerUsername', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> sortByPeerUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerUsername', Sort.desc);
    });
  }
}

extension PairedPeerQuerySortThenBy
    on QueryBuilder<PairedPeer, PairedPeer, QSortThenBy> {
  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByPairedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairedAt', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByPeerFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerFingerprint', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy>
      thenByPeerFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerFingerprint', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByPeerIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerIdentityId', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy>
      thenByPeerIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerIdentityId', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByPeerPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerPublicKey', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByPeerPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerPublicKey', Sort.desc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByPeerUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerUsername', Sort.asc);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QAfterSortBy> thenByPeerUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'peerUsername', Sort.desc);
    });
  }
}

extension PairedPeerQueryWhereDistinct
    on QueryBuilder<PairedPeer, PairedPeer, QDistinct> {
  QueryBuilder<PairedPeer, PairedPeer, QDistinct> distinctByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeenAt');
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QDistinct> distinctByPairedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pairedAt');
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QDistinct> distinctByPeerFingerprint(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerFingerprint',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QDistinct> distinctByPeerIdentityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerIdentityId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QDistinct> distinctByPeerPublicKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerPublicKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PairedPeer, PairedPeer, QDistinct> distinctByPeerUsername(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'peerUsername', caseSensitive: caseSensitive);
    });
  }
}

extension PairedPeerQueryProperty
    on QueryBuilder<PairedPeer, PairedPeer, QQueryProperty> {
  QueryBuilder<PairedPeer, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PairedPeer, DateTime?, QQueryOperations> lastSeenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeenAt');
    });
  }

  QueryBuilder<PairedPeer, DateTime, QQueryOperations> pairedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pairedAt');
    });
  }

  QueryBuilder<PairedPeer, String, QQueryOperations> peerFingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerFingerprint');
    });
  }

  QueryBuilder<PairedPeer, String, QQueryOperations> peerIdentityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerIdentityId');
    });
  }

  QueryBuilder<PairedPeer, String, QQueryOperations> peerPublicKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerPublicKey');
    });
  }

  QueryBuilder<PairedPeer, String, QQueryOperations> peerUsernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'peerUsername');
    });
  }
}
