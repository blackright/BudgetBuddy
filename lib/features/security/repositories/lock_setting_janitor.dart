import 'package:isar/isar.dart';

import '../../identity/repositories/secret_store.dart';
import '../domain/lock_secret_keys.dart';
import 'lock_setting_repository.dart';

/// The FR-034 cascade: a removed subject takes its security setting with it.
///
/// Both halves matter and neither is optional. Leaving the Isar row behind would
/// show a stale "lock is on" for a profile that no longer exists, and leaving the
/// verifier behind would let a later profile or space that happened to reuse the
/// key inherit a PIN nobody set for it. Deleting both is the only honest
/// outcome.
///
/// The Isar half is split into [deleteRowInTxn] on purpose. The space and
/// profile removal paths already own a write transaction, Isar 3.1 has no
/// nested transactions, and a janitor that opened its own would deadlock the
/// removal it is meant to complete. The secure-storage half cannot be in the
/// transaction at all (it is not Isar), so it runs after with [forgetSecrets].
class LockSettingJanitor {
  LockSettingJanitor(
    this._repository, {
    SecretStore secretStore = const FlutterSecureStorageSecretStore(),
  }) : _secretStore = secretStore;

  /// The app-wide janitor: the real keystore, so removals erase the real
  /// verifier.
  factory LockSettingJanitor.forApp(Isar isar) =>
      LockSettingJanitor(LockSettingRepository(isar));

  final LockSettingRepository _repository;
  final SecretStore _secretStore;

  /// Deletes the subject's setting row **inside the caller's transaction**.
  Future<void> deleteRowInTxn(String subjectKey) =>
      _repository.deleteRowInTxn(subjectKey);

  /// Deletes the subject's verifier and lockout records from secure storage.
  ///
  /// Runs after the row is gone, outside any transaction. Deleting a key that
  /// was never written is a no-op, so calling it for a subject that never had a
  /// lock is safe.
  Future<void> forgetSecrets(String subjectKey) async {
    await _secretStore.delete(LockSecretKeys.pin(subjectKey));
    await _secretStore.delete(LockSecretKeys.lockout(subjectKey));
  }

  /// The whole cascade, owning its own transaction — for a caller that does not
  /// already have one.
  Future<void> forget(String subjectKey) async {
    await _repository.delete(subjectKey);
    await forgetSecrets(subjectKey);
  }
}
