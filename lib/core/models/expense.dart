import 'package:isar/isar.dart';

import 'currency_code.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  static const String defaultCategoryId = 'general';

  @Index()
  late int profileId;

  @Index()
  late String yearMonth;

  @enumerated
  ExpenseType type = ExpenseType.standard;

  String title;

  /// Amount in **whole minor units** of [currency] (HUF: forint, others: the
  /// cent-scale unit) — the single money representation (FR-015, data-model
  /// §4.3). A legacy `double` value is converted by migration step 9.
  int amount;

  /// Persisted currency code. Kept as the raw string (not the enum) so a legacy
  /// value the app no longer understands survives verbatim (FR-021, §4.4);
  /// resolve it through [currencyCode].
  String currency;
  String categoryId;
  @enumerated
  ExpenseStatus status;
  bool isReimbursable;
  @enumerated
  GuiltLevel guiltLevel;
  DateTime date;
  String? receiptPath;
  String? notes;
  int budgetId;

  /// When the money actually left the account. Set on Planned → Paid,
  /// cleared on Paid → Planned.
  DateTime? paidAt;

  Expense({
    this.id = Isar.autoIncrement,
    required this.profileId,
    required this.yearMonth,
    this.type = ExpenseType.standard,
    required this.title,
    required this.amount,
    required this.currency,
    required this.categoryId,
    this.status = ExpenseStatus.paid,
    this.isReimbursable = false,
    this.guiltLevel = GuiltLevel.essential,
    required this.date,
    this.receiptPath,
    this.notes,
    required this.budgetId,
    this.paidAt,
  });

  /// The parsed currency, or `null` for a legacy/unsupported code that must be
  /// preserved and excluded from converted totals (FR-021, data-model §4.4).
  @ignore
  CurrencyCode? get currencyCode => CurrencyCode.tryParse(currency);
}

enum ExpenseStatus {
  planned,
  paid,
  cancelled,
  reimbursed,
  partiallyReimbursed,
}

enum ExpenseType {
  standard,
  medical,
}

enum GuiltLevel {
  essential,
  guiltFree,
  oops,
}
