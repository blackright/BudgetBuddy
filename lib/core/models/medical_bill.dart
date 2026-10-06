import 'package:isar/isar.dart';

import 'currency_code.dart';

part 'medical_bill.g.dart';

/// A medical service the user paid for (or plans to pay for).
///
/// The bill's own [state] is the single authority for both its insurance meaning
/// and its effect on the budget. There is no separate claim workflow: asking
/// whether a bill counts as paid and asking whether the insurer has answered are
/// the same question, so they cannot disagree.
@collection
class MedicalBill {
  Id id = Isar.autoIncrement;

  @Index()
  int? profileId;

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
