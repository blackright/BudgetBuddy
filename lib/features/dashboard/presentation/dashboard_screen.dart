import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../shared/presentation/widgets/month_incomplete_banner.dart';
import 'month_navigator.dart';
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
    final symbol = currencySymbol(activeBudget);

    return Scaffold(
      appBar: AppBar(
        title: const MonthNavigator(),
        actions: [
          if (activeBudget != null)
            PopupMenuButton<PrimaryCurrency>(
              initialValue: activeBudget.currency,
              icon: const Icon(Icons.currency_exchange),
              tooltip: 'Change Currency',
              onSelected: (currency) => _changeCurrency(activeBudget, currency),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: PrimaryCurrency.usd,
                  child: Text('USD (\$)'),
                ),
                PopupMenuItem(
                  value: PrimaryCurrency.eur,
                  child: Text('EUR (€)'),
                ),
                PopupMenuItem(
                  value: PrimaryCurrency.cad,
                  child: Text('CAD (C\$)'),
                ),
                PopupMenuItem(
                  value: PrimaryCurrency.huf,
                  child: Text('HUF (Ft)'),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MonthIncompleteBanner(currencySymbol: symbol),
          MonthSummaryCard(currencySymbol: symbol),
          const SizedBox(height: 12),
          MonthSummaryDetails(
            currencySymbol: symbol,
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
                child: _buildActionButton(Icons.medical_services, 'Medical'),
              ),
              _buildActionButton(Icons.history, 'History'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changeCurrency(
    MonthlyBudget budget,
    PrimaryCurrency currency,
  ) async {
    final isar = IsarHelper.instance;
    budget.currency = currency;
    await isar.writeTxn(() async {
      await isar.monthlyBudgets.put(budget);
    });
  }

  static String currencySymbol(MonthlyBudget? budget) {
    if (budget == null) return r'$';
    return switch (budget.currency) {
      PrimaryCurrency.huf => 'Ft',
      PrimaryCurrency.usd => r'$',
      PrimaryCurrency.cad => r'C$',
      PrimaryCurrency.eur => '€',
    };
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
