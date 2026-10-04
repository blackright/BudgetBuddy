import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  static const String defaultCategoryId = 'general';

  @Index()
  late int profileId;

  @Index()
  late String yearMonth;

  double exchangeRateToPrimary = 1.0;

  @enumerated
  ExpenseType type = ExpenseType.standard;

  String title;
  double amount;
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
    this.exchangeRateToPrimary = 1.0,
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
}

enum ExpenseStatus {
  planned,
  paid,
  cancelled,
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
