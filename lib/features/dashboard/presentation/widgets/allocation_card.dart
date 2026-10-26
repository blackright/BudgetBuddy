import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../engine/providers/month_summary_provider.dart';
import '../../providers/dashboard_providers.dart';
import '../budget_status.dart';

/// The Allocation card on the dashboard.
///
/// Shows how much money is set aside in budget profiles, how much of it has
/// already been spent, how much is still sitting in the envelopes, and how
/// much is free to spend. The free-to-spend figure is the **same** number
/// as "Kept this month", so the two cards never contradict each other
/// (T146, T149, T154).
class AllocationCard extends ConsumerWidget {
  const AllocationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(dashboardCurrencyProvider);
    final profiles = ref.watch(dashboardProfilesProvider);
    final monthSummary = ref.watch(monthSummaryProvider);

    // The month summary already converts to the display currency, so these
    // are safe to format directly (T154).
    final allocated = monthSummary.allocated;
    final setAside = monthSummary.setAside;
    final freeToSpend = monthSummary.kept;
    final spentFromProfiles = allocated - setAside;

    // Empty state: nothing set aside yet.
    if (allocated <= 0 && profiles.isEmpty) {
      return _EmptyAllocationCard();
    }

    return Card(
      child: InkWell(
        onTap: () => context.push('/allocations'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Allocation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              _AllocationLine(
                label: 'Allocated this month',
                value: formatMajorUnits(allocated, currency),
              ),
              _AllocationLine(
                label: 'Spent from profiles',
                value: formatMajorUnits(spentFromProfiles, currency),
              ),
              _AllocationLine(
                label: 'Set aside (still in envelopes)',
                value: formatMajorUnits(setAside, currency),
              ),
              const Divider(height: 20),
              _AllocationLine(
                label: 'Free to spend',
                value: formatMajorUnits(freeToSpend, currency),
                bold: true,
              ),
              const SizedBox(height: 12),
              _StackedBar(profiles: profiles, currency: currency),
              // Direct profiles spend from the reserve, not from an allocation.
              ..._directProfileLines(profiles, currency),
            ],
          ),
        ),
      ),
    );
  }

  /// A line for each direct expense profile (T146, FR-002, T154).
  ///
  /// D5/T167: `DashboardProfileState.spent` is already converted into the
  /// display currency, so formatting it again would convert twice.
  List<Widget> _directProfileLines(
    List<DashboardProfileState> profiles,
    CurrencyCode displayCurrency,
  ) {
    final direct = profiles.where((p) => p.isDirect).toList();
    if (direct.isEmpty) return const [];
    return [
      const SizedBox(height: 12),
      for (final profile in direct)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '${profile.name} — spent from reserve: '
            '${formatMinorUnits(profile.spent, displayCurrency)}',
            style: const TextStyle(fontSize: 13),
          ),
        ),
    ];
  }
}

/// One labelled amount in the Allocation card.
class _AllocationLine extends StatelessWidget {
  const _AllocationLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// The stacked bar showing each profile's share of the total allocation.
class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.profiles, required this.currency});

  final List<DashboardProfileState> profiles;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final budgetProfiles = profiles.where((p) => !p.isDirect).toList();
    final total = budgetProfiles.fold<int>(0, (s, p) => s + p.allocation);
    if (total <= 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            for (final profile in budgetProfiles)
              if (profile.allocation > 0)
                Expanded(
                  flex: profile.allocation,
                  child: Container(color: profile.status.color),
                ),
          ],
        ),
      ),
    );
  }
}

/// Shown when nothing has been allocated yet.
class _EmptyAllocationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allocation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Allocated this month: 0',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push('/allocations'),
              icon: const Icon(Icons.add),
              label: const Text('Set up your budgets'),
            ),
          ],
        ),
      ),
    );
  }
}
