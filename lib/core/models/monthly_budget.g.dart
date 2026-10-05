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
      type: IsarType.byte,
      enumMap: _MonthlyBudgetcurrencyEnumValueMap,
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
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'yearMonth': PropertySchema(
      id: 6,
      name: r'yearMonth',
      type: IsarType.string,
    )
  },
  estimateSize: _monthlyBudgetEstimateSize,
  serialize: _monthlyBudgetSerialize,
  deserialize: _monthlyBudgetDeserialize,
  deserializeProp: _monthlyBudgetDeserializeProp,
  idName: r'id',
  indexes: {},
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
  writer.writeByte(offsets[2], object.currency.index);
  writer.writeDouble(offsets[3], object.netSalaryOverride);
  writer.writeBool(offsets[4], object.openingBalanceConfirmed);
  writer.writeDateTime(offsets[5], object.updatedAt);
  writer.writeString(offsets[6], object.yearMonth);
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
  object.currency =
      _MonthlyBudgetcurrencyValueEnumMap[reader.readByteOrNull(offsets[2])] ??
          PrimaryCurrency.huf;
  object.id = id;
  object.netSalaryOverride = reader.readDoubleOrNull(offsets[3]);
  object.openingBalanceConfirmed = reader.readBool(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  object.yearMonth = reader.readString(offsets[6]);
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
      return (_MonthlyBudgetcurrencyValueEnumMap[
              reader.readByteOrNull(offset)] ??
          PrimaryCurrency.huf) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MonthlyBudgetcurrencyEnumValueMap = {
  'huf': 0,
  'usd': 1,
  'cad': 2,
  'eur': 3,
};
const _MonthlyBudgetcurrencyValueEnumMap = {
  0: PrimaryCurrency.huf,
  1: PrimaryCurrency.usd,
  2: PrimaryCurrency.cad,
  3: PrimaryCurrency.eur,
};

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
      currencyEqualTo(PrimaryCurrency value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      currencyBetween(
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

  QueryBuilder<MonthlyBudget, MonthlyBudget, QDistinct> distinctByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency');
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

  QueryBuilder<MonthlyBudget, PrimaryCurrency, QQueryOperations>
      currencyProperty() {
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
