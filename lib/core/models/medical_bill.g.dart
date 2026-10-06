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
    r'billPhotoPath': PropertySchema(
      id: 0,
      name: r'billPhotoPath',
      type: IsarType.string,
    ),
    r'billedAmount': PropertySchema(
      id: 1,
      name: r'billedAmount',
      type: IsarType.double,
    ),
    r'calendarEventId': PropertySchema(
      id: 2,
      name: r'calendarEventId',
      type: IsarType.string,
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
    r'insurerReplyPath': PropertySchema(
      id: 5,
      name: r'insurerReplyPath',
      type: IsarType.string,
    ),
    r'linkedExpenseId': PropertySchema(
      id: 6,
      name: r'linkedExpenseId',
      type: IsarType.long,
    ),
    r'patientSharePercent': PropertySchema(
      id: 7,
      name: r'patientSharePercent',
      type: IsarType.double,
    ),
    r'paymentMethod': PropertySchema(
      id: 8,
      name: r'paymentMethod',
      type: IsarType.byte,
      enumMap: _MedicalBillpaymentMethodEnumValueMap,
    ),
    r'profileId': PropertySchema(
      id: 9,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'providerId': PropertySchema(
      id: 10,
      name: r'providerId',
      type: IsarType.long,
    ),
    r'reimbursedAmount': PropertySchema(
      id: 11,
      name: r'reimbursedAmount',
      type: IsarType.double,
    ),
    r'serviceDate': PropertySchema(
      id: 12,
      name: r'serviceDate',
      type: IsarType.dateTime,
    ),
    r'serviceTypeId': PropertySchema(
      id: 13,
      name: r'serviceTypeId',
      type: IsarType.long,
    ),
    r'state': PropertySchema(
      id: 14,
      name: r'state',
      type: IsarType.byte,
      enumMap: _MedicalBillstateEnumValueMap,
    ),
    r'yearMonth': PropertySchema(
      id: 15,
      name: r'yearMonth',
      type: IsarType.string,
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
    ),
    r'serviceTypeId': IndexSchema(
      id: -684333780234681877,
      name: r'serviceTypeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'serviceTypeId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'paymentMethod': IndexSchema(
      id: 8757296919228604195,
      name: r'paymentMethod',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentMethod',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'yearMonth': IndexSchema(
      id: 5465596700411800841,
      name: r'yearMonth',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'yearMonth',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'serviceDate': IndexSchema(
      id: 7987519527273564449,
      name: r'serviceDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'serviceDate',
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
  {
    final value = object.billPhotoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.calendarEventId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.insurerReplyPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _medicalBillSerialize(
  MedicalBill object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.billPhotoPath);
  writer.writeDouble(offsets[1], object.billedAmount);
  writer.writeString(offsets[2], object.calendarEventId);
  writer.writeLong(offsets[3], object.familyMemberId);
  writer.writeDateTime(offsets[4], object.followUpDate);
  writer.writeString(offsets[5], object.insurerReplyPath);
  writer.writeLong(offsets[6], object.linkedExpenseId);
  writer.writeDouble(offsets[7], object.patientSharePercent);
  writer.writeByte(offsets[8], object.paymentMethod.index);
  writer.writeLong(offsets[9], object.profileId);
  writer.writeLong(offsets[10], object.providerId);
  writer.writeDouble(offsets[11], object.reimbursedAmount);
  writer.writeDateTime(offsets[12], object.serviceDate);
  writer.writeLong(offsets[13], object.serviceTypeId);
  writer.writeByte(offsets[14], object.state.index);
  writer.writeString(offsets[15], object.yearMonth);
}

MedicalBill _medicalBillDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalBill();
  object.billPhotoPath = reader.readStringOrNull(offsets[0]);
  object.billedAmount = reader.readDouble(offsets[1]);
  object.calendarEventId = reader.readStringOrNull(offsets[2]);
  object.familyMemberId = reader.readLongOrNull(offsets[3]);
  object.followUpDate = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.insurerReplyPath = reader.readStringOrNull(offsets[5]);
  object.linkedExpenseId = reader.readLongOrNull(offsets[6]);
  object.patientSharePercent = reader.readDouble(offsets[7]);
  object.paymentMethod = _MedicalBillpaymentMethodValueEnumMap[
          reader.readByteOrNull(offsets[8])] ??
      MedicalPaymentMethod.insurerPaid;
  object.profileId = reader.readLongOrNull(offsets[9]);
  object.providerId = reader.readLongOrNull(offsets[10]);
  object.reimbursedAmount = reader.readDouble(offsets[11]);
  object.serviceDate = reader.readDateTimeOrNull(offsets[12]);
  object.serviceTypeId = reader.readLongOrNull(offsets[13]);
  object.state =
      _MedicalBillstateValueEnumMap[reader.readByteOrNull(offsets[14])] ??
          MedicalBillState.planned;
  object.yearMonth = reader.readString(offsets[15]);
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
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (_MedicalBillpaymentMethodValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalPaymentMethod.insurerPaid) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (_MedicalBillstateValueEnumMap[reader.readByteOrNull(offset)] ??
          MedicalBillState.planned) as P;
    case 15:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MedicalBillpaymentMethodEnumValueMap = {
  'insurerPaid': 0,
  'selfPaid': 1,
};
const _MedicalBillpaymentMethodValueEnumMap = {
  0: MedicalPaymentMethod.insurerPaid,
  1: MedicalPaymentMethod.selfPaid,
};
const _MedicalBillstateEnumValueMap = {
  'planned': 0,
  'waiting': 1,
  'paid': 2,
  'finished': 3,
  'rejected': 4,
};
const _MedicalBillstateValueEnumMap = {
  0: MedicalBillState.planned,
  1: MedicalBillState.waiting,
  2: MedicalBillState.paid,
  3: MedicalBillState.finished,
  4: MedicalBillState.rejected,
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyServiceTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serviceTypeId'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'paymentMethod'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serviceDate'),
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceTypeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serviceTypeId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceTypeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serviceTypeId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceTypeIdEqualTo(int? serviceTypeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serviceTypeId',
        value: [serviceTypeId],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceTypeIdNotEqualTo(int? serviceTypeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceTypeId',
              lower: [],
              upper: [serviceTypeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceTypeId',
              lower: [serviceTypeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceTypeId',
              lower: [serviceTypeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceTypeId',
              lower: [],
              upper: [serviceTypeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceTypeIdGreaterThan(
    int? serviceTypeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serviceTypeId',
        lower: [serviceTypeId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceTypeIdLessThan(
    int? serviceTypeId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serviceTypeId',
        lower: [],
        upper: [serviceTypeId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceTypeIdBetween(
    int? lowerServiceTypeId,
    int? upperServiceTypeId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serviceTypeId',
        lower: [lowerServiceTypeId],
        includeLower: includeLower,
        upper: [upperServiceTypeId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      paymentMethodEqualTo(MedicalPaymentMethod paymentMethod) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'paymentMethod',
        value: [paymentMethod],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      paymentMethodNotEqualTo(MedicalPaymentMethod paymentMethod) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentMethod',
              lower: [],
              upper: [paymentMethod],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentMethod',
              lower: [paymentMethod],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentMethod',
              lower: [paymentMethod],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentMethod',
              lower: [],
              upper: [paymentMethod],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      paymentMethodGreaterThan(
    MedicalPaymentMethod paymentMethod, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentMethod',
        lower: [paymentMethod],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      paymentMethodLessThan(
    MedicalPaymentMethod paymentMethod, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentMethod',
        lower: [],
        upper: [paymentMethod],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      paymentMethodBetween(
    MedicalPaymentMethod lowerPaymentMethod,
    MedicalPaymentMethod upperPaymentMethod, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentMethod',
        lower: [lowerPaymentMethod],
        includeLower: includeLower,
        upper: [upperPaymentMethod],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> yearMonthEqualTo(
      String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'yearMonth',
        value: [yearMonth],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> yearMonthNotEqualTo(
      String yearMonth) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [],
              upper: [yearMonth],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [yearMonth],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [yearMonth],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [],
              upper: [yearMonth],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serviceDate',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serviceDate',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> serviceDateEqualTo(
      DateTime? serviceDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serviceDate',
        value: [serviceDate],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceDateNotEqualTo(DateTime? serviceDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceDate',
              lower: [],
              upper: [serviceDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceDate',
              lower: [serviceDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceDate',
              lower: [serviceDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serviceDate',
              lower: [],
              upper: [serviceDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      serviceDateGreaterThan(
    DateTime? serviceDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serviceDate',
        lower: [serviceDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> serviceDateLessThan(
    DateTime? serviceDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serviceDate',
        lower: [],
        upper: [serviceDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> serviceDateBetween(
    DateTime? lowerServiceDate,
    DateTime? upperServiceDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serviceDate',
        lower: [lowerServiceDate],
        includeLower: includeLower,
        upper: [upperServiceDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicalBillQueryFilter
    on QueryBuilder<MedicalBill, MedicalBill, QFilterCondition> {
  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'billPhotoPath',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'billPhotoPath',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'billPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'billPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'billPhotoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'billPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'billPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'billPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'billPhotoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billPhotoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billPhotoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'billPhotoPath',
        value: '',
      ));
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
      calendarEventIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'calendarEventId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'calendarEventId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calendarEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calendarEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calendarEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calendarEventId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'calendarEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'calendarEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'calendarEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'calendarEventId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calendarEventId',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      calendarEventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'calendarEventId',
        value: '',
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
      insurerReplyPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insurerReplyPath',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insurerReplyPath',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insurerReplyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insurerReplyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insurerReplyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insurerReplyPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'insurerReplyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'insurerReplyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'insurerReplyPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'insurerReplyPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insurerReplyPath',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insurerReplyPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'insurerReplyPath',
        value: '',
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
      patientSharePercentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patientSharePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      patientSharePercentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'patientSharePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      patientSharePercentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'patientSharePercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      patientSharePercentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'patientSharePercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      paymentMethodEqualTo(MedicalPaymentMethod value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      paymentMethodGreaterThan(
    MedicalPaymentMethod value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      paymentMethodLessThan(
    MedicalPaymentMethod value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      paymentMethodBetween(
    MedicalPaymentMethod lower,
    MedicalPaymentMethod upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentMethod',
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceTypeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serviceTypeId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceTypeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serviceTypeId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceTypeIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceTypeId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceTypeIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceTypeId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceTypeIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceTypeId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      serviceTypeIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceTypeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> stateEqualTo(
      MedicalBillState value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      stateGreaterThan(
    MedicalBillState value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'state',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> stateLessThan(
    MedicalBillState value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'state',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> stateBetween(
    MedicalBillState lower,
    MedicalBillState upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'state',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      yearMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'yearMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      yearMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'yearMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      yearMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      yearMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'yearMonth',
        value: '',
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
  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByBillPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billPhotoPath', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByBillPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billPhotoPath', Sort.desc);
    });
  }

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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByCalendarEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarEventId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByCalendarEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarEventId', Sort.desc);
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
      sortByInsurerReplyPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insurerReplyPath', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByInsurerReplyPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insurerReplyPath', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByPatientSharePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientSharePercent', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByPatientSharePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientSharePercent', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByServiceTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceTypeId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByServiceTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceTypeId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MedicalBillQuerySortThenBy
    on QueryBuilder<MedicalBill, MedicalBill, QSortThenBy> {
  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByBillPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billPhotoPath', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByBillPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billPhotoPath', Sort.desc);
    });
  }

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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByCalendarEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarEventId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByCalendarEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarEventId', Sort.desc);
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
      thenByInsurerReplyPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insurerReplyPath', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByInsurerReplyPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insurerReplyPath', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByPatientSharePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientSharePercent', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByPatientSharePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientSharePercent', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByServiceTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceTypeId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByServiceTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceTypeId', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension MedicalBillQueryWhereDistinct
    on QueryBuilder<MedicalBill, MedicalBill, QDistinct> {
  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByBillPhotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billPhotoPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByBilledAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billedAmount');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByCalendarEventId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calendarEventId',
          caseSensitive: caseSensitive);
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

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByInsurerReplyPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insurerReplyPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByLinkedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedExpenseId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByPatientSharePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'patientSharePercent');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethod');
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

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByServiceTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceTypeId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByYearMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth', caseSensitive: caseSensitive);
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

  QueryBuilder<MedicalBill, String?, QQueryOperations> billPhotoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billPhotoPath');
    });
  }

  QueryBuilder<MedicalBill, double, QQueryOperations> billedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billedAmount');
    });
  }

  QueryBuilder<MedicalBill, String?, QQueryOperations>
      calendarEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calendarEventId');
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

  QueryBuilder<MedicalBill, String?, QQueryOperations>
      insurerReplyPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insurerReplyPath');
    });
  }

  QueryBuilder<MedicalBill, int?, QQueryOperations> linkedExpenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedExpenseId');
    });
  }

  QueryBuilder<MedicalBill, double, QQueryOperations>
      patientSharePercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'patientSharePercent');
    });
  }

  QueryBuilder<MedicalBill, MedicalPaymentMethod, QQueryOperations>
      paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
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

  QueryBuilder<MedicalBill, int?, QQueryOperations> serviceTypeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceTypeId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBillState, QQueryOperations>
      stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }

  QueryBuilder<MedicalBill, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
