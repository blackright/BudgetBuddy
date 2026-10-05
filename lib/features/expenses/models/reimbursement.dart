import 'package:isar/isar.dart';

part 'reimbursement.g.dart';

@collection
class Reimbursement {
  Id id = Isar.autoIncrement;

  /// Target expense or medical bill's linked expense. `null` means the target
  /// was deleted; the row is retained, flagged and surfaced to the user
  /// (FR-035).
  @Index()
  int? expenseId;

  /// The month the returned money *belongs to* — the target expense's owning
  /// month, never the month it was recorded in (FR-032).
  @Index()
  String originYearMonth = '';

  /// Set when the target expense is deleted (FR-035).
  ///
  /// The row is deliberately kept: money really did come back, so deleting it
  /// would quietly rewrite a closed month's history. Flagging it instead lets
  /// the user decide whether the payout was a mistake or the expense was deleted
  /// by accident.
  @Index()
  bool orphaned = false;

  late double amount;

  /// When the user recorded the reimbursement. Display and audit only; never
  /// used for attribution.
  late DateTime date;
}
