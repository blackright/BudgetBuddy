import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/widgets/sync_status_chip.dart';
import '../../budget_setup/providers/setup_handoff_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import 'dashboard_copy.dart';
import 'month_navigator.dart';
import 'widgets/budgets_ledger.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/dashboard_overflow_menu.dart';
import 'widgets/dashboard_row.dart';
import 'widgets/secondary_rows.dart';

/// The monthly financial verdict (FR-018).
///
/// The default view now answers one question: what did the user keep this
/// month? The hero carries the single figure, the statement row opens the full
/// explanation, and everything else is added by later phases.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(selectedYearMonthProvider, (previous, next) {
      if (previous == next) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });

    final activeBudget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    final handoff = ref.watch(setupHandoffProvider);
    final yearMonth = ref.watch(selectedYearMonthProvider);
    if (setupHandoffArrived(handoff,
        profileId: profile?.id,
        isShared: ref.watch(activeSpaceIdProvider) != null,
        budgetId: activeBudget?.id,
        yearMonth: yearMonth)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && ref.read(setupHandoffProvider) == handoff) {
          ref.read(setupHandoffProvider.notifier).state = null;
        }
      });
    }
    final canEdit = ref.watch(activeContextCanEditProvider);
    final activeSpaceId = ref.watch(activeSpaceIdProvider);
    final statementLabel = DashboardCopy.monthStatementLabel(yearMonth);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 48,
        title: const MonthNavigator(),
        // FR-008/US3 AC6: the space's sync state belongs on the month screen,
        // visible without opening settings. It cannot share the title line — the
        // month navigator already fills it — so the badge sits directly under
        // the month, still inside the app bar, so it never scrolls away.
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
        actions: const [DashboardOverflowMenu()],
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
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    const DashboardHero(),
                    const SizedBox(height: 16),
                    DashboardRow(
                      key: const Key('monthStatementRow'),
                      label: statementLabel,
                      leading: Icon(
                        Icons.receipt_long_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: scheme.onSurfaceVariant,
                      ),
                      onTap: () => context.push('/month_summary_detail'),
                      semanticLabel:
                          'Month breakdown, $statementLabel, open breakdown',
                    ),
                    if (canEdit) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardActionButton(
                              key: const Key('addExpenseAction'),
                              icon: Icons.add,
                              label: DashboardCopy.addExpense,
                              filled: true,
                              onTap: () => context.push('/add_expense'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashboardActionButton(
                              key: const Key('addMedicalBillAction'),
                              icon: Icons.medical_services_outlined,
                              label: DashboardCopy.addMedicalBill,
                              filled: false,
                              onTap: () => context.push('/medical_bill_form'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    const BudgetsLedger(),
                    const SizedBox(height: 16),
                    const SecondaryRows(),
                    const SizedBox(height: 24),
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

class _DashboardActionButton extends StatelessWidget {
  const _DashboardActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = filled ? scheme.primary : scheme.primaryContainer;
    final foreground = filled ? scheme.onPrimary : scheme.onPrimaryContainer;

    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: 64,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: foreground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
