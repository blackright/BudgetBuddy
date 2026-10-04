import 'package:isar/isar.dart';
import 'user_profile.dart';

part 'monthly_budget.g.dart';

@collection
class MonthlyBudget {
  Id id = Isar.autoIncrement;

  late String yearMonth; // Format: "YYYY-MM"

  late double baseAvailableAmount;

  @enumerated
  late PrimaryCurrency currency;

  late DateTime createdAt;

  late DateTime updatedAt;
}
