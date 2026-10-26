import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/budget_context_provider.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../vault/providers/vault_providers.dart';
import '../../../vault/presentation/vault_goal.dart';

class SavingsVaultCard extends ConsumerWidget {
  const SavingsVaultCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(budgetContextProvider).isShared) {
      return const SizedBox.shrink();
    }
    final data = ref.watch(vaultProvider);
    final review = ref.watch(vaultReviewMessageProvider);
    return Card(
        child: InkWell(
      onTap: () => context.push('/vault'),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Savings Vault • across months'),
            const SizedBox(height: 8),
            data.when(
              loading: () => const Text('Loading savings…'),
              error: (_, __) =>
                  const Text('Savings could not be loaded. Tap to retry.'),
              data: (vault) => vault == null
                  ? const Text('Start your personal Savings Vault')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                              review ??
                                  (!vault.hasValidBalance
                                      ? 'Saved balance needs review'
                                      : vault.currencyCode == null
                                          ? 'Saved currency needs review'
                                          : formatMinorUnits(vault.totalMinor,
                                              vault.currencyCode!)),
                              style: Theme.of(context).textTheme.titleLarge),
                          if (vault.sweepPaused)
                            const Text('Sweep paused • review in vault'),
                          if (review == null &&
                              vault.hasValidBalance &&
                              vault.goalTargetMinor != null) ...[
                            const SizedBox(height: 8),
                            VaultGoalProgress(vault: vault)
                          ],
                        ]),
            ),
          ])),
    ));
  }
}
