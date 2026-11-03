import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_receipt_provider.dart';
import 'package:budget_buddy/features/medical/presentation/medical_dashboard.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';

void main() {
  Future<void> pumpDashboard(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        activeProfileProvider.overrideWith((ref) => Stream.value(UserProfile()
          ..id = 1
          ..name = 'Test'
          ..primaryCurrency = PrimaryCurrency.huf)),
        activeProfileIdProvider.overrideWith((ref) => 1),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        medicalDisplayCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        activeContextCanEditProvider.overrideWithValue(true),
        activeContextCanManageProvider.overrideWithValue(true),
        medicalInboxProvider.overrideWith((ref) => const AsyncData(MedicalInbox(
              items: [],
              counts: {},
              needsYouCount: 0,
              approvedStillToReceiveMinor: 0,
              currency: CurrencyCode.huf,
              amountsNeedReview: false,
              monthOptions: [],
              allBillsCount: 0,
            ))),
        medicalProvidersProvider.overrideWith((ref) => Stream.value([
              MedicalProvider()
                ..id = 1
                ..name = 'City Hospital'
                ..specialty = 'Cardiology',
            ])),
        familyMembersProvider.overrideWith((ref) => Stream.value([
              FamilyMember()
                ..id = 1
                ..name = 'Sam'
                ..relation = 'Child',
            ])),
        medicalServiceTypesProvider.overrideWith((ref) => Stream.value([
              MedicalServiceType()
                ..id = 1
                ..name = 'Radiology',
              MedicalServiceType()
                ..id = 2
                ..name = 'Surgery'
                ..archived = true,
            ])),
        medicalDirectoryProvider.overrideWithValue(
            const MedicalDirectory(members: [], providers: [])),
        insuranceProfileProvider.overrideWith((ref) =>
            Stream.value(InsuranceProfile()..defaultPatientPercent = 20)),
      ],
      child: const MaterialApp(home: MedicalDashboard()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('directory search filters providers, people and service types',
      (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.byTooltip('Providers & family'));
    await tester.pumpAndSettle();

    expect(find.text('Medical providers'), findsOneWidget);
    expect(find.text('City Hospital'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Radiology'), findsOneWidget);
    expect(find.text('Surgery'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('directorySearchField')), 'cardio');
    await tester.pumpAndSettle();
    expect(find.text('City Hospital'), findsOneWidget);
    expect(find.text('Sam'), findsNothing);
    expect(find.text('Radiology'), findsNothing);

    await tester.enterText(
        find.byKey(const Key('directorySearchField')), 'nothing');
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);
  });

  testWidgets('bill defaults use Your share wording', (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.byKey(const Key('billDefaultsButton')));
    await tester.pumpAndSettle();
    expect(find.text('Usual Your share (%)'), findsOneWidget);
    expect(find.textContaining('deductible'), findsNothing);
  });

  testWidgets('directory and defaults fit 320px and 200% text', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        activeProfileProvider.overrideWith((ref) => Stream.value(UserProfile()
          ..id = 1
          ..name = 'Test'
          ..primaryCurrency = PrimaryCurrency.huf)),
        activeProfileIdProvider.overrideWith((ref) => 1),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        medicalDisplayCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        activeContextCanEditProvider.overrideWithValue(true),
        activeContextCanManageProvider.overrideWithValue(true),
        medicalInboxProvider.overrideWith((ref) => const AsyncData(MedicalInbox(
              items: [],
              counts: {},
              needsYouCount: 0,
              approvedStillToReceiveMinor: 0,
              currency: CurrencyCode.huf,
              amountsNeedReview: false,
              monthOptions: [],
              allBillsCount: 0,
            ))),
        medicalProvidersProvider.overrideWith((ref) => Stream.value([
              MedicalProvider()
                ..id = 1
                ..name = 'A very long provider name'
                ..specialty = 'Cardiology',
            ])),
        familyMembersProvider.overrideWith((ref) => Stream.value([
              FamilyMember()
                ..id = 1
                ..name = 'Sam'
                ..relation = 'Child',
            ])),
        medicalServiceTypesProvider.overrideWith((ref) => Stream.value([
              MedicalServiceType()
                ..id = 1
                ..name = 'Radiology',
            ])),
        medicalDirectoryProvider.overrideWithValue(
            const MedicalDirectory(members: [], providers: [])),
        insuranceProfileProvider.overrideWith((ref) =>
            Stream.value(InsuranceProfile()..defaultPatientPercent = 20)),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const MedicalDashboard(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Providers & family'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('directorySearchField')), findsOneWidget);
  });
}
