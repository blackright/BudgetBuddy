import '../models/budget_profile.dart';

/// How a budget profile is doing against its allocation.
enum BudgetStatus {
  /// Under 80% used — plenty of room left.
  green,

  /// 80% to 99% used — getting close.
  yellow,

  /// Exactly 100% used — the allocation is gone.
  orange,

  /// Over 100% used — spending has passed the allocation.
  red,
}

/// The money story of one budget profile in one month.
///
/// Every number is in whole minor units of the context currency, so the totals
/// reconcile exactly with the recorded transactions (FR-003, FR-011).
class ProfileBorrowingState {
  const ProfileBorrowingState({
    required this.allocation,
    required this.spent,
    required this.availableReserve,
  });

  /// The money set aside for this profile.
  final int allocation;

  /// The money already spent from this profile.
  final int spent;

  /// The reserve the profile may borrow from when it runs out.
  final int availableReserve;

  /// Money still inside this profile.
  int get remaining => allocation - spent;

  /// Spending above the allocation (FR-011).
  int get overspend => spent > allocation ? spent - allocation : 0;

  /// How much of the allocation is used, as a percentage.
  double get usagePercent {
    if (allocation <= 0) return spent > 0 ? 100 : 0;
    return (spent / allocation) * 100;
  }

  /// The amount taken from the reserve because the profile ran out
  /// (FR-011: `Borrowed = MIN(Overspend, Available Reserve)`).
  int get borrowed => availableReserve <= 0
      ? 0
      : (overspend > availableReserve ? availableReserve : overspend);

  /// The amount still owed after the reserve is used up
  /// (FR-011: `Deficit = Overspend - Borrowed`).
  int get deficit => overspend - borrowed;

  /// The colour band this profile is in (FR-014).
  BudgetStatus get status {
    if (spent > allocation) return BudgetStatus.red;
    if (allocation <= 0) return BudgetStatus.green;
    final percent = usagePercent;
    if (percent >= 100) return BudgetStatus.orange;
    if (percent >= 80) return BudgetStatus.yellow;
    return BudgetStatus.green;
  }
}

/// Works out borrowing and deficit for budget profiles.
///
/// The rules are simple and never change the allocation (FR-012):
///
/// - `Overspend = Net Spending - Allocation`
/// - `Borrowed  = MIN(Overspend, Available Reserve)`
/// - `Deficit   = Overspend - Borrowed`
///
/// A profile is **never** quietly given more money: the allocation stays as
/// the user set it, and the extra spending is shown as borrowed or as a
/// deficit instead.
class BorrowingService {
  const BorrowingService();

  /// The money story of [profile] when it has spent [spent] and the reserve
  /// holds [availableReserve].
  ProfileBorrowingState stateFor({
    required BudgetProfile profile,
    required int spent,
    required int availableReserve,
  }) {
    return ProfileBorrowingState(
      allocation: profile.allocation,
      spent: spent,
      availableReserve: availableReserve,
    );
  }

  /// The state of a profile described only by numbers.
  ProfileBorrowingState state({
    required int allocation,
    required int spent,
    required int availableReserve,
  }) {
    return ProfileBorrowingState(
      allocation: allocation,
      spent: spent,
      availableReserve: availableReserve,
    );
  }
}
