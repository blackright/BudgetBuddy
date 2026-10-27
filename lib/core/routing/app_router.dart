import '../models/user_profile.dart';
import '../../features/budget_setup/presentation/introduction_screen.dart';
import '../../features/finance/presentation/audit_history_screen.dart';
import '../../features/finance/presentation/month_end_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_context_provider.dart';
import '../providers/active_profile_provider.dart';
import 'package:go_router/go_router.dart';
import '../database/isar_helper.dart';
import '../../features/budget_setup/presentation/budget_setup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/month_summary_detail_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/medical/presentation/medical_dashboard.dart';
import '../../features/medical/presentation/medical_bill_form.dart';
import '../../features/medical/presentation/medical_detail_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/analytics/presentation/reports_screen.dart';
import '../../features/spaces/presentation/spaces_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/vault/presentation/vault_screen.dart';
import '../../shared/presentation/app_shell.dart';
import '../../features/expenses/presentation/add_expense_screen.dart';
import '../../features/expenses/presentation/bulk_entry_screen.dart';
import '../../features/expenses/presentation/edit_expense_screen.dart';
import '../../features/expenses/presentation/category_list_screen.dart';
import '../../features/expenses/presentation/category_edit_screen.dart';
import '../../features/expenses/presentation/profile_expenses_screen.dart';
import '../../features/expenses/presentation/expense_detail_screen.dart';
import '../../features/finance/presentation/allocations_screen.dart';
import '../../features/finance/presentation/income_sources_screen.dart';
import '../../features/finance/presentation/profiles_screen.dart';
import '../../features/finance/presentation/transfer_screen.dart';
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
final shellNavigatorSpacesKey =
    GlobalKey<NavigatorState>(debugLabel: 'spacesShell');
final shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'settingsShell');

String _getInitialLocation() {
  // A missing month is provisioned normally; it is not a missing identity.
  final hasProfile = IsarHelper.instance.userProfiles.countSync() > 0;
  return hasProfile ? '/dashboard' : '/setup';
}

GoRouter createAppRouter(
        {String? initialLocation,
        Listenable? refreshListenable,
        GoRouterRedirect? redirect,
        WidgetBuilder? setupBuilder,
        WidgetBuilder? dashboardBuilder}) =>
    GoRouter(
      navigatorKey: rootNavigatorKey,
      refreshListenable: refreshListenable,
      redirect: redirect,
      initialLocation: initialLocation ?? _getInitialLocation(),
      routes: [
        GoRoute(
            path: '/introduction',
            builder: (context, state) => const IntroductionScreen()),
        GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen()),
        GoRoute(
          path: '/setup',
          builder: (context, state) =>
              setupBuilder?.call(context) ?? const BudgetSetupScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
            path: '/audit_history',
            builder: (context, state) => const AuditHistoryScreen()),
        GoRoute(
          path: '/vault',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const VaultScreen(),
        ),
        GoRoute(
          path: '/income_sources',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const IncomeSourcesScreen(),
        ),
        GoRoute(
          path: '/profiles',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const ProfilesScreen(),
        ),
        GoRoute(
          path: '/transfers',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const TransferScreen(),
        ),
        GoRoute(
          path: '/profile_expenses/:id',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => ProfileExpensesScreen(
            profileId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            profileType: state.uri.queryParameters['type'] ??
                FinancialProfileType.budget,
          ),
        ),
        GoRoute(
            path: '/month_end',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const MonthEndScreen()),
        GoRoute(
          path: '/allocations',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AllocationsScreen(),
        ),
        GoRoute(
          path: '/month_summary_detail',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const MonthSummaryDetailScreen(),
        ),
        GoRoute(
          path: '/bulk_entry',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const BulkEntryScreen(),
        ),
        GoRoute(
            path: '/reports',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ReportsScreen()),
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
        GoRoute(
          path: '/medical_detail',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              MedicalDetailScreen(billId: state.extra as int),
        ),
        GoRoute(
          path: '/medical_bill_form',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              MedicalBillFormRoute(billId: state.extra as int?),
        ),
        GoRoute(
          path: '/edit_medical_bill',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) =>
              MedicalBillFormRoute(billId: state.extra as int),
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
                  builder: (context, state) => _ContextRoot(
                      child: dashboardBuilder?.call(context) ??
                          const DashboardScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: shellNavigatorExpensesKey,
              routes: [
                GoRoute(
                  path: '/expenses',
                  builder: (context, state) {
                    final extra = state.extra;
                    String? categoryId;
                    String? statusName;
                    if (extra is Map) {
                      final c = extra['categoryId'];
                      if (c is String) categoryId = c;
                      final s = extra['status'];
                      if (s is String) statusName = s;
                    }
                    ExpenseStatus? status;
                    if (statusName != null) {
                      status = ExpenseStatus.values.firstWhere(
                        (e) => e.name == statusName,
                        orElse: () => ExpenseStatus.paid,
                      );
                    }
                    return _ContextRoot(
                        requestToken: state.extra,
                        child: ExpensesScreen(
                          key: ValueKey('$categoryId:$statusName'),
                          filterCategoryId: categoryId,
                          filterStatus: status,
                        ));
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: shellNavigatorMedicalKey,
              routes: [
                GoRoute(
                  path: '/medical',
                  builder: (context, state) =>
                      const _ContextRoot(child: MedicalDashboard()),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: shellNavigatorAnalyticsKey,
              routes: [
                GoRoute(
                  path: '/analytics',
                  builder: (context, state) =>
                      const _ContextRoot(child: AnalyticsScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: shellNavigatorSpacesKey,
              routes: [
                GoRoute(
                  path: '/spaces',
                  builder: (context, state) =>
                      const _ContextRoot(child: SpacesScreen()),
                ),
              ],
            ),
          ],
        ),
      ],
    );

final goRouter = createAppRouter();

/// Recreate owner-bound page state even in inactive cached shell branches.
class _ContextRoot extends ConsumerStatefulWidget {
  const _ContextRoot({required this.child, this.requestToken});
  final Widget child;
  final Object? requestToken;
  @override
  ConsumerState<_ContextRoot> createState() => _ContextRootState();
}

class _ContextRootState extends ConsumerState<_ContextRoot> {
  // A cached route may still carry a previous owner's chart-filter payload.
  // Reuse it only for its original owner or a newly issued route request.
  String? requestOwner;
  @override
  void didUpdateWidget(covariant _ContextRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.requestToken, widget.requestToken)) {
      requestOwner = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(budgetContextProvider),
        actor = ref.watch(actingProfileIdProvider);
    final ownerKey = '$actor:${owner.profileId}:${owner.spaceId}';
    requestOwner ??= ownerKey;
    final child = widget.child is ExpensesScreen && requestOwner != ownerKey
        ? const ExpensesScreen()
        : widget.child;
    return KeyedSubtree(
        key: ValueKey('$actor:${owner.profileId}:${owner.spaceId}'),
        child: child);
  }
}

/// Opens the expenses of one budget profile (T130, T132, T133).
///
/// The screen reads the **active** context, so the same route works for a
/// personal profile and for a profile inside a shared space: whichever pot is
/// active when the card is tapped is the pot the expenses come from. That
/// keeps the personal and shared money apart without a second route.
void openProfileExpenses(BuildContext context, int profileId,
    {bool isDirect = false}) {
  context.push(
      '/profile_expenses/$profileId?type=${isDirect ? FinancialProfileType.direct : FinancialProfileType.budget}');
}

/// Starts a new expense that belongs to one budget profile (T129).
///
/// The profile id travels with the route, so the saved expense is filed under
/// that profile and its spending is counted there.
void openAddExpenseForProfile(BuildContext context, int profileId,
    {bool isDirect = false}) {
  context.push('/add_expense', extra: {
    'budgetProfileId': profileId,
    'financialProfileType':
        isDirect ? FinancialProfileType.direct : FinancialProfileType.budget
  });
}
