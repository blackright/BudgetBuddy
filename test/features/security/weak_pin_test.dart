import 'package:budget_buddy/features/security/domain/pin_policy.dart';
import 'package:budget_buddy/features/security/domain/weak_pins.dart';
import 'package:flutter_test/flutter_test.dart';

/// T018: FR-010 — a clearly guessable PIN is refused with a plain message.
///
/// The three families the requirement names are pinned separately (all
/// identical digits, simple runs, the short weak list) so a later "fix" that
/// drops one of them fails here rather than shipping.
void main() {
  group('T018: identical digits are refused', () {
    test('every repeated-digit PIN is weak', () {
      for (var digit = 0; digit <= 9; digit++) {
        final pin = List.filled(4, '$digit').join();
        expect(WeakPins.isWeak(pin), isTrue, reason: '$pin must be refused');
        expect(WeakPins.isWeak('$pin$digit'), isTrue);
      }
    });
  });

  group('T018: simple runs are refused', () {
    test('ascending and descending runs of any start are weak', () {
      expect(WeakPins.isWeak('1234'), isTrue);
      expect(WeakPins.isWeak('2345'), isTrue);
      expect(WeakPins.isWeak('6789'), isTrue);
      expect(WeakPins.isWeak('4321'), isTrue);
      expect(WeakPins.isWeak('9876'), isTrue);
      expect(WeakPins.isWeak('0123'), isTrue);
    });

    test('a stepped pattern is not a run, but may be on the weak list', () {
      expect(WeakPins.isWeak('1357'), isFalse,
          reason: 'a step of two is not the simple run FR-010 names');
      expect(WeakPins.isWeak('2468'), isFalse);
    });
  });

  group('T018: the short weak list is refused', () {
    test('the maintained list is refused even without a run', () {
      for (final pin in WeakPins.knownWeak) {
        expect(WeakPins.isWeak(pin), isTrue, reason: '$pin must be refused');
      }
    });

    test('a normal PIN is not weak', () {
      expect(WeakPins.isWeak('4821'), isFalse);
      expect(WeakPins.isWeak('73915'), isFalse);
      expect(WeakPins.isWeak('842963'), isFalse);
    });
  });

  group('T018: PinPolicy is the single entry point', () {
    test('a normal PIN passes the policy', () {
      expect(PinPolicy.inspect('4821'), isNull);
      expect(PinPolicy.errorFor('4821'), isNull);
    });

    test('too short, too long, non-digits and guessable each get a message',
        () {
      expect(PinPolicy.inspect('482'), PinProblem.tooShort);
      expect(PinPolicy.inspect('4821372910'), PinProblem.tooLong);
      expect(PinPolicy.inspect('48a1'), PinProblem.notDigits);
      expect(PinPolicy.inspect('1111'), PinProblem.guessable);
      for (final problem in PinProblem.values) {
        expect(PinPolicy.message(problem), isNotEmpty);
      }
    });

    test('the bounds are exactly 4 to 8 digits (FR-007)', () {
      expect(PinPolicy.minLength, 4);
      expect(PinPolicy.maxLength, 8);
      expect(PinPolicy.errorFor('4821'), isNull);
      expect(PinPolicy.errorFor('48213729'), isNull);
      expect(PinPolicy.errorFor('482'), isNotNull);
      expect(PinPolicy.errorFor('482137291'), isNotNull);
    });
  });
}
