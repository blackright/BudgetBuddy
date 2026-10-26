import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart';

import '../../identity/repositories/secret_store.dart';
import '../domain/lock_secret_keys.dart';

/// The key-derivation seam behind the PIN verifier (research R2/R2b).
///
/// Split out so the widget and unit tests can run the whole unlock path without
/// paying PBKDF2's deliberately-slow cost, while production gets the real KDF.
/// The [floorIterations] is the documented minimum the calibrated count is never
/// taken below, and is also the value a stored record is compared against to
/// decide whether its cost should be raised.
abstract class PinKdf {
  /// The documented floor the iteration count is never set below.
  int get floorIterations;

  /// Derives the 32-byte verifier for [pin] with [salt] and [iterations].
  Future<List<int>> derive({
    required String pin,
    required List<int> salt,
    required int iterations,
  });

  /// Picks the iteration count to use when a PIN is set (research R2b): the
  /// highest count that keeps the derivation under the target time, never below
  /// the floor.
  Future<int> calibrate();
}

/// The real KDF: PBKDF2-HMAC-SHA256, the shape `cryptography` provides and the
/// one research R2 chose over a bespoke construction.
class Pbkdf2PinKdf implements PinKdf {
  const Pbkdf2PinKdf({
    this.floorIterations = 100000,
    this.targetMs = 150,
    this.ceiling = 2000000,
  });

  @override
  final int floorIterations;

  /// The derivation time the calibration tries to stay under, on this device.
  final int targetMs;

  /// A hard ceiling so a very fast device cannot calibrate into a multi-second
  /// unlock.
  final int ceiling;

  @override
  Future<List<int>> derive({
    required String pin,
    required List<int> salt,
    required int iterations,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    final key = await pbkdf2.deriveKeyFromPassword(password: pin, nonce: salt);
    return key.extractBytes();
  }

  @override
  Future<int> calibrate() async {
    final salt = randomBytes(16);
    var iterations = floorIterations;
    while (true) {
      final stopwatch = Stopwatch()..start();
      await derive(pin: '000000', salt: salt, iterations: iterations);
      stopwatch.stop();
      if (stopwatch.elapsedMilliseconds >= targetMs || iterations >= ceiling) {
        return iterations;
      }
      final doubled = iterations * 2;
      iterations = doubled > ceiling ? ceiling : doubled;
    }
  }
}

/// One subject's PIN verifier, as stored in the OS secure storage.
class PinRecord {
  const PinRecord({
    required this.version,
    required this.kdf,
    required this.salt,
    required this.iterations,
    required this.verifier,
  });

  static const int currentVersion = 1;
  static const String algorithm = 'pbkdf2-hmac-sha256';

  final int version;
  final String kdf;
  final List<int> salt;
  final int iterations;
  final List<int> verifier;

  Map<String, Object?> toJson() => {
        'v': version,
        'kdf': kdf,
        'salt': base64Encode(salt),
        'iterations': iterations,
        'verifier': base64Encode(verifier),
      };

  /// Parses a stored record, or returns `null` when it is absent or damaged.
  ///
  /// A damaged record reads as "no PIN": the subject then cannot be unlocked
  /// through this path, which is the fail-closed direction — it never lets a
  /// half-read record be treated as a match.
  static PinRecord? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final version = decoded['v'];
      final kdf = decoded['kdf'];
      final salt = decoded['salt'];
      final iterations = decoded['iterations'];
      final verifier = decoded['verifier'];
      if (version is! int ||
          kdf is! String ||
          salt is! String ||
          iterations is! int ||
          verifier is! String) {
        return null;
      }
      return PinRecord(
        version: version,
        kdf: kdf,
        salt: base64Decode(salt),
        iterations: iterations,
        verifier: base64Decode(verifier),
      );
    } on Object {
      return null;
    }
  }
}

/// Reads, writes and checks one subject's PIN verifier (FR-008, FR-009,
/// FR-011, FR-012).
///
/// The only storage is the [SecretStore] — the OS keystore. Nothing here ever
/// writes to Isar, a log, a crash report or the wire, so the verifier physically
/// cannot travel with the data it protects (FR-008).
class PinVerifierStore {
  PinVerifierStore(this._secrets, {PinKdf? kdf})
      : _kdf = kdf ?? const Pbkdf2PinKdf();

  final SecretStore _secrets;
  final PinKdf _kdf;

  /// Whether a PIN has ever been set for `subjectKey`.
  Future<bool> isSet(String subjectKey) async =>
      await _read(subjectKey) != null;

  /// Writes a fresh salt and verifier for [pin] (FR-009, FR-012).
  ///
  /// This touches **only** the PIN record, by design: a change must carry no
  /// risk to any other stored record.
  Future<void> setPin(String subjectKey, String pin) async {
    final salt = randomBytes(16);
    final iterations = await _kdf.calibrate();
    final verifier = await _kdf.derive(
      pin: pin,
      salt: salt,
      iterations: iterations,
    );
    final record = PinRecord(
      version: PinRecord.currentVersion,
      kdf: PinRecord.algorithm,
      salt: salt,
      iterations: iterations,
      verifier: verifier,
    );
    await _secrets.write(
      LockSecretKeys.pin(subjectKey),
      jsonEncode(record.toJson()),
    );
  }

  /// Whether [pin] matches, in constant time (FR-011).
  ///
  /// On a match, a record whose cost has fallen behind the floor is re-derived
  /// with the current cost, so the KDF's strength travels with the app rather
  /// than being frozen at whatever was chosen the first time.
  Future<bool> verify(String subjectKey, String pin) async {
    final record = await _read(subjectKey);
    if (record == null) return false;

    final candidate = await _kdf.derive(
      pin: pin,
      salt: record.salt,
      iterations: record.iterations,
    );
    final matches =
        constantTimeBytesEquality.equals(candidate, record.verifier);

    if (matches && record.iterations < _kdf.floorIterations) {
      await setPin(subjectKey, pin);
    }
    return matches;
  }

  /// Removes the subject's verifier (turning the lock off).
  Future<void> delete(String subjectKey) =>
      _secrets.delete(LockSecretKeys.pin(subjectKey));

  Future<PinRecord?> _read(String subjectKey) async {
    final raw = await _secrets.read(LockSecretKeys.pin(subjectKey));
    return raw == null ? null : PinRecord.tryParse(raw);
  }
}
