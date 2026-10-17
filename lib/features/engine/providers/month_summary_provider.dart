import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../finance/providers/finance_providers.dart';
import '../../settings/providers/settings_provider.dart';
import '../currency_resolution.dart';
import '../month_summary.dart';
import 'rate_registry_provider.dart';
import 'true_available_provider.dart';

/// Reimbursements belonging to the selected month.
///
/// Scoped by `originYearMonth` — the month the money belongs to — not by the
/// month the user happened to record them in (FR-032).
final monthlyOriginReimbursementsProvider = StreamProvider((ref) {
  final context = ref.watch(budgetContextProvider);
  return ref
      .watch(expenseRepositoryProvider)
      .watchReimbursementsForContext(context);
});

/// The target expenses of this month's reimbursements, resolved **by id across
/// months** (US8).
///
/// A payout credited next month keeps its medical bill in the previous month, so
/// the target is not part of the selected month's own expense list. This stream
/// looks the targets up directly so the summary can tell an insurance return
/// from an expense return. Isar-backed; overridden in tests that supply targets
/// directly.
final reimbursementTargetExpensesProvider =
    StreamProvider<List<Expense>>((ref) {
  final reimbursements =
      ref.watch(monthlyOriginReimbursementsProvider).value ?? const [];
  final targetIds = <int>{
    for (final reimbursement in reimbursements)
      if (reimbursement.expenseId != null) reimbursement.expenseId!,
  }.toList();
  if (targetIds.isEmpty) return Stream.value(const <Expense>[]);
  return ref.watch(expenseRepositoryProvider).watchExpensesByIds(targetIds);
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
  final income = ref.watch(resolvedIncomeProvider);
  final main = ref.watch(mainCurrencyProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
  final display = resolveContextDisplayCurrency(month, main);
  final source = main;
  final expenses =
      ref.watch(monthlyExpensesProvider).value ?? const <Expense>[];
  final reimbursements =
      ref.watch(monthlyOriginReimbursementsProvider).value ?? const [];

  // Reimbursements are denominated in their target's currency. Targets inside
  // the selected month can be converted from the rows already held; a payout
  // credited to the month after its bill keeps its target in the previous
  // month, so it is absent from this map and contributes no excess here (the
  // payout is never mistaken for a full over-reimbursement).
  final targetPaidAmounts = <int, double>{
    for (final expense in expenses)
      if (expense.status == ExpenseStatus.paid)
        expense.id: expenseToDisplay(expense, display, table).majorValue,
  };

  // US8: classify each return by its target's kind, resolved across months.
  final medicalTargetIds = MonthSummary.medicalTargetIdsOf(
    ref.watch(reimbursementTargetExpensesProvider).value ?? const <Expense>[],
  );

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
    medicalTargetIds: medicalTargetIds,
  );
});
