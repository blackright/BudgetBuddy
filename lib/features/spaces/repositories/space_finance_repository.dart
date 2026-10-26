import '../../../core/models/budget_profile.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/services/borrowing_service.dart';

/// The money of a shared space, in whole minor units of the space currency.
///
/// A shared space has its own pot of money — "Our income" — and it is that pot
/// a profile borrows from when it overspends, not the acting member's personal
/// reserve (FR-028, research R4). Keeping personal and shared money apart
/// stops one member's overspending from quietly eating another member's own
/// money.
class SpaceFinanceRepository {
  const SpaceFinanceRepository();

  /// The money left in the space after everything is set aside.
  ///
  /// `reserve = shared income - allocations - direct spending`
  int availableReserve({
    required int sharedIncomeMinor,
    required List<BudgetProfile> budgetProfiles,
    required List<DirectExpenseProfile> directExpenseProfiles,
  }) {
    var allocated = 0;
    for (final profile in budgetProfiles) {
      allocated += profile.allocation;
    }
    var directSpent = 0;
    for (final profile in directExpenseProfiles) {
      directSpent += profile.spent;
    }
    return sharedIncomeMinor - allocated - directSpent;
  }

  /// The borrowing and deficit state of one profile inside the space.
  ///
  /// The deficit is never negative: the space cannot owe more than the
  /// overspend itself (FR-011).
  ProfileBorrowingState borrowingState({
    required BudgetProfile profile,
    required int spent,
    required int availableReserve,
  }) {
    const service = BorrowingService();
    return service.stateFor(
      profile: profile,
      spent: spent,
      availableReserve: availableReserve,
    );
  }
}
