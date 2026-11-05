import '../../../../core/models/medical_appeal.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// One repeatable insurance appeal. Never carries salary or payslip data.
class MedicalAppealCodec extends SyncCodec<MedicalAppeal> {
  const MedicalAppealCodec();

  @override
  String get entityType => 'MedicalAppeal';

  @override
  Map<String, Object?> toJson(MedicalAppeal a) => {
        'version': 1,
        'syncGuid': a.syncGuid,
        'billGuid': a.billGuid,
        'profileId': a.profileId,
        'submittedAt': encodeDate(a.submittedAt),
        'reference': a.reference,
        'expectedResponseAt': encodeDate(a.expectedResponseAt),
        'notes': a.notes,
        'documentPaths': a.documentPaths,
        'outcome': a.outcome.name,
        'decidedAt': encodeDate(a.decidedAt),
        'recordedAt': encodeDate(a.recordedAt),
        'operationIdentity': a.operationIdentity,
      };

  @override
  MedicalAppeal fromJson(Map<String, Object?> j) {
    final submittedAt = decodeDate(j['submittedAt']);
    final decidedAt = decodeDate(j['decidedAt']);
    final outcome = decodeEnum(MedicalAppealOutcome.values, j['outcome']);
    final row = MedicalAppeal()
      ..syncGuid = decodeGuid(j['syncGuid'])
      ..billGuid = decodeGuid(j['billGuid'])
      ..profileId = decodeIntOrNull(j['profileId'])
      ..submittedAt =
          submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
      ..reference = j['reference'] as String?
      ..expectedResponseAt = decodeDate(j['expectedResponseAt'])
      ..notes = (j['notes'] as String?) ?? ''
      ..documentPaths =
          (j['documentPaths'] as List?)?.whereType<String>().toList() ?? []
      ..outcome = outcome
      ..decidedAt = decidedAt
      ..recordedAt = decodeDateRequired(j['recordedAt'])
      ..actorId = 0
      ..operationIdentity = (j['operationIdentity'] as String?) ?? '';
    final decidedValid = outcome == MedicalAppealOutcome.pending
        ? decidedAt == null
        : decidedAt != null;
    if (j['version'] != 1 ||
        row.billGuid.isEmpty ||
        submittedAt == null ||
        submittedAt.isAfter(row.recordedAt) ||
        !decidedValid ||
        (decidedAt != null && decidedAt.isBefore(submittedAt)) ||
        row.notes.length > 500 ||
        row.operationIdentity.isEmpty ||
        row.operationIdentity.length > 512) {
      throw const FormatException('Invalid Medical appeal.');
    }
    return row;
  }
}
