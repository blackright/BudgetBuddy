import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/monthly_budget.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../repositories/month_finance_repository.dart';

/// Provisions the selected month on every selection change.
///
/// Navigating to a month must never surface an error just because that month has
/// no record yet (R16, N6): the row is created on arrival, with a zero
/// unconfirmed opening balance and no carryover from the previous month (FR-007).
final selectedMonthProvisioningProvider = FutureProvider<void>((ref) async {
  final yearMonth = ref.watch(selectedYearMonthProvider);
  await ref.watch(monthFinanceRepositoryProvider).ensureMonth(yearMonth);
});

/// The selected month's finance record.
final monthFinanceProvider = StreamProvider<MonthlyBudget?>((ref) {
  ref.watch(selectedMonthProvisioningProvider);
  final yearMonth = ref.watch(selectedYearMonthProvider);
  return ref.watch(monthFinanceRepositoryProvider).watchMonth(yearMonth);
});

/// The profile-wide default take-home pay (FR-001).
final defaultNetSalaryProvider = Provider<double>((ref) {
  return ref.watch(activeProfileProvider).value?.defaultNetSalary ?? 0.0;
});

/// Income applied to the selected month, resolving override against default.
final resolvedIncomeProvider = Provider<ResolvedIncome>((ref) {
  final month = ref.watch(monthFinanceProvider).value;
  return ResolvedIncome.resolve(
    override: month?.netSalaryOverride,
    profileDefault: ref.watch(defaultNetSalaryProvider),
  );
});

/// Whether the selected month has enough recorded to present a real verdict
/// (FR-025).
///
/// A month missing either its opening balance or its income is incomplete: the
/// hero figure is withheld and a prompt is shown rather than a misleading zero.
/// Planned expenses do not make a month complete — they are commitments, not
/// settled money.
final monthCompletenessProvider = Provider<bool>((ref) {
  final month = ref.watch(monthFinanceProvider).value;
  if (month == null || !month.openingBalanceConfirmed) return false;
  return ref.watch(resolvedIncomeProvider).amount > 0;
});
