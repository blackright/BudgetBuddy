import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/expense.dart';
import '../models/reimbursement.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(IsarHelper.instance);
});

class ExpenseRepository {
  final Isar _isar;

  ExpenseRepository(this._isar);

  Future<void> addExpense(Expense expense) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
  }

  Future<void> updateExpense(Expense expense) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
  }

  /// Deletes an expense, flagging any reimbursement that pointed at it.
  ///
  /// The reimbursement rows survive on purpose (FR-035): their money was real, so
  /// removing them silently would erase a return from a month that is already
  /// closed. Flagging hands the decision to the user.
  Future<void> deleteExpense(int id) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.delete(id);

      final linked =
          await _isar.reimbursements.filter().expenseIdEqualTo(id).findAll();
      if (linked.isEmpty) return;
      for (final reimbursement in linked) {
        reimbursement.orphaned = true;
      }
      await _isar.reimbursements.putAll(linked);
    });
  }

  Stream<List<Expense>> watchExpenses(int profileId, String yearMonth) {
    return _isar.expenses
        .filter()
        .profileIdEqualTo(profileId)
        .and()
        .yearMonthEqualTo(yearMonth)
        .watch(fireImmediately: true);
  }

  Future<List<Expense>> getExpenses(int profileId, String yearMonth) {
    return _isar.expenses
        .filter()
        .profileIdEqualTo(profileId)
        .and()
        .yearMonthEqualTo(yearMonth)
        .findAll();
  }

  Future<Expense?> getExpense(int id) {
    return _isar.expenses.get(id);
  }

  /// Records a reimbursement for a non-medical expense.
  ///
  /// Two guarantees beyond a plain insert (FR-034):
  /// - the amount is credited to the target expense's owning month, never the
  ///   month it was recorded in (FR-032, R-5);
  /// - re-entry *replaces* rather than stacks, so one expense can never accrue
  ///   two payouts and inflate the month's returns (R-3, R-4).
  ///
  /// A `null` [Reimbursement.expenseId] is preserved as-is: that is an orphan the
  /// user has to resolve, and quietly dropping it would lose money (FR-035).
  Future<void> addReimbursement(Reimbursement reimbursement) async {
    await _isar.writeTxn(() async {
      final expenseId = reimbursement.expenseId;
      if (expenseId != null) {
        final expense = await _isar.expenses.get(expenseId);
        if (expense != null && reimbursement.originYearMonth.isEmpty) {
          reimbursement.originYearMonth = expense.yearMonth;
        }

        final existing = await _isar.reimbursements
            .filter()
            .expenseIdEqualTo(expenseId)
            .findAll();
        if (existing.isNotEmpty) {
          existing.sort((a, b) => a.id.compareTo(b.id));
          // Keep the earliest row's identity and date so the row stays stable
          // for anything watching it, and drop any duplicates behind it.
          existing.first
            ..amount = reimbursement.amount
            ..date = reimbursement.date
            ..originYearMonth = reimbursement.originYearMonth.isEmpty
                ? existing.first.originYearMonth
                : reimbursement.originYearMonth;
          reimbursement = existing.first;

          final extras = existing.skip(1).map((r) => r.id).toList();
          if (extras.isNotEmpty) {
            await _isar.reimbursements.deleteAll(extras);
          }
        }
      }
      await _isar.reimbursements.put(reimbursement);
    });
  }

  /// Reimbursements whose target expense has been deleted (FR-035).
  ///
  /// Keyed on the `orphaned` flag, which [deleteExpense] sets, rather than
  /// inferred from a dangling id: an indexed flag is queryable and survives a
  /// future id reuse, whereas re-deriving it would mean a row-by-row join on
  /// every read.
  Stream<List<Reimbursement>> watchOrphanedReimbursements() {
    return _isar.reimbursements
        .filter()
        .orphanedEqualTo(true)
        .watch(fireImmediately: true);
  }

  Future<List<Reimbursement>> getOrphanedReimbursements() {
    return _isar.reimbursements.filter().orphanedEqualTo(true).findAll();
  }

  /// Discards an orphan the user chose to remove (FR-035).
  Future<void> discardOrphanReimbursement(int id) async {
    await _isar.writeTxn(() async {
      await _isar.reimbursements.delete(id);
    });
  }

  /// Re-attaches an orphan to [expenseId] the user restored (FR-035).
  Future<void> restoreOrphanReimbursement(
    int reimbursementId,
    int expenseId,
  ) async {
    final expense = await _isar.expenses.get(expenseId);
    await _isar.writeTxn(() async {
      final reimbursement = await _isar.reimbursements.get(reimbursementId);
      if (reimbursement == null) return;
      reimbursement
        ..expenseId = expenseId
        ..orphaned = false
        ..originYearMonth = expense?.yearMonth ?? reimbursement.originYearMonth;
      await _isar.reimbursements.put(reimbursement);
    });
  }

  Stream<List<Reimbursement>> watchReimbursementsForExpense(int expenseId) {
    return _isar.reimbursements
        .filter()
        .expenseIdEqualTo(expenseId)
        .watch(fireImmediately: true);
  }

  Stream<List<Reimbursement>> watchReimbursementsForExpenses(
      List<int> expenseIds) {
    if (expenseIds.isEmpty) return Stream.value([]);
    return _isar.reimbursements
        .filter()
        .anyOf(expenseIds, (q, int id) => q.expenseIdEqualTo(id))
        .watch(fireImmediately: true);
  }

  Future<List<Reimbursement>> getReimbursementsForExpense(int expenseId) {
    return _isar.reimbursements.filter().expenseIdEqualTo(expenseId).findAll();
  }

  /// Reimbursements that *belong* to [yearMonth], regardless of when they were
  /// recorded (FR-032).
  ///
  /// Keyed on `originYearMonth` — the target expense's owning month — rather
  /// than the viewed month's expense ids, which is what stops a reimbursement
  /// recorded in a later month from going missing.
  Stream<List<Reimbursement>> watchReimbursementsForMonth(String yearMonth) {
    return _isar.reimbursements
        .filter()
        .originYearMonthEqualTo(yearMonth)
        .watch(fireImmediately: true);
  }

  Future<List<Reimbursement>> getReimbursementsForMonth(String yearMonth) {
    return _isar.reimbursements
        .filter()
        .originYearMonthEqualTo(yearMonth)
        .findAll();
  }
}
