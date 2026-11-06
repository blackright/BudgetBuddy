import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/pending_action.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../shared/presentation/modals/app_dialog.dart';
import '../../../shared/presentation/money_format.dart';
import '../models/savings_vault.dart';
import '../providers/vault_providers.dart';
import '../vault_suggestion_service.dart';
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
/// Money enters and leaves only through an explicit, previewed transfer, so the
/// total always reconciles with real confirmations. The vault is personal-only
/// and is never shared or synced (011/012 FR-015/FR-017), hence the blocked
/// state in a shared context.
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
                  'Saved in Vault',
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
                const SizedBox(height: 8),
                Text(
                  'Internal transfer - not spending and not income.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (current != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Updated: ${formatVaultTime(current.updatedAt)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 12),
                const _CheckSavingsButton(),
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
                'Earlier automatic savings paused',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              subtitle: Text(
                current?.pauseReason ??
                    'A previous automatic savings month could not be valued safely.',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _SuggestionsCard(),
        const SizedBox(height: 12),
        _PlannedWithdrawalsCard(),
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
        const VaultTransferPanel(),
        if (current?.totalMinor == corruptedMinorSentinel)
          OutlinedButton(
              onPressed: () => showAppDialog<void>(
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
                            onPressed: () => showAppDialog<void>(
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
              ? 'No savings yet. Your first deposit starts the Vault; earlier '
                  'months are never saved retroactively.'
              : 'Only a transfer you review and confirm moves money. A planned '
                  'withdrawal is a reminder and never withdraws by itself.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  String _totalText(SavingsVault? vault) {
    if (vault == null) return 'No savings yet';
    if (!vault.hasValidBalance) return 'Saved balance needs review';
    final code = vault.currencyCode;
    if (code == null) return 'Saved currency needs review (${vault.currency})';
    return formatMinorUnits(vault.totalMinor, code);
  }
}

/// Suggests finished months with money left. It never writes a Vault entry or
/// moves money; "Review deposit" opens the normal preview.
class _SuggestionsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(vaultDepositSuggestionsProvider).valueOrNull;
    if (suggestions == null || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Card(
      key: const Key('vaultSuggestions'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Money left to review',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'These finished months had money left. Nothing was saved '
              'automatically; choose what to deposit.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            for (final suggestion in suggestions)
              _SuggestionRow(suggestion: suggestion),
          ],
        ),
      ),
    );
  }
}

class _SuggestionRow extends ConsumerWidget {
  const _SuggestionRow({required this.suggestion});

  final PendingAction suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = CurrencyCode.tryParse(suggestion.currency ?? '');
    final amount = suggestion.expectedAmountMinor;
    final month = suggestion.expectedMonth ?? suggestion.recordRef;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.savings_outlined),
      title: Text(suggestion.title),
      subtitle: Text(
        amount != null && currency != null
            ? '${formatMinorUnits(amount, currency)} left in $month'
            : 'Review the finished month',
      ),
      trailing: TextButton(
        onPressed: () => showAppDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => VaultTransferDialog(
            kind: 'deposit',
            initialAmountMinor: amount,
            initialCurrency: suggestion.currency,
            completesActionType: suggestion.actionType,
            completesRecordRef: suggestion.recordRef,
            completesCycleOrMonth:
                suggestion.expectedMonth ?? suggestion.recordRef,
          ),
        ),
        child: const Text('Review deposit'),
      ),
    );
  }
}

/// Planned withdrawals are derived reminders. A due one opens the normal
/// withdrawal preview; no money moves until the user confirms.
class _PlannedWithdrawalsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planned = ref.watch(plannedVaultWithdrawalsProvider);
    if (planned.isEmpty) return const SizedBox.shrink();
    final currentMonth =
        vaultSuggestionCurrentMonth(ref.watch(vaultClockProvider)());
    final theme = Theme.of(context);
    return Card(
      key: const Key('vaultPlanned'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Planned withdrawals',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'A target month is a reminder only. Withdraw when you confirm.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            for (final item in planned)
              _PlannedRow(item: item, currentMonth: currentMonth),
          ],
        ),
      ),
    );
  }
}

class _PlannedRow extends StatelessWidget {
  const _PlannedRow({required this.item, required this.currentMonth});

  final PlannedVaultWithdrawal item;
  final String currentMonth;

  @override
  Widget build(BuildContext context) {
    final currency = CurrencyCode.tryParse(item.deposit.currency);
    final due = item.isDue(currentMonth);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(due ? Icons.notifications_active_outlined : Icons.schedule),
      title: Text('Planned for ${item.targetMonth}'),
      subtitle: Text(
        currency == null
            ? 'Amount needs review'
            : '${formatMinorUnits(item.deposit.amountMinor.abs(), currency)}'
                '${due ? ' - due now' : ''}',
      ),
      trailing: due
          ? TextButton(
              onPressed: () => showAppDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => VaultTransferDialog(
                  kind: 'withdrawal',
                  initialAmountMinor: item.deposit.amountMinor.abs(),
                  initialCurrency: item.deposit.currency,
                  completesActionType: vaultWithdrawalDueType,
                  completesRecordRef: item.deposit.operationKey,
                  completesCycleOrMonth: item.targetMonth,
                ),
              ),
              child: const Text('Withdraw'),
            )
          : null,
    );
  }
}

class _CheckSavingsButton extends ConsumerStatefulWidget {
  const _CheckSavingsButton();

  @override
  ConsumerState<_CheckSavingsButton> createState() =>
      _CheckSavingsButtonState();
}

class _CheckSavingsButtonState extends ConsumerState<_CheckSavingsButton> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: _busy
          ? null
          : () async {
              setState(() => _busy = true);
              try {
                final check = ref.read(vaultSuggestionCheckProvider);
                final result = await check();
                if (context.mounted) {
                  showFinancialFeedback(
                    context,
                    result.message,
                    kind:
                        result.pausedReason != null || result.skipped.isNotEmpty
                            ? FinancialFeedbackKind.warning
                            : FinancialFeedbackKind.success,
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  showFinancialFeedback(
                    context,
                    'The savings check could not finish. No savings were changed; retry safely.',
                    kind: FinancialFeedbackKind.error,
                  );
                }
              } finally {
                if (mounted) setState(() => _busy = false);
              }
            },
      icon: const Icon(Icons.savings_outlined),
      label: Text(_busy ? 'Checking...' : 'Check savings'),
    );
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
          'Switch back to your personal space to see money saved from your own '
          'finished months. Shared spaces never see or write this vault.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
