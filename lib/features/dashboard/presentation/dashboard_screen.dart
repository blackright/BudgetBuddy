import '../../budget_setup/providers/setup_handoff_provider.dart';
import 'widgets/onboarding_guidance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/expense.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/widgets/month_incomplete_banner.dart';
import '../../../shared/presentation/widgets/sync_status_chip.dart';
import '../../analytics/presentation/widgets/analytics_mini_charts.dart';
import '../../engine/currency_resolution.dart';
import '../../spaces/presentation/move_month_sheet.dart';
import '../../spaces/providers/spaces_providers.dart';
import 'month_navigator.dart';
import 'widgets/allocation_card.dart';
import 'widgets/savings_vault_card.dart';
import 'widgets/budget_profile_cards.dart';
import 'widgets/month_convert_to_menu.dart';
import 'widgets/month_summary_card.dart';
import 'widgets/month_summary_details.dart';

/// The monthly financial verdict (FR-018).
///
/// Rebuilt around a single dominant figure — what the user kept this month —
/// with everything else subordinate or collapsed. Safe to Spend and True
/// Available are gone from this view (FR-023); their providers remain for the
/// expense screens, which still need them.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBudget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    final handoff = ref.watch(setupHandoffProvider);
    if (setupHandoffArrived(handoff,
        profileId: profile?.id,
        isShared: ref.watch(activeSpaceIdProvider) != null,
        budgetId: activeBudget?.id,
        yearMonth: ref.watch(selectedYearMonthProvider))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && ref.read(setupHandoffProvider) == handoff) {
          ref.read(setupHandoffProvider.notifier).state = null;
        }
      });
    }
    final canEdit = ref.watch(activeContextCanEditProvider);
    final activeSpaceId = ref.watch(activeSpaceIdProvider);
    final personal = !ref.watch(budgetContextProvider).isShared;
    final display =
        resolveDisplayCurrency(month: activeBudget, profile: profile);
    final symbol = display.symbol;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, toolbarHeight: 48,
        title: const MonthNavigator(),
        // FR-008/US3 AC6: the space's sync state belongs on the month screen,
        // visible without opening settings. It cannot share the title line — the
        // month navigator already fills it (288 logical px of the ~232 a 360 px
        // phone leaves), so the badge sits directly **under** the month, still
        // inside the app bar, so it never scrolls away. Only a shared space has a
        // peer, so a personal month keeps the shorter app bar.
        bottom: activeSpaceId == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: SizedBox(
                  height: 30,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: SyncStatusChip(spaceId: activeSpaceId),
                    ),
                  ),
                ),
              ),
        actions: [
          if (activeBudget != null && canEdit) const MonthConvertToMenu(),
          if (activeBudget != null && canEdit)
            IconButton(
              key: const Key('moveMonthButton'),
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Move this month',
              onPressed: () => MoveMonthSheet.show(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < -300) {
                    ref
                        .read(selectedYearMonthProvider.notifier)
                        .update((state) => nextMonth(state));
                  } else if (details.primaryVelocity! > 300) {
                    ref
                        .read(selectedYearMonthProvider.notifier)
                        .update((state) => previousMonth(state));
                  }
                }
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (!ref.watch(onboardingGuidanceEligibleProvider))
                      MonthIncompleteBanner(currencySymbol: symbol),
                    MonthSummaryCard(
                      currency: display,
                      // US8: insurance returns came from medical bills; expense
                      // returns came from ordinary expenses.
                      onInsuranceReturnTap: () => context.go('/medical'),
                      onExpenseReturnTap: () => context.go(
                        '/expenses',
                        extra: {'status': ExpenseStatus.reimbursed.name},
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (activeSpaceId == null) const OnboardingGuidanceCard(),
                    const AllocationCard(),
                    if (activeSpaceId == null) ...[
                      const SizedBox(height: 12),
                      const SavingsVaultCard(),
                    ],
                    const SizedBox(height: 12),
                    MonthSummaryDetails(
                      currency: display,
                      // The selected month lives in a provider, so the Medical tab opens
                      // on the same month with no route parameter to carry (FR-022,
                      // FR-027).
                      onMedicalTap: () => context.go('/medical'),
                      onInsuranceReturnTap: () => context.go('/medical'),
                      onExpenseReturnTap: () => context.go(
                        '/expenses',
                        extra: {'status': ExpenseStatus.reimbursed.name},
                      ),
                    ),
                    const SizedBox(height: 12),
                    // T142: the profiles section sits between the month details
                    // and the analytics, so the budget picture is read before
                    // the charts.
                    const BudgetProfileCards(),
                    const SizedBox(height: 12),
                    const AnalyticsMiniCharts(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.bolt_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick actions',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Jump straight to what you need',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final actions = <_QuickAction>[
                          if (canEdit)
                            _QuickAction(
                              icon: Icons.add_card_outlined,
                              label: 'Add Expense',
                              hint: 'Record new spending',
                              color: Theme.of(context).colorScheme.primary,
                              onTap: () => context.push('/add_expense'),
                            ),
                          _QuickAction(
                            icon: Icons.medical_services_outlined,
                            label: 'Medical',
                            hint: 'Claims, bills and refunds',
                            color: Colors.teal,
                            onTap: () => context.go('/medical'),
                          ),
                          if (personal)
                            _QuickAction(
                              key: const Key('vaultQuickAction'),
                              icon: Icons.savings_outlined,
                              label: 'Savings Vault',
                              hint: 'Your saved money and history',
                              color: Colors.indigo,
                              onTap: () => context.push('/vault'),
                            ),
                          _QuickAction(
                            icon: Icons.history,
                            label: 'History',
                            hint: 'Your audit trail',
                            color: Colors.purple,
                            onTap: () => context.push('/audit_history'),
                          ),
                        ];
                        final columns = constraints.maxWidth >= 540 ? 3 : 2;
                        final width =
                            (constraints.maxWidth - (columns - 1) * 12) /
                                columns;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final action in actions)
                              SizedBox(
                                width: width,
                                child: _QuickActionCard(
                                    key: action.key, action: action),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    this.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  final Key? key;
  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({super.key, required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: action.color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: action.color.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(action.icon, color: action.color, size: 21),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded,
                      size: 17, color: action.color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: action.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                action.hint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.25,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
