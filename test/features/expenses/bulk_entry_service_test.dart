import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/services/bulk_entry_service.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cryptography/dart.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';

BulkExpenseDraft readyBulkRow() => addBulkTestProof(BulkExpenseDraft()
  ..title = 'Lunch'
  ..amount = '1,234.56'
  ..currency = 'USD'
  ..merchant = ' Cafe '
  ..category = 'food'
  ..payment = 'card'
  ..profileChosen = true
  ..date = DateTime(2026, 10, 4)
  ..status = ExpenseStatus.paid);

BulkExpenseDraft addBulkTestProof(BulkExpenseDraft row) {
  final bytes = Uint8List.fromList(base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4//8/AAX+Av4N70a4AAAAAElFTkSuQmCC'));
  final hash = const DartSha256()
      .hashSync(bytes)
      .bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  for (final role in ['receipt', 'payment']) {
    final doc = EvidenceDocument(
        guid: newSyncGuid(),
        role: role,
        name: '$role.png',
        mediaType: 'image/png',
        length: bytes.length,
        hash: hash);
    row.evidence.documents.add(doc);
    row.evidence.prepared[doc.guid] = PreparedEvidence(doc, bytes);
  }
  row.evidence.changed = true;
  return row;
}

void main() {
  const service = BulkEntryService();
  test('required fields and exact currency precision are validated per row',
      () {
    expect(
        service.validate(BulkExpenseDraft(), '2026-10').keys,
        containsAll([
          'name',
          'amount',
          'currency',
          'merchant',
          'category',
          'payment',
          'profile',
          'date'
        ]));
    final row = readyBulkRow();
    expect(service.validate(row, '2026-10'), isEmpty);
    row.currency = 'HUF';
    expect(service.validate(row, '2026-10'), contains('amount'));
    row.amount = '1,000,000';
    expect(service.validate(row, '2026-10'), isEmpty);
    row.amount = '9,007,199,254,740,992';
    expect(service.validate(row, '2026-10'), contains('amount'));
    row.amount = '0';
    expect(service.validate(row, '2026-10'), contains('amount'));
  });
  test('date boundary, profile type and method cannot be guessed', () {
    final row = readyBulkRow()
      ..date = DateTime(2026, 11, 1)
      ..profileId = 1
      ..payment = 'unknown';
    expect(service.validate(row, '2026-10').keys,
        containsAll(['date', 'profile', 'payment']));
    row
      ..date = DateTime(2026, 10, 31)
      ..profileType = FinancialProfileType.direct
      ..profileGuid = 'direct'
      ..payment = 'cash';
    row.evidence.cashConfirmed = true;
    expect(service.validate(row, '2026-10'), isEmpty);
  });
  test('copy has new identity and never inherits amount, paid or saved state',
      () {
    final original = readyBulkRow()..saved = true;
    final copy = original.copy();
    expect(copy.guid, isNot(original.guid));
    expect(copy.amount, isEmpty);
    expect(copy.saved, isFalse);
    expect(copy.status, ExpenseStatus.planned);
    expect(copy.evidence.documents, isEmpty);
    expect(copy.evidence.cashConfirmed, isFalse);
    expect(copy.merchant, original.merchant);
    expect(copy.profileChosen, isTrue);
    final defaults = original.copy(includeDetails: false);
    expect(defaults.merchant, isEmpty);
    expect(defaults.title, isEmpty);
  });
  test(
      'construction keeps exact amount, purchase date, metadata and stable GUID',
      () {
    final row = readyBulkRow()
      ..notes = 'meeting'
      ..tags = 'office, office';
    final expense = service.expense(row,
        owner: 1, space: null, month: '2026-10', budget: 2);
    expect(expense.amount, 123456);
    expect(expense.date, DateTime(2026, 10, 4));
    expect(expense.paidAt, expense.date);
    expect(expense.syncGuid, row.guid);
    expect(expense.tags, ['office']);
    expect(expense.merchantName, 'Cafe');
  });
}
