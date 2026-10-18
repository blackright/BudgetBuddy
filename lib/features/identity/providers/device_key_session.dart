import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/identity_provider.dart';
import '../repositories/identity_service.dart';

/// The keystore seam: hands back the identity's private key **after** the
/// phone's own authentication has passed (research R1/R8, FR-002).
///
/// The prompt itself is not this seam's job — [DeviceKeySession] owns the
/// single prompt — so the real implementation reads the keystore with
/// `requireDeviceAuth: false` and never touches `local_auth` on its own.
abstract class IdentityKeyLoader {
  /// The identity's ed25519 keypair, or `null` when no key is stored yet.
  Future<SimpleKeyPair?> load();
}

/// The real keystore-backed loader (`flutter_secure_storage`, research R1).
class KeystoreIdentityKeyLoader implements IdentityKeyLoader {
  KeystoreIdentityKeyLoader(this._identityService);

  final IdentityService _identityService;

  @override
  Future<SimpleKeyPair?> load() =>
      _identityService.unlock(requireDeviceAuth: false);
}

/// The app-wide keystore seam, so tests can fake it without hardware.
final identityKeyLoaderProvider = Provider<IdentityKeyLoader>(
  (ref) => KeystoreIdentityKeyLoader(ref.watch(identityServiceProvider)),
);

/// The unlocked identity key for this session, or `null` while locked
/// (FR-002, research R2).
///
/// This replaces the old `unlockedKeyPairProvider` `FutureProvider`, which
/// evaluated **once** and memoised the answer for the whole app session. A
/// cancelled or dropped biometric prompt came back as `null` and was then
/// served to every later caller — so "Your identity stayed locked" appeared on
/// every invite with no way to retry (Phase 3b.2, T073).
///
/// The rules here are deliberately different:
/// * **One prompt at a time.** Concurrent callers await the *same* in-flight
///   prompt instead of each starting their own. Two racing `local_auth`
///   `authenticate()` calls is exactly what produced
///   `W/BiometricFragment: Success/Error not sent to client. Client is not
///   awaiting a result.` and the "scan my fingerprint three times" symptom.
/// * **A failure is never remembered.** When the prompt is declined, cancelled,
///   or errors, nothing is stored and the in-flight flag clears, so the next
///   `require()` genuinely prompts again.
/// * **An unlocked key is free.** Once the key is out, `require()` returns it
///   without ever showing the prompt a second time.
final deviceKeySessionProvider =
    NotifierProvider<DeviceKeySession, SimpleKeyPair?>(DeviceKeySession.new);

/// Holds the session's unlocked key and serialises every prompt behind one
/// in-memory single-flight guard.
class DeviceKeySession extends Notifier<SimpleKeyPair?> {
  /// The prompt everybody is currently waiting on, or `null` when idle.
  Future<SimpleKeyPair?>? _inFlight;

  @override
  SimpleKeyPair? build() => null;

  /// Whether the key is already out (so a caller can skip prompting).
  bool get isUnlocked => state != null;

  /// The unlocked key, prompting for [reason] at most once across all
  /// concurrent callers. Returns `null` when the user declines or there is no
  /// key to release — in which case a later call prompts again.
  Future<SimpleKeyPair?> require({required String reason}) {
    final unlocked = state;
    if (unlocked != null) return Future<SimpleKeyPair?>.value(unlocked);
    return _inFlight ??= _authenticate(reason);
  }

  /// Drops the key from memory (app lock).
  ///
  /// A no-op when the session is already locked: there is nothing to release
  /// and nothing worth notifying listeners about.
  void lock() {
    if (state == null) return;
    state = null;
  }

  Future<SimpleKeyPair?> _authenticate(String reason) async {
    // Read the seams before the first `await`: a notifier's `ref` must not be
    // used after it could have been disposed.
    final authenticator = ref.read(deviceAuthenticatorProvider);
    final loader = ref.read(identityKeyLoaderProvider);
    try {
      if (!await authenticator.authenticate(reason: reason)) return null;
      final keyPair = await loader.load();
      if (keyPair != null) state = keyPair;
      return keyPair;
    } on Object catch (error, stackTrace) {
      // A keystore/platform hiccup is a refusal like any other. Callers treat
      // `null` as "nothing was shared, try again" and several of them are
      // fire-and-forget, so letting this escape would surface as an unhandled
      // async error *and* leave the session looking permanently locked.
      debugPrint(
          'DeviceKeySession.require($reason) failed: $error\n$stackTrace');
      return null;
    } finally {
      // Clear last, so a caller that arrives while we are still storing the key
      // joins this flight rather than starting a second prompt.
      _inFlight = null;
    }
  }
}
