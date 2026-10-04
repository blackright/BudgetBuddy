// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_bill.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicalBillCollection on Isar {
  IsarCollection<MedicalBill> get medicalBills => this.collection();
}

const MedicalBillSchema = CollectionSchema(
  name: r'MedicalBill',
  id: -5833106467415866040,
  properties: {
    r'attachmentPaths': PropertySchema(
      id: 0,
      name: r'attachmentPaths',
      type: IsarType.stringList,
    ),
    r'billedAmount': PropertySchema(
      id: 1,
      name: r'billedAmount',
      type: IsarType.double,
    ),
    r'claimStatus': PropertySchema(
      id: 2,
      name: r'claimStatus',
      type: IsarType.byte,
      enumMap: _MedicalBillclaimStatusEnumValueMap,
    ),
    r'familyMemberId': PropertySchema(
      id: 3,
      name: r'familyMemberId',
      type: IsarType.long,
    ),
    r'followUpDate': PropertySchema(
      id: 4,
      name: r'followUpDate',
      type: IsarType.dateTime,
    ),
    r'insuranceCoveragePercent': PropertySchema(
      id: 5,
      name: r'insuranceCoveragePercent',
      type: IsarType.double,
    ),
    r'linkedExpenseId': PropertySchema(
      id: 6,
      name: r'linkedExpenseId',
      type: IsarType.long,
    ),
    r'profileId': PropertySchema(
      id: 7,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'providerId': PropertySchema(
      id: 8,
      name: r'providerId',
      type: IsarType.long,
    ),
    r'reimbursedAmount': PropertySchema(
      id: 9,
      name: r'reimbursedAmount',
      type: IsarType.double,
    ),
    r'serviceDate': PropertySchema(
      id: 10,
      name: r'serviceDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _medicalBillEstimateSize,
  serialize: _medicalBillSerialize,
  deserialize: _medicalBillDeserialize,
  deserializeProp: _medicalBillDeserializeProp,
  idName: r'id',
  indexes: {
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
    r'linkedExpenseId': IndexSchema(
      id: -8722540768232253689,
      name: r'linkedExpenseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'linkedExpenseId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'familyMemberId': IndexSchema(
      id: -1758271576359690709,
      name: r'familyMemberId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'familyMemberId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'providerId': IndexSchema(
      id: -1675978104265523206,
      name: r'providerId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'providerId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _medicalBillGetId,
  getLinks: _medicalBillGetLinks,
  attach: _medicalBillAttach,
  version: '3.1.0+1',
);

int _medicalBillEstimateSize(
  MedicalBill object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.attachmentPaths.length * 3;
  {
    for (var i = 0; i < object.attachmentPaths.length; i++) {
      final value = object.attachmentPaths[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _medicalBillSerialize(
  MedicalBill object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.attachmentPaths);
  writer.writeDouble(offsets[1], object.billedAmount);
  writer.writeByte(offsets[2], object.claimStatus.index);
  writer.writeLong(offsets[3], object.familyMemberId);
  writer.writeDateTime(offsets[4], object.followUpDate);
  writer.writeDouble(offsets[5], object.insuranceCoveragePercent);
  writer.writeLong(offsets[6], object.linkedExpenseId);
  writer.writeLong(offsets[7], object.profileId);
  writer.writeLong(offsets[8], object.providerId);
  writer.writeDouble(offsets[9], object.reimbursedAmount);
  writer.writeDateTime(offsets[10], object.serviceDate);
}

MedicalBill _medicalBillDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalBill();
  object.attachmentPaths = reader.readStringList(offsets[0]) ?? [];
  object.billedAmount = reader.readDouble(offsets[1]);
  object.claimStatus =
      _MedicalBillclaimStatusValueEnumMap[reader.readByteOrNull(offsets[2])] ??
          ClaimStatus.unclaimed;
  object.familyMemberId = reader.readLongOrNull(offsets[3]);
  object.followUpDate = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.insuranceCoveragePercent = reader.readDouble(offsets[5]);
  object.linkedExpenseId = reader.readLongOrNull(offsets[6]);
  object.profileId = reader.readLongOrNull(offsets[7]);
  object.providerId = reader.readLongOrNull(offsets[8]);
  object.reimbursedAmount = reader.readDouble(offsets[9]);
  object.serviceDate = reader.readDateTimeOrNull(offsets[10]);
  return object;
}

P _medicalBillDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (_MedicalBillclaimStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ClaimStatus.unclaimed) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MedicalBillclaimStatusEnumValueMap = {
  'unclaimed': 0,
  'processing': 1,
  'reimbursed': 2,
  'denied': 3,
};
const _MedicalBillclaimStatusValueEnumMap = {
  0: ClaimStatus.unclaimed,
  1: ClaimStatus.processing,
  2: ClaimStatus.reimbursed,
  3: ClaimStatus.denied,
};

Id _medicalBillGetId(MedicalBill object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicalBillGetLinks(MedicalBill object) {
  return [];
}

void _medicalBillAttach(
    IsarCollection<dynamic> col, Id id, MedicalBill object) {
  object.id = id;
}

extension MedicalBillQueryWhereSort
    on QueryBuilder<MedicalBill, MedicalBill, QWhere> {
  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyLinkedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'linkedExpenseId'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyFamilyMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'familyMemberId'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'providerId'),
      );
    });
  }
}

extension MedicalBillQueryWhere
    on QueryBuilder<MedicalBill, MedicalBill, QWhereClause> {
  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> idBetween(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> profileIdEqualTo(
      int? profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profileId',
        value: [profileId],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> profileIdNotEqualTo(
      int? profileId) {
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> profileIdLessThan(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> profileIdBetween(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      linkedExpenseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'linkedExpenseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      linkedExpenseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'linkedExpenseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      linkedExpenseIdEqualTo(int? linkedExpenseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'linkedExpenseId',
        value: [linkedExpenseId],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      linkedExpenseIdNotEqualTo(int? linkedExpenseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedExpenseId',
              lower: [],
              upper: [linkedExpenseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedExpenseId',
              lower: [linkedExpenseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedExpenseId',
              lower: [linkedExpenseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'linkedExpenseId',
              lower: [],
              upper: [linkedExpenseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      linkedExpenseIdGreaterThan(
    int? linkedExpenseId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'linkedExpenseId',
        lower: [linkedExpenseId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      linkedExpenseIdLessThan(
    int? linkedExpenseId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'linkedExpenseId',
        lower: [],
        upper: [linkedExpenseId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      linkedExpenseIdBetween(
    int? lowerLinkedExpenseId,
    int? upperLinkedExpenseId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'linkedExpenseId',
        lower: [lowerLinkedExpenseId],
        includeLower: includeLower,
        upper: [upperLinkedExpenseId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      familyMemberIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'familyMemberId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      familyMemberIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'familyMemberId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      familyMemberIdEqualTo(int? familyMemberId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'familyMemberId',
        value: [familyMemberId],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      familyMemberIdNotEqualTo(int? familyMemberId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'familyMemberId',
              lower: [],
              upper: [familyMemberId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'familyMemberId',
              lower: [familyMemberId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'familyMemberId',
              lower: [familyMemberId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'familyMemberId',
              lower: [],
              upper: [familyMemberId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      familyMemberIdGreaterThan(
    int? familyMemberId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'familyMemberId',
        lower: [familyMemberId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      familyMemberIdLessThan(
    int? familyMemberId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'familyMemberId',
        lower: [],
        upper: [familyMemberId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      familyMemberIdBetween(
    int? lowerFamilyMemberId,
    int? upperFamilyMemberId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'familyMemberId',
        lower: [lowerFamilyMemberId],
        includeLower: includeLower,
        upper: [upperFamilyMemberId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> providerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      providerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> providerIdEqualTo(
      int? providerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerId',
        value: [providerId],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      providerIdNotEqualTo(int? providerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      providerIdGreaterThan(
    int? providerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [providerId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> providerIdLessThan(
    int? providerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [],
        upper: [providerId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> providerIdBetween(
    int? lowerProviderId,
    int? upperProviderId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [lowerProviderId],
        includeLower: includeLower,
        upper: [upperProviderId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicalBillQueryFilter
    on QueryBuilder<MedicalBill, MedicalBill, QFilterCondition> {
  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachmentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attachmentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attachmentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attachmentPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'attachmentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'attachmentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'attachmentPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'attachmentPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachmentPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'attachmentPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      attachmentPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachmentPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billedAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billedAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'billedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billedAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'billedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billedAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'billedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      claimStatusEqualTo(ClaimStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'claimStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      claimStatusGreaterThan(
    ClaimStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'claimStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      claimStatusLessThan(
    ClaimStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'claimStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      claimStatusBetween(
    ClaimStatus lower,
    ClaimStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'claimStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      familyMemberIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'familyMemberId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      familyMemberIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'familyMemberId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      familyMemberIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'familyMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      familyMemberIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'familyMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      familyMemberIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'familyMemberId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      familyMemberIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'familyMemberId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      followUpDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'followUpDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      followUpDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'followUpDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      followUpDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followUpDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      followUpDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'followUpDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      followUpDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'followUpDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      followUpDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'followUpDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceCoveragePercentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceCoveragePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceCoveragePercentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insuranceCoveragePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceCoveragePercentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insuranceCoveragePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceCoveragePercentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insuranceCoveragePercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      linkedExpenseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedExpenseId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      linkedExpenseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedExpenseId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      linkedExpenseIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedExpenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      linkedExpenseIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedExpenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      linkedExpenseIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedExpenseId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      linkedExpenseIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedExpenseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      profileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      profileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'profileId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      profileIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profileId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'providerId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'providerId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      reimbursedAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reimbursedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      reimbursedAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reimbursedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      reimbursedAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reimbursedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      reimbursedAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reimbursedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serviceDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serviceDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicalBillQueryObject
    on QueryBuilder<MedicalBill, MedicalBill, QFilterCondition> {}

extension MedicalBillQueryLinks
    on QueryBuilder<MedicalBill, MedicalBill, QFilterCondition> {}

extension MedicalBillQuerySortBy
    on QueryBuilder<MedicalBill, MedicalBill, QSortBy> {
  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByBilledAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billedAmount', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByBilledAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billedAmount', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByClaimStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByClaimStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimStatus', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByFamilyMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyMemberId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByFamilyMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyMemberId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByFollowUpDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByFollowUpDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByInsuranceCoveragePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceCoveragePercent', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByInsuranceCoveragePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceCoveragePercent', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByLinkedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedExpenseId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByLinkedExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedExpenseId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByReimbursedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reimbursedAmount', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByReimbursedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reimbursedAmount', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.desc);
    });
  }
}

extension MedicalBillQuerySortThenBy
    on QueryBuilder<MedicalBill, MedicalBill, QSortThenBy> {
  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByBilledAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billedAmount', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByBilledAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billedAmount', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByClaimStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByClaimStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimStatus', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByFamilyMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyMemberId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByFamilyMemberIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyMemberId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByFollowUpDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByFollowUpDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByInsuranceCoveragePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceCoveragePercent', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByInsuranceCoveragePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceCoveragePercent', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByLinkedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedExpenseId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByLinkedExpenseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedExpenseId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByReimbursedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reimbursedAmount', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByReimbursedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reimbursedAmount', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.desc);
    });
  }
}

extension MedicalBillQueryWhereDistinct
    on QueryBuilder<MedicalBill, MedicalBill, QDistinct> {
  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByAttachmentPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attachmentPaths');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByBilledAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billedAmount');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByClaimStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'claimStatus');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByFamilyMemberId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'familyMemberId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByFollowUpDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'followUpDate');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByInsuranceCoveragePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insuranceCoveragePercent');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByLinkedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedExpenseId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByReimbursedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reimbursedAmount');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDate');
    });
  }
}

extension MedicalBillQueryProperty
    on QueryBuilder<MedicalBill, MedicalBill, QQueryProperty> {
  QueryBuilder<MedicalBill, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicalBill, List<String>, QQueryOperations>
      attachmentPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentPaths');
    });
  }

  QueryBuilder<MedicalBill, double, QQueryOperations> billedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billedAmount');
    });
  }

  QueryBuilder<MedicalBill, ClaimStatus, QQueryOperations>
      claimStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'claimStatus');
    });
  }

  QueryBuilder<MedicalBill, int?, QQueryOperations> familyMemberIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'familyMemberId');
    });
  }

  QueryBuilder<MedicalBill, DateTime?, QQueryOperations>
      followUpDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'followUpDate');
    });
  }

  QueryBuilder<MedicalBill, double, QQueryOperations>
      insuranceCoveragePercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insuranceCoveragePercent');
    });
  }

  QueryBuilder<MedicalBill, int?, QQueryOperations> linkedExpenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedExpenseId');
    });
  }

  QueryBuilder<MedicalBill, int?, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<MedicalBill, int?, QQueryOperations> providerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerId');
    });
  }

  QueryBuilder<MedicalBill, double, QQueryOperations>
      reimbursedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reimbursedAmount');
    });
  }

  QueryBuilder<MedicalBill, DateTime?, QQueryOperations> serviceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDate');
    });
  }
}
