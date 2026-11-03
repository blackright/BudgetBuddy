/// Builders and seed helpers for Bill Management tests.
///
/// Phase 1 keeps these fixtures on the current schema. Phases 2–7 extend them
/// with the tracker fields, appeal rows and actual-month overrides as those
/// fields are introduced. Nothing here fakes a field that does not exist yet.
library;

import 'package:isar/isar.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';

/// A bill and its linked expense written by [seedManagementBill].
class SeededManagementBill {
  const SeededManagementBill({required this.bill, required this.expense});

  final MedicalBill bill;
  final Expense expense;
}

/// Access guard used by service tests.
typedef AccessCheck = bool Function();

/// A guard that stays valid for the whole command.
AccessCheck alwaysCurrentAccess() => () => true;

/// A guard that fails immediately, as after a lock or context change.
AccessCheck revokedAccess() => () => false;

/// Builds a medical bill without writing it.
///
/// Defaults describe a personal, planned user-paid bill. Pass
/// `sharedSpaceId` for a shared bill; the conflicting profile key is then set
/// to the app's shared convention (`0`).
MedicalBill buildMedicalBill({
  int? profileId,
  int? sharedSpaceId,
  int billedAmount = 10000,
  double patientSharePercent = 20,
  MedicalPaymentMethod paymentMethod = MedicalPaymentMethod.selfPaid,
  MedicalBillState state = MedicalBillState.planned,
  String currency = 'usd',
  String yearMonth = '2026-10',
  DateTime? serviceDate,
  int reimbursedAmount = 0,
  String? billPhotoPath,
  String? insurerReplyPath,
  DateTime? followUpDate,
  MedicalOverallStatus overallStatus = MedicalOverallStatus.open,
  MedicalProviderPaymentStatus providerPaymentStatus =
      MedicalProviderPaymentStatus.notConfirmed,
  MedicalInsuranceRequestStatus insuranceRequestStatus =
      MedicalInsuranceRequestStatus.notSubmitted,
  MedicalSalarySettlementType salarySettlementType =
      MedicalSalarySettlementType.none,
  MedicalSalarySettlementStatus salarySettlementStatus =
      MedicalSalarySettlementStatus.notRequired,
  bool needsReview = false,
  DateTime? submissionDate,
  String? expectedSalaryMonth,
}) {
  assert(
    reimbursedAmount == 0 || paymentMethod == MedicalPaymentMethod.selfPaid,
    'Only a self-paid bill can carry a reimbursement.',
  );
  final date = serviceDate ?? DateTime(2026, 10, 15);
  return MedicalBill()
    ..profileId = sharedSpaceId == null ? profileId : 0
    ..sharedSpaceId = sharedSpaceId
    ..billedAmount = billedAmount
    ..patientSharePercent = patientSharePercent
    ..paymentMethod = paymentMethod
    ..state = state
    ..currency = currency
    ..yearMonth = yearMonth
    ..serviceDate = date
    ..reimbursedAmount = reimbursedAmount
    ..billPhotoPath = billPhotoPath
    ..insurerReplyPath = insurerReplyPath
    ..followUpDate = followUpDate
    ..overallStatus = overallStatus
    ..providerPaymentStatus = providerPaymentStatus
    ..insuranceRequestStatus = insuranceRequestStatus
    ..salarySettlementType = salarySettlementType
    ..salarySettlementStatus = salarySettlementStatus
    ..needsReview = needsReview
    ..submissionDate = submissionDate
    ..expectedSalaryMonth = expectedSalaryMonth;
}

/// Builds the linked medical expense for [bill].
///
/// Planned bills carry no money movement, matching the Bill Creation contract.
/// Any later state uses the bill's money impact and is marked paid.
Expense buildLinkedMedicalExpense(
  MedicalBill bill, {
  required int budgetId,
  DateTime? paidAt,
}) {
  final planned = bill.state == MedicalBillState.planned;
  final status = planned ? ExpenseStatus.planned : ExpenseStatus.paid;
  final date = bill.serviceDate ?? DateTime(2026, 10, 15);
  return Expense(
    profileId: bill.profileId ?? 0,
    sharedSpaceId: bill.sharedSpaceId,
    yearMonth: bill.yearMonth,
    title: 'Medical fixture',
    amount: planned ? 0 : bill.fundsImpact,
    currency: bill.currency,
    categoryId: 'health',
    date: date,
    budgetId: budgetId,
    type: ExpenseType.medical,
    status: status,
    isReimbursable: bill.canBeReimbursed,
    paidAt: status == ExpenseStatus.paid ? (paidAt ?? date) : null,
  );
}

/// Writes a bill and its linked expense in one transaction.
///
/// The caller owns the budget month. Existing harnesses wrap this helper so
/// tests can seed a bill without repeating the two-row setup.
Future<SeededManagementBill> seedManagementBill(
  Isar db, {
  required int profileId,
  required int budgetId,
  int? sharedSpaceId,
  int billedAmount = 10000,
  double patientSharePercent = 20,
  MedicalPaymentMethod paymentMethod = MedicalPaymentMethod.selfPaid,
  MedicalBillState state = MedicalBillState.planned,
  String currency = 'usd',
  String yearMonth = '2026-10',
  DateTime? serviceDate,
  DateTime? paidAt,
  int reimbursedAmount = 0,
  String? billPhotoPath,
  String? insurerReplyPath,
  DateTime? followUpDate,
  MedicalOverallStatus overallStatus = MedicalOverallStatus.open,
  MedicalProviderPaymentStatus providerPaymentStatus =
      MedicalProviderPaymentStatus.notConfirmed,
  MedicalInsuranceRequestStatus insuranceRequestStatus =
      MedicalInsuranceRequestStatus.notSubmitted,
  MedicalSalarySettlementType salarySettlementType =
      MedicalSalarySettlementType.none,
  MedicalSalarySettlementStatus salarySettlementStatus =
      MedicalSalarySettlementStatus.notRequired,
  bool needsReview = false,
  DateTime? submissionDate,
  String? expectedSalaryMonth,
}) async {
  final bill = buildMedicalBill(
    profileId: profileId,
    sharedSpaceId: sharedSpaceId,
    billedAmount: billedAmount,
    patientSharePercent: patientSharePercent,
    paymentMethod: paymentMethod,
    state: state,
    currency: currency,
    yearMonth: yearMonth,
    serviceDate: serviceDate,
    reimbursedAmount: reimbursedAmount,
    billPhotoPath: billPhotoPath,
    insurerReplyPath: insurerReplyPath,
    followUpDate: followUpDate,
    overallStatus: overallStatus,
    providerPaymentStatus: providerPaymentStatus,
    insuranceRequestStatus: insuranceRequestStatus,
    salarySettlementType: salarySettlementType,
    salarySettlementStatus: salarySettlementStatus,
    needsReview: needsReview,
    submissionDate: submissionDate,
    expectedSalaryMonth: expectedSalaryMonth,
  );
  final expense = buildLinkedMedicalExpense(
    bill,
    budgetId: budgetId,
    paidAt: paidAt,
  );
  await db.writeTxn(() async {
    expense.id = await db.expenses.put(expense);
    bill
      ..linkedExpenseId = expense.id
      ..id = await db.medicalBills.put(bill);
  });
  return SeededManagementBill(bill: bill, expense: expense);
}

/// Planned self-paid bill: the user has not paid the provider yet.
MedicalBill plannedUserPaidBill({int? profileId, int? sharedSpaceId}) =>
    buildMedicalBill(
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      paymentMethod: MedicalPaymentMethod.selfPaid,
      state: MedicalBillState.planned,
    );

/// Planned insurer-paid bill: the insurer pays the provider; only the share is
/// expected to reach the user's budget later.
MedicalBill plannedInsurancePaidBill({int? profileId, int? sharedSpaceId}) =>
    buildMedicalBill(
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      paymentMethod: MedicalPaymentMethod.insurerPaid,
      state: MedicalBillState.planned,
    );

/// User-paid bill whose provider payment has already been confirmed.
MedicalBill providerPaidBill({int? profileId, int? sharedSpaceId}) =>
    buildMedicalBill(
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      paymentMethod: MedicalPaymentMethod.selfPaid,
      state: MedicalBillState.paid,
    );

/// Bill waiting for an insurer decision or refund.
MedicalBill awaitingInsurerBill({int? profileId, int? sharedSpaceId}) =>
    buildMedicalBill(
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      paymentMethod: MedicalPaymentMethod.selfPaid,
      state: MedicalBillState.waiting,
    );

/// Bill whose insurer request was rejected.
MedicalBill rejectedMedicalBill({int? profileId, int? sharedSpaceId}) =>
    buildMedicalBill(
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      paymentMethod: MedicalPaymentMethod.selfPaid,
      state: MedicalBillState.rejected,
    );

/// Closed/finished bill.
MedicalBill closedMedicalBill({
  int? profileId,
  int? sharedSpaceId,
  MedicalPaymentMethod paymentMethod = MedicalPaymentMethod.selfPaid,
}) =>
    buildMedicalBill(
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      paymentMethod: paymentMethod,
      state: MedicalBillState.finished,
    );

/// Legacy bill with money already recorded as partly reimbursed.
///
/// Phase 8 freezes these as Needs review; the fixture keeps the old amount
/// visible so migration tests can prove nothing is silently converted.
MedicalBill legacyPartialReimbursementBill({
  int? profileId,
  int? sharedSpaceId,
  int reimbursedAmount = 2500,
}) =>
    buildMedicalBill(
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      paymentMethod: MedicalPaymentMethod.selfPaid,
      state: MedicalBillState.waiting,
      reimbursedAmount: reimbursedAmount,
    );
