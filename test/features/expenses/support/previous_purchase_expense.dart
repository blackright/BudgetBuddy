import 'package:isar/isar.dart';

import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';

import 'package:budget_buddy/core/models/expense.dart'
    show ExpenseStatus, ExpenseType, GuiltLevel;
part 'previous_purchase_expense.g.dart';

@collection
@Name('Expense')
class PreviousPurchaseExpense {
  Id id = Isar.autoIncrement;

  /// Device-independent identity of this row (research R5); indexed, not unique
  /// (uniqueness held by construction and migration step 17).
  @Index()
  String syncGuid = newSyncGuid();

  static const String defaultCategoryId = 'general';

  @Index()
  late int profileId;

  /// Owning shared space, or `null` for a personal expense. Exactly one of
  /// [profileId] / [sharedSpaceId] is set (FR-003, data-model Â§3.3).
  @Index()
  int? sharedSpaceId;

  @Index()
  late String yearMonth;

  @enumerated
  ExpenseType type = ExpenseType.standard;

  String title;

  /// Amount in **whole minor units** of [currency] (HUF: forint, others: the
  /// cent-scale unit) â€” the single money representation (FR-015, data-model
  /// Â§4.3). A legacy `double` value is converted by migration step 9.
  int amount;

  /// Persisted currency code. Kept as the raw string (not the enum) so a legacy
  /// value the app no longer understands survives verbatim (FR-021, Â§4.4);
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

  /// Optional Phase 10 metadata; unknown old values are never inferred.
  String? merchantSyncGuid;
  String? merchantName;
  List<String> tags = [];
  String? paymentMethod;

  /// Versioned portable document manifest and explicit payment declaration.
  /// Null preserves legacy records without inventing evidence.
  String? paymentEvidenceJson;

  /// Validated again at the write boundary; never serialized as local paths.
  @ignore
  List<ExpenseEvidenceChunk> pendingEvidenceChunks = [];
  @ignore
  Map<String, String> pendingEvidenceFiles = {};
  int budgetId;

  /// The Budget Profile or Direct PreviousPurchaseExpense Profile this expense belongs to
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

  /// When the money actually left the account. Set on Planned â†’ Paid,
  /// cleared on Paid â†’ Planned.
  DateTime? paidAt;

  PreviousPurchaseExpense({
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
    this.merchantSyncGuid,
    this.merchantName,
    this.paymentMethod,
    this.paymentEvidenceJson,
    required this.budgetId,
    this.budgetProfileId,
    this.financialProfileType,
    this.financialProfileSyncGuid,
    this.paidAt,
  });

  /// The parsed currency, or `null` for a legacy/unsupported code that must be
  /// preserved and excluded from converted totals (FR-021, data-model Â§4.4).
  @ignore
  CurrencyCode? get currencyCode => CurrencyCode.tryParse(currency);
}
