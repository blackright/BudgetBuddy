import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/routing/app_router.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final router = createAppRouter(initialLocation: '/dashboard');

  setUp(() {
    router.go('/dashboard');
  });

  tearDownAll(() {
    router.dispose();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
          monthlyExpensesProvider.overrideWith((ref) => Stream.value([])),
          monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
          insuranceProfileProvider.overrideWith((ref) => Stream.value(null)),
          medicalBillsProvider
              .overrideWith((ref) => Stream.value(<MedicalBill>[])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard Medical quick action opens the Medical dashboard',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Medical').first);
    await tester.pumpAndSettle();

    expect(find.text('Health & Insurance'), findsOneWidget);
    expect(find.text('Medical Bills Placeholder'), findsNothing);
  });

  testWidgets('Medical navigation tab opens the Medical dashboard',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Medical').last);
    await tester.pumpAndSettle();

    expect(find.text('Health & Insurance'), findsOneWidget);
    expect(find.text('Medical Bills Placeholder'), findsNothing);
  });
}
