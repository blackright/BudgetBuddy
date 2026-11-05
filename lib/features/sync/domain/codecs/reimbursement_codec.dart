import '../../../../features/expenses/models/reimbursement.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [Reimbursement] (data-model §2.6, FR-010).
class ReimbursementCodec extends SyncCodec<Reimbursement> {
  const ReimbursementCodec();

  @override
  String get entityType => 'Reimbursement';

  @override
  Map<String, Object?> toJson(Reimbursement value) => {
        'syncGuid': value.syncGuid,
        'profileId': value.profileId,
        'originYearMonth': value.originYearMonth,
        'creditYearMonth': value.creditYearMonth,
        'source': value.source.name,
        'orphaned': value.orphaned,
        'amount': value.amount,
        'fxHistoryJson': value.fxHistoryJson,
        if (value.medicalReceiptJson != null)
          'medicalReceiptJson': value.medicalReceiptJson,
        'currency': value.currency,
        'date': encodeDate(value.date),
        'note': value.note,
      };

  @override
  Reimbursement fromJson(Map<String, Object?> json) => Reimbursement(
        profileId: decodeInt(json['profileId']),
        originYearMonth: (json['originYearMonth'] as String?) ?? '',
        orphaned: (json['orphaned'] as bool?) ?? false,
        amount: decodeInt(json['amount']),
        fxHistoryJson: json['fxHistoryJson'] as String?,
        medicalReceiptJson: json['medicalReceiptJson'] as String?,
        currency: (json['currency'] as String?) ?? '',
        date: decodeDateRequired(json['date']),
        note: json['note'] as String?,
      )
        ..syncGuid = decodeGuid(json['syncGuid'])
        ..creditYearMonth = json['creditYearMonth'] as String?
        ..source = decodeEnum(ReimbursementSource.values, json['source']);
}
