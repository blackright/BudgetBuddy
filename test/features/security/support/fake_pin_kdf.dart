import 'dart:convert';

import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';

/// A fast, deterministic stand-in for PBKDF2 in the unit tests.
///
/// The real `Pbkdf2PinKdf` is a pure-Dart KDF whose whole point is to be slow;
/// running it in every test would make the suite unusable. This double produces
/// a 32-byte digest that depends on the PIN, the salt **and** the iteration
/// count, so every rule the tests pin (a wrong PIN yields a different verifier, a
/// fresh salt per subject, a raised cost re-derives) still holds.
class FakePinKdf implements PinKdf {
  FakePinKdf({this.floorIterations = 1000, this.calibrated = 2000});

  @override
  final int floorIterations;

  /// What [calibrate] returns — usually above the floor, as on a real device.
  final int calibrated;

  /// How many derivations have happened, so a test can see the cost being paid
  /// again after a raised iteration count.
  int derivations = 0;

  @override
  Future<int> calibrate() async => calibrated;

  @override
  Future<List<int>> derive({
    required String pin,
    required List<int> salt,
    required int iterations,
  }) async {
    derivations++;
    final pinBytes = utf8.encode(pin);
    // Fold the whole PIN, the whole salt and the count into a small running
    // state, then expand it to 32 bytes. Not a real KDF — just impossible to
    // collide on a one-character difference.
    var state = 0x811c9dc5 ^ iterations;
    void mix(int byte) {
      state = (state ^ byte) & 0xffffffff;
      state = (state * 0x01000193) & 0xffffffff;
    }

    for (final byte in salt) {
      mix(byte);
    }
    for (final byte in pinBytes) {
      mix(byte);
    }

    final out = List<int>.filled(32, 0);
    for (var i = 0; i < out.length; i++) {
      mix(i + 1);
      mix(pinBytes.length);
      out[i] = state & 0xff;
    }
    return out;
  }
}
