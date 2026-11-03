import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'medical_withholding_match.g.dart';

extension MedicalWithholdingMatchCollection on Isar {
  IsarCollection<MedicalWithholdingMatch> get medicalWithholdingMatches =>
      medicalWithholdingMatchs;
}

/// Immutable provenance linking an actual net salary receipt (IncomeReceiptGroup)
/// to a Medical bill whose patient share was withheld from that salary.
///
/// This is a classification, not a cash event: no money is created, deducted or
/// refunded. It prevents the same withheld share from being counted twice.
@collection
class MedicalWithholdingMatch {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String guid = newSyncGuid();

  /// Owning personal profile.
  @Index()
  int? profileId;

  /// The Medical bill's syncGuid.
  @Index()
  late String billGuid;

  /// The IncomeReceiptGroup.guid of the salary receipt.
  @Index()
  late String salaryReceiptGroupGuid;

  /// The confirmed withheld amount in whole minor units.
  int withheldMinor = 0;

  late String currency;

  /// Affected months (bill month, receipt month, destination month).
  List<String> affectedMonths = [];

  /// Whether this match has been reversed.
  bool reversed = false;

  /// If reversed, the guid of the reversal record.
  String? reversalGuid;

  /// Reversal reason.
  String reversalReason = '';

  late DateTime createdAt;
  late DateTime updatedAt;
}
