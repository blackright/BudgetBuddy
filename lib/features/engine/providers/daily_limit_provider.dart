import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'safe_to_spend_provider.dart';
import '../../../core/providers/active_budget_provider.dart';
import 'dart:math' as math;

final dailyLimitProvider = Provider<double>((ref) {
  final safeToSpend = ref.watch(safeToSpendProvider);
  final budget = ref.watch(activeBudgetProvider).value;

  if (budget == null) return 0.0;

  // Assuming budget.yearMonth is 'yyyy-MM'
  final parts = budget.yearMonth.split('-');
  if (parts.length != 2) return 0.0;

  final year = int.tryParse(parts[0]) ?? DateTime.now().year;
  final month = int.tryParse(parts[1]) ?? DateTime.now().month;

  final now = DateTime.now();

  // If the budget is for a future month, use total days of that month.
  // If it's a past month, days remaining is 0 (or 1 depending on logic, let's say 1 to avoid division by zero).
  // If it's the current month, compute remaining days including today.

  int daysRemaining;

  if (now.year == year && now.month == month) {
    // Current month
    final lastDay = DateTime(year, month + 1,
        0); // 0 means the last day of the previous month (which is month here)
    daysRemaining = lastDay.day - now.day + 1;
  } else if (year > now.year || (year == now.year && month > now.month)) {
    // Future month
    final lastDay = DateTime(year, month + 1, 0);
    daysRemaining = lastDay.day;
  } else {
    // Past month
    daysRemaining = 1;
  }

  if (daysRemaining <= 0) daysRemaining = 1; // Prevent division by zero

  return math.max(0.0, safeToSpend / daysRemaining);
});
