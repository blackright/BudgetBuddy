import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/network/exchange_rate_cache.dart';
import '../../../core/models/expense.dart';
import '../models/reimbursement.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(
    IsarHelper.instance,
    ref.watch(exchangeRateCacheProvider),
  );
});

class ExpenseRepository {
  final Isar _isar;
  final ExchangeRateCache _cache;

  ExpenseRepository(this._isar, this._cache);

  Future<void> addExpense(Expense expense, String primaryCurrency) async {
    final rate = await _cache.getRate(expense.currency, primaryCurrency);
    expense.exchangeRateToPrimary = rate;

    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
  }

  Future<void> updateExpense(Expense expense, String primaryCurrency) async {
    // Usually exchange rate is locked in at creation, but if currency changes, we update it.
    final rate = await _cache.getRate(expense.currency, primaryCurrency);
    expense.exchangeRateToPrimary = rate;

    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
  }

  Future<void> deleteExpense(int id) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.delete(id);
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

  Future<void> addReimbursement(Reimbursement reimbursement) async {
    await _isar.writeTxn(() async {
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
}
