import 'package:isar/isar.dart';

part 'reimbursement.g.dart';

@collection
class Reimbursement {
  Id id = Isar.autoIncrement;

  @Index()
  int profileId;

  /// Target expense or medical bill's linked expense. `null` means the target
  /// was deleted; the row is retained, flagged and surfaced to the user
  /// (FR-035).
  @Index()
  int? expenseId;

  /// The month the returned money *belongs to* — the target expense's owning
  /// month, never the month it was recorded in (FR-032).
  @Index()
  String originYearMonth;

  /// Set when the target expense is deleted (FR-035).
  @Index()
  bool orphaned;

  double amount;
  String currency;
  double exchangeRateToPrimary;

  /// When the user recorded the reimbursement. Display and audit only; never
  /// used for attribution.
  DateTime date;

  String? note;

  Reimbursement({
    this.id = Isar.autoIncrement,
    required this.profileId,
    this.expenseId,
    required this.originYearMonth,
    this.orphaned = false,
    required this.amount,
    required this.currency,
    this.exchangeRateToPrimary = 1.0,
    required this.date,
    this.note,
  });
}
