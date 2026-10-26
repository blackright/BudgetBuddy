import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/features/expenses/providers/daily_cards_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/daily_expense_card.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/presentation/expenses_screen.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T044 — a Viewer in a shared space sees the data but is offered no
/// add/edit/delete control (US4 AC1).
///
/// The presentation wiring is driven by the real capability provider
/// ([activeContextCanEditProvider]); only the Isar-backed data streams are
/// overridden so the widget test runs under the fake clock (the same rule the
/// space-creation suite follows). The data layer's own refusal is owned by T043.
void main() {
  final now = DateTime(2026, 1, 1);

  Future<_Fixture> seed(WidgetTester tester) async {
    final fixture = await tester.runAsync(() async {
      final harness = await MedicalTestHarness.create();
      final ava = UserProfile()
        ..name = 'Ava'
        ..primaryCurrency = PrimaryCurrency.usd
        ..monthlyAvailableAmount = 0
        ..createdAt = now
        ..updatedAt = now;
      final bea = UserProfile()
        ..name = 'Bea'
        ..primaryCurrency = PrimaryCurrency.usd
        ..monthlyAvailableAmount = 0
        ..createdAt = now
        ..updatedAt = now;
      ava.id = await harness.isar.writeTxn(
        () => harness.isar.userProfiles.put(ava),
      );
      bea.id = await harness.isar.writeTxn(
        () => harness.isar.userProfiles.put(bea),
      );
      final space = SharedSpace()
        ..name = 'Home'
        ..avatar = '🏠'
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 0
        ..createdByProfileId = ava.id
        ..createdAt = now;
      final spaceId = await harness.isar.writeTxn(
        () => harness.isar.sharedSpaces.put(space),
      );
      return _Fixture(harness, ava, bea, spaceId);
    });
    return fixture!;
  }

  ProviderContainer containerFor(_Fixture f, SharedMemberRole actingRole) {
    final acting = actingRole == SharedMemberRole.viewer ? f.bea : f.ava;
    final members = [
      SharedMember()
        ..id = 1
        ..sharedSpaceId = f.spaceId
        ..profileId = f.ava.id
        ..role = SharedMemberRole.owner
        ..joinedAt = now,
      SharedMember()
        ..id = 2
        ..sharedSpaceId = f.spaceId
        ..profileId = f.bea.id
        ..role = actingRole
        ..joinedAt = now,
    ];

    final expense = Expense(
      profileId: 0,
      sharedSpaceId: f.spaceId,
      yearMonth: '2026-01',
      title: 'Groceries',
      amount: 5000,
      currency: 'USD',
      categoryId: 'general',
      date: DateTime(2026, 1, 5),
      budgetId: 0,
    );

    return ProviderContainer(
      overrides: [
        activeSpaceIdProvider.overrideWith((ref) => f.spaceId),
        activeProfileProvider.overrideWith((ref) => Stream.value(acting)),
        activeSpaceMembersProvider.overrideWith((ref) => Stream.value(members)),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.usd),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        categoriesProvider.overrideWith((ref) => <Category>[]),
        expenseSearchRowsProvider
            .overrideWith((ref) => Stream.value(<Expense>[expense])),
        expenseSearchMerchantsProvider.overrideWith((ref) => Stream.value([])),
        dailyCardReturnsProvider.overrideWith((ref) => Stream.value([])),
        expenseSearchProfileNamesProvider
            .overrideWith((ref) async => {'main': 'Main'}),
        expenseRepositoryProvider
            .overrideWith((ref) => _FakeExpenseRepository(f.harness.isar)),
      ],
    );
  }

  Future<void> pump(WidgetTester tester, ProviderContainer container) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ExpensesScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a Viewer sees the expense but no add/edit/delete control',
      (WidgetTester tester) async {
    final f = await seed(tester);
    final container = containerFor(f, SharedMemberRole.viewer);
    addTearDown(container.dispose);
    await pump(tester, container);

    // The shared expense is visible (US4 AC1: a Viewer may read).
    await tester.tap(find.byType(DailyExpenseCardTile).first);
    await tester.pumpAndSettle();
    expect(find.text('Groceries'), findsOneWidget);

    // No add control (FAB) and no edit/delete swipe actions are offered.
    expect(find.byType(FloatingActionButton), findsNothing);
    final slidable = tester.widget<Slidable>(find.byType(Slidable));
    expect(slidable.startActionPane, isNull,
        reason: 'no toggle-to-paid action for a Viewer');
    expect(slidable.endActionPane, isNull,
        reason: 'no edit/delete actions for a Viewer');
    // The convert-to control is a shared money write, so it is hidden too.
    expect(find.byKey(const Key('monthConvertToMenu')), findsNothing);

    await tester.runAsync(f.harness.close);
  });

  testWidgets('an Editor sees the add control and the edit/delete actions',
      (WidgetTester tester) async {
    final f = await seed(tester);
    final container = containerFor(f, SharedMemberRole.editor);
    addTearDown(container.dispose);
    await pump(tester, container);

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(DailyExpenseCardTile).first);
    await tester.pumpAndSettle();
    final slidable = tester.widget<Slidable>(find.byType(Slidable));
    expect(slidable.startActionPane, isNotNull);
    expect(slidable.endActionPane, isNotNull,
        reason: 'an Editor is offered the edit/delete actions');

    await tester.runAsync(f.harness.close);
  });
}

class _Fixture {
  _Fixture(this.harness, this.ava, this.bea, this.spaceId);

  final MedicalTestHarness harness;
  final UserProfile ava;
  final UserProfile bea;
  final int spaceId;
}

/// In-memory stand-in so `_OrphanBannerButton` never touches Isar under the
/// widget-test fake clock (a real Isar watch stream cannot run there).
class _FakeExpenseRepository extends ExpenseRepository {
  _FakeExpenseRepository(super.isar);

  @override
  Stream<List<Reimbursement>> watchOrphanedReimbursements() =>
      Stream.value(const <Reimbursement>[]);
}
