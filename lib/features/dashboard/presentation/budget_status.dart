import 'package:flutter/material.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/services/borrowing_service.dart';
import '../../../core/services/continuous_balance_service.dart';
import '../../../shared/presentation/money_format.dart';

/// The colours a budget profile card is painted with (FR-014).
///
/// - **Green** — under 80% of the allocation used
/// - **Yellow** — 80% to 99% used
/// - **Orange** — exactly 100% used
/// - **Red** — over 100% used (the profile is over budget)
extension BudgetStatusColors on BudgetStatus {
  Color get color {
    switch (this) {
      case BudgetStatus.green:
        return const Color(0xFF2E7D32);
      case BudgetStatus.yellow:
        return const Color(0xFFF9A825);
      case BudgetStatus.orange:
        return const Color(0xFFEF6C00);
      case BudgetStatus.red:
        return const Color(0xFFC62828);
    }
  }

  /// A soft version of the colour, used for the card background.
  Color get softColor => color.withValues(alpha: 0.12);

  /// The colour to paint on that soft background.
  Color get onSoftColor => color;

  /// A short word for the status, so the meaning is not carried by colour
  /// alone (accessibility).
  String get label {
    switch (this) {
      case BudgetStatus.green:
        return 'On track';
      case BudgetStatus.yellow:
        return 'Getting close';
      case BudgetStatus.orange:
        return 'Fully used';
      case BudgetStatus.red:
        return 'Over budget';
    }
  }
}

/// Dashboard wording for a budget status.
///
/// Other screens keep using [BudgetStatusColors.label]. The Dashboard uses the
/// approved short vocabulary and always states an over-budget amount in words.
extension DashboardBudgetStatusCopy on BudgetStatus {
  String dashboardLabel({
    required CurrencyCode currency,
    int overspendMinor = 0,
  }) {
    switch (this) {
      case BudgetStatus.green:
        return 'On track';
      case BudgetStatus.yellow:
        return 'Close';
      case BudgetStatus.orange:
        return 'Fully used';
      case BudgetStatus.red:
        return 'Over by ${formatMinorUnits(overspendMinor, currency)}';
    }
  }
}

/// User-facing copy for the derived continuous-balance chain state.
extension BalanceChainStatusCopy on BalanceChainStatus {
  String get title {
    switch (this) {
      case BalanceChainStatus.intact:
        return 'Balance is continuous';
      case BalanceChainStatus.firstMonth:
        return 'Confirm the first opening balance';
      case BalanceChainStatus.legacyGap:
        return 'A month is missing from the balance chain';
      case BalanceChainStatus.needsReview:
        return 'Review your balance chain';
    }
  }

  String get guidance {
    switch (this) {
      case BalanceChainStatus.intact:
        return 'Opening money follows the previous month\'s closing balance.';
      case BalanceChainStatus.firstMonth:
        return 'Record what was in your bank at the start of this month. Unknown is different from a confirmed zero.';
      case BalanceChainStatus.legacyGap:
        return 'Confirm the opening balance for the missing month before carrying money forward.';
      case BalanceChainStatus.needsReview:
        return 'A stored amount, currency or settlement needs review before money can move.';
    }
  }
}
