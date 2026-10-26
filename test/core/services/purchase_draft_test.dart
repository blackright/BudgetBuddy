import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/services/purchase_draft.dart';
import 'package:budget_buddy/core/models/expense.dart';

void main() {
  PurchaseDraft example() {
    final p = PurchaseDraft();
    p.header
      ..merchant = 'Shop'
      ..currency = 'HUF'
      ..payment = 'cash'
      ..date = DateTime(2026, 10, 26);
    for (final amount in ['5,000', '3,000', '2,000']) {
      p.addItem()
        ..title = 'Item'
        ..amount = amount
        ..category = 'general'
        ..profileChosen = true;
    }
    return p;
  }

  test('exact item totals and explicit receipt matching', () {
    final p = example();
    expect(p.totalMinor, 10000);
    expect(p.validate('2026-10'), isEmpty);
    p.header.status = ExpenseStatus.paid;
    p.receiptTotal = '9,999';
    expect(p.validate('2026-10'),
        contains('Receipt total must match the items total exactly.'));
    p.receiptTotal = '10,000';
    expect(p.validate('2026-10'),
        isNot(contains('Receipt total must match the items total exactly.')));
  });
  test('copy never inherits payment, identities, amounts or evidence', () {
    final p = example()..receiptTotal = '10,000';
    p.header.status = ExpenseStatus.paid;
    p.evidence.cashConfirmed = true;
    final copy = p.copy();
    expect(copy.guid, isNot(p.guid));
    expect(copy.header.status, ExpenseStatus.planned);
    expect(copy.evidence.cashConfirmed, isFalse);
    expect(copy.evidence.documents, isEmpty);
    expect(copy.items.first.guid, isNot(p.items.first.guid));
    expect(copy.items.first.amount, isEmpty);
  });
  test('overflow never wraps into a small amount', () {
    final p = example();
    p.items.first.amount = '9,007,199,254,740,991';
    expect(p.totalMinor, isNull);
  });
  test('category and profile defaults affect new items only', () {
    final p = example();
    p.defaults
      ..category = 'transport'
      ..profileChosen = true
      ..profileId = 3
      ..profileType = FinancialProfileType.budget
      ..profileGuid = 'portable-profile-identity';
    final added = p.addItem();
    expect(added.category, 'transport');
    expect(added.profileId, 3);
    expect(p.items.first.category, 'general');
    expect(p.items.first.profileId, isNull);
  });
}
