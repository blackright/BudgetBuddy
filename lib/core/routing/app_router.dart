import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import '../database/isar_helper.dart';
import '../../core/models/monthly_budget.dart';
import '../../features/budget_setup/presentation/budget_setup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/medical/presentation/medical_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/presentation/app_shell.dart';
import '../../features/expenses/presentation/add_expense_placeholder.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboardShell');
final shellNavigatorExpensesKey = GlobalKey<NavigatorState>(debugLabel: 'expensesShell');
final shellNavigatorMedicalKey = GlobalKey<NavigatorState>(debugLabel: 'medicalShell');
final shellNavigatorAnalyticsKey = GlobalKey<NavigatorState>(debugLabel: 'analyticsShell');
final shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settingsShell');

String _getInitialLocation() {
  final hasBudget = IsarHelper.instance.monthlyBudgets.countSync() > 0;
  return hasBudget ? '/dashboard' : '/setup';
}

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: _getInitialLocation(),
  routes: [
    GoRoute(
      path: '/setup',
      builder: (context, state) => const BudgetSetupScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: shellNavigatorDashboardKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: shellNavigatorExpensesKey,
          routes: [
            GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpensesScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddExpensePlaceholder(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: shellNavigatorMedicalKey,
          routes: [
            GoRoute(
              path: '/medical',
              builder: (context, state) => const MedicalScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: shellNavigatorAnalyticsKey,
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
