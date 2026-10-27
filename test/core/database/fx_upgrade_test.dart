import 'package:budget_buddy/core/models/app_settings.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import '../../features/expenses/support/previous_purchase_expense.dart';

void main() {
  test(
      'pre-FX native schema reopens at 32 without booking or changing legacy money',
      () async {
    await Isar.initializeIsarCore(download: false);
    final directory = await Directory.systemTemp.createTemp('fx_upgrade_');
    var db = await Isar.open(
        [PreviousPurchaseExpenseSchema, SchemaMigrationStampSchema],
        directory: directory.path, name: 'fx-upgrade');
    final old = PreviousPurchaseExpense(
        profileId: 7,
        budgetId: 9,
        yearMonth: '2026-01',
        title: 'Legacy payment',
        amount: 123456789,
        currency: 'eur',
        categoryId: 'food',
        date: DateTime(2026, 1, 3),
        status: ExpenseStatus.paid,
        merchantName: 'Market');
    await db.writeTxn(() => db.previousPurchaseExpenses.put(old));
    await writeSchemaVersion(db, 30);
    await db.close();
    db = await Isar.open(
        [AppSettingsSchema, ExpenseSchema, SchemaMigrationStampSchema],
        directory: directory.path, name: 'fx-upgrade');
    try {
      await runSchemaMigrations(db);
      await runSchemaMigrations(db);
      final row = (await db.expenses.get(old.id))!;
      expect(row.fxHistoryJson, isNull);
      expect(row.amount, old.amount);
      expect(row.currency, 'eur');
      expect(row.syncGuid, old.syncGuid);
      expect(row.date, old.date);
      expect(row.status, ExpenseStatus.paid);
      expect(row.merchantName, 'Market');
      expect(await readSchemaVersion(db), 32);
      await db.close();
      db = await Isar.open(
          [AppSettingsSchema, ExpenseSchema, SchemaMigrationStampSchema],
          directory: directory.path, name: 'fx-upgrade');
      expect((await db.expenses.get(old.id))!.fxHistoryJson, isNull);
    } finally {
      await db.close(deleteFromDisk: true);
      // Only this test-created, verified temporary directory is removed.
      expect(directory.path, contains('fx_upgrade_'));
      await directory.delete(recursive: true);
    }
  });
}
