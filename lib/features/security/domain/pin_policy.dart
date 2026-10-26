import 'weak_pins.dart';

/// Why a PIN was refused, or `null` when it was accepted.
enum PinProblem { tooShort, tooLong, notDigits, guessable }

/// The one place a PIN's shape is judged (FR-007, FR-010).
///
/// Pure Dart. The screens call [errorFor]; the verifier store never sees a PIN
/// that failed here, which is what keeps a 3-digit or `1111` PIN out of the
/// keystore entirely rather than merely out of the UI.
class PinPolicy {
  const PinPolicy._();

  /// FR-007: a PIN is 4-8 digits.
  static const int minLength = 4;
  static const int maxLength = 8;

  /// The problem with [pin], or `null` when it is acceptable.
  static PinProblem? inspect(String pin) {
    if (pin.length < minLength) return PinProblem.tooShort;
    if (pin.length > maxLength) return PinProblem.tooLong;
    for (final unit in pin.codeUnits) {
      if (unit < 0x30 || unit > 0x39) return PinProblem.notDigits;
    }
    if (WeakPins.isWeak(pin)) return PinProblem.guessable;
    return null;
  }

  /// The plain-English message for [problem] (FR-010: "a plain message").
  static String message(PinProblem problem) => switch (problem) {
        PinProblem.tooShort => 'Use at least $minLength digits.',
        PinProblem.tooLong => 'Use no more than $maxLength digits.',
        PinProblem.notDigits => 'A PIN is digits only.',
        PinProblem.guessable => WeakPins.refusedMessage,
      };

  /// The message to show for [pin], or `null` when it may be accepted.
  static String? errorFor(String pin) {
    final problem = inspect(pin);
    return problem == null ? null : message(problem);
  }
}
