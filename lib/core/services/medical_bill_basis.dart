import 'dart:convert';
import '../models/medical_bill.dart';

/// Reuses the existing coverage calculation; this is a decision reference,
/// never a new money movement or exchange-rate calculation.
String medicalBillBasis(MedicalBill bill) => jsonEncode({
      'billedMinor': bill.billedAmount,
      'patientMinor': bill.patientShareAmount,
      'expectedMinor': bill.insurerPaidAmount,
      'patientSharePercent': bill.patientSharePercent,
      'currency': bill.currency,
      'paymentMethod': bill.paymentMethod.name,
      'serviceDate': bill.serviceDate?.toUtc().toIso8601String(),
      'yearMonth': bill.yearMonth,
      'providerId': bill.providerId,
      'familyMemberId': bill.familyMemberId,
      'serviceTypeId': bill.serviceTypeId,
    });

MedicalBill copyMedicalBill(MedicalBill b) => MedicalBill()
  ..id = b.id
  ..syncGuid = b.syncGuid
  ..profileId = b.profileId
  ..sharedSpaceId = b.sharedSpaceId
  ..linkedExpenseId = b.linkedExpenseId
  ..familyMemberId = b.familyMemberId
  ..providerId = b.providerId
  ..serviceTypeId = b.serviceTypeId
  ..paymentMethod = b.paymentMethod
  ..patientSharePercent = b.patientSharePercent
  ..state = b.state
  ..yearMonth = b.yearMonth
  ..serviceDate = b.serviceDate
  ..billedAmount = b.billedAmount
  ..currency = b.currency
  ..billPhotoPath = b.billPhotoPath
  ..insurerReplyPath = b.insurerReplyPath
  ..followUpDate = b.followUpDate
  ..calendarEventId = b.calendarEventId
  ..reimbursedAmount = b.reimbursedAmount;
