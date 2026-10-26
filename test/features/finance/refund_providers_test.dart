import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/finance/providers/reserve_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direct in [true, false]) {
    for (final returned in [0, 25000]) {
      test(
          'live ${direct ? 'direct' : 'budget'} spending with $returned returned ignores stale caches',
          () async {
        final now = DateTime(2026);
        final e = Expense(
            id: 1,
            profileId: 1,
            yearMonth: '2026-10',
            title: 'Purchase',
            amount: 130000,
            currency: 'huf',
            categoryId: 'food',
            date: now,
            budgetId: 1,
            budgetProfileId: 7,
            status: returned == 0
                ? ExpenseStatus.paid
                : ExpenseStatus.partiallyReimbursed);
        final user = UserProfile()
          ..id = 1
          ..name = 'Me'
          ..primaryCurrency = PrimaryCurrency.huf
          ..monthlyAvailableAmount = 0
          ..createdAt = now
          ..updatedAt = now;
        final container = ProviderContainer(overrides: [
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
          activeProfileProvider.overrideWith((ref) => Stream.value(user)),
          activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          resolvedIncomeProvider.overrideWithValue(
              const ResolvedIncome(amount: 110000, usesOverride: false)),
          monthlyExpensesProvider.overrideWith((ref) => Stream.value([e])),
          monthlyReimbursementsProvider
              .overrideWith((ref) => Stream.value(returned == 0
                  ? []
                  : [
                      Reimbursement(
                          profileId: 1,
                          expenseId: 1,
                          originYearMonth: '2026-10',
                          amount: returned,
                          currency: 'huf',
                          date: now),
                    ])),
          budgetProfilesProvider.overrideWith((ref) => Stream.value(direct
              ? []
              : [
                  BudgetProfile()
                    ..id = 7
                    ..profileId = 1
                    ..yearMonth = '2026-10'
                    ..name = 'Food'
                    ..allocation = 100000
                    ..spent = 130000
                    ..createdAt = now
                    ..updatedAt = now,
                ])),
          directExpenseProfilesProvider
              .overrideWith((ref) => Stream.value(!direct
                  ? []
                  : [
                      DirectExpenseProfile()
                        ..id = 7
                        ..profileId = 1
                        ..yearMonth = '2026-10'
                        ..name = 'Emergency'
                        ..spent = 130000
                        ..createdAt = now
                        ..updatedAt = now,
                    ])),
        ]);
        addTearDown(container.dispose);
        await container.read(activeProfileProvider.future);
        await container.read(monthlyExpensesProvider.future);
        await container.read(monthlyReimbursementsProvider.future);
        await container.read(budgetProfilesProvider.future);
        await container.read(directExpenseProfilesProvider.future);
        final state = container.read(dashboardProfilesProvider).single;
        expect(state.spent, 130000 - returned);
        expect(
            state.borrowed,
            direct
                ? 0
                : returned == 0
                    ? 10000
                    : 5000);
        expect(state.deficit, returned == 0 ? 20000 : 0);
        expect(container.read(availableReserveProvider),
            direct ? returned - 20000 : 10000);
      });
    }
  }
}
