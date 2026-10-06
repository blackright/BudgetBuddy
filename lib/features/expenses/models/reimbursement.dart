import 'package:isar/isar.dart';

import '../../../core/models/currency_code.dart';

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

  /// Amount in whole minor units of [currency] (FR-015, data-model §4.3).
  int amount;

  /// Persisted currency code; resolve via [currencyCode] (FR-021, §4.4).
  String currency;

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
    required this.date,
    this.note,
  });

  /// The parsed currency, or `null` for a legacy/unsupported code (FR-021).
  @ignore
  CurrencyCode? get currencyCode => CurrencyCode.tryParse(currency);
}
