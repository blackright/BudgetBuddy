import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../models/reimbursement.dart';
import '../repositories/expense_repository.dart';
import 'expense_search_provider.dart';

class DailyExpenseCard {
  const DailyExpenseCard(this.date, this.expenses, this.paid, this.planned,
      this.incompleteCurrencies);
  final DateTime date;
  final List<Expense> expenses;
  final Map<String, int> paid, planned;
  final Set<String> incompleteCurrencies;
}

List<DailyExpenseCard> groupDailyExpenses(
    List<Expense> expenses, List<Reimbursement> returns,
    {int? Function(Reimbursement, Expense)? convertReturn}) {
  final groups = <DateTime, List<Expense>>{};
  for (final expense in expenses) {
    final date = expense.date.toLocal();
    (groups[DateTime(date.year, date.month, date.day)] ??= []).add(expense);
  }
  final refunds = <int, List<Reimbursement>>{};
  for (final row in returns) {
    if (!row.orphaned && row.expenseId != null) {
      (refunds[row.expenseId!] ??= []).add(row);
    }
  }
  final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates)
      (() {
        final rows = groups[date]!
          ..sort((a, b) {
            final time = b.date.compareTo(a.date);
            return time == 0 ? b.id.compareTo(a.id) : time;
          });
        final paid = <String, int>{}, planned = <String, int>{};
        final incomplete = <String>{};
        void add(Map<String, int> totals, String currency, int amount) {
          final next = (totals[currency] ?? 0) + amount;
          if (next < 0 || next > 9007199254740991) {
            incomplete.add(currency);
            totals.putIfAbsent(currency, () => 0);
          } else {
            totals[currency] = next;
          }
        }

        for (final expense in rows) {
          final currency = expense.currency.toUpperCase();
          if (expense.status == ExpenseStatus.cancelled) continue;
          if (expense.amount < 0 ||
              expense.amount > 9007199254740991 ||
              expense.currencyCode == null) {
            incomplete.add(currency);
            (expense.status == ExpenseStatus.planned ? planned : paid)
                .putIfAbsent(currency, () => 0);
            continue;
          }
          if (expense.status == ExpenseStatus.planned) {
            add(planned, currency, expense.amount);
            continue;
          }
          var returned = 0;
          final linked = (refunds[expense.id] ?? const <Reimbursement>[])
              .where((r) =>
                  r.originYearMonth == expense.yearMonth &&
                  r.sharedSpaceId == expense.sharedSpaceId &&
                  (expense.sharedSpaceId != null ||
                      r.profileId == expense.profileId))
              .toList();
          for (final refund in linked) {
            final amount = refund.currency.toUpperCase() == currency
                ? refund.amount
                : convertReturn?.call(refund, expense);
            if (amount == null ||
                amount < 0 ||
                amount > 9007199254740991 ||
                returned + amount > 9007199254740991) {
              incomplete.add(currency);
            } else {
              returned += amount;
            }
          }
          // Match the spending engine's explicit legacy fully-returned meaning.
          final net =
              expense.status == ExpenseStatus.reimbursed && linked.isEmpty
                  ? 0
                  : (expense.amount - returned).clamp(0, expense.amount);
          add(paid, currency, net);
        }
        return DailyExpenseCard(
            date, List.unmodifiable(rows), paid, planned, incomplete);
      })()
  ];
}

final dailyCardReturnsProvider =
    StreamProvider.autoDispose<List<Reimbursement>>((ref) async* {
  final scope = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  if (scope.isShared) ref.watch(activeSpaceMembersProvider);
  var disposed = false;
  ref.onDispose(() => disposed = true);
  final search = ref.watch(expenseSearchRepositoryProvider);
  final repository = ref.watch(expenseRepositoryProvider);
  await search.authorize(scope, actor);
  if (disposed) return;
  yield* repository.watchReimbursementsForOwner(scope);
});

final dailyCardsProvider = Provider<AsyncValue<List<DailyExpenseCard>>>((ref) {
  final expenses = ref.watch(expenseSearchResultsProvider);
  final returns = ref.watch(dailyCardReturnsProvider);
  final registry = ref.watch(rateRegistryProvider);
  if (expenses.hasError) {
    return AsyncValue.error(expenses.error!, expenses.stackTrace!);
  }
  if (returns.hasError) {
    return AsyncValue.error(returns.error!, returns.stackTrace!);
  }
  if (expenses.isLoading ||
      returns.isLoading ||
      !expenses.hasValue ||
      !returns.hasValue) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data(groupDailyExpenses(expenses.value!, returns.value!,
      convertReturn: (row, expense) {
    final from = row.currencyCode, to = CurrencyCode.tryParse(expense.currency);
    if (from == null || to == null) return null;
    final result = registry.convert(
        amount: Money(row.amount, from), to: to, yearMonth: expense.yearMonth);
    return result.isDegraded ? null : result.amount.minorUnits;
  }));
});
