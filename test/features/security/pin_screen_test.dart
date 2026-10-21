import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/domain/pin_result.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// T022: FR-036 — the PIN screen is a numeric keypad, a clear error line, a
/// lockout countdown and a disabled keypad while a wait runs.
///
/// The screen is presentational: it takes the submit callback and the remaining
/// wait as parameters, so these cases need no provider, no database and no
/// keystore.
void main() {
  const subject = LockSubject(
    kind: LockSubjectKind.profile,
    localId: 1,
    guid: '',
    name: 'Ann',
    avatar: '🧑',
  );

  Widget host({
    required Future<PinResult> Function(String) onSubmit,
    Duration Function()? remainingWait,
  }) =>
      MaterialApp(
        home: PinScreen(
          subject: subject,
          onSubmit: onSubmit,
          remainingWait: remainingWait ?? () => Duration.zero,
        ),
      );

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

  String display(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('pinDisplay'))).data!;

  testWidgets('shows the subject and a numeric keypad', (tester) async {
    await tester.pumpWidget(host(onSubmit: (_) async => PinResult.wrongPin));

    expect(find.text('Ann'), findsOneWidget);
    expect(find.byKey(const Key(LockKeys.pinKeypad)), findsOneWidget);
    for (final digit in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      expect(find.text(digit), findsOneWidget, reason: 'keypad digit $digit');
    }
  });

  testWidgets('a wrong PIN shows the error line and clears the entry',
      (tester) async {
    await tester.pumpWidget(host(onSubmit: (_) async => PinResult.wrongPin));

    await enter(tester, '4821');
    expect(display(tester), '••••');
    await submit(tester);

    expect(find.byKey(const Key(LockKeys.pinError)), findsOneWidget);
    expect(display(tester), isEmpty, reason: 'the entry is cleared to retry');
  });

  testWidgets('a correct PIN leaves no error behind', (tester) async {
    await tester.pumpWidget(host(onSubmit: (_) async => PinResult.accepted));

    await enter(tester, '4821');
    await submit(tester);

    expect(find.byKey(const Key(LockKeys.pinError)), findsNothing);
  });

  testWidgets('while locked out the keypad is disabled and a countdown shows',
      (tester) async {
    await tester.pumpWidget(host(
      onSubmit: (_) async => PinResult.lockedOut,
      remainingWait: () => const Duration(seconds: 30),
    ));

    expect(find.byKey(const Key(LockKeys.lockoutCountdown)), findsOneWidget);
    expect(find.textContaining('30'), findsWidgets);

    await enter(tester, '48');
    expect(display(tester), isEmpty,
        reason: 'the keypad is disabled while the wait runs (FR-036)');

    // Let the periodic countdown ticker be disposed with the tree.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the entry is masked, never the digits themselves',
      (tester) async {
    await tester.pumpWidget(host(onSubmit: (_) async => PinResult.wrongPin));

    await enter(tester, '4821');

    expect(display(tester), '••••');
    expect(find.text('4821'), findsNothing);
  });

  testWidgets('a locked-out submit reports the wait, not a wrong PIN',
      (tester) async {
    final results = <String>[];
    await tester.pumpWidget(host(
      onSubmit: (pin) async {
        results.add(pin);
        return PinResult.lockedOut;
      },
      remainingWait: () => Duration.zero,
    ));

    await enter(tester, '4821');
    await submit(tester);

    expect(results, ['4821']);
    expect(find.byKey(const Key(LockKeys.pinError)), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
