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
        'syncGuid': value.syncGuid,
        'profileId': value.profileId,
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
    ..syncGuid = decodeGuid(json['syncGuid'])
    ..profileId = decodeIntOrNull(json['profileId'])
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
