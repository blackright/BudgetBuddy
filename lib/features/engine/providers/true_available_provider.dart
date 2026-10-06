import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../expenses/providers/reimbursement_provider.dart';
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

  final repository = ref.watch(reimbursementRepositoryProvider);
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
    if (exp.status == ExpenseStatus.paid ||
        exp.status == ExpenseStatus.reimbursed ||
        exp.status == ExpenseStatus.partiallyReimbursed) {
      // Amount is converted to primary currency
      totalPaid += exp.amount * exp.exchangeRateToPrimary;
    }
  }

  double totalReimbursements = 0.0;
  for (final reimb in reimbursements) {
    totalReimbursements += reimb.amount * reimb.exchangeRateToPrimary;
  }

  return baseAmount - totalPaid + totalReimbursements;
});
