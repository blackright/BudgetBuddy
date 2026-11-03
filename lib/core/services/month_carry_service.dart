import 'dart:math' as math;

import 'package:isar/isar.dart';

import '../models/allocation.dart';
import '../models/budget_profile.dart';
import '../models/currency_code.dart';
import '../models/month_end_run.dart';
import '../models/user_profile.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/sync/repositories/sync_recorder.dart';
import 'free_funds.dart';

class MonthCarryException implements Exception {
  const MonthCarryException(this.code);
  final String code;
  @override
  String toString() => code;
}

/// Carries each recurring envelope into the next personal month exactly once.
///
/// The destination row uses the existing `auto-carry:<previous>:<family>`
/// sentinel so a later month-end run can adopt it when the arithmetic matches.
class MonthCarryService {
  MonthCarryService(this.db,
      {this.recorder, this.actorId, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  final Isar db;
  final SyncRecorder? recorder;
  final int? actorId;
  final DateTime Function() clock;

  Future<int> ensureCarry(
          {required int profileId,
          required String yearMonth,
          bool Function()? isAccessCurrent}) =>
      db.writeTxn(() => ensureCarryInTxn(
          profileId: profileId,
          yearMonth: yearMonth,
          isAccessCurrent: isAccessCurrent));

  /// Caller already holds the month-provisioning write transaction.
  Future<int> ensureCarryInTxn(
      {required int profileId,
      required String yearMonth,
      bool Function()? isAccessCurrent}) async {
    if (isAccessCurrent != null && !isAccessCurrent()) {
      throw const MonthCarryException('accessChanged');
    }
    if (!_validMonth(yearMonth)) {
      throw const MonthCarryException('invalidMonth');
    }
    final owner = await db.userProfiles.get(profileId);
    if (owner == null) throw const MonthCarryException('missingProfile');
    final previous = _previousMonth(yearMonth);
    final rows = await db.budgetProfiles
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .yearMonthEqualTo(previous)
        .findAll();
    if (rows.isEmpty) return 0;

    final runs = await db.monthEndRuns
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    if (runs.any((run) =>
        run.hasConflict &&
        (run.yearMonth == previous || run.destinationMonth == yearMonth))) {
      throw const MonthCarryException('settlementConflict');
    }

    final destinationRows = await db.budgetProfiles
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .yearMonthEqualTo(yearMonth)
        .findAll();
    final existingFamilies = {
      for (final row in destinationRows)
        if (row.familyGuid.isNotEmpty) row.familyGuid,
    };
    final audit =
        AuditRepository(db, recorder: recorder, actorId: actorId);
    final now = clock().toUtc();
    final currency = owner.primaryCurrency.code.code;
    var created = 0;
    for (final source in rows) {
      final family = source.familyGuid.trim();
      if (family.isEmpty || existingFamilies.contains(family)) continue;
      final base = source.defaultAllocationMinor;
      if (base == null || base < 0) continue;
      final unused = math.max(0, source.allocation - source.spent);
      final carried =
          source.monthEndRule == MonthEndRule.carryForward ? unused : 0;
      final allocation = sumFinancialMinor([base, carried]);
      if (allocation < 0) {
        throw const MonthCarryException('invalidAllocation');
      }
      final profile = BudgetProfile()
        ..syncGuid = 'auto-carry-profile:$profileId:$yearMonth:$family'
        ..familyGuid = family
        ..defaultAllocationMinor = base
        ..monthEndOriginGuid = 'auto-carry:$previous:$family'
        ..monthEndFingerprint =
            '$profileId|$yearMonth|$family|$base|$carried|$allocation'
        ..profileId = profileId
        ..yearMonth = yearMonth
        ..name = source.name
        ..allocation = allocation
        ..spent = 0
        ..monthEndRule = source.monthEndRule
        ..createdAt = now
        ..updatedAt = now;
      profile.id = await audit.put(db.budgetProfiles, profile,
          id: profile.id, type: 'BudgetProfile');
      if (allocation > 0) {
        final delta = Allocation()
          ..syncGuid = 'auto-carry:${profile.syncGuid}'
          ..profileId = profileId
          ..yearMonth = yearMonth
          ..budgetProfileId = profile.id
          ..amount = allocation
          ..currency = currency
          ..date = now
          ..createdAt = now;
        await audit.put(db.allocations, delta,
            id: delta.id, type: 'Allocation');
      }
      await audit.append(
          profileId: profileId,
          action: 'allocation.carry',
          objectType: 'BudgetProfile',
          objectGuid: profile.syncGuid,
          after: {
            'familyGuid': family,
            'sourceMonth': previous,
            'unusedMinor': unused,
            'carriedMinor': carried,
            'allocationMinor': allocation,
          });
      existingFamilies.add(family);
      created++;
    }
    return created;
  }

  String _previousMonth(String month) {
    final parts = month.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]) - 1);
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}';
  }

  bool _validMonth(String month) =>
      RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month);
}
