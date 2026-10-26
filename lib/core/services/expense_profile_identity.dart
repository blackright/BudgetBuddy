import '../models/budget_profile.dart';
import '../models/direct_expense_profile.dart';
import '../models/expense.dart';

/// Backfills only a unique match in the expense's own context and month.
/// Returns false for ambiguous, missing, or unsupported references.
bool resolveExpenseProfileIdentity(Expense expense, List<BudgetProfile> budgets,
    List<DirectExpenseProfile> directs) {
  if (expense.budgetProfileId == null &&
      expense.financialProfileSyncGuid == null) {
    return expense.financialProfileType == null;
  }
  bool owns(int? owner, int? space, String month) =>
      month == expense.yearMonth &&
      (expense.sharedSpaceId != null
          ? space == expense.sharedSpaceId
          : space == null && owner == expense.profileId);
  bool matches(int id, String guid) => expense.financialProfileSyncGuid != null
      ? guid == expense.financialProfileSyncGuid
      : id == expense.budgetProfileId;
  final budget = budgets.where((p) =>
      owns(p.profileId, p.sharedSpaceId, p.yearMonth) &&
      matches(p.id, p.syncGuid));
  final direct = directs.where((p) =>
      owns(p.profileId, p.sharedSpaceId, p.yearMonth) &&
      matches(p.id, p.syncGuid));
  final type = expense.financialProfileType;
  if ((type == null && budget.length == 1 && direct.isEmpty) ||
      (type == FinancialProfileType.budget && budget.length == 1)) {
    expense
      ..budgetProfileId = budget.single.id
      ..financialProfileType = FinancialProfileType.budget
      ..financialProfileSyncGuid = budget.single.syncGuid;
    return true;
  }
  if ((type == null && direct.length == 1 && budget.isEmpty) ||
      (type == FinancialProfileType.direct && direct.length == 1)) {
    expense
      ..budgetProfileId = direct.single.id
      ..financialProfileType = FinancialProfileType.direct
      ..financialProfileSyncGuid = direct.single.syncGuid;
    return true;
  }
  return false;
}
