import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../../core/services/medical_receipt_booking_service.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../providers/finance_providers.dart';
import 'month_end_providers.dart';
import '../providers/profile_providers.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../engine/providers/continuous_balance_provider.dart';
import '../../../core/services/continuous_balance_service.dart';
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
  if (!context.isShared && context.profileId != null) {
    final continuous = ref
        .watch(continuousBalanceProvider(
            (profileId: context.profileId!, yearMonth: context.yearMonth)))
        .valueOrNull;
    if (continuous?.status == BalanceChainStatus.needsReview) {
      throw FormatException(
          continuous!.reviewReason ?? 'The balance chain needs review.');
    }
    if (continuous != null && continuous.status == BalanceChainStatus.intact) {
      return continuous.freeToUseMinor;
    }
  }
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
      medicalRecoveryForMonth(returns, context.yearMonth,
          convert: (r) => reimbursementToDisplay(r, currency, table,
                  accountingCurrency: currency)
              .minorUnits) +
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
