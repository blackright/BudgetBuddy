import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../finance/providers/finance_providers.dart';
import '../currency_resolution.dart';
import '../month_summary.dart';
import 'rate_registry_provider.dart';
import 'true_available_provider.dart';

/// Reimbursements belonging to the selected month.
///
/// Scoped by `originYearMonth` — the month the money belongs to — not by the
/// month the user happened to record them in (FR-032).
final monthlyOriginReimbursementsProvider = StreamProvider((ref) {
  ref.watch(activeProfileProvider);
  final yearMonth = ref.watch(selectedYearMonthProvider);
  return ref
      .watch(expenseRepositoryProvider)
      .watchReimbursementsForMonth(yearMonth);
});

/// The financial verdict for the selected month.
///
/// Derived on every read from already-watched streams and never persisted
/// (FR-017), so an edit anywhere upstream is reflected without a manual
/// refresh. Recomputes in microseconds because it is pure arithmetic over rows
/// that are already in memory.
final monthSummaryProvider = Provider<MonthSummary>((ref) {
  final yearMonth = ref.watch(selectedYearMonthProvider);
  final month = ref.watch(monthFinanceProvider).value;
  final profile = ref.watch(activeProfileProvider).value;
  final income = ref.watch(resolvedIncomeProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
  final display = resolveDisplayCurrency(month: month, profile: profile);
  final source = mainSourceCurrency(profile);
  final expenses =
      ref.watch(monthlyExpensesProvider).value ?? const <Expense>[];
  final reimbursements =
      ref.watch(monthlyOriginReimbursementsProvider).value ?? const [];

  // Reimbursements are denominated in their target's currency. Targets inside
  // the selected month can be converted from the rows already held; a target in
  // another month contributes no excess figure until User Story 3 resolves
  // cross-month targets.
  final targetPaidAmounts = <int, double>{
    for (final expense in expenses)
      if (expense.status == ExpenseStatus.paid)
        expense.id: expenseToDisplay(expense, display, table).majorValue,
  };

  return MonthSummary.from(
    yearMonth: yearMonth,
    income: toDisplay(Money.fromMajor(income.amount, source), display, table)
        .majorValue,
    usesOverriddenIncome: income.usesOverride,
    expenses: expenses,
    reimbursements: reimbursements,
    convertExpense: (e) => expenseToDisplay(e, display, table),
    convertReimbursement: (r) => reimbursementToDisplay(r, display, table),
    openingBalance: month != null && month.openingBalanceConfirmed
        ? toDisplay(Money.fromMajor(month.baseAvailableAmount, source), display,
                table)
            .majorValue
        : null,
    targetPaidAmounts: targetPaidAmounts,
  );
});
