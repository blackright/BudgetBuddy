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

/// Reimbursements that *belong* to the selected month, keyed on
/// `originYearMonth` (FR-032, FR-033).
///
/// Deliberately not derived from the viewed month's expense ids: a
/// reimbursement recorded months after the expense it belongs to would then
/// vanish from the month that actually spent the money. Keying on the origin
/// month is what stops that (SC-005).
final monthlyReimbursementsProvider =
    StreamProvider<List<Reimbursement>>((ref) {
  final budget = ref.watch(activeBudgetProvider).value;
  if (budget == null) return Stream.value([]);

  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchReimbursementsForMonth(budget.yearMonth);
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
    // The origin month is the target expense's own month, so the target expense
    // is in `expenses` unless it was deleted. A reimbursement with no surviving
    // expense (FR-035) contributes nothing rather than guessing a rate.
    final expense = expenses.where((e) => e.id == reimb.expenseId).firstOrNull;
    if (expense != null) {
      totalReimbursements += reimb.amount * expense.exchangeRateToPrimary;
    }
  }

  return baseAmount - totalPaid + totalReimbursements;
});
