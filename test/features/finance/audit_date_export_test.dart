import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'dart:convert';
import 'package:budget_buddy/features/finance/presentation/audit_values.dart';
import 'package:budget_buddy/features/vault/presentation/vault_time.dart';

void main() {
  test('native audit snapshots export dates as epoch microseconds', () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);
    final time = DateTime.utc(2026, 10, 24, 12, 34, 56, 789);
    final expense = Expense(
        profileId: 1,
        yearMonth: '2026-10',
        title: 'Date check',
        amount: 100,
        currency: 'huf',
        categoryId: 'general',
        date: time,
        paidAt: time,
        budgetId: 1);
    await harness.isar.writeTxn(() async {
      await harness.isar.expenses.put(expense);
    });
    final snapshot = await AuditRepository(harness.isar)
        .snapshot(harness.isar.expenses, expense.id);
    expect(snapshot!['date'], time.microsecondsSinceEpoch);
    expect(snapshot['paidAt'], time.microsecondsSinceEpoch);
    final original = jsonEncode(snapshot);
    final displayed = formatAuditValues(original, objectType: 'Expense');
    expect(displayed, contains('Date: ${formatVaultTime(time)}'));
    expect(displayed, contains('Paid at: ${formatVaultTime(time)}'));
    expect(jsonEncode(snapshot), original);
  });
}
