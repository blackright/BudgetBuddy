import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../engine/providers/safe_to_spend_provider.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/models/user_profile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trueAvailableAsync = ref.watch(trueAvailableProvider);
    final safeToSpendAsync = ref.watch(safeToSpendProvider);
    final activeBudget = ref.watch(activeBudgetProvider).value;

    String currencySymbol = '\$';
    if (activeBudget != null) {
      switch (activeBudget.currency) {
        case PrimaryCurrency.huf: currencySymbol = 'Ft'; break;
        case PrimaryCurrency.usd: currencySymbol = '\$'; break;
        case PrimaryCurrency.cad: currencySymbol = 'C\$'; break;
        case PrimaryCurrency.eur: currencySymbol = '€'; break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('Safe to Spend',
                          style: TextStyle(fontSize: 16)),
                      Text(
                        '$currencySymbol${NumberFormat('#,##0.00').format(safeToSpendAsync)}',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const Divider(height: 32),
                      const Text('True Available',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        '$currencySymbol${NumberFormat('#,##0.00').format(trueAvailableAsync)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Actions',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () => context.push('/add_expense'),
                        child: _buildActionButton(Icons.add, 'Add Expense'),
                      ),
                      _buildActionButton(Icons.medical_services, 'Medical'),
                      _buildActionButton(Icons.history, 'History'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
