// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_withholding_match.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicalWithholdingMatchCollection on Isar {
  IsarCollection<MedicalWithholdingMatch> get medicalWithholdingMatchs =>
      this.collection();
}

const MedicalWithholdingMatchSchema = CollectionSchema(
  name: r'MedicalWithholdingMatch',
  id: -4181976941966933394,
  properties: {
    r'affectedMonths': PropertySchema(
      id: 0,
      name: r'affectedMonths',
      type: IsarType.stringList,
    ),
    r'billGuid': PropertySchema(
      id: 1,
      name: r'billGuid',
      type: IsarType.string,
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
    r'guid': PropertySchema(
      id: 4,
      name: r'guid',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 5,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'reversalGuid': PropertySchema(
      id: 6,
      name: r'reversalGuid',
      type: IsarType.string,
    ),
    r'reversalReason': PropertySchema(
      id: 7,
      name: r'reversalReason',
      type: IsarType.string,
    ),
    r'reversed': PropertySchema(
      id: 8,
      name: r'reversed',
      type: IsarType.bool,
    ),
    r'salaryReceiptGroupGuid': PropertySchema(
      id: 9,
      name: r'salaryReceiptGroupGuid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'withheldMinor': PropertySchema(
      id: 11,
      name: r'withheldMinor',
      type: IsarType.long,
    )
  },
  estimateSize: _medicalWithholdingMatchEstimateSize,
  serialize: _medicalWithholdingMatchSerialize,
  deserialize: _medicalWithholdingMatchDeserialize,
  deserializeProp: _medicalWithholdingMatchDeserializeProp,
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
    r'salaryReceiptGroupGuid': IndexSchema(
      id: 1889790076454701838,
      name: r'salaryReceiptGroupGuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'salaryReceiptGroupGuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _medicalWithholdingMatchGetId,
  getLinks: _medicalWithholdingMatchGetLinks,
  attach: _medicalWithholdingMatchAttach,
  version: '3.1.0+1',
);

int _medicalWithholdingMatchEstimateSize(
  MedicalWithholdingMatch object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.affectedMonths.length * 3;
  {
    for (var i = 0; i < object.affectedMonths.length; i++) {
      final value = object.affectedMonths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.billGuid.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.guid.length * 3;
  {
    final value = object.reversalGuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reversalReason.length * 3;
  bytesCount += 3 + object.salaryReceiptGroupGuid.length * 3;
  return bytesCount;
}

void _medicalWithholdingMatchSerialize(
  MedicalWithholdingMatch object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.affectedMonths);
  writer.writeString(offsets[1], object.billGuid);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.currency);
  writer.writeString(offsets[4], object.guid);
  writer.writeLong(offsets[5], object.profileId);
  writer.writeString(offsets[6], object.reversalGuid);
  writer.writeString(offsets[7], object.reversalReason);
  writer.writeBool(offsets[8], object.reversed);
  writer.writeString(offsets[9], object.salaryReceiptGroupGuid);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeLong(offsets[11], object.withheldMinor);
}

MedicalWithholdingMatch _medicalWithholdingMatchDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalWithholdingMatch();
  object.affectedMonths = reader.readStringList(offsets[0]) ?? [];
  object.billGuid = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.currency = reader.readString(offsets[3]);
  object.guid = reader.readString(offsets[4]);
  object.id = id;
  object.profileId = reader.readLongOrNull(offsets[5]);
  object.reversalGuid = reader.readStringOrNull(offsets[6]);
  object.reversalReason = reader.readString(offsets[7]);
  object.reversed = reader.readBool(offsets[8]);
  object.salaryReceiptGroupGuid = reader.readString(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  object.withheldMinor = reader.readLong(offsets[11]);
  return object;
}

P _medicalWithholdingMatchDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicalWithholdingMatchGetId(MedicalWithholdingMatch object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicalWithholdingMatchGetLinks(
    MedicalWithholdingMatch object) {
  return [];
}

void _medicalWithholdingMatchAttach(
    IsarCollection<dynamic> col, Id id, MedicalWithholdingMatch object) {
  object.id = id;
}

extension MedicalWithholdingMatchByIndex
    on IsarCollection<MedicalWithholdingMatch> {
  Future<MedicalWithholdingMatch?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  MedicalWithholdingMatch? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<MedicalWithholdingMatch?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<MedicalWithholdingMatch?> getAllByGuidSync(List<String> guidValues) {
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

  Future<Id> putByGuid(MedicalWithholdingMatch object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(MedicalWithholdingMatch object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<MedicalWithholdingMatch> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<MedicalWithholdingMatch> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }
}

extension MedicalWithholdingMatchQueryWhereSort
    on QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QWhere> {
  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension MedicalWithholdingMatchQueryWhere on QueryBuilder<
    MedicalWithholdingMatch, MedicalWithholdingMatch, QWhereClause> {
  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterWhereClause> guidEqualTo(String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterWhereClause> guidNotEqualTo(String guid) {
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterWhereClause> profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterWhereClause> profileIdEqualTo(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterWhereClause> billGuidEqualTo(String billGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'billGuid',
        value: [billGuid],
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterWhereClause>
      salaryReceiptGroupGuidEqualTo(String salaryReceiptGroupGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'salaryReceiptGroupGuid',
        value: [salaryReceiptGroupGuid],
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterWhereClause>
      salaryReceiptGroupGuidNotEqualTo(String salaryReceiptGroupGuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salaryReceiptGroupGuid',
              lower: [],
              upper: [salaryReceiptGroupGuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salaryReceiptGroupGuid',
              lower: [salaryReceiptGroupGuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salaryReceiptGroupGuid',
              lower: [salaryReceiptGroupGuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salaryReceiptGroupGuid',
              lower: [],
              upper: [salaryReceiptGroupGuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MedicalWithholdingMatchQueryFilter on QueryBuilder<
    MedicalWithholdingMatch, MedicalWithholdingMatch, QFilterCondition> {
  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'affectedMonths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'affectedMonths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'affectedMonths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'affectedMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'affectedMonths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'affectedMonths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      affectedMonthsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'affectedMonths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      affectedMonthsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'affectedMonths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'affectedMonths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'affectedMonths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'affectedMonths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'affectedMonths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'affectedMonths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'affectedMonths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'affectedMonths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> affectedMonthsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'affectedMonths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> billGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> billGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> guidEqualTo(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> guidGreaterThan(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> guidLessThan(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> guidBetween(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> guidStartsWith(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> guidEndsWith(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      guidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      guidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reversalGuid',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reversalGuid',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reversalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reversalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reversalGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reversalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reversalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      reversalGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reversalGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      reversalGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reversalGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversalGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reversalGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalReasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalReasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalReasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalReasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reversalReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      reversalReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reversalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      reversalReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reversalReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversalReason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversalReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reversalReason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> reversedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reversed',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> salaryReceiptGroupGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salaryReceiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> salaryReceiptGroupGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'salaryReceiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> salaryReceiptGroupGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'salaryReceiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> salaryReceiptGroupGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'salaryReceiptGroupGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> salaryReceiptGroupGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'salaryReceiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> salaryReceiptGroupGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'salaryReceiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      salaryReceiptGroupGuidContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salaryReceiptGroupGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
          QAfterFilterCondition>
      salaryReceiptGroupGuidMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salaryReceiptGroupGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> salaryReceiptGroupGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salaryReceiptGroupGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> salaryReceiptGroupGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salaryReceiptGroupGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> withheldMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'withheldMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> withheldMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'withheldMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> withheldMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'withheldMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch,
      QAfterFilterCondition> withheldMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'withheldMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicalWithholdingMatchQueryObject on QueryBuilder<
    MedicalWithholdingMatch, MedicalWithholdingMatch, QFilterCondition> {}

extension MedicalWithholdingMatchQueryLinks on QueryBuilder<
    MedicalWithholdingMatch, MedicalWithholdingMatch, QFilterCondition> {}

extension MedicalWithholdingMatchQuerySortBy
    on QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QSortBy> {
  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByReversalGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByReversalGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByReversalReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalReason', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByReversalReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalReason', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByReversed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversed', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByReversedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversed', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortBySalaryReceiptGroupGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salaryReceiptGroupGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortBySalaryReceiptGroupGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salaryReceiptGroupGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByWithheldMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withheldMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      sortByWithheldMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withheldMinor', Sort.desc);
    });
  }
}

extension MedicalWithholdingMatchQuerySortThenBy on QueryBuilder<
    MedicalWithholdingMatch, MedicalWithholdingMatch, QSortThenBy> {
  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByBillGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByBillGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByReversalGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByReversalGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByReversalReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalReason', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByReversalReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversalReason', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByReversed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversed', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByReversedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reversed', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenBySalaryReceiptGroupGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salaryReceiptGroupGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenBySalaryReceiptGroupGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salaryReceiptGroupGuid', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByWithheldMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withheldMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QAfterSortBy>
      thenByWithheldMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withheldMinor', Sort.desc);
    });
  }
}

extension MedicalWithholdingMatchQueryWhereDistinct on QueryBuilder<
    MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct> {
  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByAffectedMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'affectedMonths');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByBillGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByReversalGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reversalGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByReversalReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reversalReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByReversed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reversed');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctBySalaryReceiptGroupGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salaryReceiptGroupGuid',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, MedicalWithholdingMatch, QDistinct>
      distinctByWithheldMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'withheldMinor');
    });
  }
}

extension MedicalWithholdingMatchQueryProperty on QueryBuilder<
    MedicalWithholdingMatch, MedicalWithholdingMatch, QQueryProperty> {
  QueryBuilder<MedicalWithholdingMatch, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, List<String>, QQueryOperations>
      affectedMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'affectedMonths');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, String, QQueryOperations>
      billGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billGuid');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, String, QQueryOperations>
      guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, int?, QQueryOperations>
      profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, String?, QQueryOperations>
      reversalGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reversalGuid');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, String, QQueryOperations>
      reversalReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reversalReason');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, bool, QQueryOperations>
      reversedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reversed');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, String, QQueryOperations>
      salaryReceiptGroupGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salaryReceiptGroupGuid');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MedicalWithholdingMatch, int, QQueryOperations>
      withheldMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'withheldMinor');
    });
  }
}
