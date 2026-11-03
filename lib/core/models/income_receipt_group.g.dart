// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_receipt_group.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIncomeReceiptGroupCollection on Isar {
  IsarCollection<IncomeReceiptGroup> get incomeReceiptGroups =>
      this.collection();
}

const IncomeReceiptGroupSchema = CollectionSchema(
  name: r'IncomeReceiptGroup',
  id: 1879275748461145010,
  properties: {
    r'actualDate': PropertySchema(
      id: 0,
      name: r'actualDate',
      type: IsarType.dateTime,
    ),
    r'componentReceiptGuids': PropertySchema(
      id: 1,
      name: r'componentReceiptGuids',
      type: IsarType.stringList,
    ),
    r'componentRevisionRefs': PropertySchema(
      id: 2,
      name: r'componentRevisionRefs',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 4,
      name: r'currency',
      type: IsarType.string,
    ),
    r'cycleGuid': PropertySchema(
      id: 5,
      name: r'cycleGuid',
      type: IsarType.string,
    ),
    r'destinationMonth': PropertySchema(
      id: 6,
      name: r'destinationMonth',
      type: IsarType.string,
    ),
    r'fingerprint': PropertySchema(
      id: 7,
      name: r'fingerprint',
      type: IsarType.string,
    ),
    r'guid': PropertySchema(
      id: 8,
      name: r'guid',
      type: IsarType.string,
    ),
    r'operationIdentity': PropertySchema(
      id: 9,
      name: r'operationIdentity',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 10,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'sourceGuid': PropertySchema(
      id: 11,
      name: r'sourceGuid',
      type: IsarType.string,
    ),
    r'timezone': PropertySchema(
      id: 12,
      name: r'timezone',
      type: IsarType.string,
    ),
    r'totalMinor': PropertySchema(
      id: 13,
      name: r'totalMinor',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _incomeReceiptGroupEstimateSize,
  serialize: _incomeReceiptGroupSerialize,
  deserialize: _incomeReceiptGroupDeserialize,
  deserializeProp: _incomeReceiptGroupDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _incomeReceiptGroupGetId,
  getLinks: _incomeReceiptGroupGetLinks,
  attach: _incomeReceiptGroupAttach,
  version: '3.1.0+1',
);

int _incomeReceiptGroupEstimateSize(
  IncomeReceiptGroup object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.componentReceiptGuids.length * 3;
  {
    for (var i = 0; i < object.componentReceiptGuids.length; i++) {
      final value = object.componentReceiptGuids[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.componentRevisionRefs.length * 3;
  {
    for (var i = 0; i < object.componentRevisionRefs.length; i++) {
      final value = object.componentRevisionRefs[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.cycleGuid.length * 3;
  bytesCount += 3 + object.destinationMonth.length * 3;
  bytesCount += 3 + object.fingerprint.length * 3;
  bytesCount += 3 + object.guid.length * 3;
  bytesCount += 3 + object.operationIdentity.length * 3;
  bytesCount += 3 + object.sourceGuid.length * 3;
  bytesCount += 3 + object.timezone.length * 3;
  return bytesCount;
}

void _incomeReceiptGroupSerialize(
  IncomeReceiptGroup object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.actualDate);
  writer.writeStringList(offsets[1], object.componentReceiptGuids);
  writer.writeStringList(offsets[2], object.componentRevisionRefs);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.currency);
  writer.writeString(offsets[5], object.cycleGuid);
  writer.writeString(offsets[6], object.destinationMonth);
  writer.writeString(offsets[7], object.fingerprint);
  writer.writeString(offsets[8], object.guid);
  writer.writeString(offsets[9], object.operationIdentity);
  writer.writeLong(offsets[10], object.profileId);
  writer.writeString(offsets[11], object.sourceGuid);
  writer.writeString(offsets[12], object.timezone);
  writer.writeLong(offsets[13], object.totalMinor);
  writer.writeDateTime(offsets[14], object.updatedAt);
}

IncomeReceiptGroup _incomeReceiptGroupDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IncomeReceiptGroup();
  object.actualDate = reader.readDateTime(offsets[0]);
  object.componentReceiptGuids = reader.readStringList(offsets[1]) ?? [];
  object.componentRevisionRefs = reader.readStringList(offsets[2]) ?? [];
  object.createdAt = reader.readDateTime(offsets[3]);
  object.currency = reader.readString(offsets[4]);
  object.cycleGuid = reader.readString(offsets[5]);
  object.destinationMonth = reader.readString(offsets[6]);
  object.fingerprint = reader.readString(offsets[7]);
  object.guid = reader.readString(offsets[8]);
  object.id = id;
  object.operationIdentity = reader.readString(offsets[9]);
  object.profileId = reader.readLongOrNull(offsets[10]);
  object.sourceGuid = reader.readString(offsets[11]);
  object.timezone = reader.readString(offsets[12]);
  object.totalMinor = reader.readLong(offsets[13]);
  object.updatedAt = reader.readDateTime(offsets[14]);
  return object;
}

P _incomeReceiptGroupDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _incomeReceiptGroupGetId(IncomeReceiptGroup object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _incomeReceiptGroupGetLinks(
    IncomeReceiptGroup object) {
  return [];
}

void _incomeReceiptGroupAttach(
    IsarCollection<dynamic> col, Id id, IncomeReceiptGroup object) {
  object.id = id;
}

extension IncomeReceiptGroupByIndex on IsarCollection<IncomeReceiptGroup> {
  Future<IncomeReceiptGroup?> getByGuid(String guid) {
    return getByIndex(r'guid', [guid]);
  }

  IncomeReceiptGroup? getByGuidSync(String guid) {
    return getByIndexSync(r'guid', [guid]);
  }

  Future<bool> deleteByGuid(String guid) {
    return deleteByIndex(r'guid', [guid]);
  }

  bool deleteByGuidSync(String guid) {
    return deleteByIndexSync(r'guid', [guid]);
  }

  Future<List<IncomeReceiptGroup?>> getAllByGuid(List<String> guidValues) {
    final values = guidValues.map((e) => [e]).toList();
    return getAllByIndex(r'guid', values);
  }

  List<IncomeReceiptGroup?> getAllByGuidSync(List<String> guidValues) {
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

  Future<Id> putByGuid(IncomeReceiptGroup object) {
    return putByIndex(r'guid', object);
  }

  Id putByGuidSync(IncomeReceiptGroup object, {bool saveLinks = true}) {
    return putByIndexSync(r'guid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGuid(List<IncomeReceiptGroup> objects) {
    return putAllByIndex(r'guid', objects);
  }

  List<Id> putAllByGuidSync(List<IncomeReceiptGroup> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'guid', objects, saveLinks: saveLinks);
  }
}

extension IncomeReceiptGroupQueryWhereSort
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QWhere> {
  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhere>
      anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension IncomeReceiptGroupQueryWhere
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QWhereClause> {
  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
      guidEqualTo(String guid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'guid',
        value: [guid],
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
      guidNotEqualTo(String guid) {
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
      profileIdEqualTo(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterWhereClause>
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
}

extension IncomeReceiptGroupQueryFilter
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QFilterCondition> {
  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      actualDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      actualDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      actualDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      actualDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'componentReceiptGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'componentReceiptGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'componentReceiptGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'componentReceiptGuids',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'componentReceiptGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'componentReceiptGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'componentReceiptGuids',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'componentReceiptGuids',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'componentReceiptGuids',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'componentReceiptGuids',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentReceiptGuids',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentReceiptGuids',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentReceiptGuids',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentReceiptGuids',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentReceiptGuids',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentReceiptGuidsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentReceiptGuids',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'componentRevisionRefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'componentRevisionRefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'componentRevisionRefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'componentRevisionRefs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'componentRevisionRefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'componentRevisionRefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'componentRevisionRefs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'componentRevisionRefs',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'componentRevisionRefs',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'componentRevisionRefs',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentRevisionRefs',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentRevisionRefs',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentRevisionRefs',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentRevisionRefs',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentRevisionRefs',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      componentRevisionRefsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'componentRevisionRefs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cycleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cycleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cycleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cycleGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cycleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cycleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cycleGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cycleGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cycleGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      cycleGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cycleGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'destinationMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'destinationMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'destinationMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'destinationMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      destinationMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'destinationMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      fingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidEqualTo(
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidGreaterThan(
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidLessThan(
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidBetween(
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidStartsWith(
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidEndsWith(
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'guid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'guid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      guidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'guid',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      operationIdentityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationIdentity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      operationIdentityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationIdentity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      operationIdentityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      operationIdentityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationIdentity',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceGuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      sourceGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timezone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'timezone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'timezone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timezone',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      timezoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'timezone',
        value: '',
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      totalMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      totalMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      totalMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      totalMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      updatedAtGreaterThan(
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterFilterCondition>
      updatedAtBetween(
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
}

extension IncomeReceiptGroupQueryObject
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QFilterCondition> {}

extension IncomeReceiptGroupQueryLinks
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QFilterCondition> {}

extension IncomeReceiptGroupQuerySortBy
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QSortBy> {
  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByActualDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDate', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByActualDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDate', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByCycleGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleGuid', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByCycleGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleGuid', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByDestinationMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByDestinationMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortBySourceGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortBySourceGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IncomeReceiptGroupQuerySortThenBy
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QSortThenBy> {
  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByActualDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDate', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByActualDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDate', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByCycleGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleGuid', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByCycleGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cycleGuid', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByDestinationMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByDestinationMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'destinationMonth', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guid', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByOperationIdentity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByOperationIdentityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationIdentity', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenBySourceGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenBySourceGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceGuid', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timezone', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByTotalMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMinor', Sort.desc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IncomeReceiptGroupQueryWhereDistinct
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct> {
  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByActualDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualDate');
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByComponentReceiptGuids() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'componentReceiptGuids');
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByComponentRevisionRefs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'componentRevisionRefs');
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByCycleGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cycleGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByDestinationMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'destinationMonth',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByFingerprint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fingerprint', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByOperationIdentity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationIdentity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctBySourceGuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByTimezone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timezone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByTotalMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMinor');
    });
  }

  QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension IncomeReceiptGroupQueryProperty
    on QueryBuilder<IncomeReceiptGroup, IncomeReceiptGroup, QQueryProperty> {
  QueryBuilder<IncomeReceiptGroup, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IncomeReceiptGroup, DateTime, QQueryOperations>
      actualDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualDate');
    });
  }

  QueryBuilder<IncomeReceiptGroup, List<String>, QQueryOperations>
      componentReceiptGuidsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'componentReceiptGuids');
    });
  }

  QueryBuilder<IncomeReceiptGroup, List<String>, QQueryOperations>
      componentRevisionRefsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'componentRevisionRefs');
    });
  }

  QueryBuilder<IncomeReceiptGroup, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IncomeReceiptGroup, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<IncomeReceiptGroup, String, QQueryOperations>
      cycleGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cycleGuid');
    });
  }

  QueryBuilder<IncomeReceiptGroup, String, QQueryOperations>
      destinationMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'destinationMonth');
    });
  }

  QueryBuilder<IncomeReceiptGroup, String, QQueryOperations>
      fingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fingerprint');
    });
  }

  QueryBuilder<IncomeReceiptGroup, String, QQueryOperations> guidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guid');
    });
  }

  QueryBuilder<IncomeReceiptGroup, String, QQueryOperations>
      operationIdentityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationIdentity');
    });
  }

  QueryBuilder<IncomeReceiptGroup, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<IncomeReceiptGroup, String, QQueryOperations>
      sourceGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceGuid');
    });
  }

  QueryBuilder<IncomeReceiptGroup, String, QQueryOperations>
      timezoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timezone');
    });
  }

  QueryBuilder<IncomeReceiptGroup, int, QQueryOperations> totalMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMinor');
    });
  }

  QueryBuilder<IncomeReceiptGroup, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
