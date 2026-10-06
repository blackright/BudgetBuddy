import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/medical/providers/medical_providers.dart';
import '../../core/providers/clock_provider.dart';
import '../../core/models/medical_bill.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check due or overdue bills
    final medicalBillsAsync = ref.watch(medicalBillsProvider);
    final now = ref.watch(clockProvider);

    int dueOrOverdueCount = 0;
    if (medicalBillsAsync.value != null) {
      for (final bill in medicalBillsAsync.value!) {
        if (bill.followUpDate != null && bill.state.isPending) {
          if (bill.followUpDate!.isBefore(now) ||
              bill.followUpDate!.difference(now).inHours < 24) {
            dueOrOverdueCount++;
          }
        }
      }
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: dueOrOverdueCount > 0,
              label: Text(dueOrOverdueCount.toString()),
              child: const Icon(Icons.medical_services_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: dueOrOverdueCount > 0,
              label: Text(dueOrOverdueCount.toString()),
              child: const Icon(Icons.medical_services),
            ),
            label: 'Medical',
          ),
          const NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
