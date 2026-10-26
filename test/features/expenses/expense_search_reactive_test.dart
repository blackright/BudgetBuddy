import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  test('live search removes results after membership revocation', () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    IsarHelper.instance = h.isar;
    await h.seedBudget();
    final space = await h.createSpace();
    final member = SharedMember()
      ..sharedSpaceId = space
      ..profileId = 1
      ..role = SharedMemberRole.viewer
      ..joinedAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      await h.isar.sharedMembers.put(member);
      await h.isar.expenses.put(Expense(
          profileId: 0,
          sharedSpaceId: space,
          yearMonth: '2026-10',
          title: 'Permitted record',
          amount: 100,
          currency: 'usd',
          categoryId: 'food',
          date: DateTime(2026, 10),
          budgetId: 1));
    });
    final container = ProviderContainer(overrides: [
      expenseSearchRepositoryProvider
          .overrideWithValue(ExpenseSearchRepository(h.isar)),
      actingProfileIdProvider.overrideWithValue(1),
      activeSpaceIdProvider.overrideWith((ref) => space),
      budgetContextProvider.overrideWithValue(
          ContextRef.shared(spaceId: space, yearMonth: '2026-10')),
    ]);
    addTearDown(container.dispose);
    container.listen(expenseSearchResultsProvider, (_, __) {});
    Future<void> waitFor(bool Function() ready) async {
      for (var i = 0; i < 100; i++) {
        if (ready()) return;
        await Future<void>.delayed(const Duration(milliseconds: 15));
      }
      fail('Search state did not update.');
    }

    await waitFor(() =>
        container.read(expenseSearchResultsProvider).asData?.value.length == 1);
    member.revokedAt = DateTime.now();
    await h.isar.writeTxn(() => h.isar.sharedMembers.put(member));
    await waitFor(() => container.read(expenseSearchResultsProvider).hasError);
    expect(container.read(expenseSearchResultsProvider).asData, isNull);
  });
}
