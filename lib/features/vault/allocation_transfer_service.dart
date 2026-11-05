import 'dart:convert';
import 'dart:math' as math;

import 'package:isar/isar.dart';

import '../../core/models/allocation.dart';
import '../../core/models/budget_profile.dart';
import '../../core/models/currency_code.dart';
import '../../core/models/month_rate_seal.dart';
import '../../core/models/month_end_run.dart';
import '../../core/models/monthly_budget.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/continuous_balance_service.dart';
import '../../core/services/fx_booking_service.dart';
import '../../features/finance/repositories/audit_repository.dart';
import 'models/savings_vault.dart';
import 'models/vault_entry.dart';
import 'vault_math.dart';
import 'vault_transfer_service.dart';

class AllocationTransferException implements Exception {
  const AllocationTransferException(this.code);
  final String code;
  @override
  String toString() => code;
}

/// Moves reserved allocation money into the Vault without changing free-to-use.
///
/// The allocation is reduced (which raises free-to-use) and a normal Vault
/// deposit is recorded (which lowers it by the same amount). One transaction
/// covers both legs; any Vault validation failure rolls the allocation back.
class AllocationTransferService {
  AllocationTransferService(this.db,
      {this.actorId, DateTime Function()? clock, this.isAccessCurrent})
      : clock = clock ?? DateTime.now;

  final Isar db;
  final int? actorId;
  final DateTime Function() clock;
  final bool Function()? isAccessCurrent;

  Future<VaultEntry> moveToVault(
          {required int profileId,
          required String yearMonth,
          required int amount,
          required String operationKey,
          String note = ''}) =>
      db.writeTxn(() async {
        if (amount <= 0) {
          throw const AllocationTransferException('invalidAmount');
        }
        if (!RegExp(r'^[a-zA-Z0-9_-]{1,80}$').hasMatch(operationKey)) {
          throw const AllocationTransferException('invalidRequest');
        }
        if (isAccessCurrent != null && !isAccessCurrent!()) {
          throw const AllocationTransferException('accessChanged');
        }
        final profile = await db.budgetProfiles.get(profileId);
        if (profile == null ||
            profile.sharedSpaceId != null ||
            profile.profileId == null) {
          throw const AllocationTransferException('missingProfile');
        }
        if (actorId != null && actorId != profile.profileId) {
          throw const AllocationTransferException('wrongOwner');
        }
        if (profile.yearMonth != yearMonth) {
          throw const AllocationTransferException('wrongMonth');
        }
        final owner = await db.userProfiles.get(profile.profileId!);
        if (owner == null) {
          throw const AllocationTransferException('missingProfile');
        }
        final ownerId = owner.id;
        final currency = owner.primaryCurrency.code;
        final key = 'vault:$ownerId:allocation:$operationKey';
        final old =
            await db.vaultEntrys.filter().operationKeyEqualTo(key).findFirst();
        if (old != null) {
          if (old.profileId != ownerId ||
              old.kind != 'deposit' ||
              old.amountMinor != amount) {
            throw const AllocationTransferException('duplicateMismatch');
          }
          return old;
        }
        final remaining = math.max(0, profile.allocation - profile.spent);
        if (amount > remaining) {
          throw const AllocationTransferException('allocationTooLarge');
        }
        final month =
            '${clock().year.toString().padLeft(4, '0')}-${clock().month.toString().padLeft(2, '0')}';
        if (profile.yearMonth != month) {
          throw const AllocationTransferException('wrongMonth');
        }
        final budget = await db.monthlyBudgets
            .filter()
            .profileIdEqualTo(ownerId)
            .sharedSpaceIdIsNull()
            .yearMonthEqualTo(month)
            .findFirst();
        if (budget == null || !budget.openingBalanceConfirmed) {
          throw const AllocationTransferException('missingOpening');
        }
        final seal = await db.monthRateSeals
            .filter()
            .yearMonthEqualTo(month)
            .findFirst();
        if (seal != null && seal.status != SealStatus.open) {
          throw const AllocationTransferException('sealedMonth');
        }
        final runs = await db.monthEndRuns
            .filter()
            .profileIdEqualTo(ownerId)
            .sharedSpaceIdIsNull()
            .findAll();
        if (runs.any((r) =>
            r.yearMonth == month ||
            (r.destinationMonth == month && (!r.applied || r.hasConflict)))) {
          throw const AllocationTransferException('settlementNeedsReview');
        }
        final vault = await VaultTransferService(db,
                actorId: ownerId,
                isStillActive: () => isAccessCurrent?.call() ?? true,
                clock: clock)
            .ensureVault(ownerId);
        if (vault.currency != currency.code) {
          throw const AllocationTransferException('currencyMismatch');
        }
        final entries =
            await db.vaultEntrys.filter().profileIdEqualTo(ownerId).findAll();
        if (vaultEntriesProblem(vault, entries) != null) {
          throw const AllocationTransferException('vaultNeedsReview');
        }
        if (!validVaultAmount(vaultSum(vault.totalMinor, amount))) {
          throw const AllocationTransferException('vaultLimit');
        }
        final balance = await ContinuousBalanceService(db,
                rates: await readFxRates(db), clock: clock)
            .balance(profileId: ownerId, yearMonth: month);
        if (balance.status != BalanceChainStatus.intact) {
          throw const AllocationTransferException('balanceNeedsReview');
        }
        final audit = AuditRepository(db, actorId: ownerId);
        final now = clock().toUtc();
        final before = profile.allocation;
        profile
          ..allocation = before - amount
          ..updatedAt = now;
        await audit.put(db.budgetProfiles, profile,
            id: profile.id, type: 'BudgetProfile');
        final delta = Allocation()
          ..syncGuid =
              'allocation.moveToVault:${profile.syncGuid}:$operationKey'
          ..profileId = ownerId
          ..yearMonth = month
          ..budgetProfileId = profile.id
          ..amount = -amount
          ..currency = currency.code
          ..date = now
          ..createdAt = now;
        await audit.put(db.allocations, delta,
            id: delta.id, type: 'Allocation');
        final vaultBefore = vault.totalMinor;
        final entry = VaultEntry()
          ..profileId = ownerId
          ..operationKey = key
          ..kind = 'deposit'
          ..yearMonth = month
          ..currency = currency.code
          ..amountMinor = amount
          ..balanceAfterMinor = vaultSum(vaultBefore, amount)
          ..createdAt = now
          ..reason = note.trim().isEmpty ? null : note.trim()
          ..breakdownJson = jsonEncode({
            'version': 1,
            'month': month,
            'currency': currency.code,
            'vaultDelta': amount,
            'monthDelta': -amount,
            'vaultBefore': vaultBefore,
            'bankBefore': balance.freeToUseMinor,
            'bankAfter': vaultSum(balance.freeToUseMinor, -amount),
            'reserveBefore': balance.freeToUseMinor,
            'reserveAfter': vaultSum(balance.freeToUseMinor, -amount),
            'note': note.trim(),
            'sourceAllocationGuid': profile.syncGuid,
            'allocationDeltaGuid': delta.syncGuid,
          });
        await audit.put(db.vaultEntrys, entry,
            id: entry.id, type: 'VaultEntry');
        vault
          ..totalMinor = entry.balanceAfterMinor
          ..updatedAt = now;
        await db.savingsVaults.put(vault);
        await audit.append(
            profileId: ownerId,
            action: 'allocation.moveToVault',
            objectType: 'BudgetProfile',
            objectGuid: profile.syncGuid,
            before: {
              'allocationMinor': before
            },
            after: {
              'allocationMinor': profile.allocation,
              'amountMinor': amount,
              'vaultOperationKey': key,
            });
        if (isAccessCurrent != null && !isAccessCurrent!()) {
          throw const AllocationTransferException('accessChanged');
        }
        return entry;
      });
}
