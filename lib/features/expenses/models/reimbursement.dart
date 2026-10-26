import 'package:isar/isar.dart';

import '../../../core/models/currency_code.dart';
import '../../sync/domain/sync_guid.dart';

part 'reimbursement.g.dart';

@collection
class Reimbursement {
  Id id = Isar.autoIncrement;

  /// Device-independent identity of this row (research R5); indexed, not unique
  /// (uniqueness held by construction and migration step 17).
  @Index()
  String syncGuid = newSyncGuid();

  @Index()
  int profileId;

  /// Owning shared space, or `null` for a personal reimbursement. Exactly one of
  /// [profileId] / [sharedSpaceId] is set (FR-003, data-model §3.4). Credit
  /// always goes to the row's `originYearMonth` in this context.
  @Index()
  int? sharedSpaceId;

  /// Target expense or medical bill's linked expense. `null` means the target
  /// was deleted; the row is retained, flagged and surfaced to the user
  /// (FR-035).
  @Index()
  int? expenseId;

  /// The month the returned money *belongs to* — the target expense's owning
  /// month, never the month it was recorded in (FR-032).
  @Index()
  String originYearMonth;

  /// Set when the target expense is deleted (FR-035).
  @Index()
  bool orphaned;

  /// Amount in whole minor units of [currency] (FR-015, data-model §4.3).
  int amount;

  /// Persisted currency code; resolve via [currencyCode] (FR-021, §4.4).
  String currency;

  /// When the user recorded the reimbursement. Display and audit only; never
  /// used for attribution.
  DateTime date;

  String? note;
  String? fxHistoryJson;

  Reimbursement({
    this.id = Isar.autoIncrement,
    required this.profileId,
    this.sharedSpaceId,
    this.expenseId,
    required this.originYearMonth,
    this.orphaned = false,
    required this.amount,
    required this.currency,
    required this.date,
    this.note,
    this.fxHistoryJson,
  });

  /// The parsed currency, or `null` for a legacy/unsupported code (FR-021).
  @ignore
  CurrencyCode? get currencyCode => CurrencyCode.tryParse(currency);
}
