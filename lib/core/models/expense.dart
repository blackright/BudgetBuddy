import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';
import 'currency_code.dart';
import 'expense_evidence_chunk.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  /// Device-independent identity of this row (research R5); indexed, not unique
  /// (uniqueness held by construction and migration step 17).
  @Index()
  String syncGuid = newSyncGuid();

  static const String defaultCategoryId = 'general';

  @Index()
  late int profileId;

  /// Owning shared space, or `null` for a personal expense. Exactly one of
  /// [profileId] / [sharedSpaceId] is set (FR-003, data-model §3.3).
  @Index()
  int? sharedSpaceId;

  @Index()
  late String yearMonth;

  @enumerated
  ExpenseType type = ExpenseType.standard;

  String title;

  /// Amount in **whole minor units** of [currency] (HUF: forint, others: the
  /// cent-scale unit) — the single money representation (FR-015, data-model
  /// §4.3). A legacy `double` value is converted by migration step 9.
  int amount;

  /// Persisted currency code. Kept as the raw string (not the enum) so a legacy
  /// value the app no longer understands survives verbatim (FR-021, §4.4);
  /// resolve it through [currencyCode].
  String currency;
  String categoryId;
  @enumerated
  ExpenseStatus status;
  bool isReimbursable;
  @enumerated
  GuiltLevel guiltLevel;
  DateTime date;
  String? receiptPath;
  String? notes;

  /// Immutable conversion revisions; null means legacy FX was not recorded.
  String? fxHistoryJson;

  /// Optional Phase 10 metadata; unknown old values are never inferred.
  String? merchantSyncGuid;
  String? merchantName;
  List<String> tags = [];
  String? paymentMethod;

  /// Versioned portable document manifest and explicit payment declaration.
  /// Null preserves legacy records without inventing evidence.
  String? paymentEvidenceJson;
  @Index()
  String? purchaseSyncGuid;
  String? purchaseEvidenceOwnerGuid;

  /// Validated again at the write boundary; never serialized as local paths.
  @ignore
  List<ExpenseEvidenceChunk> pendingEvidenceChunks = [];
  @ignore
  Map<String, String> pendingEvidenceFiles = {};
  int budgetId;

  /// The Budget Profile or Direct Expense Profile this expense belongs to
  /// (FR-005). `null` means it belongs to the Main Profile directly.
  ///
  /// Kept separate from [budgetId] (the owning month) so an expense can be
  /// counted against one profile while still living in its month.
  @Index()
  int? budgetProfileId;

  /// Disambiguates independent collection IDs. Null with a non-null ID is a
  /// legacy assignment that still needs review; it must never be guessed.
  String? financialProfileType;

  /// Portable target identity. Kept even when a remote profile is not present
  /// locally, so an unresolved reference cannot silently become Main spending.
  String? financialProfileSyncGuid;

  /// When the money actually left the account. Set on Planned → Paid,
  /// cleared on Paid → Planned.
  DateTime? paidAt;

  Expense({
    this.id = Isar.autoIncrement,
    required this.profileId,
    this.sharedSpaceId,
    required this.yearMonth,
    this.type = ExpenseType.standard,
    required this.title,
    required this.amount,
    required this.currency,
    required this.categoryId,
    this.status = ExpenseStatus.paid,
    this.isReimbursable = false,
    this.guiltLevel = GuiltLevel.essential,
    required this.date,
    this.receiptPath,
    this.notes,
    this.fxHistoryJson,
    this.merchantSyncGuid,
    this.merchantName,
    this.paymentMethod,
    this.paymentEvidenceJson,
    this.purchaseSyncGuid,
    this.purchaseEvidenceOwnerGuid,
    required this.budgetId,
    this.budgetProfileId,
    this.financialProfileType,
    this.financialProfileSyncGuid,
    this.paidAt,
  });

  /// The parsed currency, or `null` for a legacy/unsupported code that must be
  /// preserved and excluded from converted totals (FR-021, data-model §4.4).
  @ignore
  CurrencyCode? get currencyCode => CurrencyCode.tryParse(currency);

  /// An editor must not mutate the live row before its transaction succeeds.
  Expense copyForEditing() => Expense(
      id: id,
      profileId: profileId,
      sharedSpaceId: sharedSpaceId,
      yearMonth: yearMonth,
      type: type,
      title: title,
      amount: amount,
      currency: currency,
      categoryId: categoryId,
      status: status,
      isReimbursable: isReimbursable,
      guiltLevel: guiltLevel,
      date: date,
      receiptPath: receiptPath,
      notes: notes,
      fxHistoryJson: fxHistoryJson,
      merchantSyncGuid: merchantSyncGuid,
      merchantName: merchantName,
      paymentMethod: paymentMethod,
      paymentEvidenceJson: paymentEvidenceJson,
      purchaseSyncGuid: purchaseSyncGuid,
      purchaseEvidenceOwnerGuid: purchaseEvidenceOwnerGuid,
      budgetId: budgetId,
      budgetProfileId: budgetProfileId,
      financialProfileType: financialProfileType,
      financialProfileSyncGuid: financialProfileSyncGuid,
      paidAt: paidAt)
    ..syncGuid = syncGuid
    ..tags = List.of(tags);
}

abstract final class FinancialProfileType {
  static const budget = 'budget';
  static const direct = 'direct';
}

enum ExpenseStatus {
  planned,
  paid,
  cancelled,
  reimbursed,
  partiallyReimbursed,
}

enum ExpenseType {
  standard,
  medical,
}

enum GuiltLevel {
  essential,
  guiltFree,
  oops,
}
