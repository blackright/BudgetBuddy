import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../finance/providers/finance_providers.dart';
import '../../finance/providers/profile_providers.dart';
import '../../finance/providers/month_end_providers.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../../core/services/free_funds.dart';
import '../../settings/providers/settings_provider.dart';
import '../currency_resolution.dart';
import '../month_summary.dart';
import 'rate_registry_provider.dart';
import 'true_available_provider.dart';
import '../../vault/providers/vault_providers.dart';

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

  // T144: total allocation and set-aside (unused part) for this month's
  // budget profiles, in minor units of the context currency. Both are
  // converted to the display currency below, exactly like every other amount.
  final budgetProfiles = ref.watch(budgetProfilesProvider).value ?? const [];
  final contextExpenses = ref.watch(contextExpensesProvider);
  const spendingService = ProfileSpendingService();
  var totalAllocatedMinor = 0;
  var totalSetAsideMinor = 0;
  for (final profile in budgetProfiles) {
    totalAllocatedMinor += profile.allocation;
    final spent = spendingService.spentInYearMonth(
      profileId: profile.id,
      profileType: FinancialProfileType.budget,
      yearMonth: yearMonth,
      expenses: contextExpenses,
      reimbursements: reimbursements,
      convertReimbursement: (r) =>
          reimbursementToDisplay(r, source, table, accountingCurrency: source)
              .minorUnits,
      convert: (expense) =>
          expenseToDisplay(expense, source, table, accountingCurrency: source)
              .minorUnits,
    );
    final unused = profile.allocation - spent;
    totalSetAsideMinor += unused > 0 ? unused : 0;
  }

  // Reimbursements are denominated in their target's currency. Targets inside
  // the selected month can be converted from the rows already held; a payout
  // credited to the month after its bill keeps its target in the previous
  // month, so it is absent from this map and contributes no excess here (the
  // payout is never mistaken for a full over-reimbursement).
  final targetPaidAmounts = <int, double>{
    for (final expense in expenses)
      if (expense.status == ExpenseStatus.paid)
        expense.id: expenseToDisplay(expense, display, table,
                accountingCurrency: source)
            .majorValue,
  };

  // US8: classify each return by its target's kind, resolved across months.
  final medicalTargetIds = MonthSummary.medicalTargetIdsOf(
    ref.watch(reimbursementTargetExpensesProvider).value ?? const <Expense>[],
  );

  return MonthSummary.from(
    resolvedFreeToSpend: toDisplay(
            Money(
                freeToSpend(
                        income:
                            Money.fromMajor(income.amount, source).minorUnits,
                        paid: sumFinancialMinor(expenses
                            .where((e) => {
                                  ExpenseStatus.paid,
                                  ExpenseStatus.partiallyReimbursed,
                                  ExpenseStatus.reimbursed
                                }.contains(e.status))
                            .map((e) => expenseToDisplay(e, source, table,
                                    accountingCurrency: source)
                                .minorUnits)),
                        returned: sumFinancialMinor(
                            reimbursements.map((r) => reimbursementToDisplay(r, source, table, accountingCurrency: source).minorUnits)),
                        unused: totalSetAsideMinor,
                        carry: ref.watch(monthEndBalanceProvider).carryShortfall,
                        incoming: ref.watch(monthEndBalanceProvider).incoming,
                        released: ref.watch(monthEndBalanceProvider).released,
                        transfers: ref.watch(monthlyVaultCreditProvider))
                    .toInt(),
                source),
            display,
            table)
        .majorValue,
    vaultTransfers: toDisplay(
            Money(ref.watch(monthlyVaultCreditProvider), source),
            display,
            table)
        .majorValue,
    yearMonth: yearMonth,
    income: toDisplay(Money.fromMajor(income.amount, source), display, table)
        .majorValue,
    usesOverriddenIncome: income.usesOverride,
    expenses: expenses,
    reimbursements: reimbursements,
    convertExpense: (e) =>
        expenseToDisplay(e, display, table, accountingCurrency: source),
    convertReimbursement: (r) =>
        reimbursementToDisplay(r, display, table, accountingCurrency: source),
    openingBalance: month != null && month.openingBalanceConfirmed
        ? toDisplay(Money.fromMajor(month.baseAvailableAmount, source), display,
                table)
            .majorValue
        : null,
    targetPaidAmounts: targetPaidAmounts,
    medicalTargetIds: medicalTargetIds,
    allocated: toDisplay(Money(totalAllocatedMinor, source), display, table)
        .majorValue,
    setAside:
        toDisplay(Money(totalSetAsideMinor, source), display, table).majorValue,
    carryOver: toDisplay(
            Money(ref.watch(monthEndBalanceProvider).carryShortfall, source),
            display,
            table)
        .majorValue,
    carriedIn: toDisplay(
            Money(ref.watch(monthEndBalanceProvider).incoming, source),
            display,
            table)
        .majorValue,
    releasedAtMonthEnd: toDisplay(
            Money(ref.watch(monthEndBalanceProvider).released, source),
            display,
            table)
        .majorValue,
  );
});
