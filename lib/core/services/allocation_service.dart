import '../models/budget_profile.dart';
import '../models/direct_expense_profile.dart';

/// Pure allocation guard used before a profile allocation is written.
///
/// Direct expense profiles never receive allocation funds (FR-002); reserving
/// more than the available reserve is refused; releasing more than the profile
/// currently holds is refused. No database access lives here.
class AllocationService {
  const AllocationService();

  bool canAllocateToDirect(DirectExpenseProfile profile) => false;

  bool apply({
    required BudgetProfile profile,
    required int amount,
    required int availableReserve,
  }) {
    if (amount <= 0 || amount > availableReserve) return false;
    profile.allocation += amount;
    return true;
  }

  bool release({required BudgetProfile profile, required int amount}) {
    if (amount <= 0 || amount > profile.allocation) return false;
    profile.allocation -= amount;
    return true;
  }
}
