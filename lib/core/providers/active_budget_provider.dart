import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../database/isar_helper.dart';
import '../models/monthly_budget.dart';
import 'selected_month_provider.dart';

/// The finance record for the month the user is currently looking at.
///
/// Reads through [selectedYearMonthProvider], which is the single funnel every
/// month-scoped query resolves through. That is what makes the selected month
/// persist across screens without any per-screen plumbing (FR-027).
final activeBudgetProvider = StreamProvider<MonthlyBudget?>((ref) {
  final isar = IsarHelper.instance;
  final yearMonth = ref.watch(selectedYearMonthProvider);
  return isar.monthlyBudgets
      .filter()
      .yearMonthEqualTo(yearMonth)
      .watch(fireImmediately: true)
      .map((budgets) => budgets.isNotEmpty ? budgets.first : null);
});
