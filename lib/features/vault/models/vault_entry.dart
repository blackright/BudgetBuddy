import 'package:isar/isar.dart';
import 'savings_vault.dart';
import '../vault_math.dart';
import '../vault_transfer_ledger.dart';

part 'vault_entry.g.dart';

/// Immutable local evidence for an opening balance or a processed month.
@collection
class VaultEntry {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String operationKey;
  @Index()
  late int profileId;
  late String kind;
  String? yearMonth;
  late int amountMinor;
  late String currency;
  late int balanceAfterMinor;
  late DateTime createdAt;
  String breakdownJson = '{}';
  String? reason;

  @ignore
  bool get hasValidAmounts =>
      (vaultTransferKinds.contains(kind)
          ? validVaultSignedAmount(amountMinor)
          : validVaultAmount(amountMinor)) &&
      validVaultAmount(balanceAfterMinor);
}

/// Must run in the caller's write transaction, including migration step 25.
/// A legacy total is preserved, not reconstructed into invented monthly rows.
Future<void> seedVaultOpeningInTxn(
    Isar isar, SavingsVault vault, DateTime now) async {
  if (!vault.hasValidBalance) return;
  final key = 'vault:${vault.profileId}:opening';
  if (await isar.vaultEntrys.filter().operationKeyEqualTo(key).count() > 0) {
    return;
  }
  await isar.vaultEntrys.put(VaultEntry()
    ..operationKey = key
    ..profileId = vault.profileId
    ..kind = 'opening'
    ..amountMinor = vault.totalMinor
    ..balanceAfterMinor = vault.totalMinor
    ..currency = vault.currency
    ..createdAt = now
    ..reason =
        'Existing savings at history start; earlier contributions are unavailable.');
}

/// Read-only reconciliation. Invalid evidence is retained for review, never
/// erased or treated as zero. IDs reflect commit order; do not native-sort IDs.
Future<String?> vaultHistoryProblem(Isar isar, SavingsVault vault) async {
  final entries = await isar.vaultEntrys
      .filter()
      .profileIdEqualTo(vault.profileId)
      .findAll();
  return vaultEntriesProblem(vault, entries);
}

String? vaultEntriesProblem(SavingsVault vault, List<VaultEntry> history) {
  if (!vault.hasValidBalance) {
    return 'The saved balance is invalid and needs review. No savings were changed.';
  }
  final entries = [...history];
  if (entries.isEmpty) return null;
  entries.sort((a, b) => a.id.compareTo(b.id));
  var total = BigInt.zero;
  final operations = <String, VaultEntry>{};
  final reversed = <String>{};
  for (final entry in entries) {
    final transfer = vaultTransferKinds.contains(entry.kind);
    if (entry.profileId != vault.profileId ||
        !entry.hasValidAmounts ||
        entry.currency != vault.currency ||
        (entry.kind == 'sweep' &&
            vaultBreakdown(entry.breakdownJson) == null) ||
        (transfer && transferDetails(entry) == null) ||
        (entry.kind != 'opening' && entry.kind != 'sweep' && !transfer) ||
        operations.containsKey(entry.operationKey)) {
      return 'Saved history contains an invalid amount or currency and needs review.';
    }
    total += BigInt.from(entry.amountMinor);
    if (entry.kind == 'reversal') {
      final key = transferDetails(entry)!['reverses'] as String;
      final original = operations[key];
      if (original == null ||
          !{'deposit', 'withdrawal'}.contains(original.kind) ||
          original.yearMonth != entry.yearMonth ||
          original.amountMinor != -entry.amountMinor ||
          !reversed.add(key)) {
        return 'Saved reversal links need review.';
      }
    }
    operations[entry.operationKey] = entry;
    if (total < BigInt.zero ||
        total > BigInt.from(maxVaultMinor) ||
        total != BigInt.from(entry.balanceAfterMinor)) {
      return 'Saved history does not reconcile. Review the vault before adding savings.';
    }
  }
  return total == BigInt.from(vault.totalMinor)
      ? null
      : 'Saved history and the balance disagree. Review the vault before adding savings.';
}
