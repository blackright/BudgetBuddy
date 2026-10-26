import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../models/savings_vault.dart';
import '../models/vault_entry.dart';
import '../vault_goal_schedule.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepository(IsarHelper.instance);
});

class VaultRepository {
  final Isar _isar;

  VaultRepository(this._isar);

  Stream<List<VaultEntry>> watchHistory(int profileId) => _isar.vaultEntrys
      .filter()
      .profileIdEqualTo(profileId)
      .sortByCreatedAtDesc()
      .thenByYearMonthDesc()
      .watch(fireImmediately: true);

  /// Only goal metadata is editable. Balance/history are never overwritten by
  /// a stale goal form. Owner identity is captured by the personal-context UI.
  Future<void> saveGoal(
      {required int profileId,
      required int actorId,
      required String expectedCurrency,
      String? name,
      int? targetMinor,
      String? targetYearMonth,
      DateTime Function()? clock,
      bool Function()? isStillActive}) async {
    if (profileId != actorId) {
      throw StateError('This vault belongs to another profile.');
    }
    final now = (clock ?? DateTime.now)();
    if (targetYearMonth != null &&
        (name == null ||
            !validGoalMonth(targetYearMonth) ||
            targetYearMonth.compareTo(vaultYearMonth(now)) < 0)) {
      throw ArgumentError('Choose the current month or a future target month.');
    }
    if ((name == null) != (targetMinor == null) ||
        (name != null && (name.trim().isEmpty || name.trim().length > 80)) ||
        (targetMinor != null &&
            (targetMinor <= 0 || targetMinor > 9007199254740991))) {
      throw ArgumentError('Enter a goal name and a positive supported amount.');
    }
    await _isar.writeTxn(() async {
      if (isStillActive != null && !isStillActive()) {
        throw StateError(
            'The active profile changed. Reopen this goal editor.');
      }
      final vault = await getVault(profileId);
      if (vault == null ||
          !vault.hasValidBalance ||
          vault.currency != expectedCurrency ||
          vault.currencyCode == null) {
        throw StateError(
            'The vault changed or is not ready. Reopen the goal editor.');
      }
      vault
        ..goalName = name?.trim()
        ..goalTargetMinor = targetMinor
        ..goalTargetYearMonth = targetYearMonth
        ..updatedAt = DateTime.now();
      await _isar.savingsVaults.put(vault);
    });
  }

  Future<SavingsVault?> getVault(int profileId) async {
    return await _isar.savingsVaults
        .filter()
        .profileIdEqualTo(profileId)
        .findFirst();
  }

  Stream<SavingsVault?> watchVault(int profileId) {
    return _isar.savingsVaults
        .filter()
        .profileIdEqualTo(profileId)
        .watch(fireImmediately: true)
        .map((vaults) => vaults.isNotEmpty ? vaults.first : null);
  }
}
