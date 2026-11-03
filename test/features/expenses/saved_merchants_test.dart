import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/merchant.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saved merchants put the most recently used first, then newest unused',
      () async {
    Merchant merchant(String guid, String name, DateTime created) => Merchant()
      ..syncGuid = guid
      ..canonicalName = name
      ..createdAt = created
      ..updatedAt = created;

    final merchants = [
      merchant('a', 'Alpha', DateTime(2026, 1, 1)),
      merchant('b', 'Beta', DateTime(2026, 2, 1)),
      merchant('c', 'Charlie', DateTime(2026, 3, 1)),
      merchant('d', 'Delta', DateTime(2026, 4, 1)),
    ];
    final c = ProviderContainer(overrides: [
      expenseSearchMerchantsProvider
          .overrideWith((ref) => Stream.value(merchants)),
      expenseSearchRowsProvider.overrideWith((ref) => Stream.value([
            expense('a', DateTime(2026, 1, 10)),
            expense('c', DateTime(2026, 3, 20)),
            expense('b', DateTime(2026, 2, 15)),
          ])),
    ]);
    addTearDown(c.dispose);

    await c.read(expenseSearchMerchantsProvider.future);
    await c.read(expenseSearchRowsProvider.future);

    final sorted = c.read(savedMerchantsProvider).requireValue;
    expect(sorted.map((m) => m.canonicalName),
        ['Charlie', 'Beta', 'Alpha', 'Delta']);
  });
}

Expense expense(String merchantGuid, DateTime date) => Expense(
      profileId: 1,
      yearMonth: '2026-03',
      title: 'Test',
      amount: 100,
      currency: 'HUF',
      categoryId: 'food',
      date: date,
      budgetId: 1,
      merchantSyncGuid: merchantGuid,
    );
