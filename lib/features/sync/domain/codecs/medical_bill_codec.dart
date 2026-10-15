import '../../../../core/models/medical_bill.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [MedicalBill] (data-model §2.6, FR-010).
class MedicalBillCodec extends SyncCodec<MedicalBill> {
  const MedicalBillCodec();

  @override
  String get entityType => 'MedicalBill';

  @override
  Map<String, Object?> toJson(MedicalBill value) => {
        'id': value.id,
        'profileId': value.profileId,
        'sharedSpaceId': value.sharedSpaceId,
        'linkedExpenseId': value.linkedExpenseId,
        'familyMemberId': value.familyMemberId,
        'providerId': value.providerId,
        'serviceTypeId': value.serviceTypeId,
        'paymentMethod': value.paymentMethod.name,
        'patientSharePercent': value.patientSharePercent,
        'state': value.state.name,
        'yearMonth': value.yearMonth,
        'serviceDate': encodeDate(value.serviceDate),
        'billedAmount': value.billedAmount,
        'currency': value.currency,
        'billPhotoPath': value.billPhotoPath,
        'insurerReplyPath': value.insurerReplyPath,
        'followUpDate': encodeDate(value.followUpDate),
        'calendarEventId': value.calendarEventId,
        'reimbursedAmount': value.reimbursedAmount,
      };

  @override
  MedicalBill fromJson(Map<String, Object?> json) => MedicalBill()
    ..id = decodeInt(json['id'])
    ..profileId = decodeIntOrNull(json['profileId'])
    ..sharedSpaceId = decodeIntOrNull(json['sharedSpaceId'])
    ..linkedExpenseId = decodeIntOrNull(json['linkedExpenseId'])
    ..familyMemberId = decodeIntOrNull(json['familyMemberId'])
    ..providerId = decodeIntOrNull(json['providerId'])
    ..serviceTypeId = decodeIntOrNull(json['serviceTypeId'])
    ..paymentMethod =
        decodeEnum(MedicalPaymentMethod.values, json['paymentMethod'])
    ..patientSharePercent = decodeDouble(json['patientSharePercent'])
    ..state = decodeEnum(MedicalBillState.values, json['state'])
    ..yearMonth = (json['yearMonth'] as String?) ?? ''
    ..serviceDate = decodeDate(json['serviceDate'])
    ..billedAmount = decodeInt(json['billedAmount'])
    ..currency = (json['currency'] as String?) ?? ''
    ..billPhotoPath = json['billPhotoPath'] as String?
    ..insurerReplyPath = json['insurerReplyPath'] as String?
    ..followUpDate = decodeDate(json['followUpDate'])
    ..calendarEventId = json['calendarEventId'] as String?
    ..reimbursedAmount = decodeInt(json['reimbursedAmount']);
}
