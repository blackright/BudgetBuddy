import '../../../../core/models/medical_approval.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/models/fx_revision.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Approval only: never includes salary groups, personal balances or cash.
class MedicalApprovalCodec extends SyncCodec<MedicalApproval> {
  const MedicalApprovalCodec();
  @override
  String get entityType => 'MedicalApproval';
  @override
  Map<String, Object?> toJson(MedicalApproval a) => {
        // Legacy callers still write only approvedMinor; emit v2 for them so
        // old peers and the strict v3 invariant remain compatible.
        'version': a.approvedBillMinor > 0 ? 3 : 2,
        'syncGuid': a.syncGuid,
        'billGuid': a.billGuid,
        'yearMonth': a.yearMonth,
        'approvedMinor': a.approvedMinor,
        'approvedBillMinor': a.approvedBillMinor,
        'approvedShareMinor': a.approvedShareMinor,
        'approvedInsuranceMinor': a.approvedInsuranceMinor,
        'expectedBillMinor': a.expectedBillMinor,
        'expectedShareMinor': a.expectedShareMinor,
        'expectedInsuranceMinor': a.expectedInsuranceMinor,
        'appealGuid': a.appealGuid,
        'currency': a.currency,
        'decisionDate': encodeDate(a.decisionDate),
        'recordedAt': encodeDate(a.recordedAt),
        'revision': a.revision,
        'previousGuid': a.previousGuid,
        'operationIdentity': a.operationIdentity,
        'inputFingerprint': a.inputFingerprint,
      };
  @override
  MedicalApproval fromJson(Map<String, Object?> j) {
    final version = decodeIntOrNull(j['version']) ?? 0;
    final legacyApprovedMinor = decodeInt(j['approvedMinor']);
    final row = MedicalApproval()
      ..syncGuid = decodeGuid(j['syncGuid'])
      ..billGuid = decodeGuid(j['billGuid'])
      ..yearMonth = (j['yearMonth'] as String?) ?? ''
      ..approvedMinor = legacyApprovedMinor
      ..currency = (j['currency'] as String?) ?? ''
      ..decisionDate = decodeDateRequired(j['decisionDate'])
      ..recordedAt = decodeDateRequired(j['recordedAt'])
      ..revision = decodeInt(j['revision'])
      ..previousGuid = (j['previousGuid'] as String?)
      ..operationIdentity = (j['operationIdentity'] as String?) ?? ''
      ..inputFingerprint = (j['inputFingerprint'] as String?) ?? ''
      ..actorId = 0
      ..approvedBillMinor = decodeIntOrNull(j['approvedBillMinor']) ?? 0
      ..approvedShareMinor = decodeIntOrNull(j['approvedShareMinor']) ?? 0
      ..approvedInsuranceMinor =
          decodeIntOrNull(j['approvedInsuranceMinor']) ?? legacyApprovedMinor
      ..expectedBillMinor = decodeIntOrNull(j['expectedBillMinor']) ?? 0
      ..expectedShareMinor = decodeIntOrNull(j['expectedShareMinor']) ?? 0
      ..expectedInsuranceMinor =
          decodeIntOrNull(j['expectedInsuranceMinor']) ?? 0
      ..appealGuid = j['appealGuid'] as String?;
    checkedFxMinor(row.approvedMinor);
    final breakdownInvalid = version >= 3 &&
        (row.approvedBillMinor <= 0 ||
            row.approvedShareMinor < 0 ||
            row.approvedInsuranceMinor <= 0 ||
            row.approvedShareMinor + row.approvedInsuranceMinor !=
                row.approvedBillMinor);
    if (!{2, 3}.contains(version) ||
        row.approvedMinor <= 0 ||
        breakdownInvalid ||
        row.revision < 1 ||
        CurrencyCode.tryParse(row.currency) == null ||
        row.decisionDate.isAfter(row.recordedAt) ||
        row.operationIdentity.isEmpty ||
        row.operationIdentity.length > 512 ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(row.inputFingerprint) ||
        !RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$').hasMatch(row.yearMonth)) {
      throw const FormatException('Invalid Medical approval.');
    }
    return row;
  }
}
