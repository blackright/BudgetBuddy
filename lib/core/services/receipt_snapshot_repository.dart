import '../models/income_receipt_group.dart';
import '../models/money_receipt.dart';
import '../models/salary_cycle.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import '../models/allocation.dart';
import '../models/budget_profile.dart';
import '../models/currency_code.dart';
import '../models/direct_expense_profile.dart';
import '../models/expense.dart';
import '../models/income_source.dart';
import '../models/medical_bill.dart';
import '../models/month_end_run.dart';
import '../models/month_rate_seal.dart';
import '../models/live_rate_set.dart';
import '../models/monthly_budget.dart';
import '../models/reconciliation_snapshot.dart';
import '../models/shared_member.dart';
import '../models/shared_space.dart';
import '../models/transfer.dart';
import '../models/user_profile.dart';
import '../providers/budget_context_provider.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import '../../features/vault/models/savings_vault.dart';
import '../../features/vault/models/vault_entry.dart';

class ReceiptGuardException implements Exception {
  const ReceiptGuardException(this.code);
  final String code;
  @override
  String toString() => 'ReceiptGuardException: $code';
}

/// Consistent current-schema read and preview fingerprint. No financial writes,
/// migration, policy activation or cached balance. Never export raw source rows
/// to a UI/sync recipient: their canonical representation stays inside the hash.
class ReceiptSnapshotRepository {
  ReceiptSnapshotRepository(this.db, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final DateTime Function() clock;

  Future<ReceiptSourceSnapshot> read({
    required ContextRef context,
    required int actorId,
    required bool Function() isAccessCurrent,
  }) =>
      db.txn(() => readInTransaction(
          context: context,
          actorId: actorId,
          isAccessCurrent: isAccessCurrent));

  /// Caller owns one read/write transaction. Used by the write guard to avoid
  /// nested transactions and to re-read the same sources under the write lock.
  Future<ReceiptSourceSnapshot> readInTransaction({
    required ContextRef context,
    required int actorId,
    required bool Function() isAccessCurrent,
  }) async {
    if (!isAccessCurrent()) throw const ReceiptGuardException('accessChanged');
    final month = context.yearMonth;
    if (!RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$').hasMatch(month) ||
        actorId <= 0 ||
        (context.profileId == null) == (context.spaceId == null) ||
        (context.profileId ?? context.spaceId ?? 0) <= 0) {
      throw const ReceiptGuardException('invalidContext');
    }
    final actor = await db.userProfiles.get(actorId);
    if (actor == null) throw const ReceiptGuardException('missingActor');
    CurrencyCode currency;
    final sources = <String, List<Map<String, dynamic>>>{};
    if (context.isShared) {
      final space = await db.sharedSpaces.get(context.spaceId!);
      final member =
          await SpaceWriteGuard(db).memberOf(context.spaceId!, actorId);
      if (space == null || member == null || member.revokedAt != null) {
        throw const ReceiptGuardException('notActiveMember');
      }
      currency = space.currency.code;
      sources['owner'] =
          await _rows(db.sharedSpaces, [_eq('id', context.spaceId)]);
      sources['actorMembership'] =
          await _rows(db.sharedMembers, [_eq('id', member.id)]);
    } else {
      if (context.profileId != actorId) {
        throw const ReceiptGuardException('wrongOwner');
      }
      currency = actor.primaryCurrency.code;
      sources['owner'] = await _rows(db.userProfiles, [_eq('id', actorId)]);
    }
    final owner = <FilterOperation>[
      if (context.isShared)
        _eq('sharedSpaceId', context.spaceId)
      else ...[_eq('profileId', context.profileId), _eq('sharedSpaceId', null)],
    ];
    final monthly = [...owner, _eq('yearMonth', month)];
    sources['months'] = await _rows(db.monthlyBudgets, monthly);
    sources['expenses'] = await _rows(db.expenses, monthly);
    sources['returns'] = await _rows(
        db.reimbursements, [...owner, _eq('originYearMonth', month)]);
    sources['budgetProfiles'] = await _rows(db.budgetProfiles, monthly);
    sources['directProfiles'] = await _rows(db.directExpenseProfiles, monthly);
    sources['allocations'] = await _rows(db.allocations, monthly);
    sources['transfers'] = await _rows(db.transfers, monthly);
    sources['incomeSources'] = await _rows(db.incomeSources, owner);
    if (!context.isShared) {
      sources['incomeGroups'] = await _rows(db.incomeReceiptGroups, [_eq('profileId',context.profileId)]);
      sources['incomeComponents'] = await _rows(db.moneyReceipts, owner);
      sources['incomeRevisions'] = await _rows(db.receiptRevisions, owner);
      sources['salaryCycles'] = await _rows(db.salaryCycles, [_eq('profileId',context.profileId)]);
    }
    sources['medicalBills'] = await _rows(db.medicalBills, monthly);
    sources['seals'] =
        await _rows(db.monthRateSeals, [_eq('yearMonth', month)]);
    sources['liveRates'] = await _rows(db.liveRateSets, []);
    sources['settlements'] = await _rows(db.monthEndRuns, [
      ...owner,
      FilterGroup.or([_eq('yearMonth', month), _eq('destinationMonth', month)]),
    ]);
    if (!context.isShared) {
      sources['vault'] =
          await _rows(db.savingsVaults, [_eq('profileId', actorId)]);
      // Balance/history changes can invalidate deposit/receipt preview eligibility.
      sources['vaultEntries'] =
          await _rows(db.vaultEntrys, [_eq('profileId', actorId)]);
    }
    final blockers = <ReceiptBlocker>[];
    final months = sources['months']!;
    if (months.length != 1) blockers.add(ReceiptBlocker.missingMonth);
    if (months.length == 1 &&
        months.single['openingBalanceConfirmed'] != true) {
      blockers.add(ReceiptBlocker.missingOpeningReview);
    }
    // Existing rate-seal contract treats any stored seal as a closed month.
    if (sources['seals']!.isNotEmpty) blockers.add(ReceiptBlocker.sealedMonth);
    for (final run in sources['settlements']!) {
      if (run['yearMonth'] == month) blockers.add(ReceiptBlocker.settledMonth);
      if (run['applied'] != true || run['hasConflict'] == true) {
        blockers.add(ReceiptBlocker.settlementNeedsReview);
      }
    }
    if (!context.isShared) {
      final cursorPassed = sources['vault']!.any((v) {
        final cursor = v['lastSweepYearMonth'];
        return cursor is String &&
            RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$').hasMatch(cursor) &&
            cursor.compareTo(month) > 0;
      });
      final swept = sources['vaultEntries']!
          .any((v) => v['kind'] == 'sweep' && v['yearMonth'] == month);
      if (cursorPassed || swept) blockers.add(ReceiptBlocker.sweptMonth);
    }
    final canonical = _canonical({
      'kind': context.isShared ? 'shared' : 'personal',
      'owner': context.spaceId ?? context.profileId,
      'month': month,
      'actor': actorId,
      'currency': currency.code,
      'sources': sources,
    });
    if (!isAccessCurrent()) throw const ReceiptGuardException('accessChanged');
    return ReceiptSourceSnapshot(
      context: context,
      actorId: actorId,
      currency: currency,
      fingerprint:
          sha256.convert(utf8.encode(jsonEncode(canonical))).toString(),
      capturedAt: clock().toUtc(),
      blockers: blockers.toSet(),
      sourceCounts: {
        for (final entry in sources.entries) entry.key: entry.value.length
      },
    );
  }

  static FilterCondition _eq(String property, Object? value) =>
      FilterCondition.equalTo(property: property, value: value);

  Future<List<Map<String, dynamic>>> _rows<T>(
      IsarCollection<T> collection, List<FilterOperation> filters) async {
    final query = collection.buildQuery<T>(filter: FilterGroup.and(filters));
    final rows = await query.exportJson();
    // Query ordering is not a financial change. Sort canonical row encodings.
    rows.sort((a, b) =>
        jsonEncode(_canonical(a)).compareTo(jsonEncode(_canonical(b))));
    return rows;
  }

  static Object? _canonical(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: _canonical(value[key])};
    }
    if (value is List) return value.map(_canonical).toList();
    return value;
  }
}
