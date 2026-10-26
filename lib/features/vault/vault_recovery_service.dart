import '../finance/repositories/audit_repository.dart';
// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import '../../core/database/money_integrity.dart' show corruptedMinorSentinel;
import '../../core/models/user_profile.dart';
import '../../core/models/monthly_budget.dart';
import '../../core/models/expense.dart';
import '../../core/models/budget_profile.dart';
import '../../core/models/month_end_run.dart';
import '../expenses/models/reimbursement.dart';
import 'models/savings_vault.dart';
import 'models/vault_entry.dart';

class VaultRecoveryException implements Exception {
  const VaultRecoveryException(this.message);
  final String message;
  @override
  String toString() => message;
}

class VaultRecoveryPreview {
  const VaultRecoveryPreview(this.profileId, this.months, this.fingerprint);
  final int profileId;
  final List<String> months;
  final String fingerprint;
}

/// Narrow, owner-confirmed recovery for the observed missing-int defect.
/// This does not reconstruct general historic savings. Only the evidenced zero
/// case is supported; any payments, returns, carry or positive opening blocks it.
class VaultRecoveryService {
  VaultRecoveryService(this.db,
      {required this.actorId,
      required this.isStillActive,
      DateTime Function()? clock,
      Future<void> Function()? beforeCommit})
      : _clock = clock ?? DateTime.now,
        _beforeCommit = beforeCommit;
  final Isar db;
  final int actorId;
  final bool Function() isStillActive;
  final DateTime Function() _clock;
  final Future<void> Function()? _beforeCommit;

  Future<VaultRecoveryPreview> preview() =>
      db.txn(() async => (await _read()).preview);

  Future<void> confirm(VaultRecoveryPreview reviewed) => db.writeTxn(() async {
        final state = await _read();
        if (reviewed.profileId != actorId ||
            reviewed.fingerprint != state.preview.fingerprint) {
          throw const VaultRecoveryException(
              'The records changed. Close and generate a fresh recovery preview.');
        }
        final vault = state.vault;
        final entry = state.entry;
        final now = _clock();
        // Preserve the invalid evidence verbatim as strings, not formatted money.
        final evidence = {
          'recovery': {
            'reason':
                'Owner-confirmed recovery of an Isar missing-integer balance',
            'confirmedAt': now.toIso8601String(),
            'actorProfileId': actorId,
            'sourceMonths': state.preview.months,
            'sourceFingerprint': reviewed.fingerprint,
            'confirmedMinor': 0,
            'currency': 'huf',
            'originalVault': {
              'id': vault.id,
              'minor': vault.totalMinor.toString(),
              'legacyMajor': vault.totalAmount.toString(),
              'currency': vault.currency,
              'cursor': vault.lastSweepYearMonth,
              'paused': vault.sweepPaused,
              'pauseReason': vault.pauseReason,
              'updatedAt': vault.updatedAt.toIso8601String()
            },
            'originalEntry': {
              'id': entry.id,
              'operationKey': entry.operationKey,
              'kind': entry.kind,
              'month': entry.yearMonth,
              'minor': entry.amountMinor.toString(),
              'balanceAfterMinor': entry.balanceAfterMinor.toString(),
              'currency': entry.currency,
              'createdAt': entry.createdAt.toIso8601String(),
              'reason': entry.reason,
              'breakdownJson': entry.breakdownJson
            },
          }
        };
        if (!isStillActive()) {
          throw const VaultRecoveryException(
              'The active profile changed. Reopen recovery.');
        }
        entry
          ..amountMinor = 0
          ..balanceAfterMinor = 0
          ..breakdownJson = jsonEncode(evidence)
          ..reason =
              'Owner-confirmed recovery to Ft 0. Recorded completed personal months have zero confirmed opening funds and no expenses, returns or carry. Original invalid evidence is preserved.';
        vault
          ..totalMinor = 0
          ..sweepPaused = false
          ..pauseReason = null
          ..updatedAt = now;
        await AuditRepository(db)
            .put(db.vaultEntrys, entry, id: entry.id, type: 'VaultEntry');
        await _beforeCommit?.call();
        if (!isStillActive()) {
          throw const VaultRecoveryException(
              'The active profile changed. No recovery was committed.');
        }
        await db.savingsVaults.put(vault);
      });

  Future<({VaultRecoveryPreview preview, SavingsVault vault, VaultEntry entry})>
      _read() async {
    if (!isStillActive()) {
      throw const VaultRecoveryException(
          'Select the owning personal profile before recovery.');
    }
    final owner = await db.userProfiles.get(actorId);
    final vault =
        await db.savingsVaults.filter().profileIdEqualTo(actorId).findFirst();
    final date = _clock();
    final current =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
    if (owner == null ||
        owner.primaryCurrency != PrimaryCurrency.huf ||
        vault == null ||
        vault.currency != 'huf' ||
        vault.totalMinor != corruptedMinorSentinel ||
        vault.lastSweepYearMonth != current ||
        vault.totalAmount != 0) {
      throw const VaultRecoveryException(
          'This vault does not match the verified zero-balance recovery case. No data was changed.');
    }
    final entries =
        await db.vaultEntrys.filter().profileIdEqualTo(actorId).findAll();
    if (entries.length != 1 ||
        entries.single.kind != 'opening' ||
        entries.single.operationKey != 'vault:$actorId:opening' ||
        entries.single.currency != 'huf' ||
        entries.single.amountMinor != corruptedMinorSentinel ||
        entries.single.balanceAfterMinor != corruptedMinorSentinel) {
      throw const VaultRecoveryException(
          'Existing history needs a separate review. This recovery will not overwrite it.');
    }
    bool past(String month) {
      if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month)) {
        throw const VaultRecoveryException(
            'A recorded month is invalid and needs review.');
      }
      return month.compareTo(current) < 0;
    }

    final months = (await db.monthlyBudgets
            .filter()
            .profileIdEqualTo(actorId)
            .sharedSpaceIdIsNull()
            .findAll())
        .where((m) => past(m.yearMonth))
        .toList()
      ..sort((a, b) => a.yearMonth.compareTo(b.yearMonth));
    if (months.isEmpty ||
        months.any((m) =>
            !m.openingBalanceConfirmed ||
            !m.baseAvailableAmount.isFinite ||
            m.baseAvailableAmount != 0 ||
            (m.currency != null && m.currency != 'huf'))) {
      throw const VaultRecoveryException(
          'Recorded completed months do not establish a confirmed zero balance. Review their opening funds first.');
    }
    final expenses = await db.expenses
        .filter()
        .profileIdEqualTo(actorId)
        .sharedSpaceIdIsNull()
        .findAll();
    final returns = await db.reimbursements
        .filter()
        .profileIdEqualTo(actorId)
        .sharedSpaceIdIsNull()
        .findAll();
    final profiles = await db.budgetProfiles
        .filter()
        .profileIdEqualTo(actorId)
        .sharedSpaceIdIsNull()
        .findAll();
    final settlements = await db.monthEndRuns
        .filter()
        .profileIdEqualTo(actorId)
        .sharedSpaceIdIsNull()
        .findAll();
    if (expenses.any((e) => past(e.yearMonth)) ||
        returns.any((r) => past(r.originYearMonth)) ||
        profiles.any((p) => past(p.yearMonth)) ||
        settlements.any((r) => past(r.yearMonth))) {
      throw const VaultRecoveryException(
          'A completed personal month contains financial activity. The zero-balance repair is blocked for review.');
    }
    final entry = entries.single;
    final fingerprint = sha256
        .convert(utf8.encode(jsonEncode({
          'actor': actorId,
          'month': current,
          'vault': [
            vault.id,
            vault.totalMinor.toString(),
            vault.totalAmount.toString(),
            vault.currency,
            vault.lastSweepYearMonth,
            vault.updatedAt.toIso8601String()
          ],
          'entry': [
            entry.id,
            entry.operationKey,
            entry.amountMinor.toString(),
            entry.balanceAfterMinor.toString(),
            entry.breakdownJson,
            entry.reason,
            entry.createdAt.toIso8601String()
          ],
          'months': [
            for (final m in months)
              [
                m.id,
                m.yearMonth,
                m.baseAvailableAmount,
                m.openingBalanceConfirmed,
                m.currency,
                m.updatedAt.toIso8601String()
              ]
          ],
        })))
        .toString();
    return (
      preview: VaultRecoveryPreview(actorId,
          List.unmodifiable(months.map((m) => m.yearMonth)), fingerprint),
      vault: vault,
      entry: entry
    );
  }
}
