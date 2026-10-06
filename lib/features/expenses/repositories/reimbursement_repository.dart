import 'package:isar/isar.dart';

import '../../../core/network/exchange_rate_cache.dart';
import '../models/reimbursement.dart';

class ReimbursementRepository {
  final Isar _isar;
  final ExchangeRateCache _cache;

  ReimbursementRepository(this._isar, this._cache);

  /// Adds a new reimbursement. 
  /// Supports multiple reimbursements per expense (Partial Reimbursements).
  Future<void> addReimbursement(Reimbursement reimbursement, String primaryCurrency) async {
    final rate = await _cache.getRate(reimbursement.currency, primaryCurrency);
    reimbursement.exchangeRateToPrimary = rate;

    await _isar.writeTxn(() async {
      await _isar.reimbursements.put(reimbursement);
    });
  }

  /// Updates an existing reimbursement.
  Future<void> updateReimbursement(Reimbursement reimbursement, String primaryCurrency) async {
    final rate = await _cache.getRate(reimbursement.currency, primaryCurrency);
    reimbursement.exchangeRateToPrimary = rate;

    await _isar.writeTxn(() async {
      await _isar.reimbursements.put(reimbursement);
    });
  }

  /// Deletes a specific reimbursement.
  Future<void> deleteReimbursement(int id) async {
    await _isar.writeTxn(() async {
      await _isar.reimbursements.delete(id);
    });
  }

  /// Watch all reimbursements for a specific expense.
  Stream<List<Reimbursement>> watchReimbursementsForExpense(int expenseId) {
    return _isar.reimbursements
        .filter()
        .expenseIdEqualTo(expenseId)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  /// Get all reimbursements for a specific expense.
  Future<List<Reimbursement>> getReimbursementsForExpense(int expenseId) {
    return _isar.reimbursements
        .filter()
        .expenseIdEqualTo(expenseId)
        .sortByDateDesc()
        .findAll();
  }

  /// Reimbursements that *belong* to [yearMonth].
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
