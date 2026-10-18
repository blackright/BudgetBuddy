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
        'title': value.title,
        'amount': value.amount,
        'currency': value.currency,
        'categoryId': value.categoryId,
        'status': value.status.name,
        'isReimbursable': value.isReimbursable,
        'guiltLevel': value.guiltLevel.name,
        'date': encodeDate(value.date),
        'receiptPath': value.receiptPath,
        'notes': value.notes,
        'paidAt': encodeDate(value.paidAt),
      };

  @override
  Expense fromJson(Map<String, Object?> json) => (Expense(
        profileId: decodeInt(json['profileId']),
        yearMonth: (json['yearMonth'] as String?) ?? '',
        type: decodeEnum(ExpenseType.values, json['type']),
        title: (json['title'] as String?) ?? '',
        amount: decodeInt(json['amount']),
        currency: (json['currency'] as String?) ?? '',
        categoryId:
            (json['categoryId'] as String?) ?? Expense.defaultCategoryId,
        status: decodeEnum(ExpenseStatus.values, json['status']),
        isReimbursable: (json['isReimbursable'] as bool?) ?? false,
        guiltLevel: decodeEnum(GuiltLevel.values, json['guiltLevel']),
        date: decodeDateRequired(json['date']),
        receiptPath: json['receiptPath'] as String?,
        notes: json['notes'] as String?,
        // `budgetId` is resolved from `budgetSyncGuid` by the applier; the codec
        // is pure and cannot look the budget up.
        budgetId: 0,
        paidAt: decodeDate(json['paidAt']),
      ))
        ..syncGuid = decodeGuid(json['syncGuid']);
}
