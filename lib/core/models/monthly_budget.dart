import 'package:isar/isar.dart';
import 'user_profile.dart';

part 'monthly_budget.g.dart';

@collection
class MonthlyBudget {
  Id id = Isar.autoIncrement;

  late String yearMonth; // Format: "YYYY-MM"

  /// The month's opening balance: money in the bank at the start of the month
  /// (FR-006). Nothing is ever carried forward into a new month (FR-007).
  late double baseAvailableAmount;

  /// Distinguishes "the user entered 0" from "the user never entered a
  /// balance" (FR-010). While false, [MonthSummary.moneyInBank] is absent and
  /// the app prompts rather than assuming a figure.
  bool openingBalanceConfirmed = false;

  /// Income for this month only. `null` means "follow
  /// [UserProfile.defaultNetSalary]" (FR-003). Must be null or >= 0.
  double? netSalaryOverride;

  @enumerated
  late PrimaryCurrency currency;

  late DateTime createdAt;

  late DateTime updatedAt;
}
