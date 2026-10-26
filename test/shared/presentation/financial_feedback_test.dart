import 'dart:async';
import 'package:budget_buddy/shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('success follows completion, replaces older feedback and expires',
      (tester) async {
    final completion = Completer<void>();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => Column(children: [
                      TextButton(
                          onPressed: () =>
                              showFinancialFeedback(context, 'Old message'),
                          child: const Text('Old')),
                      TextButton(
                          onPressed: () => runFinancialAction(context,
                              action: () => completion.future,
                              success: 'Saved',
                              failure: 'Failed'),
                          child: const Text('Save')),
                    ])))));
    await tester.tap(find.text('Old'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Saved'), findsNothing);
    completion.complete();
    await tester.pumpAndSettle();
    expect(find.text('Old message'), findsNothing);
    expect(find.text('Saved'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets(
      'failed operation never displays success and keeps the form available',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () => runFinancialAction(context,
                        action: () async =>
                            throw StateError('isolated failure'),
                        success: 'Saved',
                        failure: 'Could not save'),
                    child: const Text('Save'))))));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
    expect(find.text('Could not save'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('Could not save'), findsNothing);
  });
}
