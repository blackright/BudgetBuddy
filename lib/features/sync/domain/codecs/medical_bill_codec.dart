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
        'overallStatus': value.overallStatus.name,
        'providerPaymentStatus': value.providerPaymentStatus.name,
        'insuranceRequestStatus': value.insuranceRequestStatus.name,
        'salarySettlementType': value.salarySettlementType.name,
        'salarySettlementStatus': value.salarySettlementStatus.name,
        'submissionDate': encodeDate(value.submissionDate),
        'receiptConfirmedDate': encodeDate(value.receiptConfirmedDate),
        'insuranceReference': value.insuranceReference,
        'expectedSalaryMonth': value.expectedSalaryMonth,
        'actualSalaryMonth': value.actualSalaryMonth,
        'settlementAmountMinor': value.settlementAmountMinor,
        'settledAmountMinor': value.settledAmountMinor,
        'settledDate': encodeDate(value.settledDate),
        'rejectionResolution': value.rejectionResolution.name,
        'needsReview': value.needsReview,
        'lastUpdatedAt': encodeDate(value.lastUpdatedAt),
        'closedAt': encodeDate(value.closedAt),
        'closeReason': value.closeReason,
      };

  @override
  MedicalBill fromJson(Map<String, Object?> json) {
    final bill = MedicalBill()
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
      ..reimbursedAmount = decodeInt(json['reimbursedAmount'])
      ..overallStatus =
          decodeEnum(MedicalOverallStatus.values, json['overallStatus'])
      ..providerPaymentStatus = decodeEnum(
          MedicalProviderPaymentStatus.values, json['providerPaymentStatus'])
      ..insuranceRequestStatus = decodeEnum(
          MedicalInsuranceRequestStatus.values, json['insuranceRequestStatus'])
      ..salarySettlementType = decodeEnum(
          MedicalSalarySettlementType.values, json['salarySettlementType'])
      ..salarySettlementStatus = decodeEnum(
          MedicalSalarySettlementStatus.values, json['salarySettlementStatus'])
      ..submissionDate = decodeDate(json['submissionDate'])
      ..receiptConfirmedDate = decodeDate(json['receiptConfirmedDate'])
      ..insuranceReference = json['insuranceReference'] as String?
      ..expectedSalaryMonth = json['expectedSalaryMonth'] as String?
      ..actualSalaryMonth = json['actualSalaryMonth'] as String?
      ..settlementAmountMinor = decodeIntOrNull(json['settlementAmountMinor'])
      ..settledAmountMinor = decodeIntOrNull(json['settledAmountMinor'])
      ..settledDate = decodeDate(json['settledDate'])
      ..rejectionResolution = decodeEnum(
          MedicalRejectionResolution.values, json['rejectionResolution'])
      ..needsReview = (json['needsReview'] as bool?) ?? false
      ..lastUpdatedAt = decodeDate(json['lastUpdatedAt'])
      ..closedAt = decodeDate(json['closedAt'])
      ..closeReason = json['closeReason'] as String?;

    // A peer on the previous app version does not send tracker fields. Derive
    // conservative defaults from the legacy state instead of overwriting the
    // local trackers with "not submitted/not confirmed".
    if (!json.containsKey('overallStatus')) {
      final finished = bill.state == MedicalBillState.finished;
      final rejected = bill.state == MedicalBillState.rejected;
      final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
      bill
        ..overallStatus =
            finished ? MedicalOverallStatus.closed : MedicalOverallStatus.open
        ..providerPaymentStatus = direct
            ? MedicalProviderPaymentStatus.notRequired
            : (bill.state == MedicalBillState.paid || finished)
                ? MedicalProviderPaymentStatus.paid
                : MedicalProviderPaymentStatus.notConfirmed
        ..insuranceRequestStatus = rejected
            ? MedicalInsuranceRequestStatus.rejected
            : finished
                ? MedicalInsuranceRequestStatus.completed
                : MedicalInsuranceRequestStatus.notSubmitted
        ..salarySettlementType = direct
            ? MedicalSalarySettlementType.userShareDeduction
            : MedicalSalarySettlementType.insuranceRefund
        ..salarySettlementStatus = MedicalSalarySettlementStatus.notRequired;
    }
    return bill;
  }
}
