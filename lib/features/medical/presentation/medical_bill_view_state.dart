import '../../../core/models/currency_code.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_settlement_event.dart';
import '../../../core/models/money.dart';
import '../../../core/services/fx_booking_service.dart' show fxPaid;
import '../../../core/services/medical_receipt_service.dart';
import '../../../core/services/medical_settlement_service.dart';

enum MedicalInboxGroup { needsYou, waiting, closed }

enum MedicalSubmission { unknown, notSent, sent }

/// Unknown is not interchangeable with an explicit unpaid/unconfirmed fact.
enum MedicalEvidence { unknown, notConfirmed, confirmed }

enum MedicalBillAction {
  recordPayment,
  markAsSent,
  recordReply,
  reviewIncomingMoney,
  recordInsurerPayment,
  recordShare,
  closeBill,
  setReminder,
  reviewBill,
  viewActivity,
  legacyShared,
}

class MedicalReadiness {
  MedicalReadiness.ready()
      : known = true,
        blockers = const [];
  MedicalReadiness.unknown()
      : known = false,
        blockers = const [];
  MedicalReadiness.blocked(Iterable<String> reasons)
      : known = true,
        blockers = List.unmodifiable(reasons);
  final bool known;
  final List<String> blockers;
}

/// Immutable scalar snapshot. Never retains mutable Isar model references.
/// Direct settlement evidence is unknown for all live Phase A reads; future
/// fixtures may supply it without creating financial records or enabling writes.
class MedicalBillFacts {
  /// Copies validated existing facts into immutable presentation inputs. A
  /// failed read or unmatched old scalar is unknown money, not a zero receipt.
  factory MedicalBillFacts.fromHistory(
      MedicalBill bill, MedicalReceiptHistory? history,
      {bool readIssue = false}) {
    final invalidAmount = bill.billedAmount <= 0 ||
        !bill.patientSharePercent.isFinite ||
        bill.patientSharePercent < 0 ||
        bill.patientSharePercent > 100;
    final code = bill.currencyCode ??
        (bill.currency.isEmpty ? history?.expense.currencyCode : null);
    final unknownReceived =
        history == null || bill.reimbursedAmount > history.receivedMinor;
    final approved = history?.approval;
    final approvalMismatch = approved != null &&
        (approved.approvedMinor < 0 ||
            CurrencyCode.tryParse(approved.currency) != code);
    final shareMinor = invalidAmount ? 0 : bill.patientShareAmount;
    final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
    final active = activeSettlements(
        history?.settlements ?? const <MedicalSettlementEvent>[]);
    final providerRows = active.where(
        (e) => e.kind == MedicalSettlementKind.insurerProviderSettlement);
    final shareRows =
        active.where((e) => e.kind == MedicalSettlementKind.shareSettlement);
    final hasClosure =
        active.any((e) => e.kind == MedicalSettlementKind.closure);
    final withholding = history?.withholdingMatches ?? const [];
    // No evidence means unknown (legacy). Once any evidence exists, a missing
    // share is an explicit "not recorded" fact, not an inference.
    final providerState = providerRows.isEmpty
        ? MedicalEvidence.unknown
        : providerRows.any((e) => e.confirmed)
            ? MedicalEvidence.confirmed
            : MedicalEvidence.notConfirmed;
    final shareState = shareMinor == 0
        ? MedicalEvidence.confirmed
        : shareRows.any((e) => e.confirmed) || withholding.isNotEmpty
            ? MedicalEvidence.confirmed
            : active.isNotEmpty || withholding.isNotEmpty
                ? MedicalEvidence.notConfirmed
                : MedicalEvidence.unknown;
    return MedicalBillFacts(
      billId: bill.id,
      billGuid: bill.syncGuid,
      method: bill.paymentMethod,
      legacyState: bill.state,
      isShared: bill.sharedSpaceId != null,
      currency: invalidAmount ? null : code,
      billedMinor: bill.billedAmount,
      patientShareMinor: shareMinor,
      providerPaid: history == null ? null : fxPaid(history.expense.status),
      submission: history?.submitted == true
          ? MedicalSubmission.sent
          : history?.activities.any((a) => a.kind == 'created') == true
              ? MedicalSubmission.notSent
              : MedicalSubmission.unknown,
      approvedMinor: approvalMismatch ? null : approved?.approvedMinor,
      receivedMinor: unknownReceived ? null : history.receivedMinor,
      needsReview: readIssue ||
          invalidAmount ||
          approvalMismatch ||
          history == null ||
          history.approvalNeedsReview ||
          (direct &&
              (providerState == MedicalEvidence.unknown ||
                  shareState == MedicalEvidence.unknown)) ||
          (bill.state == MedicalBillState.finished &&
              history.closure == null) ||
          (!fxPaid(history.expense.status) && history.receivedMinor > 0) ||
          (!bill.canBeReimbursed && history.receivedMinor != 0),
      cancelled: history?.cancelled ?? false,
      enteredInError: history?.enteredInError ?? false,
      closed: history?.closure != null || hasClosure,
      shortfallMinor: history?.shortfallMinor ?? 0,
      directProviderSettlement: providerState,
      shareSettlement: shareState,
      followUp: bill.followUpDate,
    );
  }

  const MedicalBillFacts({
    required this.billId,
    required this.billGuid,
    required this.method,
    required this.legacyState,
    required this.isShared,
    required this.currency,
    required this.billedMinor,
    required this.patientShareMinor,
    required this.providerPaid,
    this.submission = MedicalSubmission.unknown,
    this.approvedMinor,
    this.receivedMinor,
    this.needsReview = false,
    this.cancelled = false,
    this.enteredInError = false,
    this.closed = false,
    this.shortfallMinor = 0,
    this.directProviderSettlement = MedicalEvidence.unknown,
    this.shareSettlement = MedicalEvidence.unknown,
    this.followUp,
  });
  final int billId;
  final String billGuid;
  final MedicalPaymentMethod method;
  final MedicalBillState legacyState;
  final bool isShared;
  final CurrencyCode? currency;
  final int billedMinor, patientShareMinor;
  final bool? providerPaid;
  final MedicalSubmission submission;
  final int? approvedMinor, receivedMinor;
  final bool needsReview, cancelled, enteredInError, closed;
  final int shortfallMinor;
  final MedicalEvidence directProviderSettlement, shareSettlement;
  final DateTime? followUp;
}

/// One interpretation for future list and detail consumers. An action identifier
/// describes the next useful event, not authorization to perform that event.
class MedicalBillViewState {
  MedicalBillViewState({
    required this.billId,
    required this.arrangementLabel,
    required this.headline,
    required this.providerLabel,
    required this.insuranceLabel,
    required this.group,
    required this.primaryAction,
    required this.actionLabel,
    required this.actionEnabled,
    required this.blocker,
    required this.billTotal,
    required this.userObligation,
    required this.expectedRefund,
    required this.approvedRefund,
    required this.receivedRefund,
    required this.remainingRefund,
    required this.costSoFar,
    required this.estimatedFinalCost,
    required this.paymentMethod,
    required this.sharePaymentLabel,
    required this.insuranceShare,
    required this.isFinalCost,
    required this.insuranceDeclined,
    required this.isCancelled,
    required this.isEnteredInError,
    required this.isClosed,
    Iterable<MedicalBillAction> secondaryActions = const [],
  }) : secondaryActions = List.unmodifiable(secondaryActions);
  final int billId;
  final String arrangementLabel, headline, providerLabel, insuranceLabel;
  final MedicalInboxGroup group;
  final MedicalBillAction primaryAction;
  final String actionLabel;
  final bool actionEnabled;
  final String? blocker;
  final MedicalPaymentMethod paymentMethod;
  final String sharePaymentLabel;
  final Money? insuranceShare;
  final bool isFinalCost, insuranceDeclined;
  final bool isCancelled, isEnteredInError;
  final bool isClosed;
  final List<MedicalBillAction> secondaryActions;
  final Money? billTotal,
      userObligation,
      expectedRefund,
      approvedRefund,
      receivedRefund,
      remainingRefund,
      costSoFar,
      estimatedFinalCost;
}
