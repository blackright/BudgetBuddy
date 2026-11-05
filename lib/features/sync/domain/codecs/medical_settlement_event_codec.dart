import '../../../../core/models/medical_settlement_event.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Personal settlement evidence only. No salary receipt, amount or net-pay
/// component is ever serialized; a withholding link stays a GUID reference.
class MedicalSettlementEventCodec extends SyncCodec<MedicalSettlementEvent> {
  const MedicalSettlementEventCodec();
  @override
  String get entityType => 'MedicalSettlementEvent';
  @override
  Map<String, Object?> toJson(MedicalSettlementEvent e) => {
        'version': 2,
        'syncGuid': e.syncGuid,
        'billGuid': e.billGuid,
        'kind': e.kind.name,
        'confirmed': e.confirmed,
        'effectiveDate': encodeDate(e.effectiveDate),
        'recordedAt': encodeDate(e.recordedAt),
        'transactionMonth': e.transactionMonth,
        'documentPaths': e.documentPaths,
        'note': e.note,
        'currency': e.currency,
        'amountMinor': e.amountMinor,
        'basisJson': e.basisJson,
        'expenseSyncGuid': e.expenseGuid,
        'withholdingMatchGuid': e.withholdingMatchGuid,
        'supersedesGuid': e.supersedesGuid,
        'correctedByGuid': e.correctedByGuid,
        'reason': e.reason,
        'operationIdentity': e.operationIdentity,
        'inputFingerprint': e.inputFingerprint,
      };
  @override
  MedicalSettlementEvent fromJson(Map<String, Object?> j) {
    final version = decodeIntOrNull(j['version']) ?? 0;
    final kindName = j['kind'] as String?;
    final kind = MedicalSettlementKind.values
        .where((k) => k.name == kindName)
        .firstOrNull;
    final row = MedicalSettlementEvent()
      ..syncGuid = decodeGuid(j['syncGuid'])
      ..billGuid = decodeGuid(j['billGuid'])
      ..kind = kind ?? MedicalSettlementKind.closure
      ..confirmed = j['confirmed'] == true
      ..effectiveDate = decodeDateRequired(j['effectiveDate'])
      ..recordedAt = decodeDateRequired(j['recordedAt'])
      ..transactionMonth = j['transactionMonth'] as String?
      ..documentPaths =
          (j['documentPaths'] as List?)?.whereType<String>().toList() ?? []
      ..note = (j['note'] as String?) ?? ''
      ..currency = j['currency'] as String?
      ..amountMinor = decodeInt(j['amountMinor'])
      ..basisJson = j['basisJson'] as String?
      ..expenseGuid = j['expenseSyncGuid'] as String?
      ..withholdingMatchGuid = j['withholdingMatchGuid'] as String?
      ..supersedesGuid = j['supersedesGuid'] as String?
      ..correctedByGuid = j['correctedByGuid'] as String?
      ..reason = (j['reason'] as String?) ?? ''
      ..operationIdentity = (j['operationIdentity'] as String?) ?? ''
      ..inputFingerprint = (j['inputFingerprint'] as String?) ?? '';
    final monetary = {
      MedicalSettlementKind.insurerProviderSettlement,
      MedicalSettlementKind.userProviderPayment,
      MedicalSettlementKind.insuranceRefund,
      MedicalSettlementKind.salaryDeduction,
      MedicalSettlementKind.providerRefund,
    }.contains(row.kind);
    final monthValid = row.transactionMonth == null ||
        RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$')
            .hasMatch(row.transactionMonth!);
    if (!{1, 2}.contains(version) ||
        kind == null ||
        row.amountMinor < 0 ||
        !monthValid ||
        row.operationIdentity.isEmpty ||
        row.operationIdentity.length > 256 ||
        row.inputFingerprint.isEmpty ||
        row.reason.length > 240 ||
        row.effectiveDate.isAfter(row.recordedAt) ||
        (monetary && row.currency == null) ||
        (monetary && row.confirmed && row.amountMinor <= 0)) {
      throw const FormatException('Invalid Medical settlement evidence.');
    }
    return row;
  }
}
