import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/currency_code.dart';
import '../../../shared/presentation/money_format.dart';
import '../providers/vault_providers.dart';
import '../vault_math.dart';
import '../vault_transfer_ledger.dart';
import 'vault_transfer_dialog.dart';
import 'vault_time.dart';
import 'vault_history_pages.dart';

/// Entries describe the original committed calculation, never today's rates.
class VaultHistory extends ConsumerWidget {
  const VaultHistory({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(vaultHistoryProvider)
      .when(
        loading: () => const Padding(
            padding: EdgeInsets.all(16), child: Text('Loading history…')),
        error: (_, __) => const Text(
            'History could not be loaded. Reopen the vault to retry.'),
        data: (entries) => VaultHistoryPages(
            entries: entries,
            itemBuilder: (entry) {
              if (vaultTransferKinds.contains(entry.kind)) {
                return VaultTransferHistory(
                    entry: entry,
                    reversedOriginal: entries
                        .where((row) =>
                            row.operationKey ==
                            transferDetails(entry)?['reverses'])
                        .firstOrNull,
                    reversed: entries.any((row) =>
                        row.kind == 'reversal' &&
                        transferDetails(row)?['reverses'] ==
                            entry.operationKey));
              }
              if (!entry.hasValidAmounts) {
                return const Card(
                    child: ListTile(
                        title: Text('History amount needs review'),
                        subtitle: Text(
                            'The stored value is invalid. Original evidence is preserved; it is not a confirmed balance.')));
              }
              final code = CurrencyCode.tryParse(entry.currency);
              final amount = code == null
                  ? 'Currency needs review'
                  : formatMinorUnits(entry.amountMinor, code);
              final checked = entry.kind == 'opening'
                  ? <String, dynamic>{}
                  : vaultBreakdown(entry.breakdownJson);
              if (checked == null) {
                return const Card(
                    child: ListTile(
                        title: Text('Saved calculation needs review')));
              }
              final parts = checked;
              final calculationCode =
                  CurrencyCode.tryParse(parts['currency'] as String? ?? '');
              String figure(String key) => calculationCode == null
                  ? 'Unavailable'
                  : formatMinorUnits(parts[key] as int, calculationCode);
              return Card(
                  child: ExpansionTile(
                title: Text(entry.kind == 'opening'
                    ? 'Opening balance • $amount'
                    : '${entry.yearMonth} • Saved $amount'),
                subtitle: Text(formatVaultTime(entry.createdAt)),
                childrenPadding: const EdgeInsets.all(16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.reason != null) Text(entry.reason!),
                  if (entry.kind == 'opening')
                    _RecoveryEvidence(json: entry.breakdownJson),
                  if (entry.kind == 'sweep' && calculationCode != null) ...[
                    Text(
                        '${parts['formulaVersion'] == 2 ? 'Opening funds (reference)' : 'Opening funds'}: ${figure('opening')}'),
                    if (parts['formulaVersion'] == 2) ...[
                      Text('Income: ${figure('income')}'),
                      Text('Unused allocations: ${figure('unused')}'),
                      Text('Incoming carry: ${figure('incoming')}'),
                      Text('Released at Month-End: ${figure('released')}'),
                    ],
                    Text('Spending: ${figure('spent')}'),
                    Text('Returns: ${figure('returned')}'),
                    Text(
                        '${parts['formulaVersion'] == 2 ? 'Additional carry reservation' : 'Excluded carry'}: ${figure('carry')}'),
                    if ((parts['vaultTransfers'] ?? 0) != 0)
                      Text(
                          'Vault transfer credit: ${figure('vaultTransfers')}'),
                    Text('Remaining before conversion: ${figure('available')}'),
                    if (parts['currency'] != entry.currency)
                      Text(
                          'Conversion: ${parts['currency']} → ${entry.currency}; rate ${parts['rate']}\nSource: ${parts['rateSource']} • As of ${parts['rateAsOf']}'),
                    for (final conversion
                        in (parts['conversions'] as List? ?? []))
                      Text(
                          '${conversion['label']}: ${formatMinorUnits(conversion['original'] as int, CurrencyCode.tryParse(conversion['from'] as String)!)} → ${formatMinorUnits(conversion['converted'] as int, CurrencyCode.tryParse(conversion['to'] as String)!)}; rate ${conversion['rate']}'),
                    if ((parts['conversions'] as List? ?? []).isNotEmpty)
                      Text(
                          'Rates: ${parts['rateSource']} • As of ${parts['rateAsOf']}'),
                    const Text(
                        'Saved snapshot. Later source edits do not rewrite this contribution.'),
                  ],
                  if (code != null)
                    Text(
                        'Vault balance after entry: ${formatMinorUnits(entry.balanceAfterMinor, code)}'),
                ],
              ));
            }),
      );
}

class _RecoveryEvidence extends StatelessWidget {
  const _RecoveryEvidence({required this.json});
  final String json;
  @override
  Widget build(BuildContext context) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map || decoded['recovery'] is! Map) {
        return const SizedBox.shrink();
      }
      final evidence = decoded['recovery'] as Map;
      final rawTime = evidence['confirmedAt'];
      final confirmed = rawTime is String ? DateTime.tryParse(rawTime) : null;
      if (confirmed == null) {
        return const Text('Original recovery evidence needs review.');
      }
      return Text('Recovery confirmed: ${formatVaultTime(confirmed)}\n'
          'Source months: ${evidence['sourceMonths']}\nOriginal invalid values were preserved as diagnostic evidence, not savings.');
    } on FormatException {
      return const Text('Original recovery evidence needs review.');
    }
  }
}
