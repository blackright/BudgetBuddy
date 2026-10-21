/// The widget keys the lock, PIN and security-settings tests bind to
/// (`contracts/security-settings-ui.md` §6).
///
/// They live here as plain `String` constants rather than `Key` instances so a
/// widget and its test name exactly one source: a rename that forgot one side
/// would fail to compile rather than silently orphan a test.
class LockKeys {
  const LockKeys._();

  /// The Settings card that manages this subject's lock (FR-035).
  static const String securitySection = 'securitySection';

  /// Turns the lock on or off. Turning it on starts PIN setup; turning it off
  /// requires the current PIN (FR-009).
  static const String lockSwitch = 'lockSwitch';

  /// "Change PIN" — current PIN, then the new PIN twice (FR-009).
  static const String changePinButton = 'changePinButton';

  /// The in-session biometric shortcut switch.
  static const String biometricSwitch = 'biometricSwitch';

  /// The five bounded away-time choices (FR-033).
  static const String awayTimeDropdown = 'awayTimeDropdown';

  /// The read-only active-wait row (FR-035).
  static const String lockoutStatus = 'lockoutStatus';

  /// The PIN setup / change screen.
  static const String pinSetupScreen = 'pinSetupScreen';

  /// The field in the "confirm the current PIN" dialog (turning the lock off,
  /// FR-009).
  static const String pinConfirmField = 'pinConfirmField';

  /// The confirm action in that dialog.
  static const String pinConfirmSubmit = 'pinConfirmSubmit';

  /// The numeric keypad (FR-036).
  static const String pinKeypad = 'pinKeypad';

  /// The masked PIN entry line (never the digits themselves, FR-023).
  static const String pinDisplay = 'pinDisplay';

  /// The keypad's confirm key.
  static const String pinSubmit = 'pinSubmit';

  /// The keypad's backspace key.
  static const String pinBackspace = 'pinBackspace';

  /// The PIN screen's error line.
  static const String pinError = 'pinError';

  /// The lockout countdown (FR-036).
  static const String lockoutCountdown = 'lockoutCountdown';

  /// The single Unlock action on the lock screen (FR-037).
  static const String unlockButton = 'unlockButton';

  /// The in-session biometric option on the PIN screen (FR-036).
  static const String biometricUnlockButton = 'biometricUnlockButton';

  /// The Owner's "require a PIN" switch (FR-027).
  static const String spaceRequirePinSwitch = 'spaceRequirePinSwitch';

  /// The Owner's "forbid the biometric shortcut" switch (FR-027).
  static const String spaceForbidBiometricsSwitch =
      'spaceForbidBiometricsSwitch';

  /// The Owner's away-time for the space (FR-027).
  static const String spaceAwayTimeDropdown = 'spaceAwayTimeDropdown';
}
