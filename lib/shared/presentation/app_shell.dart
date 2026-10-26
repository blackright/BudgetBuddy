import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/active_profile_provider.dart';

import '../../core/models/medical_bill.dart';
import '../../core/providers/clock_provider.dart';
import '../../features/medical/providers/medical_providers.dart';
import 'widgets/spaces_dropdown.dart';
import '../../core/providers/budget_context_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  String? visitedOwner;
  final visitedBranches = <int>{};
  String get ownerKey {
    final owner = ref.read(budgetContextProvider);
    return '${ref.read(actingProfileIdProvider)}:${owner.profileId}:${owner.spaceId}';
  }

  void _goBranch(int index) {
    if (visitedOwner != ownerKey) {
      visitedOwner = ownerKey;
      visitedBranches.clear();
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex ||
          !visitedBranches.contains(index),
    );
    visitedBranches.add(index);
  }

  @override
  Widget build(BuildContext context) {
    final currentOwner = ownerKey;
    if (visitedOwner != currentOwner) {
      if (visitedOwner == null) {
        visitedBranches.addAll([0, 1, 2, 3, 4]);
      } else {
        visitedBranches.clear();
      }
      visitedOwner = currentOwner;
      visitedBranches.add(widget.navigationShell.currentIndex);
    }
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
      body: Column(
        children: [
          // US2: the context switch point every tab shares (T034, context-router
          // §3). A single activeSpaceId/activeProfileId write re-derives every
          // screen below in the same frame.
          const SafeArea(
            bottom: false,
            child: SpacesDropdown(),
          ),
          Expanded(
              child: KeyedSubtree(
                  key: ValueKey(
                      '${ref.watch(budgetContextProvider).profileId}:${ref.watch(budgetContextProvider).spaceId}'),
                  child: widget.navigationShell)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
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
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Spaces',
          ),
        ],
      ),
    );
  }
}
