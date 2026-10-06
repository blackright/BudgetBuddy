import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../engine/expense_delta.dart';

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<List<Expense>>>((ref) {
  final activeBudgetAsync = ref.watch(activeBudgetProvider);

  return activeBudgetAsync.when(
    data: (budget) {
      if (budget == null) {
        return ExpensesNotifier(null, const AsyncValue.data([]));
      }
      return ExpensesNotifier(budget.id, null);
    },
    loading: () => ExpensesNotifier(null, const AsyncValue.loading()),
    error: (e, st) => ExpensesNotifier(null, AsyncValue.error(e, st)),
  );
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final int? budgetId;
  final Isar _isar = IsarHelper.instance;

  ExpensesNotifier(
    this.budgetId, [
    AsyncValue<List<Expense>>? initialState,
  ]) : super(initialState ?? const AsyncValue.loading()) {
    if (budgetId != null && initialState == null) {
      _loadExpenses();
    }
  }

  Future<void> _loadExpenses() async {
    try {
      state = const AsyncValue.loading();
      final expenses = await _isar.expenses
          .filter()
          .budgetIdEqualTo(budgetId!)
          .sortByDateDesc()
          .findAll();
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// The delta is only a coarse signal for callers; the live engine providers
  /// recompute the authoritative figures from the correct rate table.
  static double _toPrimary(ExpenseSnapshot snapshot) =>
      snapshot.amount.toDouble();

  Future<void> addExpense(Expense expense) async {
    if (budgetId == null) return;

    try {
      expense.budgetId = budgetId!;
      if (expense.status == ExpenseStatus.paid) {
        expense.paidAt ??= DateTime.now();
      }

      await _isar.writeTxn(() async {
        await _isar.expenses.put(expense);
      });

      await _loadExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Persists an edited [updated] expense and returns the exact engine delta
  /// (in primary currency) versus the previously stored version.
  ///
  /// Rules:
  /// - Planned → Paid: `paidAt` is set to now; trueAvailable drops by amount.
  /// - Paid → Planned: `paidAt` is cleared; trueAvailable is restored.
  /// - Paid → Paid: trueAvailable/safeToSpend shift by the amount difference.
  /// - Currency change: exchange rate is refreshed for the new currency.
  ///
  /// The reactive engine providers (`trueAvailableProvider`,
  /// `safeToSpendProvider`) pick up the change instantly via Isar watchers.
  Future<ExpenseDelta> updateExpense(Expense updated) async {
    if (updated.amount <= 0) {
      throw ArgumentError.value(updated.amount, 'amount', 'must be > 0');
    }
    if (updated.title.trim().isEmpty) {
      throw ArgumentError.value(updated.title, 'title', 'cannot be empty');
    }

    try {
      final stored = await _isar.expenses.get(updated.id);
      if (stored == null) {
        throw StateError('Expense ${updated.id} no longer exists');
      }
      final before = ExpenseSnapshot.of(stored);

      // Status transition → paidAt bookkeeping.
      if (updated.status == ExpenseStatus.paid &&
          stored.status != ExpenseStatus.paid) {
        updated.paidAt = DateTime.now();
      } else if (updated.status != ExpenseStatus.paid) {
        updated.paidAt = null;
      } else {
        updated.paidAt ??= stored.paidAt ?? DateTime.now();
      }

      await _isar.writeTxn(() async {
        await _isar.expenses.put(updated);
      });

      final delta = ExpenseDelta.between(
        before: before,
        after: ExpenseSnapshot.of(updated),
        toPrimary: _toPrimary,
      );

      await _loadExpenses();
      return delta;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Quick swipe action: flips Planned ↔ Paid.
  Future<ExpenseDelta> toggleStatus(Expense expense) async {
    final stored = await _isar.expenses.get(expense.id);
    if (stored == null) return ExpenseDelta.zero;
    stored.status = stored.status == ExpenseStatus.paid
        ? ExpenseStatus.planned
        : ExpenseStatus.paid;
    return updateExpense(stored);
  }

  /// Deletes the expense and returns the engine delta (money freed up).
  Future<ExpenseDelta> deleteExpense(int id) async {
    try {
      final stored = await _isar.expenses.get(id);
      if (stored == null) return ExpenseDelta.zero;
      final before = ExpenseSnapshot.of(stored);

      await _isar.writeTxn(() async {
        await _isar.expenses.delete(id);
      });

      await _loadExpenses();
      return ExpenseDelta.between(
        before: before,
        toPrimary: _toPrimary,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
