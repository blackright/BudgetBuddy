import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_form.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Defect-batch walkthrough: the medical detail "Edit" button crashed the form
/// on its first frame whenever the bill's service type was absent from the
/// selectable list (cold/empty on frame 1, or archived) — DropdownButtonFormField
/// asserts that its seeded value has exactly one matching item.
void main() {
  UserProfile makeProfile() => UserProfile()
    ..id = 1
    ..name = 'Test'
    ..primaryCurrency = PrimaryCurrency.usd;

  Future<void> pumpForm(
    WidgetTester tester, {
    required MedicalBill bill,
    required List<MedicalServiceType> types,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileProvider
              .overrideWith((ref) => Stream.value(makeProfile())),
          activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          medicalServiceTypesProvider
              .overrideWith((ref) => Stream.value(types)),
          medicalProvidersProvider
              .overrideWith((ref) => Stream.value(const [])),
          familyMembersProvider.overrideWith((ref) => Stream.value(const [])),
          insuranceProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(home: MedicalBillForm(existingBill: bill)),
      ),
    );
  }

  testWidgets('an archived service type renders without asserting',
      (tester) async {
    final archived = MedicalServiceType()
      ..id = 99
      ..name = 'Old Chiropractic'
      ..archived = true;
    final bill = MedicalBill()
      ..id = 7
      ..billedAmount = 100000
      ..patientSharePercent = 20
      ..serviceTypeId = 99;

    await pumpForm(
      tester,
      bill: bill,
      types: [archived],
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'an archived type must keep its seeded dropdown value');
    expect(find.text('Old Chiropractic'), findsOneWidget);
  });

  testWidgets('a not-yet-loaded service type list renders without asserting',
      (tester) async {
    final bill = MedicalBill()
      ..id = 8
      ..billedAmount = 50000
      ..patientSharePercent = 20
      ..serviceTypeId = 5;

    await pumpForm(tester, bill: bill, types: const []);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('serviceTypeField')), findsOneWidget);
  });
}
