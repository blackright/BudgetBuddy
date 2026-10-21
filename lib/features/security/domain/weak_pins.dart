/// The clearly-guessable PINs the app refuses (FR-010).
///
/// Three families are refused, in this order of cheapness:
///
/// * every digit identical (`0000`, `7777`) — the single most-tried shape;
/// * a simple run, ascending or descending (`1234`, `4321`, `0123`);
/// * a short maintained list of the PINs attackers try first, which catches the
///   shapes a rule cannot (`1212`, `1004`, `6969`, …).
///
/// The list is deliberately short. It is a deterrent for the obvious guesses,
/// not a dictionary: a longer list would tempt a future change into treating it
/// as a strength meter, which it is not.
class WeakPins {
  const WeakPins._();

  /// The plain message shown when a PIN is refused (FR-010).
  static const String refusedMessage =
      'That PIN is too easy to guess. Avoid repeated digits, sequences and '
      'common codes.';

  /// The maintained weak list. Kept as a `const Set` so [isWeak] is a pure,
  /// unit-testable function with no I/O.
  static const Set<String> knownWeak = {
    '1004',
    '1010',
    '1122',
    '1212',
    '1313',
    '1990',
    '2000',
    '2001',
    '2020',
    '6969',
  };

  /// Whether [pin] is clearly guessable and must be refused (FR-010).
  static bool isWeak(String pin) {
    if (pin.length < 2) return true;
    if (_allIdentical(pin)) return true;
    if (_isSimpleRun(pin)) return true;
    return knownWeak.contains(pin);
  }

  static bool _allIdentical(String pin) {
    final first = pin.codeUnitAt(0);
    for (var i = 1; i < pin.length; i++) {
      if (pin.codeUnitAt(i) != first) return false;
    }
    return true;
  }

  /// True when every step is `+1` (or every step is `-1`) across the whole PIN,
  /// so `1234` and `9876` are runs but `12349` and `1357` are not.
  static bool _isSimpleRun(String pin) {
    var ascending = true;
    var descending = true;
    for (var i = 1; i < pin.length; i++) {
      final step = pin.codeUnitAt(i) - pin.codeUnitAt(i - 1);
      if (step != 1) ascending = false;
      if (step != -1) descending = false;
    }
    return ascending || descending;
  }
}
