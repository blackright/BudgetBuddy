import 'package:flutter/material.dart';

import '../../../core/services/borrowing_service.dart';

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
