import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../expenses/providers/reimbursement_provider.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../expenses/models/reimbursement.dart';
import '../currency_resolution.dart';
import 'rate_registry_provider.dart';

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

/// Money in the bank minus what has actually left, converted to the month's
/// display currency through the registry table (FR-011, FR-013).
final trueAvailableProvider = Provider<double>((ref) {
  final budget = ref.watch(activeBudgetProvider).value;
  final profile = ref.watch(activeProfileProvider).value;
  final yearMonth = ref.watch(selectedYearMonthProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
  final expenses = ref.watch(monthlyExpensesProvider).value ?? [];
  final reimbursements = ref.watch(monthlyReimbursementsProvider).value ?? [];

  if (budget == null) return 0.0;

  final display = resolveDisplayCurrency(month: budget, profile: profile);
  var total = Money.fromMajor(budget.baseAvailableAmount, display);

  for (final exp in expenses) {
    if (exp.status == ExpenseStatus.paid ||
        exp.status == ExpenseStatus.reimbursed ||
        exp.status == ExpenseStatus.partiallyReimbursed) {
      total = total - expenseToDisplay(exp, display, table);
    }
  }

  for (final reimb in reimbursements) {
    total = total + reimbursementToDisplay(reimb, display, table);
  }

  return total.majorValue;
});