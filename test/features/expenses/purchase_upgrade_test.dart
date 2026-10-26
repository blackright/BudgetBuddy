import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/expense_purchase.dart';
import 'support/previous_purchase_expense.dart';

void main() {
  test('schema 29 reopens with evidence unchanged and no inferred purchases',
      () async {
    await Isar.initializeIsarCore(download: false);
    final dir = await Directory.systemTemp.createTemp('purchase_upgrade_');
    var db = await Isar.open(
        [PreviousPurchaseExpenseSchema, SchemaMigrationStampSchema],
        directory: dir.path, name: 'purchase-upgrade');
    const manifest =
        '{"version":1,"profileChosen":true,"documents":[],"cashActor":null,"cashAt":null,"cashFingerprint":null}';
    final old = PreviousPurchaseExpense(
        profileId: 7,
        yearMonth: '2026-10',
        title: 'Existing',
        amount: 123456789,
        currency: 'huf',
        categoryId: 'food',
        status: ExpenseStatus.planned,
        date: DateTime(2026, 10, 24),
        budgetId: 9,
        merchantName: 'Market',
        paymentMethod: 'cash',
        paymentEvidenceJson: manifest);
    await db.writeTxn(() async {
      await db.previousPurchaseExpenses.put(old);
    });
    await writeSchemaVersion(db, 29);
    await db.close();
    db = (await Isar.open(
        [ExpenseSchema, ExpensePurchaseSchema, SchemaMigrationStampSchema],
        directory: dir.path, name: 'purchase-upgrade'));
    try {
      await runSchemaMigrations(db);
      final row = (await db.expenses.get(old.id))!;
      expect(row.amount, 123456789);
      expect(row.currency, 'huf');
      expect(row.syncGuid, old.syncGuid);
      expect(row.paymentEvidenceJson, manifest);
      expect(row.date, old.date);
      expect(row.purchaseSyncGuid, isNull);
      expect(row.purchaseEvidenceOwnerGuid, isNull);
      expect(await db.expensePurchases.count(), 0);
      expect(await readSchemaVersion(db), schemaVersion);
    } finally {
      await db.close(deleteFromDisk: true);
      await dir.delete(recursive: true);
    }
  });
}
