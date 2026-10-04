import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_budget_provider.dart';

final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<Expense>>>((ref) {
  final activeBudgetAsync = ref.watch(activeBudgetProvider);
  
  return activeBudgetAsync.when(
    data: (budget) {
      if (budget == null) {
        return ExpensesNotifier(null, const AsyncValue.data([]));
      }
      return ExpensesNotifier(budget.id);
    },
    loading: () => ExpensesNotifier(null, const AsyncValue.loading()),
    error: (e, st) => ExpensesNotifier(null, AsyncValue.error(e, st)),
  );
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final int? budgetId;
  final Isar _isar = IsarHelper.instance;

  ExpensesNotifier(this.budgetId, [AsyncValue<List<Expense>>? initialState]) 
      : super(initialState ?? const AsyncValue.loading()) {
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

  Future<void> addExpense(Expense expense) async {
    if (budgetId == null) return;
    
    try {
      expense.budgetId = budgetId!;
      
      await _isar.writeTxn(() async {
        await _isar.expenses.put(expense);
      });
      
      await _loadExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.expenses.delete(id);
      });
      
      await _loadExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
