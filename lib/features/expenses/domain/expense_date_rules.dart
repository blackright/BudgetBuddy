import '../../../core/models/expense.dart';

/// The earliest date an expense may be recorded on.
///
/// Past expenses are a normal correction, so the window is deliberately wide.
DateTime expenseDateFloor() => DateTime(2000);

/// The last date the picker may offer for [status].
///
/// A paid expense cannot be dated after today; a planned one may sit up to a
/// year ahead so upcoming commitments can be recorded.
DateTime expenseDateCeiling(ExpenseStatus status, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return status == ExpenseStatus.paid
      ? today
      : DateTime(now.year + 1, now.month, now.day);
}

/// True when a Paid expense carries a future date. Without this a user could
/// record money as already gone before it leaves the account.
bool isFuturePaidExpense(ExpenseStatus status, DateTime date, DateTime now) {
  if (status != ExpenseStatus.paid) return false;
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  return day.isAfter(today);
}
