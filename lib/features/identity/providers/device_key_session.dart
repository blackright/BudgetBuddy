import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/identity_provider.dart';
import '../repositories/identity_service.dart';
import 'device_auth_session.dart';

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
  Future<SimpleKeyPair?>? _inFlight;
  int _generation = 0;
  bool _alive = false;
  @override
  SimpleKeyPair? build() {
    ref.listen(nativeAccessBindingProvider, (previous, next) {
      if (previous?.token != next.token) {
        _generation++;
        state = null;
      }
    });
    ref.listen(deviceAuthSessionProvider.select((s) => s.generation),
        (previous, next) {
      if (previous != next) {
        _generation++;
        state = null;
      }
    });
    _generation++;
    _alive = true;
    ref.onDispose(() {
      _alive = false;
      _generation++;
    });
    return null;
  }

  bool get isUnlocked => state != null;
  Future<SimpleKeyPair?> require({required String reason}) {
    final binding = ref.read(nativeAccessBindingProvider);
    if (!binding.resolved || binding.identity == null) {
      return Future.value(null);
    }
    final native = ref.read(deviceAuthSessionProvider.notifier);
    if (!native.isCurrent(native.generation)) return Future.value(null);
    if (state != null) return Future.value(state);
    return _inFlight ??= _authenticate(reason);
  }

  void lock() {
    _generation++;
    ref.read(deviceAuthSessionProvider.notifier).lock();
    if (_alive && state != null) state = null;
  }

  Future<SimpleKeyPair?> _authenticate(String reason) async {
    final auth = ref.read(deviceAuthSessionProvider.notifier);
    final loader = ref.read(identityKeyLoaderProvider);
    final epoch = _generation, authEpoch = auth.generation;
    try {
      if (!await auth.require(reason: reason)) return null;
      if (!_alive || epoch != _generation || !auth.isCurrent(authEpoch)) {
        return null;
      }
      final key = await loader.load();
      if (!_alive || epoch != _generation || !auth.isCurrent(authEpoch)) {
        return null;
      }
      if (key != null) {
        state = key;
      } else {
        auth.lock();
      }
      return key;
    } catch (_) {
      if (_alive && epoch == _generation && auth.isCurrent(authEpoch)) {
        auth.lock();
      }
      return null;
    } finally {
      _inFlight = null;
    }
  }
}
