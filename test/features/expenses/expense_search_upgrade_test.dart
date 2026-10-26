import 'dart:io';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'support/previous_search_expense.dart';

void main() {
  test(
      'actual schema 27 reopen adds unknown metadata without altering money/date/identity',
      () async {
    await Isar.initializeIsarCore(download: false);
    final dir = await Directory.systemTemp.createTemp('phase10_upgrade_');
    var db = await Isar.open(
        [PreviousSearchExpenseSchema, SchemaMigrationStampSchema],
        directory: dir.path, name: 'search-upgrade');
    final date = DateTime.utc(2026, 1, 2, 3, 4);
    final old = PreviousSearchExpense(
        profileId: 1,
        yearMonth: '2026-01',
        title: 'Original',
        amount: 100001,
        currency: 'eur',
        categoryId: 'food',
        date: date,
        budgetId: 1)
      ..notes = 'Keep this note';
    final guid = old.syncGuid;
    await db.writeTxn(() async {
      await db.previousSearchExpenses.put(old);
      await db.schemaMigrationStamps.put(SchemaMigrationStamp()
        ..key = schemaVersionKey
        ..value = '27');
    });
    await db.close();
    db = await Isar.open([ExpenseSchema, SchemaMigrationStampSchema],
        directory: dir.path, name: 'search-upgrade');
    try {
      await runSchemaMigrations(db);
      final row = (await db.expenses.where().findAll()).single;
      expect(row.amount, 100001);
      expect(row.currency, 'eur');
      expect(row.notes, 'Keep this note');
      expect(row.date.toUtc(), date);
      expect(row.syncGuid, guid);
      expect(row.merchantSyncGuid, isNull);
      expect(row.merchantName, isNull);
      expect(row.paymentMethod, isNull);
      expect(row.tags, isEmpty);
      expect(await readSchemaVersion(db), schemaVersion);
      await runSchemaMigrations(db);
      expect(await db.expenses.count(), 1);
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });
}
