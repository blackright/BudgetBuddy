import 'package:local_auth/local_auth.dart';

/// The phone's own PIN/biometrics, behind a seam so tests never touch hardware
/// (research R1/R8, FR-002).
abstract class DeviceAuthenticator {
  /// Whether this device can authenticate at all.
  Future<bool> isAvailable();

  /// Prompts the user; `true` only on a successful unlock.
  Future<bool> authenticate({required String reason});
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
}
