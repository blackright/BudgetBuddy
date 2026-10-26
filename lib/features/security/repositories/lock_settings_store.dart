import '../../../core/models/lock_setting.dart';

/// The seam the lock reads its one non-secret setting row through.
///
/// The real implementation is [LockSettingRepository] over Isar; the widget
/// tests use an in-memory double. It exists so the settings card and the
/// controller can be tested without a live database, which is the one thing
/// `testWidgets` cannot host.
abstract class LockSettingsStore {
  /// Streams the subject's row, emitting `null` when no lock was ever
  /// configured for it.
  Stream<LockSetting?> watch(String subjectKey);

  Future<LockSetting?> find(String subjectKey);

  /// Every configured setting on this device.
  Future<List<LockSetting>> all();

  /// Creates or updates the subject's row, stamping `updatedAt`.
  Future<void> upsert(LockSetting setting, {DateTime? at});

  /// Removes the subject's row.
  Future<void> delete(String subjectKey);
}
