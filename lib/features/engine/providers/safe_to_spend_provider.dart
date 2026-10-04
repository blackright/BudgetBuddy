import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'true_available_provider.dart';
import '../../expenses/models/expense.dart';

final safeToSpendProvider = Provider<double>((ref) {
  final trueAvailable = ref.watch(trueAvailableProvider);
  final expenses = ref.watch(monthlyExpensesProvider).value ?? [];

  double plannedTotal = 0.0;
  for (final exp in expenses) {
    if (exp.status == ExpenseStatus.planned) {
      plannedTotal += exp.amount * exp.exchangeRateToPrimary;
    }
  }

  return trueAvailable - plannedTotal;
});
