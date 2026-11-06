import 'dart:io';

import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../features/expenses/support/previous_purchase_expense.dart';
import '../../features/expenses/support/quantity_fixtures.dart';

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: false);
  });

  test('a pre-quantity expense reopens at quantity 1 with unchanged money',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('expense_quantity_upgrade_');
    final name =
        'expense-quantity-upgrade-${DateTime.now().microsecondsSinceEpoch}';
    var db = await Isar.open(
      [PreviousPurchaseExpenseSchema, SchemaMigrationStampSchema],
      directory: directory.path,
      name: name,
    );
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
    );
    await db.writeTxn(() => db.previousPurchaseExpenses.put(old));
    await writeSchemaVersion(db, 42);
    await db.close();

    db = await Isar.open(
      IsarHelper.schemas,
      directory: directory.path,
      name: name,
    );
    try {
      await runSchemaMigrations(db);
      final row = (await db.expenses.get(old.id))!;
      expect(row.amount, 123456789);
      expect(row.quantity, 1);
      expect(row.currency, 'huf');
      expect(row.syncGuid, old.syncGuid);
      expect(row.date, old.date);
      expect(row.status, ExpenseStatus.planned);
      expect(await readSchemaVersion(db), schemaVersion);

      await runSchemaMigrations(db);
      final again = (await db.expenses.get(old.id))!;
      expect(again.quantity, 1);
      expect(again.amount, 123456789);
    } finally {
      await db.close(deleteFromDisk: true);
      await directory.delete(recursive: true);
    }
  });

  test('step 43 normalizes an invalid stored quantity to 1', () async {
    final directory =
        await Directory.systemTemp.createTemp('expense_quantity_normalize_');
    final name =
        'expense-quantity-normalize-${DateTime.now().microsecondsSinceEpoch}';
    var db = await Isar.open(
      IsarHelper.schemas,
      directory: directory.path,
      name: name,
    );
    final invalid = quantityExpense(amount: 555, quantity: 0);
    await db.writeTxn(() => db.expenses.put(invalid));
    await writeSchemaVersion(db, 42);
    await db.close();

    db = await Isar.open(
      IsarHelper.schemas,
      directory: directory.path,
      name: name,
    );
    try {
      await runSchemaMigrations(db);
      final row = (await db.expenses.get(invalid.id))!;
      expect(row.amount, 555);
      expect(row.quantity, 1);
      expect(await readSchemaVersion(db), schemaVersion);
    } finally {
      await db.close(deleteFromDisk: true);
      await directory.delete(recursive: true);
    }
  });
}
