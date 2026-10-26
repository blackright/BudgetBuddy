import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/finance/presentation/net_salary_section.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../medical/repositories/medical_test_harness.dart';

/// US3 (FR-005, FR-010): the "My income" card names the active profile, and
/// every amount field re-syncs to the newly-active context when the profile,
/// the selected month or the personal↔shared context changes — the previous
/// context's number never lingers.
///
/// [resolvedIncomeProvider] is driven directly through [_incomeState] (the real
/// chain runs through Isar watch streams, which cannot run under the widget-test
/// fake clock). Each scenario moves the syncKey and the value together, which is
/// exactly what a real switch does.
void main() {
  late MedicalTestHarness harness;
  late UserProfile ava;
  late UserProfile bea;

  setUp(() {
    ava = UserProfile()
      ..name = 'Ava'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 0
      ..defaultNetSalary = 3000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)
      ..id = 1;
    bea = UserProfile()
      ..name = 'Bea'
      ..primaryCurrency = PrimaryCurrency.eur
      ..monthlyAvailableAmount = 0
      ..defaultNetSalary = 5000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)
      ..id = 2;
  });

  UserProfile byId(int? id) => id == bea.id ? bea : ava;

  Future<ProviderContainer> pumpCard(WidgetTester tester) async {
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
    });
    addTearDown(() => harness.close());

    final container = ProviderContainer(
      overrides: [
        activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        monthFinanceRepositoryProvider
            .overrideWithValue(MonthFinanceRepository(harness.isar)),
        profilesProvider.overrideWith((ref) => Stream.value([ava, bea])),
        activeProfileProvider.overrideWith(
          (ref) => Stream.value(byId(ref.watch(activeProfileIdProvider))),
        ),
        mainCurrencyProvider.overrideWith(
          (ref) =>
              byId(ref.watch(activeProfileIdProvider)).primaryCurrency.code,
        ),
        resolvedIncomeProvider.overrideWith((ref) => ref.watch(incomeState)),
      ],
    );
    addTearDown(container.dispose);

    container.read(selectedYearMonthProvider.notifier).state = '2026-01';
    container.read(activeProfileIdProvider.notifier).state = ava.id;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: NetSalarySection()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('names the active profile and follows a profile switch',
      (tester) async {
    final container = await pumpCard(tester);

    expect(_header(tester), 'Ava');
    expect(_fieldText(tester, 'defaultSalaryField'), '3,000.00');

    container.read(activeProfileIdProvider.notifier).state = bea.id;
    await tester.pumpAndSettle();

    expect(_header(tester), 'Bea');
    expect(_fieldText(tester, 'defaultSalaryField'), '5,000.00');
  });

  testWidgets(
      're-syncs every income field when the month, the profile or the '
      'personal↔shared context changes (FR-010)', (tester) async {
    final container = await pumpCard(tester);

    // Initial: no override for Ava / January, so the month field is empty.
    expect(_fieldText(tester, 'monthOverrideField'), '');
    expect(find.text('January 2026 only'), findsOneWidget);

    // 1) Move to February, which carries an override.
    container.read(selectedYearMonthProvider.notifier).state = '2026-02';
    container.read(incomeState.notifier).state =
        const ResolvedIncome(amount: 1200, usesOverride: true);
    await tester.pumpAndSettle();
    expect(_fieldText(tester, 'monthOverrideField'), '1,200.00');
    expect(find.text('February 2026 only'), findsOneWidget);

    // 2) Switch to Bea; her month has no override (falls back to her default).
    container.read(activeProfileIdProvider.notifier).state = bea.id;
    container.read(incomeState.notifier).state =
        const ResolvedIncome(amount: 5000, usesOverride: false);
    await tester.pumpAndSettle();
    expect(_fieldText(tester, 'monthOverrideField'), '');
    expect(_fieldText(tester, 'defaultSalaryField'), '5,000.00');

    // 3) Switch into a shared space, which owns its own income pot.
    container.read(activeSpaceIdProvider.notifier).state = 7;
    container.read(incomeState.notifier).state =
        const ResolvedIncome(amount: 9000, usesOverride: true);
    await tester.pumpAndSettle();
    expect(_fieldText(tester, 'monthOverrideField'), '9,000.00');

    // 4) Back to personal, Ava / February — the January-style override returns.
    container.read(activeSpaceIdProvider.notifier).state = null;
    container.read(activeProfileIdProvider.notifier).state = ava.id;
    container.read(incomeState.notifier).state =
        const ResolvedIncome(amount: 1200, usesOverride: true);
    await tester.pumpAndSettle();
    expect(_fieldText(tester, 'monthOverrideField'), '1,200.00');
  });
}

/// Test-only marker that [resolvedIncomeProvider] is overridden to read, so a
/// test can drive the resolved income directly.
final incomeState =
    StateProvider<ResolvedIncome>((ref) => const ResolvedIncome.empty());

String _header(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('incomeProfileName'))).data!;

String _fieldText(WidgetTester tester, String key) {
  final editable = tester.widget<EditableText>(
    find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(EditableText),
    ),
  );
  return editable.controller.text;
}
