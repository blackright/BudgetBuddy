// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_space.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSharedSpaceCollection on Isar {
  IsarCollection<SharedSpace> get sharedSpaces => this.collection();
}

const SharedSpaceSchema = CollectionSchema(
  name: r'SharedSpace',
  id: -6016545564761544410,
  properties: {
    r'avatar': PropertySchema(
      id: 0,
      name: r'avatar',
      type: IsarType.string,
    ),
    r'awayTimeIndex': PropertySchema(
      id: 1,
      name: r'awayTimeIndex',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdByProfileId': PropertySchema(
      id: 3,
      name: r'createdByProfileId',
      type: IsarType.long,
    ),
    r'currency': PropertySchema(
      id: 4,
      name: r'currency',
      type: IsarType.byte,
      enumMap: _SharedSpacecurrencyEnumValueMap,
    ),
    r'defaultIncome': PropertySchema(
      id: 5,
      name: r'defaultIncome',
      type: IsarType.long,
    ),
    r'displayName': PropertySchema(
      id: 6,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'forbidBiometrics': PropertySchema(
      id: 7,
      name: r'forbidBiometrics',
      type: IsarType.bool,
    ),
    r'isPendingSync': PropertySchema(
      id: 8,
      name: r'isPendingSync',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'requirePin': PropertySchema(
      id: 10,
      name: r'requirePin',
      type: IsarType.bool,
    ),
    r'syncGuid': PropertySchema(
      id: 11,
      name: r'syncGuid',
      type: IsarType.string,
    )
  },
  estimateSize: _sharedSpaceEstimateSize,
  serialize: _sharedSpaceSerialize,
  deserialize: _sharedSpaceDeserialize,
  deserializeProp: _sharedSpaceDeserializeProp,
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
  getId: _sharedSpaceGetId,
  getLinks: _sharedSpaceGetLinks,
  attach: _sharedSpaceAttach,
  version: '3.1.0+1',
);

int _sharedSpaceEstimateSize(
  SharedSpace object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.avatar.length * 3;
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.syncGuid.length * 3;
  return bytesCount;
}

void _sharedSpaceSerialize(
  SharedSpace object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.avatar);
  writer.writeLong(offsets[1], object.awayTimeIndex);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.createdByProfileId);
  writer.writeByte(offsets[4], object.currency.index);
  writer.writeLong(offsets[5], object.defaultIncome);
  writer.writeString(offsets[6], object.displayName);
  writer.writeBool(offsets[7], object.forbidBiometrics);
  writer.writeBool(offsets[8], object.isPendingSync);
  writer.writeString(offsets[9], object.name);
  writer.writeBool(offsets[10], object.requirePin);
  writer.writeString(offsets[11], object.syncGuid);
}

SharedSpace _sharedSpaceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SharedSpace();
  object.avatar = reader.readString(offsets[0]);
  object.awayTimeIndex = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.createdByProfileId = reader.readLong(offsets[3]);
  object.currency =
      _SharedSpacecurrencyValueEnumMap[reader.readByteOrNull(offsets[4])] ??
          PrimaryCurrency.huf;
  object.defaultIncome = reader.readLong(offsets[5]);
  object.forbidBiometrics = reader.readBool(offsets[7]);
  object.id = id;
  object.name = reader.readString(offsets[9]);
  object.requirePin = reader.readBool(offsets[10]);
  object.syncGuid = reader.readString(offsets[11]);
  return object;
}

P _sharedSpaceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (_SharedSpacecurrencyValueEnumMap[reader.readByteOrNull(offset)] ??
          PrimaryCurrency.huf) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SharedSpacecurrencyEnumValueMap = {
  'huf': 0,
  'usd': 1,
  'cad': 2,
  'eur': 3,
};
const _SharedSpacecurrencyValueEnumMap = {
  0: PrimaryCurrency.huf,
  1: PrimaryCurrency.usd,
  2: PrimaryCurrency.cad,
  3: PrimaryCurrency.eur,
};

Id _sharedSpaceGetId(SharedSpace object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sharedSpaceGetLinks(SharedSpace object) {
  return [];
}

void _sharedSpaceAttach(
    IsarCollection<dynamic> col, Id id, SharedSpace object) {
  object.id = id;
}

extension SharedSpaceQueryWhereSort
    on QueryBuilder<SharedSpace, SharedSpace, QWhere> {
  QueryBuilder<SharedSpace, SharedSpace, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SharedSpaceQueryWhere
    on QueryBuilder<SharedSpace, SharedSpace, QWhereClause> {
  QueryBuilder<SharedSpace, SharedSpace, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterWhereClause> idBetween(
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterWhereClause> syncGuidEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterWhereClause> syncGuidNotEqualTo(
      String syncGuid) {
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

extension SharedSpaceQueryFilter
    on QueryBuilder<SharedSpace, SharedSpace, QFilterCondition> {
  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> avatarEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      avatarGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> avatarLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> avatarBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      avatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> avatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> avatarContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> avatarMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      avatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      avatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      awayTimeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'awayTimeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      awayTimeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'awayTimeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      awayTimeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'awayTimeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      awayTimeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'awayTimeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      createdByProfileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByProfileId',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      createdByProfileIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdByProfileId',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      createdByProfileIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdByProfileId',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      createdByProfileIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdByProfileId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> currencyEqualTo(
      PrimaryCurrency value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      currencyGreaterThan(
    PrimaryCurrency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currency',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      currencyLessThan(
    PrimaryCurrency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currency',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> currencyBetween(
    PrimaryCurrency lower,
    PrimaryCurrency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      defaultIncomeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultIncome',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      defaultIncomeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultIncome',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      defaultIncomeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultIncome',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      defaultIncomeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultIncome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      forbidBiometricsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forbidBiometrics',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      isPendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      requirePinEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requirePin',
        value: value,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> syncGuidEqualTo(
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> syncGuidBetween(
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
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

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition> syncGuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }
}

extension SharedSpaceQueryObject
    on QueryBuilder<SharedSpace, SharedSpace, QFilterCondition> {}

extension SharedSpaceQueryLinks
    on QueryBuilder<SharedSpace, SharedSpace, QFilterCondition> {}

extension SharedSpaceQuerySortBy
    on QueryBuilder<SharedSpace, SharedSpace, QSortBy> {
  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByAwayTimeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awayTimeIndex', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      sortByAwayTimeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awayTimeIndex', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      sortByCreatedByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByProfileId', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      sortByCreatedByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByProfileId', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByDefaultIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultIncome', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      sortByDefaultIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultIncome', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      sortByForbidBiometrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forbidBiometrics', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      sortByForbidBiometricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forbidBiometrics', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      sortByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByRequirePin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePin', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortByRequirePinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePin', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }
}

extension SharedSpaceQuerySortThenBy
    on QueryBuilder<SharedSpace, SharedSpace, QSortThenBy> {
  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByAwayTimeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awayTimeIndex', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      thenByAwayTimeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'awayTimeIndex', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      thenByCreatedByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByProfileId', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      thenByCreatedByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByProfileId', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByDefaultIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultIncome', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      thenByDefaultIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultIncome', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      thenByForbidBiometrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forbidBiometrics', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      thenByForbidBiometricsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forbidBiometrics', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy>
      thenByIsPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPendingSync', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByRequirePin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePin', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenByRequirePinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePin', Sort.desc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QAfterSortBy> thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }
}

extension SharedSpaceQueryWhereDistinct
    on QueryBuilder<SharedSpace, SharedSpace, QDistinct> {
  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByAvatar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByAwayTimeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'awayTimeIndex');
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct>
      distinctByCreatedByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByProfileId');
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency');
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByDefaultIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultIncome');
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct>
      distinctByForbidBiometrics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'forbidBiometrics');
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByIsPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPendingSync');
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctByRequirePin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requirePin');
    });
  }

  QueryBuilder<SharedSpace, SharedSpace, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }
}

extension SharedSpaceQueryProperty
    on QueryBuilder<SharedSpace, SharedSpace, QQueryProperty> {
  QueryBuilder<SharedSpace, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SharedSpace, String, QQueryOperations> avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatar');
    });
  }

  QueryBuilder<SharedSpace, int, QQueryOperations> awayTimeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'awayTimeIndex');
    });
  }

  QueryBuilder<SharedSpace, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SharedSpace, int, QQueryOperations>
      createdByProfileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByProfileId');
    });
  }

  QueryBuilder<SharedSpace, PrimaryCurrency, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<SharedSpace, int, QQueryOperations> defaultIncomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultIncome');
    });
  }

  QueryBuilder<SharedSpace, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<SharedSpace, bool, QQueryOperations> forbidBiometricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'forbidBiometrics');
    });
  }

  QueryBuilder<SharedSpace, bool, QQueryOperations> isPendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPendingSync');
    });
  }

  QueryBuilder<SharedSpace, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SharedSpace, bool, QQueryOperations> requirePinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requirePin');
    });
  }

  QueryBuilder<SharedSpace, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }
}
