import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/engine/expense_delta.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Captures the expense the editor would persist, without touching Isar.
///
/// Widget save tests exercise the form, destructuring and quantity state; the
/// real write path is already covered by the native service tests. Avoiding the
/// database here keeps the widget tests deterministic and free of FFI futures.
class RecordingExpensesNotifier extends ExpensesNotifier {
  RecordingExpensesNotifier()
      : super(
          null,
          (_) => 0,
          initialState: const AsyncValue.data([]),
          rateRegistry: RateTableRegistry(),
        );

  final List<Expense> written = [];

  @override
  Future<void> addExpense(Expense expense, {int? targetBudgetId}) async {
    written.add(expense);
  }

  @override
  Future<ExpenseDelta> updateExpense(Expense updated) async {
    written.add(updated);
    return ExpenseDelta.zero;
  }
}
