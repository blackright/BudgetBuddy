import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'monthly_budget.g.dart';

@collection
class MonthlyBudget {
  Id id = Isar.autoIncrement;

  /// Device-independent identity of this row (research R5); indexed, not unique
  /// (uniqueness held by construction and migration step 17).
  @Index()
  String syncGuid = newSyncGuid();

  late String yearMonth; // Format: "YYYY-MM"

  /// Owning personal profile, or `null` when the month belongs to a shared
  /// space. Exactly one of [profileId] / [sharedSpaceId] is set (FR-003,
  /// data-model §3.2).
  ///
  /// The single unique constraint is the full context tuple
  /// `(profileId, sharedSpaceId, yearMonth)`, not two separate per-column
  /// indexes: Isar's composite-unique treats two identical tuples as duplicates
  /// (nulls included), so two zero-context columns would make a second
  /// personal budget for the same month collide on the `sharedSpaceId` index
  /// (both `(null, month)`) and a second shared budget collide on the
  /// `profileId` index. Tuple identity equals context identity instead — every
  /// context sorts, unclaimed and shared alike (FR-003, data-model §3.2).
  @Index(
      unique: true,
      composite: [CompositeIndex('sharedSpaceId'), CompositeIndex('yearMonth')])
  int? profileId;

  /// Owning shared space, or `null` when the month is personal. Exactly one of
  /// [profileId] / [sharedSpaceId] is set (FR-003, data-model §3.2).
  int? sharedSpaceId;

  /// "Our income" override for this month, in whole minor units. `null` means
  /// "follow [SharedSpace.defaultIncome]". The personal pot
  /// ([netSalaryOverride]/[UserProfile.defaultNetSalary]) is separate and never
  /// read for a shared month (FR-009, shared-income contract §2).
  int? sharedIncomeOverride;

  /// The month's opening balance: money in the bank at the start of the month
  /// (FR-006). Nothing is ever carried forward into a new month (FR-007).
  late double baseAvailableAmount;

  /// Distinguishes "the user entered 0" from "the user never entered a
  /// balance" (FR-010). While false, [MonthSummary.moneyInBank] is absent and
  /// the app prompts rather than assuming a figure.
  bool openingBalanceConfirmed = false;

  /// Income for this month only. `null` means "follow
  /// [UserProfile.defaultNetSalary]" (FR-003). Must be null or >= 0.
  double? netSalaryOverride;

  /// Display-only "convert this month to" currency code (FR-011, data-model
  /// §4.2).
  ///
  /// `null` — the default for a freshly provisioned month — means "follow the
  /// active profile's main currency". Setting it overrides the main currency
  /// for this month alone; clearing it restores the fallback. Stored as a code
  /// string because a persisted enum cannot represent "cleared"; unknown values
  /// coerce to the default at read time (data-model §4.4). It is never read by
  /// the conversion engine to decide a stored amount or rate — history stays
  /// deterministic no matter what is chosen here.
  String? currency;

  late DateTime createdAt;

  late DateTime updatedAt;
}
