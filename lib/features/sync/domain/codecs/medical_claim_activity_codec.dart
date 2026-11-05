import '../../../../core/models/medical_approval.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Shared-safe Medical claim/management activity.
///
/// Private salary or payslip evidence never travels here; it stays on the
/// owner-scoped settlement/reimbursement rows.
class MedicalClaimActivityCodec extends SyncCodec<MedicalClaimActivity> {
  const MedicalClaimActivityCodec();

  @override
  String get entityType => 'MedicalClaimActivity';

  @override
  Map<String, Object?> toJson(MedicalClaimActivity a) => {
        'version': 1,
        'syncGuid': a.syncGuid,
        'billGuid': a.billGuid,
        'profileId': a.profileId,
        'yearMonth': a.yearMonth,
        'kind': a.kind,
        'submittedAt': encodeDate(a.submittedAt),
        'approvalGuid': a.approvalGuid,
        'reason': a.reason,
        'beforeJson': a.beforeJson,
        'afterJson': a.afterJson,
        'beforeMinor': a.beforeMinor,
        'afterMinor': a.afterMinor,
        'currency': a.currency,
        'recordedAt': encodeDate(a.recordedAt),
        'transactionMonth': a.transactionMonth,
        'documentPaths': a.documentPaths,
        'reference': a.reference,
        'correctedByGuid': a.correctedByGuid,
        'operationIdentity': a.operationIdentity,
        'inputFingerprint': a.inputFingerprint,
      };

  @override
  MedicalClaimActivity fromJson(Map<String, Object?> j) {
    final row = MedicalClaimActivity()
      ..syncGuid = decodeGuid(j['syncGuid'])
      ..billGuid = decodeGuid(j['billGuid'])
      ..profileId = decodeInt(j['profileId'])
      ..yearMonth = (j['yearMonth'] as String?) ?? ''
      ..kind = (j['kind'] as String?) ?? ''
      ..submittedAt = decodeDate(j['submittedAt'])
      ..approvalGuid = j['approvalGuid'] as String?
      ..reason = (j['reason'] as String?) ?? ''
      ..beforeJson = j['beforeJson'] as String?
      ..afterJson = j['afterJson'] as String?
      ..beforeMinor = decodeInt(j['beforeMinor'])
      ..afterMinor = decodeInt(j['afterMinor'])
      ..currency = (j['currency'] as String?) ?? ''
      ..recordedAt = decodeDateRequired(j['recordedAt'])
      ..actorId = 0
      ..transactionMonth = j['transactionMonth'] as String?
      ..documentPaths =
          (j['documentPaths'] as List?)?.whereType<String>().toList() ?? []
      ..reference = j['reference'] as String?
      ..correctedByGuid = j['correctedByGuid'] as String?
      ..operationIdentity = (j['operationIdentity'] as String?) ?? ''
      ..inputFingerprint = (j['inputFingerprint'] as String?) ?? '';
    final monthValid = row.transactionMonth == null ||
        RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$')
            .hasMatch(row.transactionMonth!);
    if (j['version'] != 1 ||
        row.billGuid.isEmpty ||
        row.kind.isEmpty ||
        row.kind.length > 64 ||
        !monthValid ||
        row.operationIdentity.isEmpty ||
        row.operationIdentity.length > 512 ||
        row.inputFingerprint.isEmpty ||
        row.reason.length > 240) {
      throw const FormatException('Invalid Medical claim activity.');
    }
    return row;
  }
}
