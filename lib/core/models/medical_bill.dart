import 'package:isar/isar.dart';

part 'medical_bill.g.dart';

/// A medical service the user paid for (or plans to pay for), with the
/// insurance claim lifecycle tracked separately from the linked [Expense].
///
/// The two lifecycles are intentionally independent:
/// - `Expense.status` (planned / paid / cancelled) tracks money leaving the account.
/// - [claimStatus] tracks what the insurer is doing about the bill.
@collection
class MedicalBill {
  Id id = Isar.autoIncrement;

  @Index()
  int? profileId;

  /// 1:1 link to `Expense.id`. `null` only for bills saved without a budget.
  @Index()
  int? linkedExpenseId;

  /// Links to `FamilyMember.id`.
  @Index()
  int? familyMemberId;

  /// Links to `MedicalProvider.id`.
  @Index()
  int? providerId;

  /// Local file paths for receipts / EOBs (FR-007).
  List<String> attachmentPaths = [];

  /// Reminder date to chase a pending claim (FR-009).
  DateTime? followUpDate;

  double billedAmount = 0.0;
  double insuranceCoveragePercent = 0.0;

  @enumerated
  ClaimStatus claimStatus = ClaimStatus.unclaimed;

  DateTime? serviceDate;

  /// Actual amount the insurer paid back. Drives the budget injection (FR-005).
  double reimbursedAmount = 0.0;

  @ignore
  double get insuranceCoveredAmount =>
      billedAmount * (insuranceCoveragePercent / 100);

  /// Coverage-based estimate of the patient's share, used for the deductible.
  @ignore
  double get estimatedOutPocket => billedAmount - insuranceCoveredAmount;

  /// What the user actually ended up paying: the amount handed to the provider
  /// minus whatever the insurer paid back. Never negative.
  ///
  /// This is deliberately derived from the full [billedAmount] rather than from
  /// [estimatedOutPocket], because the linked expense leaves the budget at the
  /// full billed amount and only a logged reimbursement gives money back.
  @ignore
  double get netOutOfPocket =>
      (billedAmount - reimbursedAmount).clamp(0.0, double.infinity);

  /// What the user is responsible for right now: the coverage estimate until an
  /// insurer payout lands, then the real net cost.
  @ignore
  double get patientShare =>
      reimbursedAmount > 0 ? netOutOfPocket : estimatedOutPocket;
}

/// Where a medical bill sits in the insurance claim lifecycle.
enum ClaimStatus {
  unclaimed,
  processing,
  reimbursed,
  denied,
}

extension ClaimStatusLabel on ClaimStatus {
  String get label => switch (this) {
        ClaimStatus.unclaimed => 'Unclaimed',
        ClaimStatus.processing => 'Processing',
        ClaimStatus.reimbursed => 'Reimbursed',
        ClaimStatus.denied => 'Denied',
      };

  /// Claims still awaiting an insurer decision, i.e. ones worth following up on.
  bool get isPending =>
      this == ClaimStatus.unclaimed || this == ClaimStatus.processing;
}
