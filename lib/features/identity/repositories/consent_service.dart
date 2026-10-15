import 'package:isar/isar.dart';

import '../../../core/models/consent_record.dart';

/// The current version of the device-auth consent notice (FR-002, research R8).
///
/// Bump when the notice text changes so a newer ask is distinguishable from an
/// old consent.
const String kConsentNoticeVersion = '1';

/// Records, reads and revokes the local device-auth consent (data-model §2.2,
/// FR-002).
///
/// Consent is voluntary and revocable: declining keeps the app fully usable
/// (with a warning), and a revocation simply re-writes the single row. Nothing
/// here is ever exchanged (local only).
class ConsentService {
  const ConsentService(this._isar);

  final Isar _isar;

  /// The single consent row, or `null` before the first decision.
  Future<ConsentRecord?> current() => _isar.consentRecords.where().findFirst();

  /// Whether the user has answered the **current** notice version.
  Future<bool> hasCurrentConsent() async {
    final record = await current();
    return record != null && record.noticeVersion == kConsentNoticeVersion;
  }

  /// Records (or updates) the decision against [noticeVersion].
  Future<ConsentRecord> record({
    required String noticeVersion,
    required bool deviceAuthGranted,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    final existing = await current();
    final record = existing ?? (ConsentRecord()..decidedAt = clock);
    record.noticeVersion = noticeVersion;
    record.deviceAuthGranted = deviceAuthGranted;
    record.updatedAt = clock;
    await _isar.writeTxn(() async {
      record.id = await _isar.consentRecords.put(record);
    });
    return record;
  }

  /// Revokes device auth, keeping the app usable (FR-002).
  Future<ConsentRecord> revoke({DateTime? now}) async {
    final existing = await current();
    if (existing == null) {
      return record(
        noticeVersion: kConsentNoticeVersion,
        deviceAuthGranted: false,
        now: now,
      );
    }
    existing.deviceAuthGranted = false;
    existing.updatedAt = now ?? DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.consentRecords.put(existing);
    });
    return existing;
  }
}
