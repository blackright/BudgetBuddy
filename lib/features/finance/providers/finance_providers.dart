import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../repositories/month_finance_repository.dart';

/// Provisions the selected month on every selection change.
///
/// Navigating to a month must never surface an error just because that month has
/// no record yet (R16, N6): the row is created on arrival, with a zero
/// unconfirmed opening balance and no carryover from the previous month (FR-007).
/// Context-aware: a first visit to a shared month provisions that space's budget
/// (FR-011).
///
/// A brand-new shared space owns no months and MUST NOT auto-provision its first
/// one — the current month is brought in deliberately (at creation or via
/// "move this month"), and only then do later months accrue automatically
/// (FR-011, US5).
final selectedMonthProvisioningProvider = FutureProvider<void>((ref) async {
  final context = ref.watch(budgetContextProvider);
  final repo = ref.watch(monthFinanceRepositoryProvider);
  if (context.isShared && !await repo.spaceOwnsAnyMonth(context.spaceId!)) {
    return;
  }
  await repo.ensureMonthInContext(context);
});

/// The selected month's finance record, resolved through the active context
/// (FR-004).
final monthFinanceProvider = StreamProvider<MonthlyBudget?>((ref) {
  ref.watch(selectedMonthProvisioningProvider);
  final context = ref.watch(budgetContextProvider);
  return ref.watch(monthFinanceRepositoryProvider).watchMonthInContext(context);
});

/// The profile-wide default take-home pay (FR-001).
final defaultNetSalaryProvider = Provider<double>((ref) {
  final profile = ref.watch(activeProfileProvider).value?.defaultNetSalary;
  return profile ?? 0.0;
});

/// Income applied to the selected month, resolving override against default for
/// whichever pot the active context owns (FR-009, shared-income §2).
///
/// Synchronous over already-watched rows (month, profile, space), so a context
/// switch re-derives this in the same frame. The shared pot is stored in whole
/// minor units and converted to the space currency's major units here.
final resolvedIncomeProvider = Provider<ResolvedIncome>((ref) {
  final context = ref.watch(budgetContextProvider);
  final month = ref.watch(monthFinanceProvider).value;
  if (context.isShared) {
    final space = ref.watch(activeSpaceProvider).value;
    final override = month?.sharedIncomeOverride;
    return ResolvedIncome(
      amount: _sharedMajorOf(space, override),
      usesOverride: override != null,
    );
  }
  return ResolvedIncome.resolve(
    override: month?.netSalaryOverride,
    profileDefault: ref.watch(defaultNetSalaryProvider),
  );
});

/// Minor units → major units for a space's income pot, once (FR-009 §2).
double _sharedMajorOf(SharedSpace? space, int? override) {
  final minor = override ?? space?.defaultIncome ?? 0;
  // HUF has no minor-unit division (exponent 0 → per-major ratio 1); other
  // currencies divide by 100. While no space row is resolved yet the raw major
  // figure is returned, so nothing is invented.
  final perMajor = space?.currency.code.minorUnitsPerMajor ?? 1;
  return minor / perMajor;
}

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
