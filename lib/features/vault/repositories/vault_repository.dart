import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../models/savings_vault.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepository(IsarHelper.instance);
});

class VaultRepository {
  final Isar _isar;

  VaultRepository(this._isar);

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

  Future<void> updateVault(SavingsVault vault) async {
    await _isar.writeTxn(() async {
      await _isar.savingsVaults.put(vault);
    });
  }
}
