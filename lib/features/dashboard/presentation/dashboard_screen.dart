import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../engine/providers/safe_to_spend_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trueAvailableAsync = ref.watch(trueAvailableProvider);
    final safeToSpendAsync = ref.watch(safeToSpendProvider);

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
                        '\$${safeToSpendAsync.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const Divider(height: 32),
                      const Text('True Available',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        '\$${trueAvailableAsync.toStringAsFixed(2)}',
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
                      _buildActionButton(Icons.add, 'Add Expense'),
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
