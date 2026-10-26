/// The OS-secure-storage key spellings for one subject's secrets
/// (`contracts/pin-verifier-and-lockout.md` §1, FR-008).
///
/// One source of truth on purpose. The PIN verifier writes these, the lockout
/// record writes these, and the FR-034 cascade deletes exactly these; three
/// copies of the string would mean a rename could silently orphan a secret, and
/// an orphaned verifier is a PIN nobody can ever clear.
///
/// The records never touch Isar, a log, a crash report, a backup, or the wire
/// (FR-008, FR-042, FR-043).
class LockSecretKeys {
  const LockSecretKeys._();

  /// The PIN verifier for `subjectKey` (`p<profileId>` or `s<syncGuid>`).
  static String pin(String subjectKey) => 'sec_pin_$subjectKey';

  /// The persisted lockout record (failure count plus the wait's deadline) for
  /// `subjectKey`. Surviving a force-quit is the point (FR-014).
  static String lockout(String subjectKey) => 'sec_lockout_$subjectKey';
}
