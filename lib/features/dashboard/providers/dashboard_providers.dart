import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/borrowing_service.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../finance/providers/profile_providers.dart';
import '../../finance/providers/reserve_providers.dart';
import '../../settings/providers/settings_provider.dart';

/// How many of the newest expenses a profile card shows (T136).
const int kDashboardRecentExpenseCount = 3;

/// The money story of one profile â€” budget or direct â€” ready for a card.
///
/// The two kinds of profile are shown together, so they share one shape. The
/// difference is kept in [isDirect]:
///
/// - a **budget profile** has an allocation, so it can run out, borrow from the
///   reserve and end up in deficit (FR-002, FR-011);
/// - a **direct expense profile** has no allocation, spends straight from the
///   reserve and can only ever show a deficit (FR-002).
class DashboardProfileState {
  const DashboardProfileState({
    required this.id,
    required this.name,
    required this.isDirect,
    required this.allocation,
    required this.spent,
    required this.expenseCount,
    required this.availableReserve,
    required this.recentExpenses,
  });

  final int id;

  String get identity => '${isDirect ? "direct" : "budget"}:$id';
  final String name;

  /// True for a Direct Expense Profile, false for a Budget Profile.
  final bool isDirect;

  /// The money set aside. Always `0` for a direct profile.
  final int allocation;

  /// The money spent under this profile.
  final int spent;

  /// How many expenses are filed under this profile.
  final int expenseCount;

  /// The reserve this profile may borrow from.
  final int availableReserve;

  /// The newest expenses filed under this profile, newest first.
  final List<Expense> recentExpenses;

  /// The borrowing and deficit numbers for this profile (FR-011).
  ProfileBorrowingState get state => ProfileBorrowingState(
        allocation: allocation,
        spent: spent,
        availableReserve: availableReserve,
      );

  /// The colour band of this profile (FR-014).
  BudgetStatus get status => state.status;

  /// Money still inside the profile. A direct profile has none, so it shows
  /// what it took from the reserve instead.
  int get remaining => allocation - spent;

  /// The amount the profile took from the reserve (FR-011).
  int get borrowed => isDirect ? 0 : state.borrowed;

  /// The amount still owed (FR-011).
  ///
  /// A direct profile may also end up in deficit when the reserve is empty,
  /// so its deficit is measured against the reserve as well.
  int get deficit {
    if (!isDirect) return state.deficit;
    final capacity = availableReserve > 0 ? availableReserve : 0;
    return spent > capacity ? spent - capacity : 0;
  }
}

/// Every profile of the active context, budget and direct, with its money
/// story, ordered so that trouble comes first.
///
/// The reserve is the money that is still free. When a profile overspends it
/// borrows from this reserve, and when the reserve runs out the rest is a
/// deficit (FR-011, FR-028).
///
/// **Units (D5).** Allocation, reserve and stored spending are recorded in the
/// context currency, while each expense carries its own. Everything is brought
/// into the **display currency** here â€” one conversion per figure â€” so the
/// card's formatter and the month summary agree, and mixed-currency expenses
/// can never be summed as if they shared a unit.
///
/// **Ordering (T135).** Budget profiles come first, worst status first â€”
/// over budget, then fully used, then getting close, then on track. Inside a
/// band the one closest to the limit is first. Direct profiles follow,
/// biggest spend first.
final dashboardProfilesProvider = Provider<List<DashboardProfileState>>((ref) {
  final budgetProfiles = ref.watch(budgetProfilesProvider).value ?? const [];
  final directProfiles =
      ref.watch(directExpenseProfilesProvider).value ?? const [];
  final availableReserve = ref.watch(availableReserveProvider);
  final expenses = ref.watch(contextExpensesProvider);
  final returns = ref.watch(monthlyReimbursementsProvider).value ?? const [];
  final context = ref.watch(budgetContextProvider);
  final display = ref.watch(dashboardCurrencyProvider);
  final main = ref.watch(mainCurrencyProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(context.yearMonth);

  const service = ProfileSpendingService();
  final states = <DashboardProfileState>[];

  int toDisplayMinor(Money amount) =>
      toDisplay(amount, display, table).minorUnits;
  int convertedSpend(int? profileId, String type) => service.spentInYearMonth(
        profileId: profileId,
        profileType: type,
        yearMonth: context.yearMonth,
        expenses: expenses,
        reimbursements: returns,
        convertReimbursement: (r) =>
            reimbursementToDisplay(r, display, table, accountingCurrency: main)
                .minorUnits,
        convert: (expense) =>
            expenseToDisplay(expense, display, table, accountingCurrency: main)
                .minorUnits,
      );

  for (final profile in budgetProfiles) {
    final own = _expensesOf(expenses, profile.id, FinancialProfileType.budget);
    states.add(DashboardProfileState(
      id: profile.id,
      name: profile.name,
      isDirect: false,
      allocation: toDisplayMinor(Money(profile.allocation, main)),
      spent: convertedSpend(profile.id, FinancialProfileType.budget),
      expenseCount: own.length,
      availableReserve: toDisplayMinor(Money(availableReserve, main)),
      recentExpenses: _newest(own),
    ));
  }

  for (final profile in directProfiles) {
    final own = _expensesOf(expenses, profile.id, FinancialProfileType.direct);
    states.add(DashboardProfileState(
      id: profile.id,
      name: profile.name,
      isDirect: true,
      allocation: 0,
      spent: convertedSpend(profile.id, FinancialProfileType.direct),
      expenseCount: own.length,
      // The aggregate reserve already subtracts direct spending. Restore this
      // profile's own spending to get its capacity before spending, otherwise
      // its cost is charged twice when computing the direct-profile deficit.
      availableReserve: toDisplayMinor(Money(availableReserve, main)) +
          convertedSpend(profile.id, FinancialProfileType.direct),
      recentExpenses: _newest(own),
    ));
  }

  states.sort(_byUrgency);
  return states;
});

/// The expenses filed under [profileId].
List<Expense> _expensesOf(List<Expense> expenses, int profileId, String type) =>
    expenses
        .where((e) =>
            e.budgetProfileId == profileId && e.financialProfileType == type)
        .toList();

/// The newest expenses first, at most [kDashboardRecentExpenseCount].
List<Expense> _newest(List<Expense> expenses) {
  final sorted = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
  return sorted.take(kDashboardRecentExpenseCount).toList();
}

/// Budget profiles first (worst status first), then direct profiles (biggest
/// spend first).
int _byUrgency(DashboardProfileState a, DashboardProfileState b) {
  if (a.isDirect != b.isDirect) return a.isDirect ? 1 : -1;
  if (a.isDirect) return b.spent.compareTo(a.spent);
  final byStatus = a.status.index.compareTo(b.status.index);
  if (byStatus != 0) return byStatus;
  final byRemaining = a.remaining.compareTo(b.remaining);
  if (byRemaining != 0) return byRemaining;
  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
}

/// The totals for the one-line summary (T136).
final dashboardProfilesSummaryProvider = Provider<
    ({int count, int allocated, int spent, int borrowed, int deficit})>((ref) {
  final states = ref.watch(dashboardProfilesProvider);
  var allocated = 0;
  var spent = 0;
  var borrowed = 0;
  var deficit = 0;
  for (final entry in states) {
    allocated += entry.allocation;
    spent += entry.spent;
    borrowed += entry.borrowed;
    deficit += entry.deficit;
  }
  return (
    count: states.length,
    allocated: allocated,
    spent: spent,
    borrowed: borrowed,
    deficit: deficit,
  );
});

/// The total borrowed and the total deficit across every profile (FR-011).
final dashboardBorrowingTotalsProvider =
    Provider<({int borrowed, int deficit})>((ref) {
  final states = ref.watch(dashboardProfilesProvider);
  var borrowed = 0;
  var deficit = 0;
  for (final entry in states) {
    borrowed += entry.borrowed;
    deficit += entry.deficit;
  }
  return (borrowed: borrowed, deficit: deficit);
});

/// The currency every dashboard figure is expressed in: the selected month's
/// convert-to choice when set, otherwise the active context's main currency
/// (FR-011). This is the *display* currency, so it may differ from the context
/// currency the stored allocation and reserve use; [dashboardProfilesProvider]
/// converts those before they reach the widgets.
final dashboardCurrencyProvider = Provider<CurrencyCode>((ref) {
  final main = ref.watch(mainCurrencyProvider);
  final month = ref.watch(activeBudgetProvider).value;
  return resolveContextDisplayCurrency(month, main);
});
