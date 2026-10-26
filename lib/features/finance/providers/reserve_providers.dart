import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../providers/finance_providers.dart';
import 'month_end_providers.dart';
import '../providers/profile_providers.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../vault/providers/vault_providers.dart';

/// The money left in the reserve after everything is set aside.
///
/// The reserve is what the user can still spend freely:
///
/// `reserve = income - total allocated to budget profiles - spent directly`
///
/// A budget profile's allocation is *not* spending — it is money set aside in
/// its own envelope (FR-003). A direct expense profile spends straight from
/// the reserve, so its spending is subtracted here (FR-002).
///
/// The result is in **minor units** of the context currency, so no rounding
/// happens on the way (FR-003, T113).
final availableReserveProvider = Provider<int>((ref) {
  final context = ref.watch(budgetContextProvider);
  final income = ref.watch(resolvedIncomeProvider).amount;
  final currency = _contextCurrency(ref);

  final budgetProfiles = ref.watch(budgetProfilesProvider).value ?? const [];
  final directProfiles =
      ref.watch(directExpenseProfilesProvider).value ?? const [];

  final incomeMinor = (income * currency.minorUnitsPerMajor).round();
  final expenses = ref.watch(contextExpensesProvider);
  final returns = ref.watch(monthlyReimbursementsProvider).value ?? const [];
  final table = ref.watch(rateRegistryProvider).tableFor(context.yearMonth);
  int spent(int? id) => const ProfileSpendingService().spentInYearMonth(
      profileId: id,
      profileType: id == null ? null : FinancialProfileType.direct,
      yearMonth: context.yearMonth,
      expenses: expenses,
      reimbursements: returns,
      convert: (e) =>
          expenseToDisplay(e, currency, table, accountingCurrency: currency)
              .minorUnits,
      convertReimbursement: (r) => reimbursementToDisplay(r, currency, table,
              accountingCurrency: currency)
          .minorUnits);

  var allocated = 0;
  for (final profile in budgetProfiles) {
    allocated += profile.allocation;
  }

  var directSpent = 0;
  for (final profile in directProfiles) {
    directSpent += spent(profile.id);
  }

  // Main-profile expenses also use the context's reserve. Read live net
  // spending so a return changes the reserve even before any cache write.
  final settlement = ref.watch(monthEndBalanceProvider);
  final int vaultCredit = ref.watch(monthlyVaultCreditProvider);
  return incomeMinor +
      vaultCredit +
      settlement.incoming +
      settlement.released -
      settlement.carryShortfall -
      allocated -
      directSpent -
      spent(null);
});

/// The reserve as a major-unit value, for the display paths that still work in
/// majors.
final availableReserveMajorProvider = Provider<double>((ref) {
  final minor = ref.watch(availableReserveProvider);
  final currency = _contextCurrency(ref);
  return minor / currency.minorUnitsPerMajor;
});

/// The currency the active context spends in.
CurrencyCode _contextCurrency(Ref ref) {
  if (ref.watch(budgetContextProvider).isShared) {
    return ref.watch(activeSpaceProvider).value?.currency.code ??
        CurrencyCode.huf;
  }
  return ref.watch(activeProfileProvider).value?.primaryCurrency.code ??
      CurrencyCode.huf;
}
