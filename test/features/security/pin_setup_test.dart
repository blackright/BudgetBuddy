import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/pin_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// T023: FR-009/FR-039 — a PIN is entered twice and the two entries must match,
/// and the plain statement of what forgetting the PIN means is shown before the
/// first PIN is accepted.
void main() {
  const subject = LockSubject(
    kind: LockSubjectKind.profile,
    localId: 1,
    guid: '',
    name: 'Ann',
    avatar: '🧑',
  );

  Widget host({
    PinSetupMode mode = PinSetupMode.create,
    required Future<String?> Function(String? current, String next) onSubmit,
  }) =>
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (_) => PinSetupScreen(
                      subject: subject,
                      mode: mode,
                      onSubmit: onSubmit,
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String digits) async {
    for (final digit in digits.split('')) {
      await tester.tap(find.text(digit).first);
      await tester.pump();
    }
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('pinSubmit')));
    await tester.pump();
  }

  testWidgets('create: the forgotten-PIN warning is shown before any PIN',
      (tester) async {
    await tester.pumpWidget(host(onSubmit: (_, __) async => null));
    await open(tester);

    expect(find.byKey(const Key(LockKeys.pinSetupScreen)), findsOneWidget);
    expect(find.textContaining('cannot be recovered'), findsOneWidget);
    expect(find.textContaining('another profile on this phone'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('create: a mismatched confirmation is refused (FR-009)',
      (tester) async {
    final submitted = <String>[];
    await tester.pumpWidget(host(onSubmit: (current, next) async {
      submitted.add(next);
      expect(current, isNull, reason: 'create needs no current PIN');
      return null;
    }));
    await open(tester);

    await enter(tester, '4821');
    await submit(tester);
    await enter(tester, '4822');
    await submit(tester);

    expect(find.byKey(const Key(LockKeys.pinError)), findsOneWidget);
    expect(submitted, isEmpty, reason: 'a mismatch must not be accepted');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'create: a guessable PIN is refused with a plain message (FR-010)',
      (tester) async {
    final submitted = <String>[];
    await tester.pumpWidget(host(onSubmit: (_, next) async {
      submitted.add(next);
      return null;
    }));
    await open(tester);

    await enter(tester, '1111');
    await submit(tester);
    await enter(tester, '1111');
    await submit(tester);

    expect(find.byKey(const Key(LockKeys.pinError)), findsOneWidget);
    expect(submitted, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'create: a matched, well-formed PIN is accepted and the screen '
      'closes', (tester) async {
    final submitted = <String>[];
    await tester.pumpWidget(host(onSubmit: (current, next) async {
      submitted.add(next);
      return null;
    }));
    await open(tester);

    await enter(tester, '4821');
    await submit(tester);
    await enter(tester, '4821');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(submitted, ['4821']);
    expect(find.byKey(const Key(LockKeys.pinSetupScreen)), findsNothing,
        reason: 'a successful setup closes the screen');
  });

  testWidgets('change: the current PIN is asked for first (FR-009, FR-012)',
      (tester) async {
    final calls = <String?>[];
    await tester.pumpWidget(host(
      mode: PinSetupMode.change,
      onSubmit: (current, next) async {
        calls.add(current);
        return current == '4821' ? null : 'That is not the current PIN.';
      },
    ));
    await open(tester);

    // Step 1: the current PIN.
    await enter(tester, '4821');
    await submit(tester);
    // Step 2: the new PIN, twice.
    await enter(tester, '7731');
    await submit(tester);
    await enter(tester, '7731');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(calls, ['4821']);
    expect(find.byKey(const Key(LockKeys.pinSetupScreen)), findsNothing);
  });

  testWidgets('change: a wrong current PIN is reported and keeps the screen',
      (tester) async {
    await tester.pumpWidget(host(
      mode: PinSetupMode.change,
      onSubmit: (current, next) async => 'That is not the current PIN.',
    ));
    await open(tester);

    await enter(tester, '9999');
    await submit(tester);
    await enter(tester, '7731');
    await submit(tester);
    await enter(tester, '7731');
    await submit(tester);

    expect(find.byKey(const Key(LockKeys.pinError)), findsOneWidget);
    expect(find.byKey(const Key(LockKeys.pinSetupScreen)), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
