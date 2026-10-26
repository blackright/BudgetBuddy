import 'dart:io';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'support/previous_evidence_expense.dart';

void main() {
  test(
      'actual schema 28 upgrade preserves money, metadata and legacy receipt without inventing evidence',
      () async {
    await Isar.initializeIsarCore(download: false);
    final directory = await Directory.systemTemp.createTemp('phase12_upgrade_');
    var db = await Isar.open(
        [PreviousEvidenceExpenseSchema, SchemaMigrationStampSchema],
        directory: directory.path, name: 'evidence-upgrade');
    final old = PreviousEvidenceExpense(
        profileId: 1,
        yearMonth: '2026-10',
        title: 'Rice',
        amount: 10000,
        currency: 'HUF',
        categoryId: 'food',
        date: DateTime(2026, 10, 24),
        budgetId: 1)
      ..merchantName = 'Market'
      ..paymentMethod = 'cash'
      ..receiptPath = '/original/device/receipt.jpg'
      ..tags = ['food'];
    await db.writeTxn(() async {
      await db.previousEvidenceExpenses.put(old);
      await db.schemaMigrationStamps.put(SchemaMigrationStamp()
        ..key = schemaVersionKey
        ..value = '28');
    });
    await db.close();
    db = await Isar.open(
        [ExpenseSchema, ExpenseEvidenceChunkSchema, SchemaMigrationStampSchema],
        directory: directory.path, name: 'evidence-upgrade');
    try {
      await runSchemaMigrations(db);
      final row = (await db.expenses.where().findAll()).single;
      expect(row.amount, 10000);
      expect(row.currency, 'HUF');
      expect(row.syncGuid, old.syncGuid);
      expect(row.merchantName, 'Market');
      expect(row.paymentMethod, 'cash');
      expect(row.tags, ['food']);
      expect(row.receiptPath, '/original/device/receipt.jpg');
      expect(row.paymentEvidenceJson, isNull);
      expect(await db.expenseEvidenceChunks.count(), 0);
      expect(await readSchemaVersion(db), schemaVersion);
      await runSchemaMigrations(db);
      expect(await db.expenses.count(), 1);
    } finally {
      await db.close();
      await directory.delete(recursive: true);
    }
  });
}
