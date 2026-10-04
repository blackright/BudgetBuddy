import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/isar_helper.dart';
import '../../core/models/monthly_budget.dart';
import '../../features/budget_setup/presentation/budget_setup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/medical/presentation/medical_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/presentation/app_shell.dart';
import '../../features/expenses/presentation/add_expense_screen.dart';
import '../../features/expenses/presentation/edit_expense_screen.dart';
import '../../features/expenses/presentation/category_list_screen.dart';
import '../../features/expenses/presentation/category_edit_screen.dart';
import '../../features/expenses/presentation/expense_detail_screen.dart';
import '../models/expense.dart';
import '../models/category.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorDashboardKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboardShell');
final shellNavigatorExpensesKey =
    GlobalKey<NavigatorState>(debugLabel: 'expensesShell');
final shellNavigatorMedicalKey =
    GlobalKey<NavigatorState>(debugLabel: 'medicalShell');
final shellNavigatorAnalyticsKey =
    GlobalKey<NavigatorState>(debugLabel: 'analyticsShell');
final shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'settingsShell');

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
    GoRoute(
      path: '/add_expense',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/expense_detail',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          ExpenseDetailScreen(expense: state.extra as Expense),
    ),
    GoRoute(
      path: '/edit_expense',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          EditExpenseScreen(expense: state.extra as Expense),
    ),
    GoRoute(
      path: '/categories',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CategoryListScreen(),
    ),
    GoRoute(
      path: '/categories/edit',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          CategoryEditScreen(category: state.extra as Category?),
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
