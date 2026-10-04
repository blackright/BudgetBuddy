import 'package:isar/isar.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../engine/expense_delta.dart';
import '../../expenses/models/reimbursement.dart';

/// Budget-scoped inputs needed to keep a [MedicalBill] and its linked [Expense]
/// consistent. Supplied by the UI layer from the active profile + budget.
class MedicalBillContext {
  const MedicalBillContext({
    required this.profileId,
    required this.budgetId,
    required this.yearMonth,
    required this.primaryCurrency,
  });

  final int profileId;
  final int budgetId;

  /// `YYYY-MM` of the active budget, stored on the linked expense so the
  /// engine's `trueAvailable` picks the bill up in the right month.
  final String yearMonth;
  final String primaryCurrency;
}

/// Thrown when deleting a reimbursed bill without an explicit override.
///
/// Removing a reimbursed bill rewrites budget history (FR-005), so the caller
/// must confirm with the user first.
class ReimbursedBillDeletionException implements Exception {
  const ReimbursedBillDeletionException(this.billId, this.reimbursedAmount);

  final int billId;
  final double reimbursedAmount;

  @override
  String toString() =>
      'Bill $billId has a logged reimbursement of $reimbursedAmount. '
      'Deleting it will remove that amount from your available budget.';
}

/// Single write path for medical bills and everything they touch.
///
/// Responsibilities:
/// - CRUD + reactive streams for the medical collections.
/// - Maintains the 1:1 [MedicalBill] <-> [Expense] link (FR-003).
/// - Injects/removes the [Reimbursement] row that moves `trueAvailable`
///   (FR-004, FR-005).
class MedicalRepository {
  MedicalRepository(this._isar);

  /// Matches the seeded `Category` with `categoryId == 'health'`.
  static const String medicalCategoryId = 'health';

  final Isar _isar;

  // ---------------------------------------------------------------------------
  // Reactive reads
  // ---------------------------------------------------------------------------

  /// Bills belonging to [profileId] whose service date falls in [year].
  Stream<List<MedicalBill>> watchMedicalBills(int profileId, int year) {
    final (start, end) = _yearBounds(year);
    return _isar.medicalBills
        .filter()
        .profileIdEqualTo(profileId)
        .serviceDateIsNotNull()
        .and()
        .serviceDateBetween(start, end)
        .sortByServiceDateDesc()
        .watch(fireImmediately: true);
  }

  Stream<MedicalBill?> watchMedicalBill(int id) {
    return _isar.medicalBills.watchObject(id, fireImmediately: true);
  }

  Stream<InsuranceProfile?> watchInsuranceProfile(int profileId, int year) {
    return _isar.insuranceProfiles
        .filter()
        .yearEqualTo(year)
        .watch(fireImmediately: true)
        .map((rows) => _pickProfile(rows, profileId));
  }

  Stream<List<FamilyMember>> watchFamilyMembers(int profileId) {
    return _isar.familyMembers
        .filter()
        .profileIdEqualTo(profileId)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Stream<List<MedicalProvider>> watchMedicalProviders(int profileId) {
    return _isar.medicalProviders
        .filter()
        .profileIdEqualTo(profileId)
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Reactive `expenseId -> ExpenseStatus` map for the supplied expenses.
  Stream<Map<int, ExpenseStatus>> watchExpenseStatuses(List<int> expenseIds) {
    if (expenseIds.isEmpty) return Stream.value(const <int, ExpenseStatus>{});
    return _isar.expenses
        .filter()
        .anyOf(expenseIds, (q, int id) => q.idEqualTo(id))
        .watch(fireImmediately: true)
        .map((expenses) => {for (final e in expenses) e.id: e.status});
  }

  // ---------------------------------------------------------------------------
  // One-shot reads
  // ---------------------------------------------------------------------------

  Future<MedicalBill?> getMedicalBill(int id) => _isar.medicalBills.get(id);

  Future<List<MedicalBill>> getMedicalBillsForYear(int profileId, int year) {
    final (start, end) = _yearBounds(year);
    return _isar.medicalBills
        .filter()
        .profileIdEqualTo(profileId)
        .serviceDateIsNotNull()
        .and()
        .serviceDateBetween(start, end)
        .sortByServiceDateDesc()
        .findAll();
  }

  Future<InsuranceProfile?> getInsuranceProfile(int profileId, int year) async {
    final rows =
        await _isar.insuranceProfiles.filter().yearEqualTo(year).findAll();
    return _pickProfile(rows, profileId);
  }

  Future<List<FamilyMember>> getFamilyMembers(int profileId) =>
      _isar.familyMembers
          .filter()
          .profileIdEqualTo(profileId)
          .sortByName()
          .findAll();

  Future<List<MedicalProvider>> getMedicalProviders(int profileId) =>
      _isar.medicalProviders
          .filter()
          .profileIdEqualTo(profileId)
          .sortByName()
          .findAll();

  /// The single [Reimbursement] attached to a bill's expense, if any.
  Future<Reimbursement?> getReimbursementForBill(MedicalBill bill) async {
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) return null;
    final rows = await _isar.reimbursements
        .filter()
        .expenseIdEqualTo(expenseId)
        .findAll();
    if (rows.isEmpty) return null;
    rows.sort((a, b) => a.id.compareTo(b.id));
    return rows.first;
  }

  // ---------------------------------------------------------------------------
  // Bill lifecycle
  // ---------------------------------------------------------------------------

  /// Creates or updates [bill] together with its linked [Expense].
  ///
  /// The expense is created `planned` unless [status] says the user already
  /// paid the provider, in which case `paidAt` is stamped and `trueAvailable`
  /// drops by the billed amount (FR-004). Amount and status edits flow straight
  /// through the engine's Isar watchers.
  Future<MedicalBill> saveBill(
    MedicalBill bill,
    MedicalBillContext context, {
    ExpenseStatus? status,
  }) async {
    _validateBill(bill);

    bill
      ..serviceDate ??= DateTime.now()
      ..profileId ??= context.profileId
      ..insuranceCoveragePercent =
          bill.insuranceCoveragePercent.clamp(0.0, 100.0);

    await _isar.writeTxn(() async {
      final expense = await _syncLinkedExpense(bill, context, status: status);
      bill.linkedExpenseId = expense.id;
      await _isar.medicalBills.put(bill);
    });
    return bill;
  }

  /// Marks the bill as paid (or back to planned) for the provider.
  ///
  /// Returns the exact engine delta so the UI can explain the budget movement.
  Future<ExpenseDelta> setBillPaidToProvider(
    MedicalBill bill,
    MedicalBillContext context, {
    required bool paid,
  }) async {
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) {
      throw StateError('Bill ${bill.id} has no linked expense to pay.');
    }
    final stored = await _isar.expenses.get(expenseId);
    if (stored == null) {
      throw StateError('Linked expense $expenseId no longer exists.');
    }
    final before = ExpenseSnapshot.of(stored);

    stored
      ..status = paid ? ExpenseStatus.paid : ExpenseStatus.planned
      ..paidAt = paid ? (stored.paidAt ?? DateTime.now()) : null;

    await _isar.writeTxn(() async {
      await _isar.expenses.put(stored);
    });
    return ExpenseDelta.between(
      before: before,
      after: ExpenseSnapshot.of(stored),
    );
  }

  /// Moves the claim through its lifecycle (T019).
  ///
  /// - [ClaimStatus.reimbursed] delegates to [logReimbursement]; [reimbursedAmount]
  ///   is required.
  /// - Moving *away* from `reimbursed` (including to `denied`) deletes the
  ///   injected reimbursement so the budget no longer carries a payout the user
  ///   no longer has (edge case: denied claims are not reimbursed).
  Future<void> updateClaimStatus(
    MedicalBill bill, {
    required ClaimStatus status,
    double? reimbursedAmount,
  }) async {
    if (status == ClaimStatus.reimbursed) {
      if (reimbursedAmount == null) {
        throw ArgumentError.notNull('reimbursedAmount');
      }
      await logReimbursement(bill, amount: reimbursedAmount);
      return;
    }

    await _isar.writeTxn(() async {
      await _clearReimbursementFor(bill);
      bill
        ..claimStatus = status
        ..reimbursedAmount = 0.0;
      await _isar.medicalBills.put(bill);
    });
  }

  /// Records the insurer payout and injects it into the budget (FR-005).
  ///
  /// Idempotent: re-logging replaces the previous amount instead of stacking a
  /// second reimbursement against the same expense.
  Future<void> logReimbursement(
    MedicalBill bill, {
    required double amount,
    DateTime? date,
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'must be greater than zero',
      );
    }
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) {
      throw StateError(
        'Bill ${bill.id} has no linked expense, so a reimbursement cannot be '
        'applied to the budget.',
      );
    }
    final expenseExists = await _isar.expenses.get(expenseId);
    if (expenseExists == null) {
      throw StateError('Linked expense $expenseId no longer exists.');
    }

    await _isar.writeTxn(() async {
      final existing = await _isar.reimbursements
          .filter()
          .expenseIdEqualTo(expenseId)
          .findAll();

      if (existing.isEmpty) {
        await _isar.reimbursements.put(
          Reimbursement()
            ..expenseId = expenseId
            ..amount = amount
            ..date = date ?? DateTime.now(),
        );
      } else {
        // Collapse to a single row so the engine never sees a doubled payout.
        existing.sort((a, b) => a.id.compareTo(b.id));
        existing.first
          ..amount = amount
          ..date = date ?? existing.first.date;
        await _isar.reimbursements.put(existing.first);
        final extras = existing.skip(1).map((r) => r.id).toList();
        if (extras.isNotEmpty) {
          await _isar.reimbursements.deleteAll(extras);
        }
      }

      bill
        ..reimbursedAmount = amount
        ..claimStatus = ClaimStatus.reimbursed;
      await _isar.medicalBills.put(bill);
    });
  }

  /// Sets or clears the follow-up reminder date for a pending claim (FR-009).
  Future<void> setFollowUpDate(MedicalBill bill, DateTime? date) async {
    await _isar.writeTxn(() async {
      bill.followUpDate = date;
      await _isar.medicalBills.put(bill);
    });
  }

  /// Deletes the bill, its linked expense and any reimbursement.
  ///
  /// Throws [ReimbursedBillDeletionException] when the bill has an injected
  /// reimbursement unless [force] is set, because that rewrites past budget
  /// states and the user has to be warned first.
  Future<void> deleteBill(int billId, {bool force = false}) async {
    final bill = await _isar.medicalBills.get(billId);
    if (bill == null) return;

    if (!force && bill.claimStatus == ClaimStatus.reimbursed) {
      throw ReimbursedBillDeletionException(billId, bill.reimbursedAmount);
    }

    await _isar.writeTxn(() async {
      await _clearReimbursementFor(bill);
      final expenseId = bill.linkedExpenseId;
      if (expenseId != null) {
        await _isar.expenses.delete(expenseId);
      }
      await _isar.medicalBills.delete(billId);
    });
  }

  // ---------------------------------------------------------------------------
  // Insurance profile + directories
  // ---------------------------------------------------------------------------

  Future<void> saveInsuranceProfile(InsuranceProfile profile) async {
    await _isar.writeTxn(() async {
      await _isar.insuranceProfiles.put(profile);
    });
  }

  Future<FamilyMember> saveFamilyMember({
    int? id,
    required int profileId,
    required String name,
    required String relation,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'cannot be empty');
    }
    final existing = id == null ? null : await _isar.familyMembers.get(id);
    final member = existing ?? FamilyMember();
    member
      ..id = id ?? member.id
      ..profileId = profileId
      ..name = name.trim()
      ..relation = relation.trim();

    await _isar.writeTxn(() async {
      await _isar.familyMembers.put(member);
    });
    return member;
  }

  Future<void> deleteFamilyMember(int id) async {
    await _isar.writeTxn(() async {
      await _isar.familyMembers.delete(id);
    });
  }

  /// Creates or updates a provider, de-duplicating on (case-insensitive) name
  /// so the directory does not fill with near-identical entries (FR-008).
  Future<MedicalProvider> saveProvider({
    int? id,
    required int profileId,
    required String name,
    String? specialty,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'cannot be empty');
    }

    final siblings = await _isar.medicalProviders
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();

    MedicalProvider? duplicate;
    for (final p in siblings) {
      if (p.id != id && p.name.trim().toLowerCase() == trimmed.toLowerCase()) {
        duplicate = p;
        break;
      }
    }

    final target = duplicate ??
        (id == null ? null : await _isar.medicalProviders.get(id)) ??
        MedicalProvider();
    target
      ..id = duplicate?.id ?? id ?? target.id
      ..profileId = profileId
      ..name = trimmed
      ..specialty = (specialty == null || specialty.trim().isEmpty)
          ? null
          : specialty.trim()
      ..autoCreated = false;

    await _isar.writeTxn(() async {
      await _isar.medicalProviders.put(target);
    });
    return target;
  }

  /// Returns the provider matching [name] for [profileId], creating a
  /// placeholder entry when it is new. Used when a bill is saved with a typed
  /// provider name instead of a directory pick.
  Future<MedicalProvider> findOrCreateProvider({
    required int profileId,
    required String name,
    String? specialty,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'cannot be empty');
    }
    final existing = await _isar.medicalProviders
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();
    for (final p in existing) {
      if (p.name.trim().toLowerCase() == trimmed.toLowerCase()) return p;
    }
    final created = MedicalProvider()
      ..profileId = profileId
      ..name = trimmed
      ..specialty = (specialty == null || specialty.trim().isEmpty)
          ? null
          : specialty.trim()
      ..autoCreated = true;
    await _isar.writeTxn(() async {
      await _isar.medicalProviders.put(created);
    });
    return created;
  }

  Future<void> deleteProvider(int id) async {
    await _isar.writeTxn(() async {
      await _isar.medicalProviders.delete(id);
    });
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Prefers an exact profile match; falls back to a profile-less legacy row.
  static InsuranceProfile? _pickProfile(
    List<InsuranceProfile> rows,
    int profileId,
  ) {
    if (rows.isEmpty) return null;
    for (final row in rows) {
      if (row.profileId == profileId) return row;
    }
    return rows.first;
  }

  void _validateBill(MedicalBill bill) {
    if (bill.billedAmount <= 0) {
      throw ArgumentError.value(
        bill.billedAmount,
        'billedAmount',
        'must be greater than zero',
      );
    }
    if (bill.insuranceCoveragePercent < 0 ||
        bill.insuranceCoveragePercent > 100) {
      throw ArgumentError.value(
        bill.insuranceCoveragePercent,
        'insuranceCoveragePercent',
        'must be between 0 and 100',
      );
    }
  }

  /// Creates or refreshes the linked expense inside the caller's transaction.
  Future<Expense> _syncLinkedExpense(
    MedicalBill bill,
    MedicalBillContext context, {
    ExpenseStatus? status,
  }) async {
    final providerName = await _providerNameFor(bill.providerId);
    final title = providerName ?? 'Medical Bill';

    final stored = bill.linkedExpenseId == null
        ? null
        : await _isar.expenses.get(bill.linkedExpenseId!);

    final expense = stored ??
        Expense(
          profileId: context.profileId,
          yearMonth: context.yearMonth,
          title: title,
          amount: bill.billedAmount,
          currency: context.primaryCurrency,
          categoryId: medicalCategoryId,
          date: bill.serviceDate ?? DateTime.now(),
          budgetId: context.budgetId,
        );

    expense
      ..profileId = context.profileId
      ..yearMonth = context.yearMonth
      ..budgetId = context.budgetId
      ..title = title
      ..amount = bill.billedAmount
      // Medical bills are always tracked in the budget's primary currency, so
      // no conversion applies and the rate stays locked at 1.0.
      ..currency = context.primaryCurrency
      ..exchangeRateToPrimary = 1.0
      ..categoryId = medicalCategoryId
      ..type = ExpenseType.medical
      ..isReimbursable = true
      ..status = status ??
          (stored?.status ??
              (bill.claimStatus == ClaimStatus.reimbursed
                  ? ExpenseStatus.paid
                  : ExpenseStatus.planned))
      ..date = bill.serviceDate ?? DateTime.now()
      ..notes = '${bill.insuranceCoveragePercent.toStringAsFixed(0)}% covered';

    if (expense.status == ExpenseStatus.paid) {
      expense.paidAt ??= DateTime.now();
    } else {
      expense.paidAt = null;
    }

    await _isar.expenses.put(expense);
    return expense;
  }

  Future<String?> _providerNameFor(int? providerId) async {
    if (providerId == null) return null;
    final provider = await _isar.medicalProviders.get(providerId);
    if (provider == null || provider.name.trim().isEmpty) return null;
    return provider.name.trim();
  }

  Future<void> _clearReimbursementFor(MedicalBill bill) async {
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) return;
    final rows = await _isar.reimbursements
        .filter()
        .expenseIdEqualTo(expenseId)
        .findAll();
    if (rows.isEmpty) return;
    await _isar.reimbursements.deleteAll(rows.map((r) => r.id).toList());
  }

  static (DateTime, DateTime) _yearBounds(int year) =>
      (DateTime(year), DateTime(year + 1));
}
