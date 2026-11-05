import 'merchant_repository.dart';
import 'expense_evidence_repository.dart';
import '../../finance/repositories/audit_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../spaces/repositories/space_write_guard.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../models/reimbursement.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(
    IsarHelper.instance,
    guard: ref.watch(spaceWriteGuardProvider),
    actingProfileId: ref.watch(actingProfileIdProvider),
    syncRecorder: ref.watch(syncRecorderProvider),
  );
});

class ExpenseRepository {
  final Isar _isar;
  final SpaceWriteGuard? _writeGuard;
  final int? _actingProfileId;

  /// Appends a signed change for a paired shared context on every write
  /// (FR-006). Optional and inert when no signer/identity is attached.
  final SyncRecorder? _syncRecorder;

  ExpenseRepository(
    this._isar, {
    SpaceWriteGuard? guard,
    int? actingProfileId,
    SyncRecorder? syncRecorder,
  })  : _writeGuard = guard,
        _actingProfileId = actingProfileId,
        _syncRecorder = syncRecorder;

  /// Refuses a shared write the acting profile has no right to make (role +
  /// sealed month). Personal writes (`null` space) pass through.
  Future<void> _guardWrite(int? sharedSpaceId, String yearMonth) async {
    await _writeGuard?.assertSharedMoneyWrite(
      sharedSpaceId: sharedSpaceId,
      actingProfileId: _actingProfileId,
      yearMonth: yearMonth,
    );
  }

  Future<void> addExpense(Expense expense) async {
    AppLogger.expenseRepo(
        'ADD_EXPENSE_START id=${expense.id} profileId=${expense.profileId} sharedSpaceId=${expense.sharedSpaceId} yearMonth=${expense.yearMonth} amount=${expense.amount} currency=${expense.currency} status=${expense.status} categoryId=${expense.categoryId} type=${expense.type} title=${expense.title}');
    await _guardWrite(expense.sharedSpaceId, expense.yearMonth);
    await _isar.writeTxn(() async {
      await MerchantRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .bindExpenseInTxn(expense);
      await ExpenseEvidenceRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .saveInTxn(expense);
      await AuditRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .put(_isar.expenses, expense, id: expense.id, type: 'Expense');
      await _syncRecorder?.recordExpense(expense);
    });
    AppLogger.expenseRepo(
        'ADD_EXPENSE_DONE id=${expense.id} profileId=${expense.profileId} sharedSpaceId=${expense.sharedSpaceId} yearMonth=${expense.yearMonth} amount=${expense.amount} currency=${expense.currency} status=${expense.status}');
  }

  Future<void> updateExpense(Expense expense) async {
    AppLogger.expenseRepo(
        'UPDATE_EXPENSE_START id=${expense.id} profileId=${expense.profileId} sharedSpaceId=${expense.sharedSpaceId} yearMonth=${expense.yearMonth} amount=${expense.amount} currency=${expense.currency} status=${expense.status}');
    await _guardWrite(expense.sharedSpaceId, expense.yearMonth);
    await _isar.writeTxn(() async {
      final previous = await _isar.expenses.get(expense.id);
      if (previous == null) throw StateError('Expense no longer exists.');
      AppLogger.expenseRepo(
          'UPDATE_EXPENSE_PREV id=${previous.id} amount=${previous.amount} status=${previous.status} yearMonth=${previous.yearMonth}');
      if (expense.merchantName != previous.merchantName ||
          expense.merchantSyncGuid != previous.merchantSyncGuid) {
        await MerchantRepository(_isar,
                recorder: _syncRecorder, actorId: _actingProfileId)
            .bindExpenseInTxn(expense);
      }
      await ExpenseEvidenceRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .saveInTxn(expense, previous: previous);
      await AuditRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .put(_isar.expenses, expense, id: expense.id, type: 'Expense');
      await _syncRecorder?.recordExpense(expense);
    });
    AppLogger.expenseRepo(
        'UPDATE_EXPENSE_DONE id=${expense.id} amount=${expense.amount} status=${expense.status}');
  }

  /// Deletes an expense, flagging any reimbursement that pointed at it.
  ///
  /// The reimbursement rows survive on purpose (FR-035): their money was real, so
  /// removing them silently would erase a return from a month that is already
  /// closed. Flagging hands the decision to the user.
  Future<void> deleteExpense(int id) async {
    AppLogger.expenseRepo('DELETE_EXPENSE_START id=$id');
    final existing = await _isar.expenses.get(id);
    if (existing != null) {
      AppLogger.expenseRepo(
          'DELETE_EXPENSE_EXISTING id=${existing.id} amount=${existing.amount} status=${existing.status} yearMonth=${existing.yearMonth} profileId=${existing.profileId} sharedSpaceId=${existing.sharedSpaceId}');
      await _guardWrite(existing.sharedSpaceId, existing.yearMonth);
    }
    await _isar.writeTxn(() async {
      final current = await _isar.expenses.get(id);
      if (current?.purchaseSyncGuid != null) {
        throw StateError('Open the purchase to remove all its items together.');
      }
      await AuditRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .remove(_isar.expenses, id, type: 'Expense');
      if (existing != null) {
        await _syncRecorder?.recordExpenseRemoved(existing);
      }

      final linked =
          await _isar.reimbursements.filter().expenseIdEqualTo(id).findAll();
      AppLogger.expenseRepo(
          'DELETE_EXPENSE_ORPHAN_CHECK id=$id linkedReimbursements=${linked.length}');
      if (linked.isEmpty) return;
      for (final reimbursement in linked) {
        reimbursement.orphaned = true;
      }
      await _isar.reimbursements.putAll(linked);
      for (final reimbursement in linked) {
        await _syncRecorder?.recordReimbursement(reimbursement);
      }
    });
    AppLogger.expenseRepo('DELETE_EXPENSE_DONE id=$id');
  }

  Stream<List<Expense>> watchExpenses(int profileId, String yearMonth) {
    return _isar.expenses
        .filter()
        .profileIdEqualTo(profileId)
        .and()
        .yearMonthEqualTo(yearMonth)
        .watch(fireImmediately: true);
  }

  /// Expenses belonging to [context]'s month — the context-scoped route every
  /// feature read resolves through (FR-004, context-router §4-I3).
  Stream<List<Expense>> watchExpensesForContext(ContextRef context) {
    return _isar.expenses
        .filter()
        .group(
          (q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.profileIdEqualTo(context.profileKey),
        )
        .and()
        .yearMonthEqualTo(context.yearMonth)
        .watch(fireImmediately: true);
  }

  /// Expenses whose actual cash month is [context]'s month.
  ///
  /// Only rows with an explicit override appear here; a null override keeps the
  /// legacy service-month behavior in [watchExpensesForContext].
  Stream<List<Expense>> watchExpensesByCashMonth(ContextRef context) {
    return _isar.expenses
        .filter()
        .group(
          (q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.profileIdEqualTo(context.profileKey),
        )
        .and()
        .cashYearMonthEqualTo(context.yearMonth)
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

  /// One-shot variant of [watchExpensesForContext].
  Future<List<Expense>> getExpensesForContext(ContextRef context) {
    return _isar.expenses
        .filter()
        .group(
          (q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.profileIdEqualTo(context.profileKey),
        )
        .and()
        .yearMonthEqualTo(context.yearMonth)
        .findAll();
  }

  Future<Expense?> getExpense(int id) {
    return _isar.expenses.get(id);
  }

  /// Reactive [Expense]s for the given [ids], keyed on the id alone.
  ///
  /// Used to classify this month's reimbursements by their *target's* kind
  /// (US8): a payout credited next month keeps its bill in the previous month,
  /// so the target is not in the month's own expense list. An empty list
  /// resolves to an empty stream rather than a query that matches everything.
  Stream<List<Expense>> watchExpensesByIds(List<int> ids) {
    if (ids.isEmpty) return Stream.value(const []);
    return _isar.expenses
        .filter()
        .anyOf(ids, (q, int id) => q.idEqualTo(id))
        .watch(fireImmediately: true);
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
    AppLogger.expenseRepo(
        'ADD_REIMBURSEMENT_START expenseId=${reimbursement.expenseId} amount=${reimbursement.amount} currency=${reimbursement.currency} originYearMonth=${reimbursement.originYearMonth} date=${reimbursement.date}');
    var yearMonth = reimbursement.originYearMonth;
    final preExpenseId = reimbursement.expenseId;
    if (yearMonth.isEmpty && preExpenseId != null) {
      final pre = await _isar.expenses.get(preExpenseId);
      yearMonth = pre?.yearMonth ?? '';
    }
    await _guardWrite(reimbursement.sharedSpaceId, yearMonth);
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
        AppLogger.expenseRepo(
            'ADD_REIMBURSEMENT_EXISTING_FOR_EXPENSE expenseId=$expenseId count=${existing.length}');
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
            AppLogger.expenseRepo(
                'ADD_REIMBURSEMENT_COLLAPSE expenseId=$expenseId droppingExtras=${extras.length}');
            await _isar.reimbursements.deleteAll(extras);
          }
        }
      }
      await AuditRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .put(_isar.reimbursements, reimbursement,
              id: reimbursement.id, type: 'Reimbursement');
      await _syncRecorder?.recordReimbursement(reimbursement);
    });
    AppLogger.expenseRepo(
        'ADD_REIMBURSEMENT_DONE expenseId=${reimbursement.expenseId} amount=${reimbursement.amount} originYearMonth=${reimbursement.originYearMonth}');
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
    AppLogger.expenseRepo('DISCARD_ORPHAN_REIMBURSEMENT_START id=$id');
    final existing = await _isar.reimbursements.get(id);
    if (existing != null) {
      AppLogger.expenseRepo(
          'DISCARD_ORPHAN_REIMBURSEMENT_EXISTING id=${existing.id} amount=${existing.amount} expenseId=${existing.expenseId} orphaned=${existing.orphaned}');
      await _guardWrite(existing.sharedSpaceId, existing.originYearMonth);
    }
    await _isar.writeTxn(() async {
      await _isar.reimbursements.delete(id);
      if (existing != null) {
        await _syncRecorder?.recordReimbursementRemoved(existing);
      }
    });
    AppLogger.expenseRepo('DISCARD_ORPHAN_REIMBURSEMENT_DONE id=$id');
  }

  /// Re-attaches an orphan to [expenseId] the user restored (FR-035).
  Future<void> restoreOrphanReimbursement(
    int reimbursementId,
    int expenseId,
  ) async {
    AppLogger.expenseRepo(
        'RESTORE_ORPHAN_REIMBURSEMENT_START reimbursementId=$reimbursementId expenseId=$expenseId');
    final expense = await _isar.expenses.get(expenseId);
    final existing = await _isar.reimbursements.get(reimbursementId);
    if (existing != null) {
      await _guardWrite(
        existing.sharedSpaceId,
        expense?.yearMonth ?? existing.originYearMonth,
      );
    }
    await _isar.writeTxn(() async {
      final reimbursement = await _isar.reimbursements.get(reimbursementId);
      if (reimbursement == null) {
        AppLogger.expenseRepo(
            'RESTORE_ORPHAN_REIMBURSEMENT_MISSING reimbursementId=$reimbursementId');
        return;
      }
      AppLogger.expenseRepo(
          'RESTORE_ORPHAN_REIMBURSEMENT_BEFORE reimbursementId=${reimbursement.id} amount=${reimbursement.amount} expenseId=${reimbursement.expenseId} orphaned=${reimbursement.orphaned}');
      reimbursement
        ..expenseId = expenseId
        ..orphaned = false
        ..originYearMonth = expense?.yearMonth ?? reimbursement.originYearMonth;
      await AuditRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .put(_isar.reimbursements, reimbursement,
              id: reimbursement.id, type: 'Reimbursement');
      await _syncRecorder?.recordReimbursement(reimbursement);
    });
    AppLogger.expenseRepo(
        'RESTORE_ORPHAN_REIMBURSEMENT_DONE reimbursementId=$reimbursementId expenseId=$expenseId');
  }

  Stream<List<Reimbursement>> watchReimbursementsForOwner(ContextRef context) =>
      _isar.reimbursements
          .filter()
          .group((q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q
                  .profileIdEqualTo(context.profileKey)
                  .and()
                  .sharedSpaceIdIsNull())
          .watch(fireImmediately: true);

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

  /// Context-scoped variant: reimbursements that *belong* to [context]'s month,
  /// keyed on `originYearMonth` within that context (FR-004, data-model §3.4).
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

  Future<List<Reimbursement>> getReimbursementsForMonth(String yearMonth) {
    return _isar.reimbursements
        .filter()
        .originYearMonthEqualTo(yearMonth)
        .findAll();
  }

  /// One-shot variant of [watchReimbursementsForContext].
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
