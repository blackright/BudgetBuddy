import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/services/bulk_entry_service.dart';
import 'package:budget_buddy/core/services/purchase_draft.dart';
import 'package:budget_buddy/core/services/quantity_math.dart';
import 'package:flutter_test/flutter_test.dart';

/// US1: bulk rows and purchases record a unit price plus quantity, while the
/// expense and receipt totals use the checked line total.
void main() {
  const month = '2026-10';
  const service = BulkEntryService();

  BulkExpenseDraft plannedRow({
    String unitAmount = '1,000',
    int quantity = 1,
  }) =>
      BulkExpenseDraft()
        ..title = 'Book'
        ..unitAmount = unitAmount
        ..quantity = quantity
        ..currency = 'HUF'
        ..merchant = 'Shop'
        ..category = 'food'
        ..payment = 'card'
        ..profileChosen = true
        ..date = DateTime(2026, 10, 4)
        ..status = ExpenseStatus.planned;

  PurchaseDraft purchase() {
    final draft = PurchaseDraft();
    draft.header
      ..merchant = 'Shop'
      ..currency = 'HUF'
      ..payment = 'card'
      ..date = DateTime(2026, 10, 4);
    return draft;
  }

  test('a bulk row stores the line total and keeps the quantity', () {
    final row = plannedRow(unitAmount: '500', quantity: 2);

    expect(row.lineTotalMinor, 1000);
    expect(service.validate(row, month), isEmpty);

    final expense =
        service.expense(row, owner: 1, space: null, month: month, budget: 1);
    expect(expense.amount, 1000);
    expect(expense.quantity, 2);
    expect(expense.unitAmountMinor, 500);
  });

  test('quantity 1 leaves the stored total identical to the unit price', () {
    final row = plannedRow(unitAmount: '1,234');

    expect(row.lineTotalMinor, 1234);
    final expense =
        service.expense(row, owner: 1, space: null, month: month, budget: 1);
    expect(expense.amount, 1234);
    expect(expense.quantity, 1);
  });

  test('purchase totals and receipt matching use line totals', () {
    final draft = purchase();
    draft.addItem()
      ..title = 'Book'
      ..unitAmount = '1,000'
      ..quantity = 2
      ..category = 'food'
      ..profileChosen = true;
    draft.addItem()
      ..title = 'Pen'
      ..unitAmount = '500'
      ..category = 'food'
      ..profileChosen = true;

    expect(draft.totalMinor, 2500);

    draft.header.status = ExpenseStatus.paid;
    draft.receiptTotal = '2,500';
    expect(draft.validate(month),
        isNot(contains('Receipt total must match the items total exactly.')));

    draft.receiptTotal = '2,000';
    expect(draft.validate(month),
        contains('Receipt total must match the items total exactly.'));
  });

  test('a copied bulk row never inherits the unit price or quantity', () {
    final source = plannedRow(unitAmount: '750', quantity: 4)..notes = 'note';
    final copy = source.copy();

    expect(copy.title, source.title);
    expect(copy.notes, 'note');
    expect(copy.unitAmount, isEmpty);
    expect(copy.quantity, 1);
    expect(copy.lineTotalMinor, isNull);
  });

  test('overflowing line totals invalidate the row without wrapping', () {
    final row = plannedRow(unitAmount: '9,007,199,254,740,991', quantity: 2);

    expect(row.lineTotalMinor, isNull);
    expect(service.validate(row, month), contains('amount'));

    final draft = purchase();
    draft.addItem()
      ..title = 'Huge'
      ..unitAmount = '9,007,199,254,740,991'
      ..quantity = 2
      ..category = 'food'
      ..profileChosen = true;
    expect(draft.totalMinor, isNull);
  });

  test('a saved non-divisible total is preserved until corrected', () {
    final row = plannedRow(unitAmount: '1,001', quantity: 2)
      ..needsQuantityCorrection = true;

    // The stored total is not multiplied again while awaiting correction.
    expect(row.lineTotalMinor, 1001);
    expect(service.validate(row, month), contains('quantity'));

    row
      ..quantity = 1
      ..needsQuantityCorrection = false;
    expect(row.lineTotalMinor, 1001);
    expect(service.validate(row, month), isEmpty);
    final expense =
        service.expense(row, owner: 1, space: null, month: month, budget: 1);
    expect(expense.amount, 1001);
    expect(expense.quantity, 1);
  });

  test('unsupported quantities are rejected by both bulk and purchase rows',
      () {
    final row = plannedRow()..quantity = 0;
    expect(service.validate(row, month), contains('quantity'));
    expect(
        () => service.expense(row,
            owner: 1, space: null, month: month, budget: 1),
        throwsStateError);

    row.quantity = 1000;
    expect(service.validate(row, month), contains('quantity'));
    expect(isValidQuantity(row.quantity), isFalse);
  });
}
