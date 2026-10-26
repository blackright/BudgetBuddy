import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../shared/presentation/money_format.dart';
import '../../engine/providers/sweep_provider.dart';
import '../models/savings_vault.dart';
import '../providers/vault_providers.dart';
import 'vault_goal.dart';
import 'vault_history.dart';
import 'vault_recovery_dialog.dart';
import 'vault_transfer_dialog.dart';
import 'vault_time.dart';
import '../../../core/database/money_integrity.dart'
    show corruptedMinorSentinel;

/// The personal Savings Vault.
///
/// The balance/history are read-only; the optional goal is editable metadata.
/// Money enters only through the end-of-month sweep, so
/// the total always reconciles with months that actually closed. The vault is
/// personal-only and is never shared or synced (011/012 FR-015/FR-017), hence
/// the blocked state in a shared context.
class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(budgetContextProvider).isShared) {
      return Scaffold(
        appBar: AppBar(title: const Text('Savings Vault')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: _BlockedInSharedSpace(),
        ),
      );
    }

    final vaultAsync = ref.watch(vaultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Vault')),
      body: vaultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load the vault: $error'),
          ),
        ),
        data: (vault) => _VaultBody(vault: vault),
      ),
    );
  }
}

class _VaultBody extends ConsumerWidget {
  const _VaultBody({required this.vault});

  final SavingsVault? vault;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final current = vault;
    final review = ref.watch(vaultReviewMessageProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Saved',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  review ?? _totalText(current),
                  key: const Key('vaultTotal'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (current != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Next month to check: ${current.lastSweepYearMonth}\nUpdated: ${formatVaultTime(current.updatedAt)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (current?.sweepPaused == true) ...[
          const SizedBox(height: 12),
          Card(
            color: theme.colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(Icons.pause_circle_outline,
                  color: theme.colorScheme.onErrorContainer),
              title: Text(
                'Sweep paused',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              subtitle: Text(
                current?.pauseReason ??
                    'The next month could not be valued safely.',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Personal only'),
            subtitle: Text(
              'The Savings Vault belongs to this profile. It is never shared '
              'with a space and never synced to another device.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SweepButton(
            key: ValueKey(ref.watch(activeProfileProvider).valueOrNull?.id)),
        if (current != null && current.hasValidBalance && review == null)
          const VaultTransferPanel(),
        if (current?.totalMinor == corruptedMinorSentinel)
          OutlinedButton(
              onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const VaultRecoveryDialog()),
              child: const Text('Review balance recovery')),
        if (current != null &&
            current.currencyCode != null &&
            current.hasValidBalance &&
            review == null) ...[
          const SizedBox(height: 12),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (current.goalTargetMinor != null)
                          VaultGoalProgress(
                              vault: current,
                              maxDeposit: ref
                                  .watch(vaultTransferReadinessProvider)
                                  .valueOrNull
                                  ?.maxDeposit),
                        TextButton.icon(
                            icon: const Icon(Icons.flag_outlined),
                            label: Text(current.goalTargetMinor == null
                                ? 'Add savings goal'
                                : 'Edit savings goal'),
                            onPressed: () => showDialog<void>(
                                context: context,
                                builder: (_) =>
                                    VaultGoalEditor(vault: current))),
                      ]))),
        ],
        const SizedBox(height: 12),
        const Text('Contribution history'),
        VaultHistory(
            key: ValueKey(
                'vault-history:${ref.watch(activeProfileProvider).valueOrNull?.id}')),
        const SizedBox(height: 8),
        Text(
          current == null
              ? 'No vault yet. It will start with the current month; earlier '
                  'months are never swept retroactively.'
              : 'Only a positive balance left at the end of a finished month is '
                  'swept. A month with an unconfirmed opening balance or an '
                  'unavailable rate pauses the sweep instead of guessing.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  String _totalText(SavingsVault? vault) {
    if (vault == null) return 'Not started';
    if (!vault.hasValidBalance) return 'Saved balance needs review';
    final code = vault.currencyCode;
    if (code == null) return 'Saved currency needs review (${vault.currency})';
    return formatMinorUnits(vault.totalMinor, code);
  }
}

class _SweepButton extends ConsumerStatefulWidget {
  const _SweepButton({super.key});
  @override
  ConsumerState<_SweepButton> createState() => _SweepButtonState();
}

class _SweepButtonState extends ConsumerState<_SweepButton> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    final result = ref.watch(sweepResultProvider);
    final id = ref.watch(activeProfileProvider).valueOrNull?.id;
    final code = result == null ? null : CurrencyCode.tryParse(result.currency);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FilledButton.tonalIcon(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    final checked = await ref
                        .read(sweepServiceProvider)
                        .executeSweepCheck();
                    if (context.mounted) {
                      showFinancialFeedback(context, checked.message,
                          kind: switch (checked.outcome) {
                            SweepOutcome.failed => FinancialFeedbackKind.error,
                            SweepOutcome.paused =>
                              FinancialFeedbackKind.warning,
                            _ => FinancialFeedbackKind.success,
                          });
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'The check could not finish. Review savings and audit history; earlier completed steps may have saved.')));
                    }
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          icon: const Icon(Icons.savings_outlined),
          label: Text(_busy ? 'Checking…' : 'Check for finished months')),
      if (result != null && result.profileId == id)
        Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
                '${result.outcome.name.toUpperCase()}: ${result.message}'
                '${result.addedMinor > 0 && code != null ? '\nAdded in this check: ${formatMinorUnits(result.addedMinor, code)}' : ''}')),
    ]);
  }
}

class _BlockedInSharedSpace extends StatelessWidget {
  const _BlockedInSharedSpace();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.outline),
        const SizedBox(height: 16),
        Text(
          'The Savings Vault is personal',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Switch back to your personal space to see money swept out of your '
          'own finished months. Shared spaces never see or write this vault.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
