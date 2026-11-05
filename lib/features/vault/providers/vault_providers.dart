import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/pending_action.dart';

import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/database/isar_helper.dart';
import '../../pending_actions/providers/pending_actions_providers.dart';
import '../models/vault_entry.dart';
import '../models/savings_vault.dart';
import '../repositories/vault_repository.dart';
import '../vault_recovery_service.dart';
import '../vault_suggestion_service.dart';
import '../vault_transfer_service.dart';
import '../vault_transfer_ledger.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../finance/providers/finance_providers.dart';
import '../../finance/providers/profile_providers.dart';
import '../../finance/providers/income_source_providers.dart';
import '../../finance/providers/month_end_providers.dart';

final vaultClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final vaultNowProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  final clock = ref.watch(vaultClockProvider);
  yield clock();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => clock());
});

final vaultTransferReadinessProvider =
    FutureProvider.autoDispose<VaultTransferReadiness>((ref) {
  ref.watch(vaultHistoryProvider);
  ref.watch(vaultProvider);
  ref.watch(monthFinanceProvider);
  ref.watch(budgetProfilesProvider);
  ref.watch(directExpenseProfilesProvider);
  ref.watch(monthlyExpensesProvider);
  ref.watch(monthlyReimbursementsProvider);
  ref.watch(incomeSourcesProvider);
  ref.watch(monthEndRunsProvider);
  ref.watch(rateRegistryProvider);
  return ref.watch(vaultTransferServiceProvider).readiness();
});

final vaultTransferServiceProvider = Provider<VaultTransferService>((ref) {
  var alive = true;
  ref.onDispose(() => alive = false);
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(activeProfileProvider).valueOrNull?.id;
  if (context.isShared || actor == null || context.profileId != actor) {
    throw const VaultTransferException('Select the owning personal profile.');
  }
  return VaultTransferService(IsarHelper.instance,
      actorId: actor,
      isStillActive: () =>
          alive &&
          !ref.read(budgetContextProvider).isShared &&
          ref.read(budgetContextProvider).profileId == actor &&
          ref.read(activeProfileProvider).valueOrNull?.id == actor,
      actions: ref.watch(pendingActionServiceProvider),
      clock: ref.watch(vaultClockProvider));
});

/// Read-only discovery of finished months with money left to review.
final vaultSuggestionServiceProvider = Provider<VaultSuggestionService>((ref) {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(activeProfileProvider).valueOrNull?.id;
  if (context.isShared || actor == null || context.profileId != actor) {
    throw const VaultTransferException('Select the owning personal profile.');
  }
  return VaultSuggestionService(
    IsarHelper.instance,
    profileId: actor,
    registry: ref.watch(rateRegistryProvider),
    actions: ref.watch(pendingActionServiceProvider),
    clock: ref.watch(vaultClockProvider),
  );
});

/// Manual "Check savings" entry point. It never moves money.
final vaultSuggestionCheckProvider =
    Provider<Future<VaultSuggestionResult> Function()>((ref) {
  final service = ref.watch(vaultSuggestionServiceProvider);
  return service.check;
});

/// Active deposit suggestions for the owning personal profile.
final vaultDepositSuggestionsProvider =
    StreamProvider.autoDispose<List<PendingAction>>((ref) {
  final context = ref.watch(budgetContextProvider);
  if (context.isShared ||
      IsarHelper.maybeInstance == null ||
      context.profileId == null) {
    return Stream.value(const <PendingAction>[]);
  }
  return ref
      .watch(pendingActionServiceProvider)
      .watch(profileId: context.profileId, sharedSpaceId: null)
      .map(activeVaultDepositSuggestions);
});

/// Planned withdrawals derived from immutable Vault history. A target month is
/// a reminder only, so this never reserves or moves money.
final plannedVaultWithdrawalsProvider =
    Provider.autoDispose<List<PlannedVaultWithdrawal>>((ref) {
  final context = ref.watch(budgetContextProvider);
  if (context.isShared) return const [];
  final history = ref.watch(vaultHistoryProvider).valueOrNull ?? const [];
  final actions = ref.watch(pendingActionsProvider).valueOrNull ?? const [];
  return plannedWithdrawalsFrom(
    history: history,
    actions: actions,
  );
});

/// Source-month credit, separate from income/spending/opening funds.
final monthlyVaultCreditProvider = Provider<int>((ref) {
  final context = ref.watch(budgetContextProvider);
  if (context.isShared) return 0;
  final owner = ref.watch(activeProfileProvider).valueOrNull;
  if (owner == null || owner.id != context.profileId) return 0;
  final history = ref.watch(vaultHistoryProvider);
  if (history.hasError) {
    throw const FormatException('Vault transfers could not be verified.');
  }
  return monthlyVaultCredit(
      history.valueOrNull ?? [], context.yearMonth, owner.primaryCurrency.code);
});

/// The active personal profile's vault, or `null` before the first sweep.
///
/// The vault is personal-only; a shared space never watches or writes it, which
/// is why this provider is keyed by the personal profile and not by the budget
/// context.
final vaultProvider = StreamProvider<SavingsVault?>((ref) {
  final context = ref.watch(budgetContextProvider);
  if (context.isShared || IsarHelper.maybeInstance == null) {
    return Stream.value(null);
  }
  final profile = ref.watch(activeProfileProvider).value;
  if (profile == null || profile.id != context.profileId) {
    return Stream.value(null);
  }
  return ref.watch(vaultRepositoryProvider).watchVault(profile.id);
});

final vaultHistoryProvider = StreamProvider<List<VaultEntry>>((ref) {
  final context = ref.watch(budgetContextProvider);
  if (context.isShared || IsarHelper.maybeInstance == null) {
    return Stream.value([]);
  }
  final id = ref.watch(activeProfileProvider).valueOrNull?.id;
  return id == null || id != context.profileId
      ? Stream.value([])
      : ref.watch(vaultRepositoryProvider).watchHistory(id);
});

final vaultReviewMessageProvider = Provider<String?>((ref) {
  final vault = ref.watch(vaultProvider).valueOrNull;
  if (vault == null) return null;
  if (!vault.hasValidBalance) return 'Saved balance needs review';
  final history = ref.watch(vaultHistoryProvider);
  return history.when(
      data: (rows) => vaultEntriesProblem(vault, rows),
      error: (_, __) => 'Saved history could not be verified',
      loading: () => 'Verifying saved history…');
});

final vaultRecoveryServiceProvider = Provider<VaultRecoveryService>((ref) {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(activeProfileProvider).valueOrNull?.id;
  if (context.isShared || actor == null || context.profileId != actor) {
    throw const VaultRecoveryException('Select the owning personal profile.');
  }
  return VaultRecoveryService(IsarHelper.instance,
      actorId: actor,
      isStillActive: () =>
          !ref.read(budgetContextProvider).isShared &&
          ref.read(budgetContextProvider).profileId == actor &&
          ref.read(activeProfileProvider).valueOrNull?.id == actor);
});
