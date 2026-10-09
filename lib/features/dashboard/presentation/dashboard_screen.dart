import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/widgets/month_incomplete_banner.dart';
import '../../engine/currency_resolution.dart';
import 'month_navigator.dart';
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
    final display =
        resolveDisplayCurrency(month: activeBudget, profile: profile);
    final symbol = display.symbol;

    return Scaffold(
      appBar: AppBar(
        title: const MonthNavigator(),
        actions: [
          if (activeBudget != null) const MonthConvertToMenu(),
        ],
      ),
      body: GestureDetector(
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
              MonthIncompleteBanner(currencySymbol: symbol),
              MonthSummaryCard(currency: display),
              const SizedBox(height: 12),
              MonthSummaryDetails(
                currency: display,
                // The selected month lives in a provider, so the Medical tab opens
                // on the same month with no route parameter to carry (FR-022,
                // FR-027).
                onMedicalTap: () => context.go('/medical'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () => context.push('/add_expense'),
                    child: _buildActionButton(Icons.add, 'Add Expense'),
                  ),
                  InkWell(
                    onTap: () => context.go('/medical'),
                    child:
                        _buildActionButton(Icons.medical_services, 'Medical'),
                  ),
                  _buildActionButton(Icons.history, 'History'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(radius: 28, child: Icon(icon, size: 28)),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
