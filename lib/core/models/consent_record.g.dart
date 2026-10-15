// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConsentRecordCollection on Isar {
  IsarCollection<ConsentRecord> get consentRecords => this.collection();
}

const ConsentRecordSchema = CollectionSchema(
  name: r'ConsentRecord',
  id: 6375593322555024416,
  properties: {
    r'decidedAt': PropertySchema(
      id: 0,
      name: r'decidedAt',
      type: IsarType.dateTime,
    ),
    r'deviceAuthGranted': PropertySchema(
      id: 1,
      name: r'deviceAuthGranted',
      type: IsarType.bool,
    ),
    r'noticeVersion': PropertySchema(
      id: 2,
      name: r'noticeVersion',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _consentRecordEstimateSize,
  serialize: _consentRecordSerialize,
  deserialize: _consentRecordDeserialize,
  deserializeProp: _consentRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _consentRecordGetId,
  getLinks: _consentRecordGetLinks,
  attach: _consentRecordAttach,
  version: '3.1.0+1',
);

int _consentRecordEstimateSize(
  ConsentRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.noticeVersion.length * 3;
  return bytesCount;
}

void _consentRecordSerialize(
  ConsentRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.decidedAt);
  writer.writeBool(offsets[1], object.deviceAuthGranted);
  writer.writeString(offsets[2], object.noticeVersion);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

ConsentRecord _consentRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ConsentRecord();
  object.decidedAt = reader.readDateTime(offsets[0]);
  object.deviceAuthGranted = reader.readBool(offsets[1]);
  object.id = id;
  object.noticeVersion = reader.readString(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _consentRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _consentRecordGetId(ConsentRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _consentRecordGetLinks(ConsentRecord object) {
  return [];
}

void _consentRecordAttach(
    IsarCollection<dynamic> col, Id id, ConsentRecord object) {
  object.id = id;
}

extension ConsentRecordQueryWhereSort
    on QueryBuilder<ConsentRecord, ConsentRecord, QWhere> {
  QueryBuilder<ConsentRecord, ConsentRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ConsentRecordQueryWhere
    on QueryBuilder<ConsentRecord, ConsentRecord, QWhereClause> {
  QueryBuilder<ConsentRecord, ConsentRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterWhereClause> idBetween(
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

extension ConsentRecordQueryFilter
    on QueryBuilder<ConsentRecord, ConsentRecord, QFilterCondition> {
  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      decidedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      decidedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'decidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      decidedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'decidedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      decidedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'decidedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      deviceAuthGrantedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceAuthGranted',
        value: value,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
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

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noticeVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'noticeVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'noticeVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'noticeVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'noticeVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'noticeVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'noticeVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'noticeVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noticeVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      noticeVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'noticeVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
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

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
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

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterFilterCondition>
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

extension ConsentRecordQueryObject
    on QueryBuilder<ConsentRecord, ConsentRecord, QFilterCondition> {}

extension ConsentRecordQueryLinks
    on QueryBuilder<ConsentRecord, ConsentRecord, QFilterCondition> {}

extension ConsentRecordQuerySortBy
    on QueryBuilder<ConsentRecord, ConsentRecord, QSortBy> {
  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy> sortByDecidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decidedAt', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      sortByDecidedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decidedAt', Sort.desc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      sortByDeviceAuthGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceAuthGranted', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      sortByDeviceAuthGrantedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceAuthGranted', Sort.desc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      sortByNoticeVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noticeVersion', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      sortByNoticeVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noticeVersion', Sort.desc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ConsentRecordQuerySortThenBy
    on QueryBuilder<ConsentRecord, ConsentRecord, QSortThenBy> {
  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy> thenByDecidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decidedAt', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      thenByDecidedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decidedAt', Sort.desc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      thenByDeviceAuthGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceAuthGranted', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      thenByDeviceAuthGrantedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceAuthGranted', Sort.desc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      thenByNoticeVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noticeVersion', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      thenByNoticeVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noticeVersion', Sort.desc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ConsentRecordQueryWhereDistinct
    on QueryBuilder<ConsentRecord, ConsentRecord, QDistinct> {
  QueryBuilder<ConsentRecord, ConsentRecord, QDistinct> distinctByDecidedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decidedAt');
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QDistinct>
      distinctByDeviceAuthGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceAuthGranted');
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QDistinct> distinctByNoticeVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'noticeVersion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConsentRecord, ConsentRecord, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ConsentRecordQueryProperty
    on QueryBuilder<ConsentRecord, ConsentRecord, QQueryProperty> {
  QueryBuilder<ConsentRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ConsentRecord, DateTime, QQueryOperations> decidedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decidedAt');
    });
  }

  QueryBuilder<ConsentRecord, bool, QQueryOperations>
      deviceAuthGrantedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceAuthGranted');
    });
  }

  QueryBuilder<ConsentRecord, String, QQueryOperations>
      noticeVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'noticeVersion');
    });
  }

  QueryBuilder<ConsentRecord, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
