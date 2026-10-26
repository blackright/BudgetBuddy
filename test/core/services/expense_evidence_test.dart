import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

Expense purchase({ExpenseStatus status = ExpenseStatus.paid}) => Expense(
    profileId: 1,
    yearMonth: '2026-10',
    title: 'Rice',
    amount: 10000,
    currency: 'HUF',
    categoryId: 'food',
    date: DateTime(2026, 10, 24),
    budgetId: 1,
    merchantName: 'Market',
    paymentMethod: 'cash',
    status: status);

void main() {
  test('currency casing alone is not a legacy financial change', () {
    final old = purchase()..currency = 'huf';
    final next = old.copyForEditing()
      ..currency = 'HUF'
      ..notes = 'Corrected';
    expect(expenseEvidenceProblems(next, previous: old), isEmpty);
  });
  test('editing copies cannot alter the live expense before a successful save',
      () {
    final original = purchase()..tags = ['original'];
    final draft = original.copyForEditing()..amount = 123;
    draft.tags.add('new');
    expect(original.amount, 10000);
    expect(original.tags, ['original']);
    expect(draft.syncGuid, original.syncGuid);
    expect(draft.id, original.id);
  });
  test('decoded document value identity stays stable across widget rebuilds',
      () async {
    final prepared = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'Receipt.pdf', role: 'receipt');
    final decoded = ExpenseEvidence.decode(
        ExpenseEvidence(profileChosen: true, documents: [prepared.document])
            .encode())!;
    expect(decoded.documents.single, prepared.document);
    expect(decoded.documents.single.hashCode, prepared.document.hashCode);
  });
  test(
      'legacy notes correction does not invent proof; changed amount requires it',
      () {
    final old = purchase();
    final next = purchase()..notes = 'Corrected note';
    expect(expenseEvidenceProblems(next, previous: old), isEmpty);
    next.amount++;
    expect(expenseEvidenceProblems(next, previous: old),
        contains('Add the merchant receipt or invoice.'));
  });
  test('new Planned needs explicit profile metadata but no receipt', () {
    final next = purchase(status: ExpenseStatus.planned);
    expect(
        expenseEvidenceProblems(next), contains('Choose a financial profile.'));
    next.paymentEvidenceJson =
        const ExpenseEvidence(profileChosen: true).encode();
    expect(expenseEvidenceProblems(next), isEmpty);
  });
  test('cash declaration is specific to the confirmed purchase', () async {
    final next = purchase();
    final file = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'receipt.pdf', role: 'receipt');
    next.paymentEvidenceJson = ExpenseEvidence(
            profileChosen: true,
            documents: [file.document],
            cashActor: 'actor',
            cashAt: DateTime.now(),
            cashFingerprint: cashPaymentFingerprint(next))
        .encode();
    expect(expenseEvidenceProblems(next), isEmpty);
    next.amount++;
    expect(expenseEvidenceProblems(next),
        contains('Confirm that you paid this purchase in cash.'));
  });
  test('card requires separate screenshot; bank transfer accepts PDF proof',
      () async {
    final receipt = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'receipt.pdf', role: 'receipt');
    final proof = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 50], name: 'transfer.pdf', role: 'payment');
    final next = purchase()
      ..paymentMethod = 'card'
      ..paymentEvidenceJson = ExpenseEvidence(
          profileChosen: true,
          documents: [receipt.document, proof.document]).encode();
    expect(expenseEvidenceProblems(next),
        contains('Add a separate card-payment screenshot.'));
    next.paymentMethod = 'bankTransfer';
    expect(expenseEvidenceProblems(next), isEmpty);
  });
  test('rejects unsupported, empty and oversized content', () async {
    await expectLater(
        prepareEvidence(bytes: [], name: 'empty.pdf', role: 'receipt'),
        throwsFormatException);
    await expectLater(
        prepareEvidence(bytes: [1, 2, 3], name: 'fake.png', role: 'receipt'),
        throwsFormatException);
    await expectLater(
        prepareEvidence(
            bytes: List.filled(evidenceMaximumBytes + 1, 1),
            name: 'large.jpg',
            role: 'receipt'),
        throwsFormatException);
  });
}
