import 'package:isar/isar.dart';

import '../../../core/providers/budget_context_provider.dart';
import '../../spaces/repositories/space_write_guard.dart';
import '../models/reimbursement.dart';

class ReimbursementRepository {
  final Isar _isar;
  final SpaceWriteGuard? _writeGuard;
  final int? _actingProfileId;

  ReimbursementRepository(
    this._isar, {
    SpaceWriteGuard? guard,
    int? actingProfileId,
  })  : _writeGuard = guard,
        _actingProfileId = actingProfileId;

  Future<void> _guardWrite(int? sharedSpaceId, String yearMonth) async {
    await _writeGuard?.assertSharedMoneyWrite(
      sharedSpaceId: sharedSpaceId,
      actingProfileId: _actingProfileId,
      yearMonth: yearMonth,
    );
  }

  /// Adds a new reimbursement.
  /// Supports multiple reimbursements per expense (Partial Reimbursements).
  Future<void> addReimbursement(Reimbursement reimbursement) async {
    await _guardWrite(
        reimbursement.sharedSpaceId, reimbursement.originYearMonth);
    await _isar.writeTxn(() async {
      await _isar.reimbursements.put(reimbursement);
    });
  }

  /// Updates an existing reimbursement.
  Future<void> updateReimbursement(Reimbursement reimbursement) async {
    await _guardWrite(
        reimbursement.sharedSpaceId, reimbursement.originYearMonth);
    await _isar.writeTxn(() async {
      await _isar.reimbursements.put(reimbursement);
    });
  }

  /// Deletes a specific reimbursement.
  Future<void> deleteReimbursement(int id) async {
    final existing = await _isar.reimbursements.get(id);
    if (existing != null) {
      await _guardWrite(existing.sharedSpaceId, existing.originYearMonth);
    }
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

  /// Reimbursements that *belong* to [context]'s month, in that context
  /// (FR-004, data-model §3.4).
  Stream<List<Reimbursement>> watchReimbursementsForContext(
      ContextRef context) {
    return _isar.reimbursements
        .filter()
        .group(
          (q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.profileIdEqualTo(context.profileKey),
        )
        .and()
        .originYearMonthEqualTo(context.yearMonth)
        .watch(fireImmediately: true);
  }

  Future<List<Reimbursement>> getReimbursementsForContext(ContextRef context) {
    return _isar.reimbursements
        .filter()
        .group(
          (q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.profileIdEqualTo(context.profileKey),
        )
        .and()
        .originYearMonthEqualTo(context.yearMonth)
        .findAll();
  }
}
