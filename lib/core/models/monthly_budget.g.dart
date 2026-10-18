// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_budget.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMonthlyBudgetCollection on Isar {
  IsarCollection<MonthlyBudget> get monthlyBudgets => this.collection();
}

const MonthlyBudgetSchema = CollectionSchema(
  name: r'MonthlyBudget',
  id: -5743211326019024722,
  properties: {
    r'baseAvailableAmount': PropertySchema(
      id: 0,
      name: r'baseAvailableAmount',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 2,
      name: r'currency',
      type: IsarType.string,
    ),
    r'netSalaryOverride': PropertySchema(
      id: 3,
      name: r'netSalaryOverride',
      type: IsarType.double,
    ),
    r'openingBalanceConfirmed': PropertySchema(
      id: 4,
      name: r'openingBalanceConfirmed',
      type: IsarType.bool,
    ),
    r'profileId': PropertySchema(
      id: 5,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'sharedIncomeOverride': PropertySchema(
      id: 6,
      name: r'sharedIncomeOverride',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 7,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'syncGuid': PropertySchema(
      id: 8,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'yearMonth': PropertySchema(
      id: 10,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _monthlyBudgetEstimateSize,
  serialize: _monthlyBudgetSerialize,
  deserialize: _monthlyBudgetDeserialize,
  deserializeProp: _monthlyBudgetDeserializeProp,
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
    ),
    r'profileId_sharedSpaceId_yearMonth': IndexSchema(
      id: -1016589773913284345,
      name: r'profileId_sharedSpaceId_yearMonth',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'profileId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'sharedSpaceId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'yearMonth',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _monthlyBudgetGetId,
  getLinks: _monthlyBudgetGetLinks,
  attach: _monthlyBudgetAttach,
  version: '3.1.0+1',
);

int _monthlyBudgetEstimateSize(
  MonthlyBudget object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.currency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _monthlyBudgetSerialize(
  MonthlyBudget object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.baseAvailableAmount);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.currency);
  writer.writeDouble(offsets[3], object.netSalaryOverride);
  writer.writeBool(offsets[4], object.openingBalanceConfirmed);
  writer.writeLong(offsets[5], object.profileId);
  writer.writeLong(offsets[6], object.sharedIncomeOverride);
  writer.writeLong(offsets[7], object.sharedSpaceId);
  writer.writeString(offsets[8], object.syncGuid);
  writer.writeDateTime(offsets[9], object.updatedAt);
  writer.writeString(offsets[10], object.yearMonth);
}

MonthlyBudget _monthlyBudgetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MonthlyBudget();
  object.baseAvailableAmount = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.currency = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.netSalaryOverride = reader.readDoubleOrNull(offsets[3]);
  object.openingBalanceConfirmed = reader.readBool(offsets[4]);
  object.profileId = reader.readLongOrNull(offsets[5]);
  object.sharedIncomeOverride = reader.readLongOrNull(offsets[6]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[7]);
  object.syncGuid = reader.readString(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  object.yearMonth = reader.readString(offsets[10]);
  return object;
}

P _monthlyBudgetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _monthlyBudgetGetId(MonthlyBudget object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _monthlyBudgetGetLinks(MonthlyBudget object) {
  return [];
}

void _monthlyBudgetAttach(
    IsarCollection<dynamic> col, Id id, MonthlyBudget object) {
  object.id = id;
}

extension MonthlyBudgetByIndex on IsarCollection<MonthlyBudget> {
  Future<MonthlyBudget?> getByProfileIdSharedSpaceIdYearMonth(
      int? profileId, int? sharedSpaceId, String yearMonth) {
    return getByIndex(r'profileId_sharedSpaceId_yearMonth',
        [profileId, sharedSpaceId, yearMonth]);
  }

  MonthlyBudget? getByProfileIdSharedSpaceIdYearMonthSync(
      int? profileId, int? sharedSpaceId, String yearMonth) {
    return getByIndexSync(r'profileId_sharedSpaceId_yearMonth',
        [profileId, sharedSpaceId, yearMonth]);
  }

  Future<bool> deleteByProfileIdSharedSpaceIdYearMonth(
      int? profileId, int? sharedSpaceId, String yearMonth) {
    return deleteByIndex(r'profileId_sharedSpaceId_yearMonth',
        [profileId, sharedSpaceId, yearMonth]);
  }

  bool deleteByProfileIdSharedSpaceIdYearMonthSync(
      int? profileId, int? sharedSpaceId, String yearMonth) {
    return deleteByIndexSync(r'profileId_sharedSpaceId_yearMonth',
        [profileId, sharedSpaceId, yearMonth]);
  }

  Future<List<MonthlyBudget?>> getAllByProfileIdSharedSpaceIdYearMonth(
      List<int?> profileIdValues,
      List<int?> sharedSpaceIdValues,
      List<String> yearMonthValues) {
    final len = profileIdValues.length;
    assert(sharedSpaceIdValues.length == len && yearMonthValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add(
          [profileIdValues[i], sharedSpaceIdValues[i], yearMonthValues[i]]);
    }

    return getAllByIndex(r'profileId_sharedSpaceId_yearMonth', values);
  }

  List<MonthlyBudget?> getAllByProfileIdSharedSpaceIdYearMonthSync(
      List<int?> profileIdValues,
      List<int?> sharedSpaceIdValues,
      List<String> yearMonthValues) {
    final len = profileIdValues.length;
    assert(sharedSpaceIdValues.length == len && yearMonthValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add(
          [profileIdValues[i], sharedSpaceIdValues[i], yearMonthValues[i]]);
    }

    return getAllByIndexSync(r'profileId_sharedSpaceId_yearMonth', values);
  }

  Future<int> deleteAllByProfileIdSharedSpaceIdYearMonth(
      List<int?> profileIdValues,
      List<int?> sharedSpaceIdValues,
      List<String> yearMonthValues) {
    final len = profileIdValues.length;
    assert(sharedSpaceIdValues.length == len && yearMonthValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add(
          [profileIdValues[i], sharedSpaceIdValues[i], yearMonthValues[i]]);
    }

    return deleteAllByIndex(r'profileId_sharedSpaceId_yearMonth', values);
  }

  int deleteAllByProfileIdSharedSpaceIdYearMonthSync(List<int?> profileIdValues,
      List<int?> sharedSpaceIdValues, List<String> yearMonthValues) {
    final len = profileIdValues.length;
    assert(sharedSpaceIdValues.length == len && yearMonthValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add(
          [profileIdValues[i], sharedSpaceIdValues[i], yearMonthValues[i]]);
    }

    return deleteAllByIndexSync(r'profileId_sharedSpaceId_yearMonth', values);
  }

  Future<Id> putByProfileIdSharedSpaceIdYearMonth(MonthlyBudget object) {
    return putByIndex(r'profileId_sharedSpaceId_yearMonth', object);
  }

  Id putByProfileIdSharedSpaceIdYearMonthSync(MonthlyBudget object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'profileId_sharedSpaceId_yearMonth', object,
        saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProfileIdSharedSpaceIdYearMonth(
      List<MonthlyBudget> objects) {
    return putAllByIndex(r'profileId_sharedSpaceId_yearMonth', objects);
  }

  List<Id> putAllByProfileIdSharedSpaceIdYearMonthSync(
      List<MonthlyBudget> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'profileId_sharedSpaceId_yearMonth', objects,
        saveLinks: saveLinks);
  }
}

extension MonthlyBudgetQueryWhereSort
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QWhere> {
  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MonthlyBudgetQueryWhere
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QWhereClause> {
  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause> idBetween(
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause> syncGuidEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdIsNullAnySharedSpaceIdYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        value: [null],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdIsNotNullAnySharedSpaceIdYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdEqualToAnySharedSpaceIdYearMonth(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdNotEqualToAnySharedSpaceIdYearMonth(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [],
              upper: [profileId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdGreaterThanAnySharedSpaceIdYearMonth(
    int? profileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        lower: [profileId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdLessThanAnySharedSpaceIdYearMonth(
    int? profileId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        lower: [],
        upper: [profileId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdBetweenAnySharedSpaceIdYearMonth(
    int? lowerProfileId,
    int? upperProfileId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        lower: [lowerProfileId],
        includeLower: includeLower,
        upper: [upperProfileId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdEqualToSharedSpaceIdIsNullAnyYearMonth(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        value: [profileId, null],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdEqualToSharedSpaceIdIsNotNullAnyYearMonth(int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        lower: [profileId, null],
        includeLower: false,
        upper: [
          profileId,
        ],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdSharedSpaceIdEqualToAnyYearMonth(
          int? profileId, int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        value: [profileId, sharedSpaceId],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdEqualToSharedSpaceIdNotEqualToAnyYearMonth(
          int? profileId, int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId],
              upper: [profileId, sharedSpaceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId, sharedSpaceId],
              includeLower: false,
              upper: [profileId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId, sharedSpaceId],
              includeLower: false,
              upper: [profileId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId],
              upper: [profileId, sharedSpaceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdEqualToSharedSpaceIdGreaterThanAnyYearMonth(
    int? profileId,
    int? sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        lower: [profileId, sharedSpaceId],
        includeLower: include,
        upper: [profileId],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdEqualToSharedSpaceIdLessThanAnyYearMonth(
    int? profileId,
    int? sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        lower: [profileId],
        upper: [profileId, sharedSpaceId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdEqualToSharedSpaceIdBetweenAnyYearMonth(
    int? profileId,
    int? lowerSharedSpaceId,
    int? upperSharedSpaceId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        lower: [profileId, lowerSharedSpaceId],
        includeLower: includeLower,
        upper: [profileId, upperSharedSpaceId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdSharedSpaceIdYearMonthEqualTo(
          int? profileId, int? sharedSpaceId, String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId_sharedSpaceId_yearMonth',
        value: [profileId, sharedSpaceId, yearMonth],
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterWhereClause>
      profileIdSharedSpaceIdEqualToYearMonthNotEqualTo(
          int? profileId, int? sharedSpaceId, String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId, sharedSpaceId],
              upper: [profileId, sharedSpaceId, yearMonth],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId, sharedSpaceId, yearMonth],
              includeLower: false,
              upper: [profileId, sharedSpaceId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId, sharedSpaceId, yearMonth],
              includeLower: false,
              upper: [profileId, sharedSpaceId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profileId_sharedSpaceId_yearMonth',
              lower: [profileId, sharedSpaceId],
              upper: [profileId, sharedSpaceId, yearMonth],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MonthlyBudgetQueryFilter
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QFilterCondition> {
  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      baseAvailableAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseAvailableAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      baseAvailableAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseAvailableAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      baseAvailableAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseAvailableAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      baseAvailableAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseAvailableAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currency',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currency',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyEqualTo(
    String? value, {
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyGreaterThan(
    String? value, {
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyLessThan(
    String? value, {
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      netSalaryOverrideIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'netSalaryOverride',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      netSalaryOverrideIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'netSalaryOverride',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      netSalaryOverrideEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'netSalaryOverride',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      netSalaryOverrideGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'netSalaryOverride',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      netSalaryOverrideLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'netSalaryOverride',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      netSalaryOverrideBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'netSalaryOverride',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      openingBalanceConfirmedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openingBalanceConfirmed',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedIncomeOverrideIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedIncomeOverride',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedIncomeOverrideIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedIncomeOverride',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedIncomeOverrideEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedIncomeOverride',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedIncomeOverrideGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharedIncomeOverride',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedIncomeOverrideLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharedIncomeOverride',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedIncomeOverrideBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharedIncomeOverride',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      syncGuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
      ));
    });
  }
}

extension MonthlyBudgetQueryObject
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QFilterCondition> {}

extension MonthlyBudgetQueryLinks
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QFilterCondition> {}

extension MonthlyBudgetQuerySortBy
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QSortBy> {
  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByBaseAvailableAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseAvailableAmount', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByBaseAvailableAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseAvailableAmount', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByNetSalaryOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netSalaryOverride', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByNetSalaryOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netSalaryOverride', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByOpeningBalanceConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingBalanceConfirmed', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByOpeningBalanceConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingBalanceConfirmed', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortBySharedIncomeOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedIncomeOverride', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortBySharedIncomeOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedIncomeOverride', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MonthlyBudgetQuerySortThenBy
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QSortThenBy> {
  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByBaseAvailableAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseAvailableAmount', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByBaseAvailableAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseAvailableAmount', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByNetSalaryOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netSalaryOverride', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByNetSalaryOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netSalaryOverride', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByOpeningBalanceConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingBalanceConfirmed', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByOpeningBalanceConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingBalanceConfirmed', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenBySharedIncomeOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedIncomeOverride', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenBySharedIncomeOverrideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedIncomeOverride', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy> thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MonthlyBudgetQueryWhereDistinct
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct> {
  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct>
      distinctByBaseAvailableAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseAvailableAmount');
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct>
      distinctByNetSalaryOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'netSalaryOverride');
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct>
      distinctByOpeningBalanceConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openingBalanceConfirmed');
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct>
      distinctBySharedIncomeOverride() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedIncomeOverride');
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct>
      distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
    });
  }
}

extension MonthlyBudgetQueryProperty
    on QueryBuilder<MonthlyBudget, MonthlyBudget, QQueryProperty> {
  QueryBuilder<MonthlyBudget, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MonthlyBudget, double, QQueryOperations>
      baseAvailableAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseAvailableAmount');
    });
  }

  QueryBuilder<MonthlyBudget, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MonthlyBudget, String?, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MonthlyBudget, double?, QQueryOperations>
      netSalaryOverrideProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'netSalaryOverride');
    });
  }

  QueryBuilder<MonthlyBudget, bool, QQueryOperations>
      openingBalanceConfirmedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openingBalanceConfirmed');
    });
  }

  QueryBuilder<MonthlyBudget, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MonthlyBudget, int?, QQueryOperations>
      sharedIncomeOverrideProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedIncomeOverride');
    });
  }

  QueryBuilder<MonthlyBudget, int?, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<MonthlyBudget, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<MonthlyBudget, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MonthlyBudget, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
