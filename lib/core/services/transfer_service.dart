import '../models/budget_profile.dart';

/// Validates and applies transfers between budget profiles.
class TransferService {
  const TransferService();

  /// Whether [amount] may be moved out of a profile holding
  /// [sourceAllocation].
  ///
  /// A transfer is only allowed when the amount is positive and the source
  /// really holds that much — the source allocation may never go below zero
  /// (FR-004).
  bool canTransfer(int sourceAllocation, int amount) {
    return amount > 0 && sourceAllocation >= amount;
  }

  /// Applies a transfer to the in-memory profiles.
  ///
  /// Returns `false` and changes nothing when validation fails.
  bool apply(BudgetProfile source, BudgetProfile destination, int amount) {
    if (source.id == destination.id) return false;
    if (!canTransfer(source.allocation, amount)) return false;
    source.allocation -= amount;
    destination.allocation += amount;
    return true;
  }

  /// A human-readable reason why a transfer was refused, or `null` when it is
  /// allowed.
  String? refusalReason({
    required BudgetProfile? source,
    required BudgetProfile? destination,
    required int amount,
  }) {
    if (source == null || destination == null) {
      return 'Please choose both a source and a destination profile.';
    }
    if (source.id == destination.id) {
      return 'The source and the destination must be different profiles.';
    }
    if (amount <= 0) {
      return 'Please enter an amount greater than zero.';
    }
    if (amount > source.allocation) {
      return 'Not enough money in ${source.name} to move that amount.';
    }
    return null;
  }
}
