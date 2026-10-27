import 'package:budget_buddy/features/budget_setup/presentation/budget_setup_screen.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// US1 representative screen from the setup flow: the monthly amount field
/// groups while typing and the notifier receives the exact (ungrouped) value.
class _RecordingNotifier extends BudgetSetupNotifier {
  final List<double> amounts = [];

  @override
  void setAmount(double amount) {
    amounts.add(amount);
    super.setAmount(amount);
  }

  @override
  Future<void> loadAutoFillData() async {}
}

void main() {
  Finder amountField() => find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.labelText == 'Monthly Available Amount',
      );

  testWidgets('groups the monthly amount and saves the exact value (US1)',
      (WidgetTester tester) async {
    final notifier = _RecordingNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetSetupProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(home: BudgetSetupScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
        find.byKey(const Key('welcomeNameField')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.enterText(find.byKey(const Key('welcomeNameField')), 'Jason');
    await tester.scrollUntilVisible(
        find.byKey(const Key('welcomeContinueButton')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('welcomeContinueButton')));
    await tester.pumpAndSettle();
    expect(notifier.state.name, 'Jason');

    await tester.enterText(amountField(), '1000000');
    await tester.pump();

    expect(
        tester.widget<TextField>(amountField()).controller!.text, '1,000,000');
    expect(notifier.amounts, contains(1000000.0),
        reason:
            'the notifier stores the ungrouped value, not the display text');
  });
}
