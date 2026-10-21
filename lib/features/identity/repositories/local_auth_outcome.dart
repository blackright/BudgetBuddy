import 'package:local_auth/local_auth.dart';

/// The classified result of a biometric authentication attempt (research R5,
/// FR-017, FR-019, FR-021).
///
/// Distinct from a bare `bool` so the UI can tell a cancel (no failure counted)
/// from a device that has no biometrics from a temporary lockout, and can show
/// the right message instead of a dead end.
enum BiometricOutcome {
  /// The device accepted the user.
  unlocked,

  /// The user cancelled, or the OS cancelled it for them (timeout, background).
  /// Never counted as a wrong PIN (FR-019).
  cancelled,

  /// The device has no biometric hardware, or it is temporarily unavailable.
  unavailable,

  /// The device supports biometrics but none are enrolled (FR-017).
  notEnrolled,

  /// Too many attempts; the device locked biometrics until some other auth succeeds.
  temporarilyLockedOut,

  /// Any other failure (device error, unknown, in-progress, no credentials, etc.).
  error,
}

/// Maps a [LocalAuthExceptionCode] to a [BiometricOutcome].
///
/// Pure function, so the mapping is testable without hardware (T035).
BiometricOutcome outcomeFromExceptionCode(LocalAuthExceptionCode code) {
  switch (code) {
    case LocalAuthExceptionCode.userCanceled:
    case LocalAuthExceptionCode.systemCanceled:
    case LocalAuthExceptionCode.timeout:
      return BiometricOutcome.cancelled;

    case LocalAuthExceptionCode.noBiometricHardware:
    case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
      return BiometricOutcome.unavailable;

    case LocalAuthExceptionCode.noBiometricsEnrolled:
      return BiometricOutcome.notEnrolled;

    case LocalAuthExceptionCode.temporaryLockout:
    case LocalAuthExceptionCode.biometricLockout:
      return BiometricOutcome.temporarilyLockedOut;

    case LocalAuthExceptionCode.authInProgress:
    case LocalAuthExceptionCode.uiUnavailable:
    case LocalAuthExceptionCode.noCredentialsSet:
    case LocalAuthExceptionCode.userRequestedFallback:
    case LocalAuthExceptionCode.deviceError:
    case LocalAuthExceptionCode.unknownError:
      return BiometricOutcome.error;
  }
}
