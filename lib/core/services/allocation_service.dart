import '../models/budget_profile.dart';
import '../models/direct_expense_profile.dart';

/// The rules that decide whether money may be moved into a profile.
class AllocationService {
  const AllocationService();

  /// Direct expense profiles never receive allocations (FR-002).
  ///
  /// They spend straight from the reserve, so there is nothing to allocate to
  /// them and an allocation would be a second, hidden pot.
  bool canAllocateToDirect(DirectExpenseProfile profile) => false;

  /// Budget profiles may receive allocations (FR-002).
  bool canAllocateToBudget(BudgetProfile profile) => true;

  /// Moves [amount] of reserve into [profile]'s allocation.
  ///
  /// Returns `false` and changes nothing when the amount is not positive or the
  /// reserve cannot cover it. The allocation is never raised above the amount
  /// asked for (FR-012: allocations are not auto-increased).
  bool apply({
    required BudgetProfile profile,
    required int amount,
    required int availableReserve,
  }) {
    if (amount <= 0) return false;
    if (amount > availableReserve) return false;
    profile.allocation += amount;
    return true;
  }

  /// Takes [amount] back out of [profile]'s allocation and returns it to the
  /// reserve.
  ///
  /// Returns `false` when the profile does not hold that much.
  bool release({
    required BudgetProfile profile,
    required int amount,
  }) {
    if (amount <= 0) return false;
    if (amount > profile.allocation) return false;
    profile.allocation -= amount;
    return true;
  }
}
