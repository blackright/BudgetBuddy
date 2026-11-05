// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'previous_onboarding_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreviousOnboardingSettingsCollection on Isar {
  IsarCollection<PreviousOnboardingSettings> get previousOnboardingSettings =>
      this.collection();
}

const PreviousOnboardingSettingsSchema = CollectionSchema(
  name: r'AppSettings',
  id: -5633561779022347008,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'decimalPreferences': PropertySchema(
      id: 1,
      name: r'decimalPreferences',
      type: IsarType.string,
    ),
    r'transferToggle': PropertySchema(
      id: 2,
      name: r'transferToggle',
      type: IsarType.bool,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _previousOnboardingSettingsEstimateSize,
  serialize: _previousOnboardingSettingsSerialize,
  deserialize: _previousOnboardingSettingsDeserialize,
  deserializeProp: _previousOnboardingSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _previousOnboardingSettingsGetId,
  getLinks: _previousOnboardingSettingsGetLinks,
  attach: _previousOnboardingSettingsAttach,
  version: '3.1.0+1',
);

int _previousOnboardingSettingsEstimateSize(
  PreviousOnboardingSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.decimalPreferences;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _previousOnboardingSettingsSerialize(
  PreviousOnboardingSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.decimalPreferences);
  writer.writeBool(offsets[2], object.transferToggle);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

PreviousOnboardingSettings _previousOnboardingSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PreviousOnboardingSettings();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.decimalPreferences = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.transferToggle = reader.readBool(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _previousOnboardingSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _previousOnboardingSettingsGetId(PreviousOnboardingSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _previousOnboardingSettingsGetLinks(
    PreviousOnboardingSettings object) {
  return [];
}

void _previousOnboardingSettingsAttach(
    IsarCollection<dynamic> col, Id id, PreviousOnboardingSettings object) {
  object.id = id;
}

extension PreviousOnboardingSettingsQueryWhereSort on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QWhere> {
  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PreviousOnboardingSettingsQueryWhere on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QWhereClause> {
  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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
}

extension PreviousOnboardingSettingsQueryFilter on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QFilterCondition> {
  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'decimalPreferences',
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'decimalPreferences',
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decimalPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'decimalPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'decimalPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'decimalPreferences',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'decimalPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'decimalPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
          QAfterFilterCondition>
      decimalPreferencesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'decimalPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
          QAfterFilterCondition>
      decimalPreferencesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'decimalPreferences',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decimalPreferences',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> decimalPreferencesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'decimalPreferences',
        value: '',
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> transferToggleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transferToggle',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
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
}

extension PreviousOnboardingSettingsQueryObject on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QFilterCondition> {}

extension PreviousOnboardingSettingsQueryLinks on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QFilterCondition> {}

extension PreviousOnboardingSettingsQuerySortBy on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QSortBy> {
  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> sortByDecimalPreferences() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decimalPreferences', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> sortByDecimalPreferencesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decimalPreferences', Sort.desc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> sortByTransferToggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferToggle', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> sortByTransferToggleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferToggle', Sort.desc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PreviousOnboardingSettingsQuerySortThenBy on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QSortThenBy> {
  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByDecimalPreferences() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decimalPreferences', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByDecimalPreferencesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decimalPreferences', Sort.desc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByTransferToggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferToggle', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByTransferToggleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferToggle', Sort.desc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PreviousOnboardingSettingsQueryWhereDistinct on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QDistinct> {
  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QDistinct> distinctByDecimalPreferences({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decimalPreferences',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QDistinct> distinctByTransferToggle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transferToggle');
    });
  }

  QueryBuilder<PreviousOnboardingSettings, PreviousOnboardingSettings,
      QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PreviousOnboardingSettingsQueryProperty on QueryBuilder<
    PreviousOnboardingSettings, PreviousOnboardingSettings, QQueryProperty> {
  QueryBuilder<PreviousOnboardingSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PreviousOnboardingSettings, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PreviousOnboardingSettings, String?, QQueryOperations>
      decimalPreferencesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decimalPreferences');
    });
  }

  QueryBuilder<PreviousOnboardingSettings, bool, QQueryOperations>
      transferToggleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transferToggle');
    });
  }

  QueryBuilder<PreviousOnboardingSettings, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
