import 'package:budget_buddy/shared/presentation/confirm_space_on_save.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// US6 (T051): the shared-save confirmation dialog names the item, amount and
/// space, and reports the user's decision back to the caller.
void main() {
  late SpaceSaveDecision? result;

  Future<void> pumpAndOpen(WidgetTester tester) async {
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await confirmSpaceOnSave(
                  context,
                  title: 'Groceries',
                  amountText: 'Ft 3,850',
                  spaceName: 'Home',
                );
              },
              child: const Text('save'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the item, amount and space', (tester) async {
    await pumpAndOpen(tester);

    final message =
        tester.widget<Text>(find.byKey(const Key('confirmSpaceOnSaveMessage')));
    expect(message.data, 'Add "Groceries" (Ft 3,850) to "Home"?');
    expect(find.text('Change context'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('Confirm returns the confirm decision', (tester) async {
    await pumpAndOpen(tester);
    await tester.tap(find.byKey(const Key('confirmSaveButton')));
    await tester.pumpAndSettle();

    expect(result, SpaceSaveDecision.confirm);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Change context returns the change-context decision',
      (tester) async {
    await pumpAndOpen(tester);
    await tester.tap(find.byKey(const Key('changeContextButton')));
    await tester.pumpAndSettle();

    expect(result, SpaceSaveDecision.changeContext);
  });

  testWidgets('dismissing the dialog returns null', (tester) async {
    await pumpAndOpen(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
