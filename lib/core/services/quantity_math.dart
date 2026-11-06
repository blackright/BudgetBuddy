/// Bounds and checked arithmetic for whole-number expense quantities.
///
/// The recorded money value remains `Expense.amount` (the line total). These
/// helpers are the single place that multiplies or divides a minor-unit amount
/// by a quantity, so add/edit/bulk paths cannot disagree about overflow or
/// rounding.
library;

import '../models/expense.dart';

/// The maximum quantity accepted by the expense editors.
const int maximumExpenseQuantity = 999;

/// The same monetary ceiling used by the purchase and report boundaries.
const int maximumMinorAmount = 9007199254740991;

/// Whether [quantity] is a supported whole-number quantity.
bool isValidQuantity(int quantity) =>
    quantity >= 1 && quantity <= maximumExpenseQuantity;

/// Returns the checked line total for [unitMinor] × [quantity], or `null` when
/// the unit is not positive, the quantity is unsupported, or the product
/// exceeds [maximumMinorAmount].
int? quantityLineTotalMinor({
  required int unitMinor,
  required int quantity,
}) {
  if (unitMinor <= 0 || !isValidQuantity(quantity)) return null;
  final total = BigInt.from(unitMinor) * BigInt.from(quantity);
  if (total > BigInt.from(maximumMinorAmount)) return null;
  return total.toInt();
}

/// Returns the exact unit amount for [totalMinor] ÷ [quantity], or `null` when
/// the total is not positive, the quantity is unsupported, or the total cannot
/// be divided evenly. Callers must never round a non-divisible total.
int? quantityUnitMinor({
  required int totalMinor,
  required int quantity,
}) {
  if (totalMinor <= 0 || !isValidQuantity(quantity)) return null;
  if (totalMinor % quantity != 0) return null;
  return totalMinor ~/ quantity;
}

/// The derived unit price for a stored expense, or `null` when the recorded
/// total cannot be divided evenly by its quantity.
extension ExpenseQuantityAmount on Expense {
  int? get unitAmountMinor =>
      quantityUnitMinor(totalMinor: amount, quantity: quantity);
}
