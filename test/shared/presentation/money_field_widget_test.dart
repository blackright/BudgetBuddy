import 'package:budget_buddy/shared/presentation/widgets/money_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// US1/US2: the one shared amount field. These cover the behaviour every wired
/// screen inherits: grouping while typing, the exact value handed to the app,
/// select-all-on-focus, and re-sync when the context identity changes.
void main() {
  Future<void> pumpField(WidgetTester tester, Widget field) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: field)),
    );
  }

  String textOf(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets(
      'groups digits as the user types and reports the exact value '
      '(SC-001, SC-002)', (WidgetTester tester) async {
    final controller = TextEditingController();
    double? reported;
    addTearDown(controller.dispose);

    await pumpField(
      tester,
      MoneyField(
        controller: controller,
        label: 'Amount',
        onChanged: (value) => reported = value,
      ),
    );

    await tester.enterText(find.byType(TextField), '1000000');
    await tester.pump();

    expect(controller.text, '1,000,000',
        reason: 'grouping is a visual layer over the typed digits');
    expect(reported, 1000000, reason: 'the app receives the ungrouped amount');
  });

  testWidgets('hands back the ungrouped value on submit (SC-002)',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    double? submitted;
    addTearDown(controller.dispose);

    await pumpField(
      tester,
      MoneyField(
        controller: controller,
        label: 'Amount',
        onSubmitted: (value) => submitted = value,
      ),
    );

    await tester.enterText(find.byType(TextField), '1234567');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, 1234567);
  });

  testWidgets('a blank field reports null, never 0 (SC-002)',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    double? reported;
    addTearDown(controller.dispose);

    await pumpField(
      tester,
      MoneyField(
        controller: controller,
        label: 'Amount',
        onChanged: (value) => reported = value,
      ),
    );

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(reported, isNull);
  });

  testWidgets('focusing a prefilled field selects all of its text (SC-003)',
      (WidgetTester tester) async {
    final controller = TextEditingController(text: '0.00');
    addTearDown(controller.dispose);

    await pumpField(tester, MoneyField(controller: controller));

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump();

    expect(controller.text, '0.00', reason: 'focusing never erases the value');
    expect(controller.selection.baseOffset, 0);
    expect(controller.selection.extentOffset, controller.text.length,
        reason: 'the whole value is selected so one keystroke replaces it');
  });

  testWidgets('typing after focus replaces the prefilled value (SC-003)',
      (WidgetTester tester) async {
    final controller = TextEditingController(text: '0.00');
    addTearDown(controller.dispose);

    await pumpField(tester, MoneyField(controller: controller));

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump();
    expect(controller.selection.extentOffset, controller.text.length);

    // The platform sends the post-keystroke value (the selection was the whole
    // text, so one digit replaces it — never "0.005" or "50.00").
    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();

    expect(controller.text, '5');
  });

  testWidgets('focusing and leaving without typing keeps the value (SC-003)',
      (WidgetTester tester) async {
    final controller = TextEditingController(text: '0.00');
    addTearDown(controller.dispose);

    await pumpField(tester, MoneyField(controller: controller));

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(controller.text, '0.00');
  });

  testWidgets(
      're-syncs the text when the context identity changes '
      '(FR-010 / SC-006)', (WidgetTester tester) async {
    await pumpField(
      tester,
      const MoneyField(
          initialValue: 100, syncKey: 'profile-a', label: 'Salary'),
    );
    expect(textOf(tester), '100');

    await pumpField(
      tester,
      const MoneyField(
          initialValue: 250, syncKey: 'profile-b', label: 'Salary'),
    );
    expect(textOf(tester), '250',
        reason: 'the new context\'s value replaces the previous one');
  });

  testWidgets('re-syncs to empty when the new context has no value (SC-006)',
      (WidgetTester tester) async {
    await pumpField(
      tester,
      const MoneyField(initialValue: 3000, syncKey: 'set', label: 'Salary'),
    );
    expect(textOf(tester), '3,000');

    await pumpField(
      tester,
      const MoneyField(initialValue: null, syncKey: 'unset', label: 'Salary'),
    );
    expect(textOf(tester), '',
        reason: 'an unset context shows an empty field, not the old number');
  });

  testWidgets('renders a fixed two-decimal seed when asked (salary parity)',
      (WidgetTester tester) async {
    await pumpField(
      tester,
      const MoneyField(initialValue: 1000, fractionDigits: 2, label: 'Salary'),
    );
    expect(textOf(tester), '1,000.00');
  });

  testWidgets(
      'selectAllOnFocus helper selects a plain percentage field '
      '(FR-009)', (WidgetTester tester) async {
    final controller = TextEditingController(text: '20');
    final focus = selectAllOnFocus(controller);
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);

    await pumpField(
      tester,
      TextFormField(controller: controller, focusNode: focus),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump();

    expect(controller.text, '20', reason: 'percentages are never grouped');
    expect(controller.selection.baseOffset, 0);
    expect(controller.selection.extentOffset, 2);
  });
}
