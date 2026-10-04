import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/models/user_profile.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(monthlyExpensesProvider);
    final activeBudget = ref.watch(activeBudgetProvider).value;

    String currencySymbol = '\$';
    if (activeBudget != null) {
      switch (activeBudget.currency) {
        case PrimaryCurrency.huf: currencySymbol = 'Ft'; break;
        case PrimaryCurrency.usd: currencySymbol = '\$'; break;
        case PrimaryCurrency.cad: currencySymbol = 'C\$'; break;
        case PrimaryCurrency.eur: currencySymbol = '€'; break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses yet. Tap + to add one!'));
          }
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: expense.status == ExpenseStatus.paid 
                      ? Colors.green.withOpacity(0.2) 
                      : Colors.orange.withOpacity(0.2),
                  child: Icon(
                    expense.status == ExpenseStatus.paid ? Icons.check : Icons.schedule,
                    color: expense.status == ExpenseStatus.paid ? Colors.green : Colors.orange,
                  ),
                ),
                title: Text(expense.title),
                subtitle: Text(
                  '${expense.status.name.toUpperCase()} • ${expense.guiltLevel.name}',
                ),
                trailing: Text(
                  '$currencySymbol${NumberFormat('#,##0.00').format(expense.amount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add_expense'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
