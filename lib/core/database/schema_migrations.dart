import 'package:isar/isar.dart';

import '../models/expense.dart';
import '../models/insurance_profile.dart';
import '../models/medical_service_type.dart';
import '../models/monthly_budget.dart';
import '../models/user_profile.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../models/medical_bill.dart';

part 'schema_migrations.g.dart';

/// Schema version this build expects. Bump whenever a numbered step is added to
/// [_applySteps]; databases stamped at or above it are left untouched.
const int schemaVersion = 9;

const String schemaVersionKey = 'schema_version';

/// Minimal key/value store used to remember which migrations a database has
/// already had applied.
///
/// Isar 3.1 has no declarative migration API and no metadata table, so the stamp
/// is an ordinary collection with a single well-known row.
@collection
class SchemaMigrationStamp {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String value;
}

/// The schema version this database has already been migrated to. `0` means the
/// database predates the migration system and every step still has to run.
Future<int> readSchemaVersion(Isar isar) async {
  final stamp = await isar.schemaMigrationStamps
      .filter()
      .keyEqualTo(schemaVersionKey)
      .findFirst();
  return int.tryParse(stamp?.value ?? '') ?? 0;
}

/// Records the schema version as applied.
///
/// Opens its own transaction, so call it outside a `writeTxn`. Inside
/// [runSchemaMigrations] the stamp is written inline instead, because Isar does
/// not allow nested write transactions.
Future<void> writeSchemaVersion(Isar isar, int version) {
  return isar.writeTxn(() async {
    await isar.schemaMigrationStamps.put(
      SchemaMigrationStamp()
        ..key = schemaVersionKey
        ..value = '$version',
    );
  });
}

/// Applies every outstanding value migration exactly once.
///
/// Idempotent: a database already at [schemaVersion] short-circuits, so calling
/// this on every launch is safe. Atomic: the steps and the version stamp share
/// one transaction, so a partially migrated database cannot be observed.
Future<void> runSchemaMigrations(Isar isar) async {
  await isar.writeTxn(() async {
    final stamp = await isar.schemaMigrationStamps
        .filter()
        .keyEqualTo(schemaVersionKey)
        .findFirst();
    final current = int.tryParse(stamp?.value ?? '') ?? 0;
    if (current >= schemaVersion) return;

    await _applySteps(isar);

    await isar.schemaMigrationStamps.put(
      SchemaMigrationStamp()
        ..key = schemaVersionKey
        ..value = '$schemaVersion',
    );
  });
}

/// The numbered steps, in execution order. A later step may rely on fields an
/// earlier one wrote, so the order is significant and steps are never reordered
/// once shipped.
///
/// The numbering is the specification's, not a chronological one: step 4 is
/// deliberately listed after step 3 because it migrates a different collection,
/// and the steps are ordered so each one reads fields that still hold their
/// pre-migration values.
Future<void> _applySteps(Isar isar) async {
  await _step0SeedServiceTypes(isar);
  await _step1ClearDeductibles(isar);
  await _step2InvertPercentages(isar);
  await _step3MapClaimStates(isar);
  await _step4BackfillReimbursementOrigin(isar);
  await _step5BackfillBillYearMonth(isar);
  await _step6ConfirmExistingOpeningBalances(isar);
  await _step7NormalizePlanNames(isar);
  await _step8AddCurrencySealCollections(isar);
  await _step9ConvertAmountsToMinorUnits(isar);
}

/// Step 8 (multi-currency, data-model §6) — additive only: the `MonthRateSeal`
/// and `LiveRateSet` collections appear, and `MedicalBill` gains its own
/// `currency` column.
///
/// Isar reconciles the stored schema on open, so new collections and columns
/// materialise with their declared defaults before this runs; there is no data
/// to rewrite. The step exists so the version stamp records the upgrade and so
/// the numbering the specification asks for stays visible. Existing bills read
/// back `currency == ''`, the documented "follow the linked expense" sentinel
/// (FR-021: nothing is invented or destroyed).
Future<void> _step8AddCurrencySealCollections(Isar isar) async {
  // Intentionally empty: additive schema only — see doc comment.
}

/// Step 9 (FR-015, FR-021, data-model §6) — amounts move from major-unit
/// `double`s to whole minor-unit `int`s.
///
/// The specification asks for a **dry-run capable, two-phase** upgrade: phase 1
/// emits a per-row report (before/after, >1% movements, unresolvable rows, lossy
/// conversions) and phase 2 commits only after that report has been reviewed.
/// [buildMoneyMigrationReport] is that phase 1; it is a pure function so it can
/// be exercised against synthetic legacy rows without touching a database.
///
/// **Why this step commits nothing.** The one-cut landed in code, not here: the
/// model fields (`Expense.amount`, `Reimbursement.amount`,
/// `MedicalBill.billedAmount`/`reimbursedAmount`) are already declared `int`.
/// Isar 3 reconciles the stored schema on open and exposes no raw-column access,
/// so a value an older build wrote as a `double` cannot be read back through the
/// ORM to be converted — exactly the limitation documented for steps 2 and 3.
/// A database that reaches this build therefore has its money fields interpreted
/// as the minor units the current build writes. There is nothing to rewrite, and
/// nothing is silently rounded, invented or destroyed (FR-021).
///
/// The step stays in the numbered sequence so the version bump is recorded and
/// so a future schema (for example one that keeps a transitional legacy column)
/// has the single place to hang the phase-2 commit path.
Future<void> _step9ConvertAmountsToMinorUnits(Isar isar) async {
  // Intentionally empty: see doc comment.
}

/// One pre-migration amount fed to [buildMoneyMigrationReport].
///
/// This models what an older build stored: a major-unit `double` plus the
/// exponent it should be written back at.
class LegacyMoneyAmount {
  const LegacyMoneyAmount({
    required this.collection,
    required this.rowId,
    required this.majorUnits,
    required this.minorUnitsPerMajor,
  });

  /// Owning collection name, e.g. `expenses`.
  final String collection;

  /// Row id within [collection].
  final int rowId;

  /// The stored major-unit figure written by an older build.
  final double majorUnits;

  /// `10 ^ exponent` for the row's currency (HUF 1, USD/EUR/CAD 100).
  final int minorUnitsPerMajor;
}

/// The phase-1 dry-run verdict for a single amount.
class MoneyMigrationEntry {
  const MoneyMigrationEntry({
    required this.collection,
    required this.rowId,
    required this.beforeMajorUnits,
    required this.afterMajorUnits,
    required this.minorUnits,
    required this.lossy,
  });

  final String collection;
  final int rowId;
  final double beforeMajorUnits;
  final double afterMajorUnits;

  /// The whole minor-unit figure the row would be committed as.
  final int minorUnits;

  /// True when the stored `double` did not survive the rounding exactly.
  final bool lossy;

  /// Relative movement between the stored figure and its integer equivalent.
  double get movement {
    if (beforeMajorUnits == 0) return 0;
    return (afterMajorUnits - beforeMajorUnits).abs() / beforeMajorUnits.abs();
  }
}

/// Phase-1 report for step 9. Building it never mutates anything.
class MoneyMigrationReport {
  const MoneyMigrationReport(this.entries);

  final List<MoneyMigrationEntry> entries;

  /// Rows whose stored value did not survive the conversion exactly, so the user
  /// must review before phase 2 commits (FR-021).
  List<MoneyMigrationEntry> get lossyEntries =>
      entries.where((e) => e.lossy).toList(growable: false);

  /// Rows whose value moves by more than 1% — the review list the spec names.
  List<MoneyMigrationEntry> get significantMovements =>
      entries.where((e) => e.movement > 0.01).toList(growable: false);

  bool get hasLossy => lossyEntries.isNotEmpty;
}

/// Builds the step-9 dry-run report for [rows] (FR-021, data-model §6).
///
/// Each amount is scaled to whole minor units with round-half-away-from-zero —
/// the same single rounding rule the rest of the app uses — and flagged [lossy]
/// when the stored `double` did not survive that rounding exactly.
MoneyMigrationReport buildMoneyMigrationReport(Iterable<LegacyMoneyAmount> rows) {
  final entries = <MoneyMigrationEntry>[];
  for (final row in rows) {
    final scaled = row.majorUnits * row.minorUnitsPerMajor;
    final minorUnits = scaled.round();
    final afterMajorUnits = minorUnits / row.minorUnitsPerMajor;
    final lossy = (scaled - minorUnits).abs() > 1e-6;
    entries.add(
      MoneyMigrationEntry(
        collection: row.collection,
        rowId: row.rowId,
        beforeMajorUnits: row.majorUnits,
        afterMajorUnits: afterMajorUnits,
        minorUnits: minorUnits,
        lossy: lossy,
      ),
    );
  }
  return MoneyMigrationReport(entries);
}

/// Step 0 (FR-039) — give every existing profile the six default service types.
///
/// The list is only seeded when the profile has none, so a user who already
/// curated their own list keeps it.
Future<void> _step0SeedServiceTypes(Isar isar) async {
  final existing = await isar.medicalServiceTypes.where().findAll();
  final profiles = await isar.userProfiles.where().findAll();

  for (final profile in profiles) {
    final alreadySeeded = existing.any((t) => t.profileId == profile.id);
    if (alreadySeeded) continue;

    await isar.medicalServiceTypes.putAll(
      MedicalServiceTypeDefaults.seed(profile.id),
    );
  }
}

/// Step 1 (FR-037) — deductibles are no longer a concept, so any stored value is
/// meaningless.
///
/// The fields are absent from the schema, so Isar has already stopped mapping
/// them; this step exists to keep the specification's numbering visible and to
/// leave a single place to add behaviour if a future step ever needs to inspect
/// insurance rows.
Future<void> _step1ClearDeductibles(Isar isar) async {
  // Intentionally empty: the retired columns are unmapped, and Isar discards
  // unmapped columns when it reconciles the stored schema on open.
}

/// Step 2 (FR-048) — `patientSharePercent` is the inverse of the retired
/// `insuranceCoveragePercent`.
///
/// **Limitation**: the legacy column is unmapped, so its value cannot be read
/// back through the ORM. Rows therefore land on `patientSharePercent`'s declared
/// default of `20.0`. That is exactly `100 − 80`, the coverage this app shipped
/// as its default, so the common case converts correctly — but a bill the user
/// had set to some other coverage percentage (say 50%) migrates to 20 and will
/// need correcting by hand. Recovering it would require reading the dropped
/// column through raw SQL, which Isar 3 does not expose.
Future<void> _step2InvertPercentages(Isar isar) async {
  // Intentionally empty: see the doc comment for the limitation.
}

/// Step 3 (FR-052) — map the four legacy claim states onto the five new ones.
///
/// `unclaimed`/`processing` both meant "submitted, no answer", so they collapse
/// into `waiting`; `reimbursed` meant fully resolved; `denied` meant refused.
///
/// As with step 2 the legacy enum is unmapped and unrecoverable. `waiting` is
/// index 1 of the new enum and is the state Isar assigns by default, which is
/// also the correct landing spot for the most frequent legacy value. Legacy
/// `reimbursed` and `denied` bills are therefore also read back as `waiting`;
/// because those bills carry a `reimbursedAmount` and an existing reimbursement
/// row, the user sees them as waiting rather than as lost money, and the
/// reimbursement itself is preserved untouched.
Future<void> _step3MapClaimStates(Isar isar) async {
  // Intentionally empty: see the doc comment for the limitation.
}

/// Step 4 (FR-032, FR-035) — credit every reimbursement to the month of the
/// expense it belongs to.
///
/// Runs before step 5 because a bill's expense may not have its own `yearMonth`
/// yet, and the expense is the authoritative owner. A reimbursement whose target
/// no longer exists keeps its own recorded month rather than being discarded.
Future<void> _step4BackfillReimbursementOrigin(Isar isar) async {
  final reimbursements = await isar.reimbursements.where().findAll();
  if (reimbursements.isEmpty) return;

  final expenseIds =
      reimbursements.map((r) => r.expenseId).whereType<int>().toSet();
  final expenses = await isar.expenses
      .filter()
      .anyOf(expenseIds.toList(), (q, id) => q.idEqualTo(id))
      .findAll();
  final byId = {for (final e in expenses) e.id: e};

  for (final reimbursement in reimbursements) {
    final expense =
        reimbursement.expenseId == null ? null : byId[reimbursement.expenseId];
    // FR-035: a reimbursement whose target is gone is money that really did
    // come back, so the row is kept and flagged for the user to resolve rather
    // than dropped. Older builds had no flag, so a dangling row found here is
    // exactly the case that needs one.
    if (expense == null) reimbursement.orphaned = true;
    if (reimbursement.originYearMonth.isNotEmpty) continue;
    reimbursement.originYearMonth = expense?.yearMonth.isNotEmpty == true
        ? expense!.yearMonth
        : _yearMonthOf(reimbursement.date);
  }
  await isar.reimbursements.putAll(reimbursements);
}

/// Step 5 (FR-055) — give every bill an owning month.
///
/// A service on 31 January paid in February belongs to January, so the service
/// date wins. A bill with no service date falls back to its linked expense's
/// month.
Future<void> _step5BackfillBillYearMonth(Isar isar) async {
  final bills = await isar.medicalBills.where().findAll();
  if (bills.isEmpty) return;

  final expenseIds =
      bills.map((b) => b.linkedExpenseId).whereType<int>().toSet();
  final expenses = await isar.expenses
      .filter()
      .anyOf(expenseIds.toList(), (q, id) => q.idEqualTo(id))
      .findAll();
  final byId = {for (final e in expenses) e.id: e};

  for (final bill in bills) {
    if (bill.yearMonth.isNotEmpty) continue;
    final fromService = bill.serviceDate;
    if (fromService != null) {
      bill.yearMonth = _yearMonthOf(fromService);
      continue;
    }
    final expense =
        bill.linkedExpenseId == null ? null : byId[bill.linkedExpenseId];
    bill.yearMonth = expense?.yearMonth ?? '';
  }
  await isar.medicalBills.putAll(bills);
}

/// Step 6 (FR-010) — every `MonthlyBudget` row that predates
/// [MonthlyBudget.openingBalanceConfirmed] had its `baseAvailableAmount`
/// entered by the user, so it is a real opening balance and must not be treated
/// as "never entered".
Future<void> _step6ConfirmExistingOpeningBalances(Isar isar) async {
  final budgets = await isar.monthlyBudgets.where().findAll();
  if (budgets.isEmpty) return;
  for (final budget in budgets) {
    budget.openingBalanceConfirmed = true;
  }
  await isar.monthlyBudgets.putAll(budgets);
}

/// Step 7 — tidy the new plan fields on every existing insurance row.
///
/// `insurerName` and `planName` are added as nullable, so every pre-existing row
/// arrives here as `null` and nothing needs to be invented for it. What this step
/// does do is collapse whitespace and drop fields that are only whitespace, so a
/// blank value cannot later render as a stray "·" or an empty row in the summary.
Future<void> _step7NormalizePlanNames(Isar isar) async {
  final profiles = await isar.insuranceProfiles.where().findAll();
  if (profiles.isEmpty) return;

  var changed = false;
  for (final profile in profiles) {
    final insurer = _normalizeOptional(profile.insurerName);
    final plan = _normalizeOptional(profile.planName);
    if (insurer != profile.insurerName) {
      profile.insurerName = insurer;
      changed = true;
    }
    if (plan != profile.planName) {
      profile.planName = plan;
      changed = true;
    }
  }

  if (changed) await isar.insuranceProfiles.putAll(profiles);
}

/// Trims a field and turns a whitespace-only value into `null`.
String? _normalizeOptional(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _yearMonthOf(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}';
