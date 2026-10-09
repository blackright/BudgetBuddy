import 'package:isar/isar.dart';

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

  /// Display-only "convert this month to" currency code (FR-011, data-model
  /// §4.2).
  ///
  /// `null` — the default for a freshly provisioned month — means "follow the
  /// active profile's main currency". Setting it overrides the main currency
  /// for this month alone; clearing it restores the fallback. Stored as a code
  /// string because a persisted enum cannot represent "cleared"; unknown values
  /// coerce to the default at read time (data-model §4.4). It is never read by
  /// the conversion engine to decide a stored amount or rate — history stays
  /// deterministic no matter what is chosen here.
  String? currency;

  late DateTime createdAt;

  late DateTime updatedAt;
}
