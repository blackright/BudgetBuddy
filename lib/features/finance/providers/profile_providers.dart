import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/allocation.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../../core/services/expense_profile_identity.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../repositories/allocation_repository.dart';
import '../repositories/budget_profile_repository.dart';
import '../repositories/direct_expense_profile_repository.dart';
import '../../engine/providers/true_available_provider.dart';

final budgetProfilesProvider = StreamProvider<List<BudgetProfile>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final repo = ref.watch(budgetProfileRepositoryProvider);
  if (context.isShared) {
    return repo.watchAll(
        sharedSpaceId: context.spaceId, yearMonth: context.yearMonth);
  }
  return repo.watchAll(
      profileId: context.profileId, yearMonth: context.yearMonth);
});

final directExpenseProfilesProvider =
    StreamProvider<List<DirectExpenseProfile>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final repo = ref.watch(directExpenseProfileRepositoryProvider);
  if (context.isShared) {
    return repo.watchAll(
        sharedSpaceId: context.spaceId, yearMonth: context.yearMonth);
  }
  return repo.watchAll(
      profileId: context.profileId, yearMonth: context.yearMonth);
});

/// The expenses of the active context and month, used to work out how much
/// each profile has spent.
final contextExpensesProvider = Provider<List<Expense>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final expenses = ref.watch(monthlyExpensesProvider).value ?? const [];
  final budgets = ref.watch(budgetProfilesProvider).value ?? const [];
  final directs = ref.watch(directExpenseProfilesProvider).value ?? const [];
  for (final expense in expenses) {
    resolveExpenseProfileIdentity(expense, budgets, directs);
  }
  return expenses
      .where((e) => context.isShared
          ? e.sharedSpaceId == context.spaceId
          : e.sharedSpaceId == null && e.profileId == context.profileId)
      .where((e) => e.yearMonth == context.yearMonth)
      .toList();
});

/// Keeps each profile's stored `spent` in step with the expenses filed under
/// it.
///
/// The spending numbers on screen are computed live from the expense list, but
/// the stored value is what the delete guard and the reports read, so it has
/// to be kept true. A profile with money spent under it must not be deletable
/// by accident.
///
/// This writes only when a value actually changed, so the write cannot loop.
final profileSpendingSyncProvider = FutureProvider<void>((ref) async {
  final budgetProfiles = ref.watch(budgetProfilesProvider).value ?? const [];
  final directProfiles =
      ref.watch(directExpenseProfilesProvider).value ?? const [];
  final expenses = ref.watch(contextExpensesProvider);
  final returns = ref.watch(monthlyReimbursementsProvider).value ?? const [];
  final context = ref.watch(budgetContextProvider);
  // Stored `spent` is in the context currency alongside the allocation (D5);
  // each expense is converted into it before being summed.
  final currency = ref.watch(mainCurrencyProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(context.yearMonth);

  const service = ProfileSpendingService();
  for (final profile in budgetProfiles) {
    final spent = service.spentInYearMonth(
      profileId: profile.id,
      profileType: FinancialProfileType.budget,
      yearMonth: context.yearMonth,
      expenses: expenses,
      reimbursements: returns,
      convertReimbursement: (r) => reimbursementToDisplay(r, currency, table,
              accountingCurrency: currency)
          .minorUnits,
      convert: (expense) => expenseToDisplay(expense, currency, table,
              accountingCurrency: currency)
          .minorUnits,
    );
    if (profile.spent != spent) {
      profile.spent = spent;
      await ref.read(budgetProfileRepositoryProvider).save(profile);
    }
  }
  for (final profile in directProfiles) {
    final spent = service.spentInYearMonth(
      profileId: profile.id,
      profileType: FinancialProfileType.direct,
      yearMonth: context.yearMonth,
      expenses: expenses,
      reimbursements: returns,
      convertReimbursement: (r) => reimbursementToDisplay(r, currency, table,
              accountingCurrency: currency)
          .minorUnits,
      convert: (expense) => expenseToDisplay(expense, currency, table,
              accountingCurrency: currency)
          .minorUnits,
    );
    final count = expenses
        .where((e) =>
            e.budgetProfileId == profile.id &&
            e.financialProfileType == FinancialProfileType.direct)
        .length;
    if (profile.spent != spent || profile.expenseCount != count) {
      profile.spent = spent;
      profile.expenseCount = count;
      await ref.read(directExpenseProfileRepositoryProvider).save(profile);
    }
  }
});

final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref);
});

class ProfileActions {
  final Ref _ref;
  ProfileActions(this._ref);

  Future<void> saveBudget(BudgetProfile profile) async {
    final context = _ref.read(budgetContextProvider);
    final previousAllocation = profile.allocation;
    if (context.isShared) {
      profile.sharedSpaceId = context.spaceId;
      profile.profileId = null;
    } else {
      profile.profileId = context.profileId;
      profile.sharedSpaceId = null;
    }
    profile.yearMonth = context.yearMonth;
    await _ref.read(budgetProfileRepositoryProvider).save(profile);
    await _recordAllocation(
      profile: profile,
      previousAllocation: previousAllocation,
    );
  }

  /// Records the allocation change so the money moved in or out of the
  /// profile is traceable (FR-003).
  Future<void> _recordAllocation({
    required BudgetProfile profile,
    required int previousAllocation,
  }) async {
    final delta = profile.allocation - previousAllocation;
    if (delta == 0) return;
    final context = _ref.read(budgetContextProvider);
    final allocation = Allocation()
      ..budgetProfileId = profile.id
      ..amount = delta
      ..currency = _contextCurrency()
      ..date = DateTime.now();
    if (context.isShared) {
      allocation.sharedSpaceId = context.spaceId;
    } else {
      allocation.profileId = context.profileId;
    }
    allocation.yearMonth = context.yearMonth;
    await _ref.read(allocationRepositoryProvider).save(allocation);
  }

  /// The currency the active context spends in.
  String _contextCurrency() {
    if (_ref.read(budgetContextProvider).isShared) {
      final space = _ref.read(activeSpaceProvider).value;
      return (space?.currency.code ?? CurrencyCode.huf).code;
    }
    final profile = _ref.read(activeProfileProvider).value;
    return (profile?.primaryCurrency.code ?? CurrencyCode.huf).code;
  }

  Future<void> saveDirect(DirectExpenseProfile profile) async {
    final context = _ref.read(budgetContextProvider);
    if (context.isShared) {
      profile.sharedSpaceId = context.spaceId;
      profile.profileId = null;
    } else {
      profile.profileId = context.profileId;
      profile.sharedSpaceId = null;
    }
    profile.yearMonth = context.yearMonth;
    await _ref.read(directExpenseProfileRepositoryProvider).save(profile);
  }

  Future<void> deleteBudget(int id) async {
    await _ref.read(budgetProfileRepositoryProvider).delete(id);
  }

  Future<void> deleteDirect(int id) async {
    await _ref.read(directExpenseProfileRepositoryProvider).delete(id);
  }
}
