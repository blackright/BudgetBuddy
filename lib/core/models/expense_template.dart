import 'package:isar/isar.dart';
import 'expense.dart';

part 'expense_template.g.dart';

@collection
class ExpenseTemplate {
  Id id = Isar.autoIncrement;
  String title;
  double? amount; // Optional, can be asked later
  String? currency;
  String categoryId;
  @enumerated
  GuiltLevel guiltLevel;
  bool isReimbursable;

  // Custom metadata
  String? icon;
  int? color;

  ExpenseTemplate({
    this.id = Isar.autoIncrement,
    required this.title,
    this.amount,
    this.currency,
    required this.categoryId,
    this.guiltLevel = GuiltLevel.essential,
    this.isReimbursable = false,
    this.icon,
    this.color,
  });
}
