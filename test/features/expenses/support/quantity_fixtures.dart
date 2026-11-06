import 'package:budget_buddy/core/models/expense.dart';

/// Builds a valid standard expense for quantity-focused tests.
///
/// The recorded [amount] is the line total; [quantity] is metadata. Callers may
/// override any field needed by their scenario.
Expense quantityExpense({
  int id = 1,
  int profileId = 1,
  int? sharedSpaceId,
  String yearMonth = '2026-10',
  ExpenseType type = ExpenseType.standard,
  String title = 'Books',
  int amount = 1000,
  int quantity = 2,
  String currency = 'huf',
  String categoryId = 'food',
  ExpenseStatus status = ExpenseStatus.paid,
  DateTime? date,
  int budgetId = 1,
  int? budgetProfileId,
  String? financialProfileType,
  String? financialProfileSyncGuid,
  String? syncGuid,
}) {
  final expense = Expense(
    id: id,
    profileId: profileId,
    sharedSpaceId: sharedSpaceId,
    yearMonth: yearMonth,
    type: type,
    title: title,
    amount: amount,
    quantity: quantity,
    currency: currency,
    categoryId: categoryId,
    status: status,
    date: date ?? DateTime(2026, 10, 5),
    budgetId: budgetId,
    budgetProfileId: budgetProfileId,
    financialProfileType: financialProfileType,
    financialProfileSyncGuid: financialProfileSyncGuid,
    paidAt:
        status == ExpenseStatus.paid ? (date ?? DateTime(2026, 10, 5)) : null,
  );
  if (syncGuid != null) expense.syncGuid = syncGuid;
  return expense;
}
