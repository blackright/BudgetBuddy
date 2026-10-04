import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../database/isar_helper.dart';
import '../models/monthly_budget.dart';
import 'package:intl/intl.dart';

final currentYearMonthProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return DateFormat('yyyy-MM').format(now);
});

final activeBudgetProvider = StreamProvider<MonthlyBudget?>((ref) {
  final isar = IsarHelper.instance;
  final yearMonth = ref.watch(currentYearMonthProvider);
  return isar.monthlyBudgets
      .filter()
      .yearMonthEqualTo(yearMonth)
      .watch(fireImmediately: true)
      .map((budgets) => budgets.isNotEmpty ? budgets.first : null);
});
