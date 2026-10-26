import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';

void main() {
  IncomeSource source(String currency, int minor) => IncomeSource()
    ..name = currency
    ..amount = minor
    ..currency = currency
    ..frequency = IncomeFrequency.monthly
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);
  for (final shared in [false, true]) {
    test(
        '${shared ? 'shared' : 'personal'} income chooses accounting currency before adding minor units',
        () async {
      final container = ProviderContainer(overrides: [
        budgetContextProvider.overrideWithValue(shared
            ? ContextRef.shared(spaceId: 7, yearMonth: '2026-10')
            : ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
        activeProfileProvider.overrideWith((ref) => Stream.value(UserProfile()
          ..id = 1
          ..name = 'Test'
          ..primaryCurrency = PrimaryCurrency.huf)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(SharedSpace()
          ..id = 7
          ..name = 'Home'
          ..currency = PrimaryCurrency.eur)),
        incomeSourcesProvider.overrideWith((ref) =>
            Stream.value([source('HUF', 100000), source('EUR', 25000)])),
      ]);
      addTearDown(container.dispose);
      await container.read(activeProfileProvider.future);
      await container.read(activeSpaceProvider.future);
      await container.read(incomeSourcesProvider.future);
      expect(container.read(incomeSourcesTotalProvider), shared ? 250 : 100000);
    });
  }
  test('foreign-only income is never relabelled as accounting-currency income',
      () async {
    final container = ProviderContainer(overrides: [
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
      activeProfileProvider.overrideWith((ref) =>
          Stream.value(UserProfile()..primaryCurrency = PrimaryCurrency.huf)),
      incomeSourcesProvider
          .overrideWith((ref) => Stream.value([source('USD', 10000)]))
    ]);
    addTearDown(container.dispose);
    await container.read(activeProfileProvider.future);
    await container.read(incomeSourcesProvider.future);
    expect(container.read(incomeSourcesTotalProvider), 0);
  });
}
