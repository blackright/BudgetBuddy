import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../database/isar_helper.dart';
import '../models/monthly_budget.dart';
import 'budget_context_provider.dart';

/// The finance record for the month the user is currently looking at, resolved
/// through the active context (FR-004).
///
/// In a personal context this is `MonthlyBudget(profileId, yearMonth)`; in a
/// shared context it is `MonthlyBudget(sharedSpaceId, yearMonth)`. Falling back
/// to the lowest-id profile keeps today's single-profile behaviour while the
/// user has not picked one (R2).
final activeBudgetProvider = StreamProvider<MonthlyBudget?>((ref) {
  final context = ref.watch(budgetContextProvider);
  final isar = IsarHelper.instance;
  return isar.monthlyBudgets
      .filter()
      .group(
        (q) => context.isShared
            ? q.sharedSpaceIdEqualTo(context.spaceId)
            : q.profileIdEqualTo(context.profileKey),
      )
      .and()
      .yearMonthEqualTo(context.yearMonth)
      .watch(fireImmediately: true)
      .map((budgets) => budgets.isNotEmpty ? budgets.first : null);
});
