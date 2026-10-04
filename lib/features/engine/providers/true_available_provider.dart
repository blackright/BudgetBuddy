import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/models/expense.dart';
import '../../expenses/models/reimbursement.dart';

final monthlyExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final profile = ref.watch(activeProfileProvider).value;
  final budget = ref.watch(activeBudgetProvider).value;
  if (profile == null || budget == null) return Stream.value([]);

  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpenses(profile.id, budget.yearMonth);
});

final monthlyReimbursementsProvider =
    StreamProvider<List<Reimbursement>>((ref) {
  final expenses = ref.watch(monthlyExpensesProvider).value ?? [];
  if (expenses.isEmpty) return Stream.value([]);

  final expenseIds = expenses.map((e) => e.id).toList();
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchReimbursementsForExpenses(expenseIds);
});

final trueAvailableProvider = Provider<double>((ref) {
  final budget = ref.watch(activeBudgetProvider).value;
  final expenses = ref.watch(monthlyExpensesProvider).value ?? [];
  final reimbursements = ref.watch(monthlyReimbursementsProvider).value ?? [];

  if (budget == null) return 0.0;

  double baseAmount = budget.baseAvailableAmount;

  double totalPaid = 0.0;
  for (final exp in expenses) {
    if (exp.status == ExpenseStatus.paid) {
      // Amount is converted to primary currency
      totalPaid += exp.amount * exp.exchangeRateToPrimary;
    }
  }

  double totalReimbursements = 0.0;
  for (final reimb in reimbursements) {
    // Find matching expense to get exchange rate (or assume reimbursement amount is already in primary currency? Wait, data model says Reimbursement amount must be <= Expense amount. Usually reimbursement is in the same currency, so we should convert it using the same exchange rate).
    // Let's find the matching expense:
    final expense = expenses.where((e) => e.id == reimb.expenseId).firstOrNull;
    if (expense != null) {
      totalReimbursements += reimb.amount * expense.exchangeRateToPrimary;
    }
  }

  return baseAmount - totalPaid + totalReimbursements;
});
