import '../../../../core/models/expense.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [Expense] (data-model §2.6, FR-010).
///
/// [Expense.amount] is a whole minor unit `int`, so it round-trips byte-identical
/// (the money-field guarantee).
class ExpenseCodec extends SyncCodec<Expense> {
  const ExpenseCodec();

  @override
  String get entityType => 'Expense';

  @override
  Map<String, Object?> toJson(Expense value) => {
        'syncGuid': value.syncGuid,
        'profileId': value.profileId,
        'yearMonth': value.yearMonth,
        'type': value.type.name,
        'financialProfileType': value.financialProfileType,
        'financialProfileSyncGuid': value.financialProfileSyncGuid,
        'title': value.title,
        'amount': value.amount,
        'fxHistoryJson': value.fxHistoryJson,
        'currency': value.currency,
        'categoryId': value.categoryId,
        'status': value.status.name,
        'isReimbursable': value.isReimbursable,
        'guiltLevel': value.guiltLevel.name,
        'date': encodeDate(value.date),
        'receiptPath':
            value.type == ExpenseType.medical ? value.receiptPath : null,
        'notes': value.notes,
        'merchantSyncGuid': value.merchantSyncGuid,
        'merchantName': value.merchantName,
        'tags': value.tags,
        'paymentMethod': value.paymentMethod,
        'paymentEvidenceJson': value.paymentEvidenceJson,
        'purchaseSyncGuid': value.purchaseSyncGuid,
        'purchaseEvidenceOwnerGuid': value.purchaseEvidenceOwnerGuid,
        'paidAt': encodeDate(value.paidAt),
      };

  @override
  Expense fromJson(Map<String, Object?> json) => (Expense(
        profileId: decodeInt(json['profileId']),
        yearMonth: (json['yearMonth'] as String?) ?? '',
        type: decodeEnum(ExpenseType.values, json['type']),
        title: (json['title'] as String?) ?? '',
        amount: decodeInt(json['amount']),
        fxHistoryJson: json['fxHistoryJson'] as String?,
        currency: (json['currency'] as String?) ?? '',
        categoryId:
            (json['categoryId'] as String?) ?? Expense.defaultCategoryId,
        status: decodeEnum(ExpenseStatus.values, json['status']),
        isReimbursable: (json['isReimbursable'] as bool?) ?? false,
        guiltLevel: decodeEnum(GuiltLevel.values, json['guiltLevel']),
        date: decodeDateRequired(json['date']),
        receiptPath: json['receiptPath'] as String?,
        notes: json['notes'] as String?,
        merchantSyncGuid: decodeGuidOrNull(json['merchantSyncGuid']),
        merchantName: json['merchantName'] as String?,
        paymentMethod: json['paymentMethod'] as String?,
        paymentEvidenceJson: json['paymentEvidenceJson'] as String?,
        purchaseSyncGuid: decodeGuidOrNull(json['purchaseSyncGuid']),
        purchaseEvidenceOwnerGuid:
            decodeGuidOrNull(json['purchaseEvidenceOwnerGuid']),
        // `budgetId` is resolved from `budgetSyncGuid` by the applier; the codec
        // is pure and cannot look the budget up.
        budgetId: 0,
        financialProfileType: json['financialProfileType'] as String?,
        financialProfileSyncGuid:
            decodeGuidOrNull(json['financialProfileSyncGuid']),
        paidAt: decodeDate(json['paidAt']),
      ))
        ..tags = (json['tags'] as List? ?? []).cast<String>()
        ..syncGuid = decodeGuid(json['syncGuid']);
}
