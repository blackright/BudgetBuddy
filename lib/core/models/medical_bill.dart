import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';
import 'currency_code.dart';

part 'medical_bill.g.dart';

/// A medical service the user paid for (or plans to pay for).
///
/// [state] retains the legacy cost mapping and whole-space shared workflow.
/// Personal provider payment is read from the linked expense; insurer decisions,
/// submission and cancellation are separate immutable claim records. Do not
/// reinterpret an old Waiting bill as unpaid or infer its submission date.
@collection
class MedicalBill {
  Id id = Isar.autoIncrement;

  /// Device-independent identity of this row (research R5); indexed, not unique
  /// (uniqueness held by construction and migration step 17).
  @Index()
  String syncGuid = newSyncGuid();

  @Index()
  int? profileId;

  /// Owning shared space, or `null` for a personal bill. Exactly one of
  /// [profileId] / [sharedSpaceId] is set (FR-003, data-model §3.5).
  @Index()
  int? sharedSpaceId;

  /// 1:1 link to `Expense.id`. The two are always written together, so their
  /// amounts and owning months can never drift apart (FR-056).
  @Index()
  int? linkedExpenseId;

  /// Links to `FamilyMember.id`. Dependents are out of scope, but the key
  /// already exists and must not be orphaned by this rewrite.
  @Index()
  int? familyMemberId;

  /// Links to `MedicalProvider.id`.
  @Index()
  int? providerId;

  /// Links to `MedicalServiceType.id`.
  @Index()
  int? serviceTypeId;

  /// Which of the two payment methods applied (FR-041).
  @enumerated
  @Index()
  MedicalPaymentMethod paymentMethod = MedicalPaymentMethod.selfPaid;

  /// Percentage **the user** is responsible for (FR-048). Inverted from the
  /// retired `insuranceCoveragePercent`: 20 means the user pays a fifth.
  double patientSharePercent = 20.0;

  @enumerated
  MedicalBillState state = MedicalBillState.waiting;

  /// The bill's overall resolution, independent of the workflow trackers.
  @enumerated
  @Index()
  MedicalOverallStatus overallStatus = MedicalOverallStatus.open;

  /// Whether and how the provider was paid. Insurer-paid bills use
  /// [MedicalProviderPaymentStatus.notRequired].
  @enumerated
  @Index()
  MedicalProviderPaymentStatus providerPaymentStatus =
      MedicalProviderPaymentStatus.notConfirmed;

  /// Where the insurance request currently sits. Independent of provider
  /// payment and salary settlement.
  @enumerated
  @Index()
  MedicalInsuranceRequestStatus insuranceRequestStatus =
      MedicalInsuranceRequestStatus.notSubmitted;

  /// What kind of salary settlement this bill expects.
  @enumerated
  MedicalSalarySettlementType salarySettlementType =
      MedicalSalarySettlementType.none;

  /// Where the refund or salary deduction currently sits.
  @enumerated
  @Index()
  MedicalSalarySettlementStatus salarySettlementStatus =
      MedicalSalarySettlementStatus.notRequired;

  /// When the user submitted the insurance request.
  DateTime? submissionDate;

  /// When the user confirmed insurance received the request.
  DateTime? receiptConfirmedDate;

  /// Optional insurer reference.
  String? insuranceReference;

  /// Expected `YYYY-MM` salary month for the refund or deduction.
  String? expectedSalaryMonth;

  /// Actual `YYYY-MM` salary month when money moved.
  String? actualSalaryMonth;

  /// Expected or approved amount for the current settlement, in minor units.
  int? settlementAmountMinor;

  /// Actual confirmed amount for the current settlement, in minor units.
  int? settledAmountMinor;

  /// Actual received/deducted date when known.
  DateTime? settledDate;

  /// How a rejection was resolved.
  @enumerated
  MedicalRejectionResolution rejectionResolution =
      MedicalRejectionResolution.none;

  /// Set when legacy or ambiguous money must be reviewed before the new
  /// workflow can act. Such bills stay readable and are never auto-converted.
  @Index()
  bool needsReview = false;

  /// Last tracker update. Null for records created before the trackers existed.
  DateTime? lastUpdatedAt;

  DateTime? closedAt;
  String? closeReason;

  /// Owning month (`YYYY-MM`), derived from [serviceDate] unless the user
  /// overrides it, and mirrored onto the linked expense (FR-055).
  @Index()
  String yearMonth = '';

  @Index()
  DateTime? serviceDate;

  /// Full charge, in whole minor units of [currency] (FR-015, data-model §4.3).
  int billedAmount = 0;

  /// The bill's own currency (`huf`/`usd`/`cad`/`eur`), added by schema step 8.
  ///
  /// `''` means "legacy bill — follow the linked expense's currency", which is
  /// how bills behaved before this field existed (they inherited it with the
  /// rate forced to 1.0). New bills always record their own currency so share
  /// math runs in the original unit (FR-016, data-model §4.3).
  String currency = '';

  /// The parsed bill currency, or `null` when the bill follows its linked
  /// expense (`''`) or carries a legacy code (FR-016, FR-021).
  @ignore
  CurrencyCode? get currencyCode =>
      currency.isEmpty ? null : CurrencyCode.tryParse(currency);

  /// The bill itself. Optional for either payment method (FR-047).
  String? billPhotoPath;

  /// The insurer's reply. Self-paid bills only — an insurer-paid bill never has
  /// a payout to claim, so attaching one is invalid (FR-047).
  String? insurerReplyPath;

  /// Reminder date to chase a pending claim (FR-009).
  DateTime? followUpDate;

  /// Calendar event ID if added to device calendar.
  String? calendarEventId;

  /// Denormalised copy of the linked reimbursement, in the bill's minor units;
  /// `0` when none.
  int reimbursedAmount = 0;

  /// What the user owes the hospital before any reimbursement, in the bill's
  /// own currency, rounded once to whole minor units (FR-048, §4.3).
  @ignore
  int get patientShareAmount =>
      (billedAmount * patientSharePercent / 100).round();

  /// The insurer's portion of the charge, in the bill's own currency.
  @ignore
  int get insurerPaidAmount => billedAmount - patientShareAmount;

  /// Percentage of the bill insurance is expected to cover (0–100).
  ///
  /// Bill Creation asks for coverage; the stored field stays
  /// [patientSharePercent] so existing data and the `100 - share` invariant do
  /// not change (Bill Creation PRD §8.2).
  @ignore
  double get insuranceCoveragePercent =>
      (100.0 - patientSharePercent).clamp(0.0, 100.0);

  /// Sets coverage, clamping to 0–100 and storing the inverted share.
  ///
  /// This is a convenience for the creation form only; it keeps the stored
  /// invariant in one place instead of repeating the inversion at call sites.
  void setInsuranceCoverage(double coveragePercent) {
    patientSharePercent = (100.0 - coveragePercent).clamp(0.0, 100.0);
  }

  /// What the user expects insurance to reimburse after paying in full.
  ///
  /// Zero for an insurer-paid bill: there is no refund to the user, only a
  /// direct payment to the provider (Bill Creation PRD §10.3).
  @ignore
  int get expectedInsuranceRefund =>
      paymentMethod == MedicalPaymentMethod.selfPaid ? insurerPaidAmount : 0;

  /// What insurance is expected to pay the provider directly.
  ///
  /// Zero for a self-paid bill, where the user pays first and claims back
  /// (Bill Creation PRD §10.2).
  @ignore
  int get insurancePaysProviderAmount =>
      paymentMethod == MedicalPaymentMethod.insurerPaid ? insurerPaidAmount : 0;

  /// The amount expected to affect the budget once payment is confirmed.
  ///
  /// Creation only plans the bill, so this is a planning value and must not be
  /// mistaken for [fundsImpact], which is zero while the bill is `planned`
  /// (Bill Creation PRD §17.2).
  @ignore
  int get plannedBudgetEffect => switch (paymentMethod) {
        MedicalPaymentMethod.insurerPaid => patientShareAmount,
        MedicalPaymentMethod.selfPaid => billedAmount,
      };

  /// How much this bill removes from available funds.
  ///
  /// This *is* the money-impact table in `contracts/medical-bill-lifecycle.md`
  /// §4, collapsed into three branches because the ten rows agree:
  ///
  /// - `planned` — nothing has moved, so nothing leaves.
  /// - `rejected` — the insurer declined, so the user owes the whole charge
  ///   whatever the payment method was.
  /// - everything else — the patient share for insurer-paid bills, the full
  ///   charge for self-paid ones.
  ///
  /// `Expense.amount` is always set from this, so the bill and the budget can
  /// never disagree about what a bill cost (R07).
  @ignore
  int get fundsImpact {
    if (state == MedicalBillState.planned) return 0;
    if (state == MedicalBillState.rejected) return billedAmount;
    return switch (paymentMethod) {
      MedicalPaymentMethod.insurerPaid => patientShareAmount,
      MedicalPaymentMethod.selfPaid => billedAmount,
    };
  }

  /// Whether the bill counts against payments rather than the planned pool.
  @ignore
  bool get countsAsPaid => state != MedicalBillState.planned;

  /// Net cost to the user once reimbursements are counted.
  ///
  /// An insurer-paid bill only ever cost the user their share, so it ignores the
  /// billed amount; a self-paid bill started at the full charge and is reduced
  /// by what came back. Never negative.
  @ignore
  int get netOutOfPocket => switch (paymentMethod) {
        MedicalPaymentMethod.insurerPaid => patientShareAmount,
        MedicalPaymentMethod.selfPaid =>
          (billedAmount - reimbursedAmount).clamp(0, billedAmount),
      };

  /// A self-paid bill is the only kind that can be reimbursed (FR-044).
  @ignore
  bool get canBeReimbursed => paymentMethod == MedicalPaymentMethod.selfPaid;
}

/// Who paid the hospital.
enum MedicalPaymentMethod {
  /// The insurer bills the hospital directly; the user pays only their share.
  insurerPaid,

  /// The user paid in full and claims the insurer's share back.
  selfPaid,
}

extension MedicalPaymentMethodLabel on MedicalPaymentMethod {
  String get label => switch (this) {
        MedicalPaymentMethod.insurerPaid => 'Insurer paid',
        MedicalPaymentMethod.selfPaid => 'Self-paid',
      };
}

/// Where a bill sits. Doubles as its insurance meaning and its budget effect
/// (FR-053).
enum MedicalBillState {
  planned,
  waiting,
  paid,
  finished,
  rejected,
}

extension MedicalBillStateLabel on MedicalBillState {
  String get label => switch (this) {
        MedicalBillState.planned => 'Planned',
        MedicalBillState.waiting => 'Waiting',
        MedicalBillState.paid => 'Paid',
        MedicalBillState.finished => 'Finished',
        MedicalBillState.rejected => 'Rejected',
      };

  /// States still awaiting an insurer decision, i.e. ones worth following up on.
  bool get isPending => this == MedicalBillState.waiting;

  /// States that count against available funds.
  bool get isSettled =>
      this != MedicalBillState.planned && this != MedicalBillState.waiting;
}

/// Overall resolution, separate from the detailed workflow trackers.
enum MedicalOverallStatus { open, closed, cancelled }

/// Whether and how the healthcare provider was paid.
enum MedicalProviderPaymentStatus { notConfirmed, paid, refunded, notRequired }

/// The insurance request stage. Appeals are repeatable records, not new states.
enum MedicalInsuranceRequestStatus {
  notSubmitted,
  submitted,
  receiptPending,
  inProgress,
  approved,
  rejected,
  appealSubmitted,
  appealInProgress,
  appealApproved,
  appealRejected,
  requestCancelled,
  completed,
}

/// The kind of money expected from or owed to salary.
enum MedicalSalarySettlementType { none, insuranceRefund, userShareDeduction }

/// The salary settlement stage.
enum MedicalSalarySettlementStatus {
  notRequired,
  waitingForPayslip,
  received,
  deducted,
  notReceived,
  notDeducted,
}

/// How a rejected insurance-paid request was resolved.
enum MedicalRejectionResolution {
  none,
  accepted,
  appeal,
  providerCancelled,
  userPaidProvider,
  adjustedDeduction,
  other,
}
