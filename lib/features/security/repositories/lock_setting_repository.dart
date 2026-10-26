import 'package:isar/isar.dart';

import '../../../core/models/lock_setting.dart';
import 'lock_settings_store.dart';

/// Reads and writes the one non-secret [LockSetting] row per subject
/// (data-model §2, FR-032).
///
/// Everything secret lives in the OS secure storage, not here — this repository
/// never touches a PIN, a verifier, a salt or a lockout count (FR-008).
class LockSettingRepository implements LockSettingsStore {
  const LockSettingRepository(this._isar);

  final Isar _isar;

  /// Streams the subject's row, emitting `null` when no lock was ever
  /// configured for it (the opt-in case).
  @override
  Stream<LockSetting?> watch(String subjectKey) => _isar.lockSettings
      .filter()
      .subjectKeyEqualTo(subjectKey)
      .sortBySubjectKey()
      .watch(fireImmediately: true)
      .map((rows) => rows.isEmpty ? null : rows.first);

  @override
  Future<LockSetting?> find(String subjectKey) =>
      _isar.lockSettings.filter().subjectKeyEqualTo(subjectKey).findFirst();

  /// Every configured setting on this device.
  @override
  Future<List<LockSetting>> all() => _isar.lockSettings.where().findAll();

  /// Creates or updates the subject's row, stamping `updatedAt`.
  @override
  Future<void> upsert(LockSetting setting, {DateTime? at}) async {
    setting.updatedAt = at ?? DateTime.now();
    await _isar.writeTxn(() => _isar.lockSettings.put(setting));
  }

  /// Removes the subject's row, owning its own transaction.
  @override
  Future<void> delete(String subjectKey) async {
    await _isar.writeTxn(() => deleteRowInTxn(subjectKey));
  }

  /// Deletes the subject's row **inside the caller's transaction**.
  ///
  /// Split out for the FR-034 cascade: the space and profile removal paths
  /// already hold a write transaction, and Isar 3.1 has no nested transactions.
  Future<void> deleteRowInTxn(String subjectKey) =>
      _isar.lockSettings.filter().subjectKeyEqualTo(subjectKey).deleteAll();
}
