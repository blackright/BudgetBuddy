/// Pending Action types used by the income lifecycle.
///
/// The type is stable because it is part of the action's dedupe key and deep
/// link routing.
abstract final class PendingActionTypes {
  static const incomeActivate = 'income.activate';
  static const incomeComplete = 'income.complete';
  static const salaryConfirm = 'salary.confirm';
  static const incomeConfirm = 'income.confirm';
}
