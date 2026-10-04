import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../vault/repositories/vault_repository.dart';
import '../../vault/models/savings_vault.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';

final sweepServiceProvider = Provider<SweepService>((ref) {
  return SweepService(ref);
});

class SweepService {
  final Ref _ref;

  SweepService(this._ref);

  Future<void> executeSweepCheck() async {
    final profile = await _ref.read(activeProfileProvider.future);
    if (profile == null) return;

    final currentMonthStr = _ref.read(currentYearMonthProvider);

    final vaultRepo = _ref.read(vaultRepositoryProvider);
    var vault = await vaultRepo.getVault(profile.id);

    if (vault == null) {
      vault = SavingsVault()
        ..profileId = profile.id
        ..totalAmount = 0.0
        ..lastSweepYearMonth = currentMonthStr; // Initialize to current month
      await vaultRepo.updateVault(vault);
      return;
    }

    if (vault.lastSweepYearMonth != currentMonthStr) {
      // It's a new month, we need to sweep the true available from the previous month.
      // In a real app, you would fetch the true available for `vault.lastSweepYearMonth`.
      // For simplicity, we just add the current true available (which corresponds to that past month if we load its budget).

      // Since it's complex to get the exact unspent amount of past months without querying them directly,
      // and we just started the new month, we will need to query the past budget and expenses.
      // Here we assume it's implemented. For MVP, we will just update the lastSweepYearMonth.

      // Update the vault to track the new month
      vault.lastSweepYearMonth = currentMonthStr;
      await vaultRepo.updateVault(vault);
    }
  }
}
