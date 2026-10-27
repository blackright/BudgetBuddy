import '../../../../core/models/currency_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/active_profile_provider.dart';
import '../../../../core/providers/active_space_provider.dart';
import '../../../../core/providers/active_budget_provider.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../../core/services/income_aggregation_service.dart';
import '../../../budget_setup/domain/onboarding_state.dart';
import '../../../budget_setup/providers/onboarding_readiness_provider.dart';
import '../../../finance/providers/income_source_providers.dart';
import '../../../finance/providers/profile_providers.dart';
import '../../../finance/presentation/opening_balance_sheet.dart';
import '../../../engine/providers/true_available_provider.dart';

class SetupSuggestion {
  const SetupSuggestion(this.title, this.detail, this.route, this.icon);
  final String title, detail, route;
  final IconData icon;
}

final onboardingGuidanceEligibleProvider = Provider<bool>((ref) {
  final startup = ref.watch(onboardingStartupProvider);
  final owner = ref.watch(activeProfileProvider);
  final saved = startup.valueOrNull?.state;
  return !startup.hasError &&
      !startup.isLoading &&
      !owner.hasError &&
      !owner.isLoading &&
      ref.watch(activeSpaceIdProvider) == null &&
      saved?.stage == OnboardingStage.completed &&
      saved?.committed?.profileId == owner.valueOrNull?.id;
});
final onboardingGuidanceProvider =
    Provider<AsyncValue<List<SetupSuggestion>>>((ref) {
  if (!ref.watch(onboardingGuidanceEligibleProvider)) {
    return const AsyncData([]);
  }
  final month = ref.watch(activeBudgetProvider),
      sources = ref.watch(incomeSourcesProvider),
      profiles = ref.watch(budgetProfilesProvider),
      expenses = ref.watch(monthlyExpensesProvider);
  if (month.hasError ||
      sources.hasError ||
      profiles.hasError ||
      expenses.hasError) {
    return AsyncError(StateError('Guidance is unavailable'), StackTrace.empty);
  }
  if (month.isLoading ||
      sources.isLoading ||
      profiles.isLoading ||
      expenses.isLoading) {
    return const AsyncLoading();
  }
  final budget = month.valueOrNull,
      owner = ref.watch(activeProfileProvider).valueOrNull;
  if (budget == null || owner == null) return const AsyncLoading();
  final suggestions = <SetupSuggestion>[];
  if (!budget.openingBalanceConfirmed) {
    suggestions.add(const SetupSuggestion(
        'Confirm opening balance',
        'Record what was in your bank at the start of this month. Unknown is different from a confirmed zero.',
        'opening',
        Icons.account_balance_outlined));
  }
  final rows = sources.requireValue;
  if (rows.isEmpty) {
    suggestions.add(const SetupSuggestion(
        'Add income when you are ready',
        'No income sources are recorded. This is allowed; you can add a source later.',
        '/income_sources',
        Icons.add_card_outlined));
  } else if (rows.any((s) => !const IncomeAggregationService().isValid(s))) {
    suggestions.add(const SetupSuggestion(
        'Review income sources',
        'Some saved source information needs review. No value is guessed.',
        '/income_sources',
        Icons.info_outline));
  } else if (const IncomeAggregationService().monthlyTotal(
          rows, ref.watch(selectedYearMonthProvider),
          currency: owner.primaryCurrency.code) ==
      0) {
    suggestions.add(const SetupSuggestion(
        'Check this month?s income',
        'Your sources currently contribute zero in this month and currency. Check their amounts, recurrence and dates.',
        '/income_sources',
        Icons.event_note_outlined));
  }
  if (profiles.requireValue.every((p) => p.allocation <= 0)) {
    suggestions.add(const SetupSuggestion(
        'Plan your allocations',
        'Set aside money for the budget profiles you want to use.',
        '/allocations',
        Icons.pie_chart_outline));
  }
  if (expenses.requireValue.isEmpty) {
    suggestions.add(const SetupSuggestion(
        'Record your first expense',
        'Add a Planned or Paid purchase using its real details.',
        '/add_expense',
        Icons.receipt_long_outlined));
  }
  suggestions.addAll(const [
    SetupSuggestion(
        'Explore Medical',
        'Use the separate bill flow when you have a medical bill.',
        '/medical',
        Icons.health_and_safety_outlined),
    SetupSuggestion(
        'Explore Spaces',
        'Sharing is optional. Visit Spaces when you want to create or join a shared budget.',
        '/spaces',
        Icons.groups_outlined)
  ]);
  return AsyncData(suggestions);
});

class OnboardingGuidanceCard extends ConsumerWidget {
  const OnboardingGuidanceCard({super.key});
  void _open(BuildContext context, WidgetRef ref, SetupSuggestion suggestion) {
    if (suggestion.route == 'opening') {
      final budget = ref.read(activeBudgetProvider).valueOrNull;
      if (budget != null) {
        showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => OpeningBalanceSheet(initialBudget: budget));
      }
    } else {
      context.push(suggestion.route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(onboardingGuidanceEligibleProvider)) {
      return const SizedBox.shrink();
    }
    final state = ref.watch(onboardingGuidanceProvider);
    return Card(
        key: const Key('onboardingGuidance'),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: state.when(
              loading: () => Semantics(
                  liveRegion: true,
                  child: const Text('Checking your next steps...')),
              error: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Next steps could not be loaded. Your financial records have not been changed.'),
                    TextButton(
                        onPressed: () {
                          ref.invalidate(incomeSourcesProvider);
                          ref.invalidate(activeBudgetProvider);
                          ref.invalidate(budgetProfilesProvider);
                          ref.invalidate(monthlyExpensesProvider);
                        },
                        child: const Text('Retry guidance'))
                  ]),
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                final primary = items.first;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.auto_awesome_outlined,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text('Make this month yours',
                                style: Theme.of(context).textTheme.titleLarge))
                      ]),
                      const SizedBox(height: 16),
                      Text(primary.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(primary.detail),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                          onPressed: () => _open(context, ref, primary),
                          icon: Icon(primary.icon),
                          label:
                              Text(primary.title, textAlign: TextAlign.center)),
                      if (items.length > 1)
                        ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: const Text('More suggestions'),
                            children: [
                              for (final item in items.skip(1))
                                ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(item.icon),
                                    title: Text(item.title),
                                    subtitle: Text(item.detail),
                                    onTap: () => _open(context, ref, item))
                            ])
                    ]);
              },
            )));
  }
}
