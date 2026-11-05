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
    r'actualSalaryMonth': PropertySchema(
      id: 0,
      name: r'actualSalaryMonth',
      type: IsarType.string,
    ),
    r'billPhotoPath': PropertySchema(
      id: 1,
      name: r'billPhotoPath',
      type: IsarType.string,
    ),
    r'billedAmount': PropertySchema(
      id: 2,
      name: r'billedAmount',
      type: IsarType.long,
    ),
    r'calendarEventId': PropertySchema(
      id: 3,
      name: r'calendarEventId',
      type: IsarType.string,
    ),
    r'closeReason': PropertySchema(
      id: 4,
      name: r'closeReason',
      type: IsarType.string,
    ),
    r'closedAt': PropertySchema(
      id: 5,
      name: r'closedAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 6,
      name: r'currency',
      type: IsarType.string,
    ),
    r'expectedSalaryMonth': PropertySchema(
      id: 7,
      name: r'expectedSalaryMonth',
      type: IsarType.string,
    ),
    r'familyMemberId': PropertySchema(
      id: 8,
      name: r'familyMemberId',
      type: IsarType.long,
    ),
    r'followUpDate': PropertySchema(
      id: 9,
      name: r'followUpDate',
      type: IsarType.dateTime,
    ),
    r'insuranceReference': PropertySchema(
      id: 10,
      name: r'insuranceReference',
      type: IsarType.string,
    ),
    r'insuranceRequestStatus': PropertySchema(
      id: 11,
      name: r'insuranceRequestStatus',
      type: IsarType.byte,
      enumMap: _MedicalBillinsuranceRequestStatusEnumValueMap,
    ),
    r'insurerReplyPath': PropertySchema(
      id: 12,
      name: r'insurerReplyPath',
      type: IsarType.string,
    ),
    r'lastUpdatedAt': PropertySchema(
      id: 13,
      name: r'lastUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'linkedExpenseId': PropertySchema(
      id: 14,
      name: r'linkedExpenseId',
      type: IsarType.long,
    ),
    r'needsReview': PropertySchema(
      id: 15,
      name: r'needsReview',
      type: IsarType.bool,
    ),
    r'overallStatus': PropertySchema(
      id: 16,
      name: r'overallStatus',
      type: IsarType.byte,
      enumMap: _MedicalBilloverallStatusEnumValueMap,
    ),
    r'patientSharePercent': PropertySchema(
      id: 17,
      name: r'patientSharePercent',
      type: IsarType.double,
    ),
    r'paymentMethod': PropertySchema(
      id: 18,
      name: r'paymentMethod',
      type: IsarType.byte,
      enumMap: _MedicalBillpaymentMethodEnumValueMap,
    ),
    r'profileId': PropertySchema(
      id: 19,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'providerId': PropertySchema(
      id: 20,
      name: r'providerId',
      type: IsarType.long,
    ),
    r'providerPaymentStatus': PropertySchema(
      id: 21,
      name: r'providerPaymentStatus',
      type: IsarType.byte,
      enumMap: _MedicalBillproviderPaymentStatusEnumValueMap,
    ),
    r'receiptConfirmedDate': PropertySchema(
      id: 22,
      name: r'receiptConfirmedDate',
      type: IsarType.dateTime,
    ),
    r'reimbursedAmount': PropertySchema(
      id: 23,
      name: r'reimbursedAmount',
      type: IsarType.long,
    ),
    r'rejectionResolution': PropertySchema(
      id: 24,
      name: r'rejectionResolution',
      type: IsarType.byte,
      enumMap: _MedicalBillrejectionResolutionEnumValueMap,
    ),
    r'salarySettlementStatus': PropertySchema(
      id: 25,
      name: r'salarySettlementStatus',
      type: IsarType.byte,
      enumMap: _MedicalBillsalarySettlementStatusEnumValueMap,
    ),
    r'salarySettlementType': PropertySchema(
      id: 26,
      name: r'salarySettlementType',
      type: IsarType.byte,
      enumMap: _MedicalBillsalarySettlementTypeEnumValueMap,
    ),
    r'serviceDate': PropertySchema(
      id: 27,
      name: r'serviceDate',
      type: IsarType.dateTime,
    ),
    r'serviceTypeId': PropertySchema(
      id: 28,
      name: r'serviceTypeId',
      type: IsarType.long,
    ),
    r'settledAmountMinor': PropertySchema(
      id: 29,
      name: r'settledAmountMinor',
      type: IsarType.long,
    ),
    r'settledDate': PropertySchema(
      id: 30,
      name: r'settledDate',
      type: IsarType.dateTime,
    ),
    r'settlementAmountMinor': PropertySchema(
      id: 31,
      name: r'settlementAmountMinor',
      type: IsarType.long,
    ),
    r'sharedSpaceId': PropertySchema(
      id: 32,
      name: r'sharedSpaceId',
      type: IsarType.long,
    ),
    r'state': PropertySchema(
      id: 33,
      name: r'state',
      type: IsarType.byte,
      enumMap: _MedicalBillstateEnumValueMap,
    ),
    r'submissionDate': PropertySchema(
      id: 34,
      name: r'submissionDate',
      type: IsarType.dateTime,
    ),
    r'syncGuid': PropertySchema(
      id: 35,
      name: r'syncGuid',
      type: IsarType.string,
    ),
    r'yearMonth': PropertySchema(
      id: 36,
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
    r'sharedSpaceId': IndexSchema(
      id: 9187801792503633945,
      name: r'sharedSpaceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sharedSpaceId',
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
    r'overallStatus': IndexSchema(
      id: 2815115011056998832,
      name: r'overallStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'overallStatus',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'providerPaymentStatus': IndexSchema(
      id: 2235122319831371014,
      name: r'providerPaymentStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'providerPaymentStatus',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'insuranceRequestStatus': IndexSchema(
      id: -3907977263126765454,
      name: r'insuranceRequestStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'insuranceRequestStatus',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'salarySettlementStatus': IndexSchema(
      id: 8443215714530068692,
      name: r'salarySettlementStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'salarySettlementStatus',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'needsReview': IndexSchema(
      id: 9078383057249155778,
      name: r'needsReview',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'needsReview',
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
    final value = object.actualSalaryMonth;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
    final value = object.closeReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.currency.length * 3;
  {
    final value = object.expectedSalaryMonth;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.insuranceReference;
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
  bytesCount += 3 + object.syncGuid.length * 3;
  bytesCount += 3 + object.yearMonth.length * 3;
  return bytesCount;
}

void _medicalBillSerialize(
  MedicalBill object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actualSalaryMonth);
  writer.writeString(offsets[1], object.billPhotoPath);
  writer.writeLong(offsets[2], object.billedAmount);
  writer.writeString(offsets[3], object.calendarEventId);
  writer.writeString(offsets[4], object.closeReason);
  writer.writeDateTime(offsets[5], object.closedAt);
  writer.writeString(offsets[6], object.currency);
  writer.writeString(offsets[7], object.expectedSalaryMonth);
  writer.writeLong(offsets[8], object.familyMemberId);
  writer.writeDateTime(offsets[9], object.followUpDate);
  writer.writeString(offsets[10], object.insuranceReference);
  writer.writeByte(offsets[11], object.insuranceRequestStatus.index);
  writer.writeString(offsets[12], object.insurerReplyPath);
  writer.writeDateTime(offsets[13], object.lastUpdatedAt);
  writer.writeLong(offsets[14], object.linkedExpenseId);
  writer.writeBool(offsets[15], object.needsReview);
  writer.writeByte(offsets[16], object.overallStatus.index);
  writer.writeDouble(offsets[17], object.patientSharePercent);
  writer.writeByte(offsets[18], object.paymentMethod.index);
  writer.writeLong(offsets[19], object.profileId);
  writer.writeLong(offsets[20], object.providerId);
  writer.writeByte(offsets[21], object.providerPaymentStatus.index);
  writer.writeDateTime(offsets[22], object.receiptConfirmedDate);
  writer.writeLong(offsets[23], object.reimbursedAmount);
  writer.writeByte(offsets[24], object.rejectionResolution.index);
  writer.writeByte(offsets[25], object.salarySettlementStatus.index);
  writer.writeByte(offsets[26], object.salarySettlementType.index);
  writer.writeDateTime(offsets[27], object.serviceDate);
  writer.writeLong(offsets[28], object.serviceTypeId);
  writer.writeLong(offsets[29], object.settledAmountMinor);
  writer.writeDateTime(offsets[30], object.settledDate);
  writer.writeLong(offsets[31], object.settlementAmountMinor);
  writer.writeLong(offsets[32], object.sharedSpaceId);
  writer.writeByte(offsets[33], object.state.index);
  writer.writeDateTime(offsets[34], object.submissionDate);
  writer.writeString(offsets[35], object.syncGuid);
  writer.writeString(offsets[36], object.yearMonth);
}

MedicalBill _medicalBillDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicalBill();
  object.actualSalaryMonth = reader.readStringOrNull(offsets[0]);
  object.billPhotoPath = reader.readStringOrNull(offsets[1]);
  object.billedAmount = reader.readLong(offsets[2]);
  object.calendarEventId = reader.readStringOrNull(offsets[3]);
  object.closeReason = reader.readStringOrNull(offsets[4]);
  object.closedAt = reader.readDateTimeOrNull(offsets[5]);
  object.currency = reader.readString(offsets[6]);
  object.expectedSalaryMonth = reader.readStringOrNull(offsets[7]);
  object.familyMemberId = reader.readLongOrNull(offsets[8]);
  object.followUpDate = reader.readDateTimeOrNull(offsets[9]);
  object.id = id;
  object.insuranceReference = reader.readStringOrNull(offsets[10]);
  object.insuranceRequestStatus =
      _MedicalBillinsuranceRequestStatusValueEnumMap[
              reader.readByteOrNull(offsets[11])] ??
          MedicalInsuranceRequestStatus.notSubmitted;
  object.insurerReplyPath = reader.readStringOrNull(offsets[12]);
  object.lastUpdatedAt = reader.readDateTimeOrNull(offsets[13]);
  object.linkedExpenseId = reader.readLongOrNull(offsets[14]);
  object.needsReview = reader.readBool(offsets[15]);
  object.overallStatus = _MedicalBilloverallStatusValueEnumMap[
          reader.readByteOrNull(offsets[16])] ??
      MedicalOverallStatus.open;
  object.patientSharePercent = reader.readDouble(offsets[17]);
  object.paymentMethod = _MedicalBillpaymentMethodValueEnumMap[
          reader.readByteOrNull(offsets[18])] ??
      MedicalPaymentMethod.insurerPaid;
  object.profileId = reader.readLongOrNull(offsets[19]);
  object.providerId = reader.readLongOrNull(offsets[20]);
  object.providerPaymentStatus = _MedicalBillproviderPaymentStatusValueEnumMap[
          reader.readByteOrNull(offsets[21])] ??
      MedicalProviderPaymentStatus.notConfirmed;
  object.receiptConfirmedDate = reader.readDateTimeOrNull(offsets[22]);
  object.reimbursedAmount = reader.readLong(offsets[23]);
  object.rejectionResolution = _MedicalBillrejectionResolutionValueEnumMap[
          reader.readByteOrNull(offsets[24])] ??
      MedicalRejectionResolution.none;
  object.salarySettlementStatus =
      _MedicalBillsalarySettlementStatusValueEnumMap[
              reader.readByteOrNull(offsets[25])] ??
          MedicalSalarySettlementStatus.notRequired;
  object.salarySettlementType = _MedicalBillsalarySettlementTypeValueEnumMap[
          reader.readByteOrNull(offsets[26])] ??
      MedicalSalarySettlementType.none;
  object.serviceDate = reader.readDateTimeOrNull(offsets[27]);
  object.serviceTypeId = reader.readLongOrNull(offsets[28]);
  object.settledAmountMinor = reader.readLongOrNull(offsets[29]);
  object.settledDate = reader.readDateTimeOrNull(offsets[30]);
  object.settlementAmountMinor = reader.readLongOrNull(offsets[31]);
  object.sharedSpaceId = reader.readLongOrNull(offsets[32]);
  object.state =
      _MedicalBillstateValueEnumMap[reader.readByteOrNull(offsets[33])] ??
          MedicalBillState.planned;
  object.submissionDate = reader.readDateTimeOrNull(offsets[34]);
  object.syncGuid = reader.readString(offsets[35]);
  object.yearMonth = reader.readString(offsets[36]);
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
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (_MedicalBillinsuranceRequestStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalInsuranceRequestStatus.notSubmitted) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (_MedicalBilloverallStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalOverallStatus.open) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (_MedicalBillpaymentMethodValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalPaymentMethod.insurerPaid) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (_MedicalBillproviderPaymentStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalProviderPaymentStatus.notConfirmed) as P;
    case 22:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (_MedicalBillrejectionResolutionValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalRejectionResolution.none) as P;
    case 25:
      return (_MedicalBillsalarySettlementStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalSalarySettlementStatus.notRequired) as P;
    case 26:
      return (_MedicalBillsalarySettlementTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MedicalSalarySettlementType.none) as P;
    case 27:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 28:
      return (reader.readLongOrNull(offset)) as P;
    case 29:
      return (reader.readLongOrNull(offset)) as P;
    case 30:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 31:
      return (reader.readLongOrNull(offset)) as P;
    case 32:
      return (reader.readLongOrNull(offset)) as P;
    case 33:
      return (_MedicalBillstateValueEnumMap[reader.readByteOrNull(offset)] ??
          MedicalBillState.planned) as P;
    case 34:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 35:
      return (reader.readString(offset)) as P;
    case 36:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MedicalBillinsuranceRequestStatusEnumValueMap = {
  'notSubmitted': 0,
  'submitted': 1,
  'receiptPending': 2,
  'inProgress': 3,
  'approved': 4,
  'rejected': 5,
  'appealSubmitted': 6,
  'appealInProgress': 7,
  'appealApproved': 8,
  'appealRejected': 9,
  'requestCancelled': 10,
  'completed': 11,
};
const _MedicalBillinsuranceRequestStatusValueEnumMap = {
  0: MedicalInsuranceRequestStatus.notSubmitted,
  1: MedicalInsuranceRequestStatus.submitted,
  2: MedicalInsuranceRequestStatus.receiptPending,
  3: MedicalInsuranceRequestStatus.inProgress,
  4: MedicalInsuranceRequestStatus.approved,
  5: MedicalInsuranceRequestStatus.rejected,
  6: MedicalInsuranceRequestStatus.appealSubmitted,
  7: MedicalInsuranceRequestStatus.appealInProgress,
  8: MedicalInsuranceRequestStatus.appealApproved,
  9: MedicalInsuranceRequestStatus.appealRejected,
  10: MedicalInsuranceRequestStatus.requestCancelled,
  11: MedicalInsuranceRequestStatus.completed,
};
const _MedicalBilloverallStatusEnumValueMap = {
  'open': 0,
  'closed': 1,
  'cancelled': 2,
};
const _MedicalBilloverallStatusValueEnumMap = {
  0: MedicalOverallStatus.open,
  1: MedicalOverallStatus.closed,
  2: MedicalOverallStatus.cancelled,
};
const _MedicalBillpaymentMethodEnumValueMap = {
  'insurerPaid': 0,
  'selfPaid': 1,
};
const _MedicalBillpaymentMethodValueEnumMap = {
  0: MedicalPaymentMethod.insurerPaid,
  1: MedicalPaymentMethod.selfPaid,
};
const _MedicalBillproviderPaymentStatusEnumValueMap = {
  'notConfirmed': 0,
  'paid': 1,
  'refunded': 2,
  'notRequired': 3,
};
const _MedicalBillproviderPaymentStatusValueEnumMap = {
  0: MedicalProviderPaymentStatus.notConfirmed,
  1: MedicalProviderPaymentStatus.paid,
  2: MedicalProviderPaymentStatus.refunded,
  3: MedicalProviderPaymentStatus.notRequired,
};
const _MedicalBillrejectionResolutionEnumValueMap = {
  'none': 0,
  'accepted': 1,
  'appeal': 2,
  'providerCancelled': 3,
  'userPaidProvider': 4,
  'adjustedDeduction': 5,
  'other': 6,
};
const _MedicalBillrejectionResolutionValueEnumMap = {
  0: MedicalRejectionResolution.none,
  1: MedicalRejectionResolution.accepted,
  2: MedicalRejectionResolution.appeal,
  3: MedicalRejectionResolution.providerCancelled,
  4: MedicalRejectionResolution.userPaidProvider,
  5: MedicalRejectionResolution.adjustedDeduction,
  6: MedicalRejectionResolution.other,
};
const _MedicalBillsalarySettlementStatusEnumValueMap = {
  'notRequired': 0,
  'waitingForPayslip': 1,
  'received': 2,
  'deducted': 3,
  'notReceived': 4,
  'notDeducted': 5,
};
const _MedicalBillsalarySettlementStatusValueEnumMap = {
  0: MedicalSalarySettlementStatus.notRequired,
  1: MedicalSalarySettlementStatus.waitingForPayslip,
  2: MedicalSalarySettlementStatus.received,
  3: MedicalSalarySettlementStatus.deducted,
  4: MedicalSalarySettlementStatus.notReceived,
  5: MedicalSalarySettlementStatus.notDeducted,
};
const _MedicalBillsalarySettlementTypeEnumValueMap = {
  'none': 0,
  'insuranceRefund': 1,
  'userShareDeduction': 2,
};
const _MedicalBillsalarySettlementTypeValueEnumMap = {
  0: MedicalSalarySettlementType.none,
  1: MedicalSalarySettlementType.insuranceRefund,
  2: MedicalSalarySettlementType.userShareDeduction,
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sharedSpaceId'),
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyOverallStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'overallStatus'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere>
      anyProviderPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'providerPaymentStatus'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere>
      anyInsuranceRequestStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'insuranceRequestStatus'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere>
      anySalarySettlementStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'salarySettlementStatus'),
      );
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhere> anyNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'needsReview'),
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> syncGuidEqualTo(
      String syncGuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncGuid',
        value: [syncGuid],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> syncGuidNotEqualTo(
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
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      sharedSpaceIdEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sharedSpaceId',
        value: [sharedSpaceId],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      sharedSpaceIdNotEqualTo(int? sharedSpaceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [],
              upper: [sharedSpaceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [sharedSpaceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [sharedSpaceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sharedSpaceId',
              lower: [],
              upper: [sharedSpaceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      sharedSpaceIdGreaterThan(
    int? sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [sharedSpaceId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      sharedSpaceIdLessThan(
    int? sharedSpaceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [],
        upper: [sharedSpaceId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      sharedSpaceIdBetween(
    int? lowerSharedSpaceId,
    int? upperSharedSpaceId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sharedSpaceId',
        lower: [lowerSharedSpaceId],
        includeLower: includeLower,
        upper: [upperSharedSpaceId],
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      overallStatusEqualTo(MedicalOverallStatus overallStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'overallStatus',
        value: [overallStatus],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      overallStatusNotEqualTo(MedicalOverallStatus overallStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'overallStatus',
              lower: [],
              upper: [overallStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'overallStatus',
              lower: [overallStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'overallStatus',
              lower: [overallStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'overallStatus',
              lower: [],
              upper: [overallStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      overallStatusGreaterThan(
    MedicalOverallStatus overallStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'overallStatus',
        lower: [overallStatus],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      overallStatusLessThan(
    MedicalOverallStatus overallStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'overallStatus',
        lower: [],
        upper: [overallStatus],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      overallStatusBetween(
    MedicalOverallStatus lowerOverallStatus,
    MedicalOverallStatus upperOverallStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'overallStatus',
        lower: [lowerOverallStatus],
        includeLower: includeLower,
        upper: [upperOverallStatus],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      providerPaymentStatusEqualTo(
          MedicalProviderPaymentStatus providerPaymentStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerPaymentStatus',
        value: [providerPaymentStatus],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      providerPaymentStatusNotEqualTo(
          MedicalProviderPaymentStatus providerPaymentStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerPaymentStatus',
              lower: [],
              upper: [providerPaymentStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerPaymentStatus',
              lower: [providerPaymentStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerPaymentStatus',
              lower: [providerPaymentStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerPaymentStatus',
              lower: [],
              upper: [providerPaymentStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      providerPaymentStatusGreaterThan(
    MedicalProviderPaymentStatus providerPaymentStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerPaymentStatus',
        lower: [providerPaymentStatus],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      providerPaymentStatusLessThan(
    MedicalProviderPaymentStatus providerPaymentStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerPaymentStatus',
        lower: [],
        upper: [providerPaymentStatus],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      providerPaymentStatusBetween(
    MedicalProviderPaymentStatus lowerProviderPaymentStatus,
    MedicalProviderPaymentStatus upperProviderPaymentStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerPaymentStatus',
        lower: [lowerProviderPaymentStatus],
        includeLower: includeLower,
        upper: [upperProviderPaymentStatus],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      insuranceRequestStatusEqualTo(
          MedicalInsuranceRequestStatus insuranceRequestStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'insuranceRequestStatus',
        value: [insuranceRequestStatus],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      insuranceRequestStatusNotEqualTo(
          MedicalInsuranceRequestStatus insuranceRequestStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'insuranceRequestStatus',
              lower: [],
              upper: [insuranceRequestStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'insuranceRequestStatus',
              lower: [insuranceRequestStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'insuranceRequestStatus',
              lower: [insuranceRequestStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'insuranceRequestStatus',
              lower: [],
              upper: [insuranceRequestStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      insuranceRequestStatusGreaterThan(
    MedicalInsuranceRequestStatus insuranceRequestStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'insuranceRequestStatus',
        lower: [insuranceRequestStatus],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      insuranceRequestStatusLessThan(
    MedicalInsuranceRequestStatus insuranceRequestStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'insuranceRequestStatus',
        lower: [],
        upper: [insuranceRequestStatus],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      insuranceRequestStatusBetween(
    MedicalInsuranceRequestStatus lowerInsuranceRequestStatus,
    MedicalInsuranceRequestStatus upperInsuranceRequestStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'insuranceRequestStatus',
        lower: [lowerInsuranceRequestStatus],
        includeLower: includeLower,
        upper: [upperInsuranceRequestStatus],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      salarySettlementStatusEqualTo(
          MedicalSalarySettlementStatus salarySettlementStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'salarySettlementStatus',
        value: [salarySettlementStatus],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      salarySettlementStatusNotEqualTo(
          MedicalSalarySettlementStatus salarySettlementStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salarySettlementStatus',
              lower: [],
              upper: [salarySettlementStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salarySettlementStatus',
              lower: [salarySettlementStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salarySettlementStatus',
              lower: [salarySettlementStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'salarySettlementStatus',
              lower: [],
              upper: [salarySettlementStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      salarySettlementStatusGreaterThan(
    MedicalSalarySettlementStatus salarySettlementStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'salarySettlementStatus',
        lower: [salarySettlementStatus],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      salarySettlementStatusLessThan(
    MedicalSalarySettlementStatus salarySettlementStatus, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'salarySettlementStatus',
        lower: [],
        upper: [salarySettlementStatus],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      salarySettlementStatusBetween(
    MedicalSalarySettlementStatus lowerSalarySettlementStatus,
    MedicalSalarySettlementStatus upperSalarySettlementStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'salarySettlementStatus',
        lower: [lowerSalarySettlementStatus],
        includeLower: includeLower,
        upper: [upperSalarySettlementStatus],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause> needsReviewEqualTo(
      bool needsReview) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'needsReview',
        value: [needsReview],
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterWhereClause>
      needsReviewNotEqualTo(bool needsReview) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'needsReview',
              lower: [],
              upper: [needsReview],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'needsReview',
              lower: [needsReview],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'needsReview',
              lower: [needsReview],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'needsReview',
              lower: [],
              upper: [needsReview],
              includeUpper: false,
            ));
      }
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
      actualSalaryMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualSalaryMonth',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualSalaryMonth',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualSalaryMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actualSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actualSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actualSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actualSalaryMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualSalaryMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      actualSalaryMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actualSalaryMonth',
        value: '',
      ));
    });
  }

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
      billedAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billedAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'billedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billedAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'billedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      billedAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'billedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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
      closeReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'closeReason',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'closeReason',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closeReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'closeReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'closeReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'closeReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'closeReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'closeReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'closeReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'closeReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closeReason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closeReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'closeReason',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'closedAt',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'closedAt',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> closedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      closedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> closedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'closedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> currencyEqualTo(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> currencyBetween(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> currencyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedSalaryMonth',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedSalaryMonth',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedSalaryMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'expectedSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'expectedSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'expectedSalaryMonth',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'expectedSalaryMonth',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedSalaryMonth',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      expectedSalaryMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'expectedSalaryMonth',
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
      insuranceReferenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insuranceReference',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insuranceReference',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insuranceReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insuranceReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insuranceReference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'insuranceReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'insuranceReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'insuranceReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'insuranceReference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceReference',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceReferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'insuranceReference',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceRequestStatusEqualTo(MedicalInsuranceRequestStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceRequestStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceRequestStatusGreaterThan(
    MedicalInsuranceRequestStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insuranceRequestStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceRequestStatusLessThan(
    MedicalInsuranceRequestStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insuranceRequestStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      insuranceRequestStatusBetween(
    MedicalInsuranceRequestStatus lower,
    MedicalInsuranceRequestStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insuranceRequestStatus',
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
      lastUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdatedAt',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      lastUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdatedAt',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      lastUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      lastUpdatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      lastUpdatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      lastUpdatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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
      needsReviewEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsReview',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      overallStatusEqualTo(MedicalOverallStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overallStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      overallStatusGreaterThan(
    MedicalOverallStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overallStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      overallStatusLessThan(
    MedicalOverallStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overallStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      overallStatusBetween(
    MedicalOverallStatus lower,
    MedicalOverallStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overallStatus',
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
      providerPaymentStatusEqualTo(MedicalProviderPaymentStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerPaymentStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerPaymentStatusGreaterThan(
    MedicalProviderPaymentStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerPaymentStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerPaymentStatusLessThan(
    MedicalProviderPaymentStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerPaymentStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      providerPaymentStatusBetween(
    MedicalProviderPaymentStatus lower,
    MedicalProviderPaymentStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerPaymentStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      receiptConfirmedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receiptConfirmedDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      receiptConfirmedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receiptConfirmedDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      receiptConfirmedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptConfirmedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      receiptConfirmedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptConfirmedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      receiptConfirmedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptConfirmedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      receiptConfirmedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptConfirmedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      reimbursedAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reimbursedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      reimbursedAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reimbursedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      reimbursedAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reimbursedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      reimbursedAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reimbursedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      rejectionResolutionEqualTo(MedicalRejectionResolution value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectionResolution',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      rejectionResolutionGreaterThan(
    MedicalRejectionResolution value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rejectionResolution',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      rejectionResolutionLessThan(
    MedicalRejectionResolution value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rejectionResolution',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      rejectionResolutionBetween(
    MedicalRejectionResolution lower,
    MedicalRejectionResolution upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rejectionResolution',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      salarySettlementStatusEqualTo(MedicalSalarySettlementStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salarySettlementStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      salarySettlementStatusGreaterThan(
    MedicalSalarySettlementStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'salarySettlementStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      salarySettlementStatusLessThan(
    MedicalSalarySettlementStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'salarySettlementStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      salarySettlementStatusBetween(
    MedicalSalarySettlementStatus lower,
    MedicalSalarySettlementStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'salarySettlementStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      salarySettlementTypeEqualTo(MedicalSalarySettlementType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salarySettlementType',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      salarySettlementTypeGreaterThan(
    MedicalSalarySettlementType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'salarySettlementType',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      salarySettlementTypeLessThan(
    MedicalSalarySettlementType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'salarySettlementType',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      salarySettlementTypeBetween(
    MedicalSalarySettlementType lower,
    MedicalSalarySettlementType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'salarySettlementType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledAmountMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settledAmountMinor',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledAmountMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settledAmountMinor',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledAmountMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settledAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledAmountMinorGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settledAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledAmountMinorLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settledAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledAmountMinorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settledAmountMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settledDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settledDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settledDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settledDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settlementAmountMinorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settlementAmountMinor',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settlementAmountMinorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settlementAmountMinor',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settlementAmountMinorEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settlementAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settlementAmountMinorGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settlementAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settlementAmountMinorLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settlementAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      settlementAmountMinorBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settlementAmountMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      sharedSpaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      sharedSpaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedSpaceId',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      sharedSpaceIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedSpaceId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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
      submissionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'submissionDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      submissionDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'submissionDate',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      submissionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submissionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      submissionDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'submissionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      submissionDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'submissionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      submissionDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'submissionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> syncGuidEqualTo(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> syncGuidBetween(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      syncGuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition> syncGuidMatches(
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      syncGuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterFilterCondition>
      syncGuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGuid',
        value: '',
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
  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByActualSalaryMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualSalaryMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByActualSalaryMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualSalaryMonth', Sort.desc);
    });
  }

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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByCloseReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closeReason', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByCloseReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closeReason', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByExpectedSalaryMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedSalaryMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByExpectedSalaryMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedSalaryMonth', Sort.desc);
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
      sortByInsuranceReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceReference', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByInsuranceReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceReference', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByInsuranceRequestStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceRequestStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByInsuranceRequestStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceRequestStatus', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByLastUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByNeedsReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortByOverallStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByOverallStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallStatus', Sort.desc);
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
      sortByProviderPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerPaymentStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByProviderPaymentStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerPaymentStatus', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByReceiptConfirmedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptConfirmedDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByReceiptConfirmedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptConfirmedDate', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByRejectionResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionResolution', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortByRejectionResolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionResolution', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySalarySettlementStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarySettlementStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySalarySettlementStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarySettlementStatus', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySalarySettlementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarySettlementType', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySalarySettlementTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarySettlementType', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySettledAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySettledAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortBySettledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortBySettledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySettlementAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settlementAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySettlementAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settlementAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortBySubmissionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submissionDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      sortBySubmissionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submissionDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> sortBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
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
  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByActualSalaryMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualSalaryMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByActualSalaryMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualSalaryMonth', Sort.desc);
    });
  }

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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByCloseReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closeReason', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByCloseReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closeReason', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByExpectedSalaryMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedSalaryMonth', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByExpectedSalaryMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedSalaryMonth', Sort.desc);
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
      thenByInsuranceReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceReference', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByInsuranceReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceReference', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByInsuranceRequestStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceRequestStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByInsuranceRequestStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceRequestStatus', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByLastUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByNeedsReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsReview', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenByOverallStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByOverallStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overallStatus', Sort.desc);
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
      thenByProviderPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerPaymentStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByProviderPaymentStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerPaymentStatus', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByReceiptConfirmedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptConfirmedDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByReceiptConfirmedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptConfirmedDate', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByRejectionResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionResolution', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenByRejectionResolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionResolution', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySalarySettlementStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarySettlementStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySalarySettlementStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarySettlementStatus', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySalarySettlementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarySettlementType', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySalarySettlementTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salarySettlementType', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySettledAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySettledAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenBySettledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenBySettledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySettlementAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settlementAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySettlementAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settlementAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySharedSpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedSpaceId', Sort.desc);
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

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenBySubmissionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submissionDate', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy>
      thenBySubmissionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submissionDate', Sort.desc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenBySyncGuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.asc);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QAfterSortBy> thenBySyncGuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGuid', Sort.desc);
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
  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByActualSalaryMonth(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualSalaryMonth',
          caseSensitive: caseSensitive);
    });
  }

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

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByCloseReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closeReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closedAt');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByExpectedSalaryMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedSalaryMonth',
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

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByInsuranceReference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insuranceReference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByInsuranceRequestStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insuranceRequestStatus');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByInsurerReplyPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insurerReplyPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdatedAt');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByLinkedExpenseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedExpenseId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByNeedsReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsReview');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByOverallStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overallStatus');
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
      distinctByProviderPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerPaymentStatus');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByReceiptConfirmedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptConfirmedDate');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByReimbursedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reimbursedAmount');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctByRejectionResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rejectionResolution');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctBySalarySettlementStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salarySettlementStatus');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctBySalarySettlementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salarySettlementType');
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

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctBySettledAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settledAmountMinor');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctBySettledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settledDate');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct>
      distinctBySettlementAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settlementAmountMinor');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctBySharedSpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctBySubmissionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submissionDate');
    });
  }

  QueryBuilder<MedicalBill, MedicalBill, QDistinct> distinctBySyncGuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGuid', caseSensitive: caseSensitive);
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

  QueryBuilder<MedicalBill, String?, QQueryOperations>
      actualSalaryMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualSalaryMonth');
    });
  }

  QueryBuilder<MedicalBill, String?, QQueryOperations> billPhotoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billPhotoPath');
    });
  }

  QueryBuilder<MedicalBill, int, QQueryOperations> billedAmountProperty() {
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

  QueryBuilder<MedicalBill, String?, QQueryOperations> closeReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closeReason');
    });
  }

  QueryBuilder<MedicalBill, DateTime?, QQueryOperations> closedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closedAt');
    });
  }

  QueryBuilder<MedicalBill, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MedicalBill, String?, QQueryOperations>
      expectedSalaryMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedSalaryMonth');
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
      insuranceReferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insuranceReference');
    });
  }

  QueryBuilder<MedicalBill, MedicalInsuranceRequestStatus, QQueryOperations>
      insuranceRequestStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insuranceRequestStatus');
    });
  }

  QueryBuilder<MedicalBill, String?, QQueryOperations>
      insurerReplyPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insurerReplyPath');
    });
  }

  QueryBuilder<MedicalBill, DateTime?, QQueryOperations>
      lastUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdatedAt');
    });
  }

  QueryBuilder<MedicalBill, int?, QQueryOperations> linkedExpenseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedExpenseId');
    });
  }

  QueryBuilder<MedicalBill, bool, QQueryOperations> needsReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsReview');
    });
  }

  QueryBuilder<MedicalBill, MedicalOverallStatus, QQueryOperations>
      overallStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overallStatus');
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

  QueryBuilder<MedicalBill, MedicalProviderPaymentStatus, QQueryOperations>
      providerPaymentStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerPaymentStatus');
    });
  }

  QueryBuilder<MedicalBill, DateTime?, QQueryOperations>
      receiptConfirmedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptConfirmedDate');
    });
  }

  QueryBuilder<MedicalBill, int, QQueryOperations> reimbursedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reimbursedAmount');
    });
  }

  QueryBuilder<MedicalBill, MedicalRejectionResolution, QQueryOperations>
      rejectionResolutionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rejectionResolution');
    });
  }

  QueryBuilder<MedicalBill, MedicalSalarySettlementStatus, QQueryOperations>
      salarySettlementStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salarySettlementStatus');
    });
  }

  QueryBuilder<MedicalBill, MedicalSalarySettlementType, QQueryOperations>
      salarySettlementTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salarySettlementType');
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

  QueryBuilder<MedicalBill, int?, QQueryOperations>
      settledAmountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settledAmountMinor');
    });
  }

  QueryBuilder<MedicalBill, DateTime?, QQueryOperations> settledDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settledDate');
    });
  }

  QueryBuilder<MedicalBill, int?, QQueryOperations>
      settlementAmountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settlementAmountMinor');
    });
  }

  QueryBuilder<MedicalBill, int?, QQueryOperations> sharedSpaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedSpaceId');
    });
  }

  QueryBuilder<MedicalBill, MedicalBillState, QQueryOperations>
      stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }

  QueryBuilder<MedicalBill, DateTime?, QQueryOperations>
      submissionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submissionDate');
    });
  }

  QueryBuilder<MedicalBill, String, QQueryOperations> syncGuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGuid');
    });
  }

  QueryBuilder<MedicalBill, String, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
