import 'package:isar/isar.dart';

part 'expense.g.dart';

enum ExpenseStatus { planned, paid, cancelled }

enum ExpenseType { standard, medical }

@collection
class Expense {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late String title;

  late double amount;

  late String currency;

  double exchangeRateToPrimary = 1.0;

  @enumerated
  ExpenseStatus status = ExpenseStatus.planned;

  @enumerated
  ExpenseType type = ExpenseType.standard;

  late DateTime date;

  @Index()
  late String yearMonth;
}
