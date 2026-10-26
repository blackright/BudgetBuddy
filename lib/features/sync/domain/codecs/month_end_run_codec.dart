import '../../../../core/models/month_end_run.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

class MonthEndRunCodec extends SyncCodec<MonthEndRun> {
  const MonthEndRunCodec();
  @override
  String get entityType => 'MonthEndRun';
  @override
  Map<String, Object?> toJson(MonthEndRun r) => {
        'syncGuid': r.syncGuid,
        'sharedSpaceSyncGuid': r.contextGuid,
        'yearMonth': r.yearMonth,
        'destinationMonth': r.destinationMonth,
        'currency': r.currency,
        'reportJson': r.reportJson,
        'fingerprint': r.fingerprint,
        'actor': r.actor,
        'createdAt': encodeDate(r.createdAt),
        'carriedMinor': r.carriedMinor,
        'releasedMinor': r.releasedMinor,
      };
  @override
  MonthEndRun fromJson(Map<String, Object?> j) => MonthEndRun()
    ..syncGuid = decodeGuid(j['syncGuid'])
    ..contextGuid = decodeGuid(j['sharedSpaceSyncGuid'])
    ..yearMonth = j['yearMonth'] as String
    ..destinationMonth = j['destinationMonth'] as String
    ..currency = j['currency'] as String
    ..reportJson = j['reportJson'] as String
    ..fingerprint = j['fingerprint'] as String
    ..actor = j['actor'] as String
    ..createdAt = decodeDateRequired(j['createdAt'])
    ..carriedMinor = decodeInt(j['carriedMinor'])
    ..releasedMinor = decodeInt(j['releasedMinor']);
}
