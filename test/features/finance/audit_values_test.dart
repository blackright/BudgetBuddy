import 'package:budget_buddy/features/finance/presentation/audit_values.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'dart:convert';
import 'package:budget_buddy/features/vault/presentation/vault_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'payment evidence uses readable file labels without exposing manifest JSON',
      () async {
    final prepared = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'Invoice.pdf', role: 'receipt');
    final row = AuditEvent()
      ..objectType = 'Expense'
      ..newValue = jsonEncode({
        'paymentEvidenceJson':
            ExpenseEvidence(profileChosen: true, documents: [prepared.document])
                .encode()
      });
    final field = auditFieldChanges(row).single;
    expect(field.label, 'Payment evidence');
    expect(field.after, 'Receipt: Invoice.pdf');
    expect(field.after, isNot(contains(prepared.document.guid)));
  });
  test(
      'structured changes prioritise changed fields without modifying evidence',
      () {
    final row = AuditEvent()
      ..objectType = 'Expense'
      ..previousValue =
          '{"amount":1000,"currency":"huf","title":"Lunch","notes":"old","status":0}'
      ..newValue =
          '{"amount":2000,"currency":"huf","title":"Lunch","notes":null,"status":1}';
    final original = row.newValue;
    final fields = auditFieldChanges(row);
    expect(fields.singleWhere((e) => e.key == 'amount').before, 'Ft 1,000');
    expect(fields.singleWhere((e) => e.key == 'amount').after, 'Ft 2,000');
    expect(fields.singleWhere((e) => e.key == 'status').after, 'Paid');
    expect(fields.singleWhere((e) => e.key == 'notes').after, 'Not recorded');
    expect(fields.singleWhere((e) => e.key == 'title').changed, isFalse);
    expect(fields.singleWhere((e) => e.key == 'amount').section, 'Money');
    expect(row.newValue, original);
  });
  test('original expense currency is kept separate from context currency', () {
    final row = AuditEvent()
      ..objectType = 'Expense'
      ..previousValue =
          '{"amount":100,"currency":"eur","contextCurrency":"huf"}'
      ..newValue = '{"amount":100,"currency":"usd","contextCurrency":"huf"}';
    final amount = auditFieldChanges(row).singleWhere((e) => e.key == 'amount');
    expect(amount.before, contains('1.00'));
    expect(amount.before, contains('€'));
    expect(amount.after, contains(r'$'));
    expect(amount.changed, isTrue);
    expect(auditHeadlineAmount(row), isNot(contains('Ft')));
    row.newValue = '{"amount":100,"currency":"XYZ","contextCurrency":"huf"}';
    expect(auditFieldChanges(row).singleWhere((e) => e.key == 'amount').after,
        contains('XYZ (original minor units)'));
    expect(auditHeadlineAmount(row), isNull);
  });
  test('creation deletion legacy unknown enums and dates remain explicit', () {
    final row = AuditEvent()
      ..objectType = 'Expense'
      ..newValue = jsonEncode({
        'date': DateTime.utc(2026, 10, 24).microsecondsSinceEpoch,
        'paidAt': DateTime.utc(2026, 10, 24).microsecondsSinceEpoch,
        'financialProfileType': 'budget',
        'type': 0,
        'guiltLevel': 0,
        'status': 999,
        'syncGuid': 'private-reference'
      });
    var fields = auditFieldChanges(row);
    expect(fields.any((e) => e.key == 'syncGuid'), isFalse);
    expect(
        fields.singleWhere((e) => e.key == 'date').after, contains('Oct 2026'));
    expect(fields.singleWhere((e) => e.key == 'date').after,
        isNot(contains('00:00')));
    expect(fields.singleWhere((e) => e.key == 'financialProfileType').after,
        'Budget profile');
    expect(fields.singleWhere((e) => e.key == 'type').after, 'Standard');
    expect(fields.singleWhere((e) => e.key == 'status').after,
        '999 (needs review)');
    row
      ..previousValue = '{"title":"Deleted"}'
      ..newValue = null;
    expect(auditFieldChanges(row).single.after, 'Removed');
    row
      ..previousValue = 'Old salary'
      ..newValue = 'New salary';
    fields = auditFieldChanges(row);
    expect(fields.single.before, 'Old salary');
    expect(fields.single.after, 'New salary');
  });
  test('unknown invalid money cannot appear as a confirmed headline', () {
    final row = AuditEvent()
      ..objectType = 'Expense'
      ..newValue = '{"amount":-9223372036854775808,"currency":"huf"}';
    expect(auditHeadlineAmount(row), isNull);
    expect(auditFieldChanges(row).singleWhere((e) => e.key == 'amount').after,
        contains('original invalid value'));
  });
  test('income calendar dates and recording timestamps have distinct displays',
      () {
    final time = DateTime.utc(2026, 10, 24, 12, 34);
    final row = AuditEvent()
      ..objectType = 'IncomeSource'
      ..newValue = jsonEncode({
        'startDate': time.microsecondsSinceEpoch,
        'endDate': '2026-12-01T00:00:00.000Z',
        'createdAt': time.microsecondsSinceEpoch,
        'type': 0,
        'frequency': 2,
      });
    final fields = auditFieldChanges(row);
    expect(fields.singleWhere((e) => e.key == 'startDate').after,
        isNot(contains('12:34')));
    expect(fields.singleWhere((e) => e.key == 'createdAt').after,
        formatVaultTime(time));
    expect(fields.singleWhere((e) => e.key == 'endDate').after,
        contains('Dec 2026'));
    expect(fields.singleWhere((e) => e.key == 'type').after, 'Salary');
    expect(fields.singleWhere((e) => e.key == 'frequency').after, 'Monthly');
  });
  test(
      'native and web date precision give the same local time without changing evidence',
      () {
    final time = DateTime.utc(2026, 10, 24, 12, 34, 56);
    for (final value in [
      time.microsecondsSinceEpoch,
      time.millisecondsSinceEpoch
    ]) {
      final text =
          formatAuditValues(jsonEncode({'date': value, 'paidAt': value}));
      expect(text, contains('Date: ${formatVaultTime(time)}'));
      expect(text, contains('Paid at: ${formatVaultTime(time)}'));
    }
    expect(formatAuditValues('{"paidAt":-9223372036854775808}'),
        contains('date needs review'));
    expect(formatAuditValues('{"paidAt":null}'), contains('No value'));
  });
  test('friendly actions cover financial records without exposing dotted codes',
      () {
    expect(auditActionLabel('Expense.refund'), 'Expense refunded');
    expect(auditActionLabel('income.update'), 'Income updated');
    expect(
        auditActionLabel('budgetprofile.move.out'), 'Budget profile moved out');
    expect(auditActionLabel('sharedmember.update'), 'Member updated');
    expect(auditActionLabel('vault.withdrawal.create'), 'Savings withdrawn');
    expect(auditActionLabel('month.end'), 'Month-End completed');
    expect(auditActionLabel('future.action_name'), 'Future action name');
  });
  test('currency values uppercase; references stay out of business details',
      () {
    const original = '{"contextCurrency":"huf","currency":"eur",'
        '"refundSyncGuid":"refund-long-reference","reportJson":'
        '"{\\"currency\\":\\"usd\\",\\"sourceSyncGuid\\":\\"source-reference\\"}"}';
    final text = formatAuditValues(original);
    expect(text, contains('Context currency: HUF'));
    expect(text, contains('Currency: EUR'));
    expect(text, contains('Currency: USD'));
    expect(text, isNot(contains('reference')));
    expect(original, contains('"huf"'));
  });
  test('record labels use names saved in evidence including deletions', () {
    final row = AuditEvent()
      ..objectType = 'Expense'
      ..previousValue = '{"title":"Old groceries"}'
      ..newValue = '{"title":"Groceries"}';
    expect(auditObjectName(row), 'Groceries');
    row.newValue = null;
    expect(auditObjectName(row), 'Old groceries');
    row.previousValue = '{"amount":100}';
    expect(auditObjectName(row), 'Expense');
  });
  test(
      'original amounts use grouping and accounting currency without exposing local IDs',
      () {
    final text = formatAuditValues(
        '{"accountingCurrency":"huf","allocation":1000000,"profileId":42,"id":9}');
    expect(text, contains('Ft 1,000,000'));
    expect(text, isNot(contains('profileId')));
    expect(text, isNot(contains('42')));
  });
  test('invalid original value is evidence, never formatted as confirmed money',
      () {
    final text =
        formatAuditValues('{"currency":"huf","amount":-9223372036854775808}');
    expect(text, contains('original invalid value'));
    expect(text, isNot(contains('Ft')));
  });
  test(
      'roles and expense statuses are readable and legacy strings remain readable',
      () {
    expect(formatAuditValues('{"role":1}', objectType: 'SharedMember'),
        contains('editor'));
    expect(formatAuditValues('{"status":1}', objectType: 'Expense'),
        contains('paid'));
    expect(formatAuditValues('Old salary'), 'Old salary');
  });
}
