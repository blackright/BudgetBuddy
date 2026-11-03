import 'dart:math' as math;

import 'package:isar/isar.dart';

import '../models/allocation.dart';
import '../models/budget_profile.dart';
import '../models/currency_code.dart';
import '../models/user_profile.dart';
import '../../features/finance/repositories/audit_repository.dart';
import 'continuous_balance_service.dart';
import 'fx_booking_service.dart';

class AllocationException implements Exception {
  const AllocationException(this.code);
  final String code;
  @override
  String toString() => code;
}

/// Reserve and release one personal allocation envelope.
///
/// Both operations are one transaction with a signed [Allocation] delta and an
/// audit event. The original history rows are never edited.
class AllocationOperationsService {
  AllocationOperationsService(this.db,
      {this.actorId, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  final Isar db;
  final int? actorId;
  final DateTime Function() clock;

  Future<void> reserve(
          {required int profileId,
          required String yearMonth,
          required int amount,
          String? operationKey,
          bool Function()? isAccessCurrent}) =>
      _write('reserve', profileId, yearMonth, amount, operationKey,
          isAccessCurrent: isAccessCurrent);

  Future<void> release(
          {required int profileId,
          required String yearMonth,
          required int amount,
          String? reason,
          String? operationKey,
          bool Function()? isAccessCurrent}) =>
      _write('release', profileId, yearMonth, amount, operationKey,
          reason: reason, isAccessCurrent: isAccessCurrent);

  /// A signed correction delta. The original allocation history is never edited.
  Future<void> correct(
          {required int profileId,
          required String yearMonth,
          required int amount,
          required String reason,
          String? operationKey,
          bool Function()? isAccessCurrent}) =>
      _write('correct', profileId, yearMonth, amount, operationKey,
          reason: reason, isAccessCurrent: isAccessCurrent);

  Future<void> _write(String kind, int profileId, String yearMonth, int amount,
      String? operationKey,
      {String? reason, bool Function()? isAccessCurrent}) async {
    if (kind == 'correct' ? amount == 0 : amount <= 0) {
      throw const AllocationException('invalidAmount');
    }
    await db.writeTxn(() async {
      if (isAccessCurrent != null && !isAccessCurrent()) {
        throw const AllocationException('accessChanged');
      }
      final profile = await db.budgetProfiles.get(profileId);
      if (profile == null ||
          profile.sharedSpaceId != null ||
          profile.profileId == null) {
        throw const AllocationException('missingProfile');
      }
      if (profile.profileId != (actorId ?? profile.profileId)) {
        throw const AllocationException('wrongOwner');
      }
      if (profile.yearMonth != yearMonth) {
        throw const AllocationException('wrongMonth');
      }
      final owner = await db.userProfiles.get(profile.profileId!);
      if (owner == null) throw const AllocationException('missingProfile');
      final key = operationKey == null
          ? null
          : 'allocation.$kind:${profile.profileId}:$yearMonth:$operationKey';
      if (key != null) {
        final existing =
            await db.allocations.filter().syncGuidEqualTo(key).findFirst();
        if (existing != null) return;
      }
      final audit = AuditRepository(db, actorId: actorId ?? profile.profileId);
      final before = profile.allocation;
      if (kind == 'reserve') {
        final balance = await ContinuousBalanceService(db,
                rates: await readFxRates(db), clock: clock)
            .balance(profileId: profile.profileId!, yearMonth: yearMonth);
        if (balance.status != BalanceChainStatus.intact) {
          throw const AllocationException('allocationNeedsReview');
        }
        if (amount > balance.freeToUseMinor) {
          throw const AllocationException('insufficientFreeFunds');
        }
        profile.allocation = before + amount;
      } else if (kind == 'correct') {
        final remaining = math.max(0, before - profile.spent);
        if (amount < 0 && -amount > remaining) {
          throw const AllocationException('allocationTooLarge');
        }
        if (amount > 0) {
          final balance = await ContinuousBalanceService(db,
                  rates: await readFxRates(db), clock: clock)
              .balance(profileId: profile.profileId!, yearMonth: yearMonth);
          if (balance.status != BalanceChainStatus.intact) {
            throw const AllocationException('allocationNeedsReview');
          }
          if (amount > balance.freeToUseMinor) {
            throw const AllocationException('insufficientFreeFunds');
          }
        }
        profile.allocation = before + amount;
        if (profile.allocation < 0) {
          throw const AllocationException('allocationTooLarge');
        }
      } else {
        final remaining = math.max(0, before - profile.spent);
        if (amount > remaining) {
          throw const AllocationException('allocationTooLarge');
        }
        profile.allocation = before - amount;
      }
      profile.updatedAt = clock().toUtc();
      await audit.put(db.budgetProfiles, profile,
          id: profile.id, type: 'BudgetProfile');
      final delta = Allocation()
        ..syncGuid = key ??
            'allocation.$kind:${profile.syncGuid}:${clock().microsecondsSinceEpoch}'
        ..profileId = profile.profileId
        ..yearMonth = yearMonth
        ..budgetProfileId = profile.id
        ..amount = profile.allocation - before
        ..currency = owner.primaryCurrency.code.code
        ..date = clock().toUtc()
        ..createdAt = clock().toUtc();
      await audit.put(db.allocations, delta, id: delta.id, type: 'Allocation');
      await audit.append(
          profileId: profile.profileId,
          action: 'allocation.$kind',
          objectType: 'BudgetProfile',
          objectGuid: profile.syncGuid,
          before: {
            'allocationMinor': before
          },
          after: {
            'allocationMinor': profile.allocation,
            'deltaMinor': profile.allocation - before,
            if (reason != null && reason.trim().isNotEmpty)
              'reason': reason.trim(),
          });
      if (isAccessCurrent != null && !isAccessCurrent()) {
        throw const AllocationException('accessChanged');
      }
    });
  }
}
