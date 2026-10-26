import '../models/expense.dart';
import '../models/monthly_budget.dart';
import '../../features/expenses/models/reimbursement.dart';

/// A budget profile's money story for one month.
///
/// Every number here is in whole minor units, so nothing is ever rounded on
/// the way in and the totals always reconcile with the recorded transactions.
class ProfileMoneyState {
  const ProfileMoneyState({
    required this.allocation,
    required this.spent,
  });

  final int allocation;
  final int spent;

  /// Money still available inside this profile.
  int get remaining => allocation - spent;

  /// How much of the allocation is used, as a percentage.
  double get usagePercent {
    if (allocation <= 0) return spent > 0 ? 100 : 0;
    return (spent / allocation) * 100;
  }

  /// Spending above the allocation.
  int get overspend => spent > allocation ? spent - allocation : 0;
}

/// Computes per-profile spending from the recorded expenses.
///
/// Only **paid** expenses count as spending: a planned expense is a
/// commitment, not money that has moved, and a cancelled one never happened.
/// Returns reduce the expense by the amount actually returned. A partial
/// reimbursement must never remove the entire original expense from spending.
class ProfileSpendingService {
  const ProfileSpendingService();

  /// The total spent under [profileId] for the month of [budget].
  ///
  /// [convert] maps each expense's amount into the unit the caller wants the
  /// total expressed in (context currency for stored figures, display currency
  /// for the dashboard). Without it the raw `amount` is summed, which is only
  /// correct when every row already shares one currency (D5).
  int spentFor({
    required int? profileId,
    String? profileType,
    required MonthlyBudget? budget,
    List<Expense> expenses = const [],
    int Function(Expense expense)? convert,
    List<Reimbursement> reimbursements = const [],
    int Function(Reimbursement reimbursement)? convertReimbursement,
  }) {
    if (budget == null) return 0;
    return spentInYearMonth(
      profileId: profileId,
      profileType: profileType,
      yearMonth: budget.yearMonth,
      expenses: expenses,
      convert: convert,
      reimbursements: reimbursements,
      convertReimbursement: convertReimbursement,
    );
  }

  /// The total spent under [profileId] in [yearMonth].
  ///
  /// The expense list is supplied by the caller (usually a query scoped to the
  /// active context) so this service stays free of database access and easy to
  /// reason about.
  ///
  /// Expenses carry their own currency, so a currency-blind sum mixes units
  /// (D5). Pass [convert] to bring each row into a single unit before adding;
  /// returning `0` from it excludes an unsupported row, matching the engine's
  /// "never invent a figure" rule.
  int spentInYearMonth({
    required int? profileId,
    String? profileType,
    required String yearMonth,
    List<Expense> expenses = const [],
    int Function(Expense expense)? convert,
    List<Reimbursement> reimbursements = const [],
    int Function(Reimbursement reimbursement)? convertReimbursement,
  }) {
    var total = 0;
    final returnsByExpense = <int, List<Reimbursement>>{};
    for (final row in reimbursements) {
      if (row.expenseId != null && row.originYearMonth == yearMonth) {
        (returnsByExpense[row.expenseId!] ??= []).add(row);
      }
    }
    for (final expense in expenses) {
      if (expense.yearMonth != yearMonth) continue;
      // null budgetProfileId means the expense belongs to the Main Profile.
      if (expense.budgetProfileId != profileId) continue;
      if (profileId != null &&
          profileType != null &&
          expense.financialProfileType != profileType) {
        continue;
      }
      if (profileId == null && expense.financialProfileSyncGuid != null) {
        continue;
      }
      if (!_countsAsSpending(expense.status)) continue;
      final linked = (returnsByExpense[expense.id] ?? const <Reimbursement>[])
          .where((r) =>
              r.sharedSpaceId == expense.sharedSpaceId &&
              (expense.sharedSpaceId != null ||
                  r.profileId == expense.profileId));
      // Legacy fully-returned rows may predate their ledger entry. Retain that
      // meaning; partial rows still represent unrecovered spending.
      if (expense.status == ExpenseStatus.reimbursed && linked.isEmpty) {
        continue;
      }
      final gross = convert == null ? expense.amount : convert(expense);
      var returned = 0;
      for (final row in linked) {
        if (convertReimbursement != null) {
          returned += convertReimbursement(row);
        } else {
          if (row.currencyCode != expense.currencyCode) {
            throw ArgumentError('Mixed-currency returns need a converter');
          }
          returned += row.amount;
        }
      }
      final net = gross - returned;
      total += net > 0 ? net : 0;
    }
    return total;
  }

  /// Whether an expense in this status represents money that has been spent.
  bool _countsAsSpending(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.paid:
      case ExpenseStatus.reimbursed:
      case ExpenseStatus.partiallyReimbursed:
        return true;
      case ExpenseStatus.planned:
      case ExpenseStatus.cancelled:
        return false;
    }
  }
}
