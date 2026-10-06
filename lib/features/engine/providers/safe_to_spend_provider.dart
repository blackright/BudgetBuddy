import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'true_available_provider.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../currency_resolution.dart';
import 'rate_registry_provider.dart';

final safeToSpendProvider = Provider<double>((ref) {
  final trueAvailable = ref.watch(trueAvailableProvider);
  final budget = ref.watch(activeBudgetProvider).value;
  final profile = ref.watch(activeProfileProvider).value;
  final yearMonth = ref.watch(selectedYearMonthProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
  final expenses = ref.watch(monthlyExpensesProvider).value ?? [];

  final display = resolveDisplayCurrency(month: budget, profile: profile);
  var planned = 0.0;
  for (final exp in expenses) {
    if (exp.status == ExpenseStatus.planned) {
      planned += expenseToDisplay(exp, display, table).majorValue;
    }
  }

  return trueAvailable - planned;
});