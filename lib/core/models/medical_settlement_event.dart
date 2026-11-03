import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'medical_settlement_event.g.dart';

extension MedicalSettlementEventCollection on Isar {
  IsarCollection<MedicalSettlementEvent> get medicalSettlements =>
      medicalSettlementEvents;
}

/// What a settlement event records. Only the first three are monetary facts;
/// [correction] and [reversal] are reviewed links back to an earlier event.
enum MedicalSettlementKind {
  /// The insurer paid the provider. [MedicalSettlementEvent.confirmed] is false
  /// while the payment is only expected, true once it is confirmed.
  insurerProviderSettlement,

  /// The patient share was paid separately or withheld from net salary.
  shareSettlement,

  /// Explicit, metadata-only completion of a direct-insurer bill.
  closure,

  /// Reviewed correction that supersedes an earlier event.
  correction,

  /// Reviewed reversal that invalidates an earlier event without deleting it.
  reversal,

  /// The user paid the provider in full.
  userProviderPayment,

  /// The insurer refunded the user.
  insuranceRefund,

  /// The user's share was taken from salary.
  salaryDeduction,

  /// The provider returned money to the user.
  providerRefund,
}

/// Immutable personal evidence for a direct-insurer settlement command.
///
/// These rows never move cash by themselves. The linked expense remains the one
/// booking for the patient share; a salary withholding is referenced by GUID and
/// never copies salary amounts into new income. Legacy rows without evidence
/// stay Needs review and are never backfilled.
@collection
class MedicalSettlementEvent {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String syncGuid = newSyncGuid();

  /// Owning personal profile. Settlement evidence is never shared.
  @Index()
  int? profileId;

  /// The Medical bill's syncGuid.
  @Index()
  late String billGuid;

  @enumerated
  @Index()
  MedicalSettlementKind kind = MedicalSettlementKind.insurerProviderSettlement;

  /// Confirmed fact vs. an explicitly pending provider payment.
  bool confirmed = true;

  late DateTime effectiveDate;

  late DateTime recordedAt;

  /// Actual `YYYY-MM` month whose Free-to-Use money changes. Null on legacy
  /// evidence that predates actual-month posting.
  String? transactionMonth;

  /// Evidence attached to this settlement event.
  List<String> documentPaths = [];

  /// Optional note about the event.
  String note = '';

  /// Settlement currency code, or `null` when the event carries no amount.
  String? currency;

  /// Exact minor amount when applicable; `0` for metadata-only events.
  int amountMinor = 0;

  /// Bill basis at the time of the event. Never reconstructed from today's bill.
  String? basisJson;

  /// Local link to the already-booked expense, when this event relies on it.
  int? expenseId;

  /// Device-independent link to the same expense for retained evidence.
  String? expenseGuid;

  /// The MedicalWithholdingMatch this share settlement points at, if any.
  String? withholdingMatchGuid;

  /// Earlier event this correction/reversal supersedes.
  String? supersedesGuid;

  /// Later correction/reversal that supersedes this row.
  String? correctedByGuid;

  String reason = '';

  @Index(unique: true)
  late String operationIdentity;

  late String inputFingerprint;

  int actorId = 0;
}
