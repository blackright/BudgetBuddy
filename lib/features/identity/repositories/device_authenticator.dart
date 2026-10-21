import 'package:local_auth/local_auth.dart';

import 'local_auth_outcome.dart';

/// The phone's own PIN/biometrics, behind a seam so tests never touch hardware
/// (research R1/R8, FR-002).
abstract class DeviceAuthenticator {
  /// Whether this device can authenticate at all (hardware support).
  Future<bool> isAvailable();

  /// Whether at least one biometric is enrolled (FR-017).
  Future<bool> isEnrolled();

  /// Prompts the user; `true` only on a successful unlock.
  Future<bool> authenticate({required String reason});

  /// Classifies the device's biometric capability and, when capable, prompts
  /// for it (research R5, FR-017, FR-019, FR-021).
  ///
  /// Returns a [BiometricOutcome] so callers can tell a cancel (no failure
  /// counted) from a device with no biometrics from a temporary lockout, and
  /// can show the right message instead of a dead end. The existing
  /// [authenticate] keeps its signature and its call sites.
  Future<BiometricOutcome> classify({required String reason});
}

/// The real `local_auth` implementation.
///
/// `biometricOnly: false` accepts the device passcode/PIN as a fallback, which
/// is exactly the "the phone's own PIN/biometrics" the spec asks for (R1).
class LocalAuthDeviceAuthenticator implements DeviceAuthenticator {
  LocalAuthDeviceAuthenticator([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isEnrolled() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<BiometricOutcome> classify({required String reason}) async {
    try {
      if (!await _auth.isDeviceSupported()) {
        return BiometricOutcome.unavailable;
      }
      final enrolled = await _auth.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        return BiometricOutcome.notEnrolled;
      }
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricOutcome.unlocked : BiometricOutcome.cancelled;
    } on LocalAuthException catch (e) {
      return outcomeFromExceptionCode(e.code);
    } catch (_) {
      return BiometricOutcome.error;
    }
  }
}
