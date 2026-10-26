/// The outcome of an unlock attempt or a PIN check (FR-011, FR-048).
///
/// Deliberately richer than a `bool`: the PIN screen must tell "wrong PIN"
/// (count it, offer a retry) from "locked out" (a wait is running) from "the
/// device's own prompt was declined" (a correct PIN that still must not open
/// the app). Collapsing those into `false` would accuse the user wrongly.
enum PinResult {
  /// The PIN matched and the subject is open.
  accepted,

  /// The PIN did not match; the failure has been recorded (FR-011, FR-013).
  wrongPin,

  /// A lockout wait is still running; nothing was checked (FR-013).
  lockedOut,

  /// The PIN matched but the phone's own authentication was declined, so the
  /// key stayed in the keystore (FR-048).
  deviceRefused,

  /// No PIN was ever set for this subject.
  notConfigured,
}
