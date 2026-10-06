import 'package:isar/isar.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/services/reminder_notification_service.dart';
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

/// Thrown when a state change would produce an impossible bill.
class InvalidBillTransitionException implements Exception {
  const InvalidBillTransitionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a document is attached to a bill that cannot have one (FR-047).
class InvalidDocumentException implements Exception {
  const InvalidDocumentException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a service type name collides with an existing one (FR-040).
class DuplicateServiceTypeException implements Exception {
  const DuplicateServiceTypeException(this.name);

  final String name;

  @override
  String toString() =>
      'A service type named "$name" already exists. Choose a different name.';
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

  /// Bills belonging to [profileId] whose owning month is [yearMonth].
  ///
  /// Month-scoped rather than year-scoped because a bill's money impact lands in
  /// exactly one month's totals (FR-055, FR-056).
  Stream<List<MedicalBill>> watchMedicalBills(int profileId, String yearMonth) {
    return _isar.medicalBills
        .filter()
        .profileIdEqualTo(profileId)
        .yearMonthEqualTo(yearMonth)
        .sortByServiceDateDesc()
        .watch(fireImmediately: true);
  }

  Stream<MedicalBill?> watchMedicalBill(int id) {
    return _isar.medicalBills.watchObject(id, fireImmediately: true);
  }

  Stream<InsuranceProfile?> watchInsuranceProfile(int profileId) {
    return _isar.insuranceProfiles
        .filter()
        .profileIdEqualTo(profileId)
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

  Future<List<MedicalBill>> getMedicalBillsForMonth(
    int profileId,
    String yearMonth,
  ) {
    return _isar.medicalBills
        .filter()
        .profileIdEqualTo(profileId)
        .yearMonthEqualTo(yearMonth)
        .sortByServiceDateDesc()
        .findAll();
  }

  Future<InsuranceProfile?> getInsuranceProfile(int profileId) async {
    final rows = await _isar.insuranceProfiles
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();
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
      ..patientSharePercent = bill.patientSharePercent.clamp(0.0, 100.0);

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

  /// Validation gate for a state change (T2, FR-044).
  ///
  /// `finished` means "fully resolved, money accounted for". An insurer-paid
  /// bill has no reimbursement to account for, so the state cannot be reached.
  static void _validateTransition(MedicalBill bill, MedicalBillState next) {
    if (next == MedicalBillState.finished &&
        bill.paymentMethod == MedicalPaymentMethod.insurerPaid) {
      throw const InvalidBillTransitionException(
        'An insurer-paid bill has no reimbursement to finish. Mark it paid or '
        'rejected instead.',
      );
    }
  }

  /// Moves a bill to [state], keeping the linked expense and any reimbursement
  /// consistent (FR-054, M5).
  ///
  /// Entering or leaving `rejected` recomputes the expense from the method and
  /// percentage rather than leaving a stale amount, and any reimbursement is
  /// deleted when the bill is rejected or when it moves away from `finished`
  /// (T3, T4). Money that did not return must not appear as returned.
  Future<void> setBillState(
    MedicalBill bill,
    MedicalBillState state, {
    MedicalBillContext? context,
    double? reimbursedAmount,
  }) async {
    _validateTransition(bill, state);

    if (state == MedicalBillState.finished && bill.canBeReimbursed) {
      // T1 — a self-paid bill cannot be finished without the payout recorded, so
      // the amount is required rather than silently defaulted to zero.
      if (reimbursedAmount == null) {
        throw ArgumentError.notNull('reimbursedAmount');
      }
      await logReimbursement(bill, amount: reimbursedAmount);
      // `logReimbursement` sets the state itself.
      return;
    }

    await _isar.writeTxn(() async {
      // T4 — a bill that is no longer finished, or is rejected, must not keep a
      // reimbursement.
      final losesReimbursement = state == MedicalBillState.rejected ||
          bill.state == MedicalBillState.finished;
      if (losesReimbursement) {
        await _clearReimbursementFor(bill);
        bill.reimbursedAmount = 0.0;
      }

      bill.state = state;
      await _isar.medicalBills.put(bill);

      final syncContext = context ?? await _contextForExistingBill(bill);
      if (syncContext != null) {
        await _syncLinkedExpense(bill, syncContext);
      }
    });

    if (state == MedicalBillState.paid || state == MedicalBillState.finished) {
      await _clearReminder(bill);
    }
  }

  /// Switches a bill between insurer-paid and self-paid (FR-041).
  ///
  /// The method is the biggest lever on the budget, so the linked expense is
  /// re-synced through the same money-impact rule as any other change. Moving to
  /// insurer-paid clears the insurer reply (D2) and any reimbursement, because
  /// neither is meaningful when the insurer settles directly.
  Future<void> setPaymentMethod(
    MedicalBill bill,
    MedicalPaymentMethod method, {
    MedicalBillContext? context,
  }) async {
    if (bill.paymentMethod == method) return;

    await _isar.writeTxn(() async {
      final becomesInsurerPaid = method == MedicalPaymentMethod.insurerPaid;
      if (becomesInsurerPaid) {
        await _clearReimbursementFor(bill);
        bill
          ..reimbursedAmount = 0.0
          ..insurerReplyPath = null;
        // R-1 — an insurer-paid bill is settled with the provider, so it can
        // never be `finished`.
        if (bill.state == MedicalBillState.finished) {
          bill.state = MedicalBillState.paid;
        }
      }

      bill.paymentMethod = method;
      await _isar.medicalBills.put(bill);

      final syncContext = context ?? await _contextForExistingBill(bill);
      if (syncContext != null) {
        await _syncLinkedExpense(bill, syncContext);
      }
    });
  }

  Future<void> updateMedicalBillReimbursement(MedicalBill bill, double totalReimbursed) async {
    await _isar.writeTxn(() async {
      bill
        ..reimbursedAmount = totalReimbursed
        ..state = (totalReimbursed >= bill.insurerPaidAmount - 0.01)
            ? MedicalBillState.finished
            : MedicalBillState.waiting; // or however we want to represent partial
      await _isar.medicalBills.put(bill);
    });
  }

  /// Records the insurer payout and injects it into the budget (FR-005).
  ///
  /// All-or-nothing and idempotent: re-logging replaces the previous amount
  /// instead of stacking a second reimbursement against the same expense (R-2,
  /// R-3, R-4). The money is attributed to the bill's owning month, not the date
  /// it was recorded (R-5).
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
    // FR-044 / R-1: an insurer-paid bill is settled with the provider, so there
    // is no payout to record. Refuse before touching the budget rather than
    // silently injecting money that was never coming.
    if (!bill.canBeReimbursed) {
      throw ArgumentError.value(
        amount,
        'amount',
        'only a self-paid bill can be reimbursed; bill ${bill.id} is '
            '${bill.paymentMethod.label}',
      );
    }
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) {
      throw StateError(
        'Bill ${bill.id} has no linked expense, so a reimbursement cannot be '
        'applied to the budget.',
      );
    }
    final expense = await _isar.expenses.get(expenseId);
    if (expense == null) {
      throw StateError('Linked expense $expenseId no longer exists.');
    }

    await _isar.writeTxn(() async {
      final existing = await _isar.reimbursements
          .filter()
          .expenseIdEqualTo(expenseId)
          .findAll();

      if (existing.isEmpty) {
        await _isar.reimbursements.put(
          Reimbursement(
            profileId: bill.profileId ?? expense.profileId,
            expenseId: expenseId,
            amount: amount,
            currency: expense.currency,
            originYearMonth: bill.yearMonth.isNotEmpty ? bill.yearMonth : expense.yearMonth,
            date: date ?? DateTime.now(),
          ),
        );
      } else {
        // Collapse to a single row so the engine never sees a doubled payout.
        existing.sort((a, b) => a.id.compareTo(b.id));
        existing.first
          ..amount = amount
          ..originYearMonth =
              bill.yearMonth.isNotEmpty ? bill.yearMonth : expense.yearMonth
          ..date = date ?? existing.first.date;
        await _isar.reimbursements.put(existing.first);
        final extras = existing.skip(1).map((r) => r.id).toList();
        if (extras.isNotEmpty) {
          await _isar.reimbursements.deleteAll(extras);
        }
      }

      bill
        ..reimbursedAmount = amount
        ..state = MedicalBillState.finished;
      await _isar.medicalBills.put(bill);
    });
  }

  /// Sets or clears the follow-up reminder date for a pending claim (FR-009).
  Future<void> setFollowUpDate(MedicalBill bill, DateTime? date) async {
    if (date != null && date.isBefore(DateTime.now())) {
      throw ArgumentError('Follow up date must be in the future.');
    }
    await _isar.writeTxn(() async {
      bill.followUpDate = date;
      await _isar.medicalBills.put(bill);
    });

    if (date != null) {
      await ReminderNotificationService().scheduleReminder(
        id: bill.id,
        title: 'Claim Follow-up',
        body: 'Follow up on your pending medical bill',
        scheduledDate: date,
      );
    } else {
      await ReminderNotificationService().cancelReminder(bill.id);
    }
  }

  Future<void> setCalendarEventId(MedicalBill bill, String? eventId) async {
    await _isar.writeTxn(() async {
      bill.calendarEventId = eventId;
      await _isar.medicalBills.put(bill);
    });
  }

  Future<void> _clearReminder(MedicalBill bill) async {
    if (bill.followUpDate != null) {
      await _isar.writeTxn(() async {
        bill.followUpDate = null;
        // Optionally, clear calendarEventId here if we are removing the event too,
        // but removing device_calendar event requires device_calendar plugin.
        // The UI or a dedicated service should probably handle device_calendar deletion.
        await _isar.medicalBills.put(bill);
      });
      await ReminderNotificationService().cancelReminder(bill.id);
    }
  }

  /// Deletes the bill, its linked expense and any reimbursement.
  ///
  /// T5 — a bill carrying a reimbursement MUST NOT have that reimbursement
  /// deleted silently, because it removes money from a closed month's history.
  /// Throws [ReimbursedBillDeletionException] unless [force] is set, so the
  /// caller has to warn the user first.
  Future<void> deleteBill(int billId, {bool force = false}) async {
    final bill = await _isar.medicalBills.get(billId);
    if (bill == null) return;

    if (!force && bill.reimbursedAmount > 0) {
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
    
    await ReminderNotificationService().cancelReminder(billId);
  }

  // ---------------------------------------------------------------------------
  // Service types (FR-039, FR-040)
  // ---------------------------------------------------------------------------

  /// Service types available for new bills: not archived, in display order.
  Stream<List<MedicalServiceType>> watchServiceTypes(int profileId) {
    return _isar.medicalServiceTypes
        .filter()
        .profileIdEqualTo(profileId)
        .sortBySortOrder()
        .thenByName()
        .watch(fireImmediately: true);
  }

  /// The types still offered in the picker (FR-040).
  ///
  /// Archived types stay in the database so historical bills keep their label,
  /// but they must not clutter the list of new choices.
  Future<List<MedicalServiceType>> getServiceTypes(int profileId) {
    return _isar.medicalServiceTypes
        .filter()
        .profileIdEqualTo(profileId)
        .archivedEqualTo(false)
        .sortBySortOrder()
        .thenByName()
        .findAll();
  }

  /// Every type including archived ones, for rendering historical bills (FR-040).
  Future<List<MedicalServiceType>> getAllServiceTypes(int profileId) {
    return _isar.medicalServiceTypes
        .filter()
        .profileIdEqualTo(profileId)
        .sortBySortOrder()
        .thenByName()
        .findAll();
  }

  /// Creates or renames a service type, rejecting a name that already exists for
  /// the same profile regardless of case (FR-040).
  Future<MedicalServiceType> saveServiceType({
    int? id,
    required int profileId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'cannot be empty');
    }

    final siblings = await _isar.medicalServiceTypes
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();

    for (final type in siblings) {
      if (type.id != id &&
          type.name.trim().toLowerCase() == trimmed.toLowerCase()) {
        throw DuplicateServiceTypeException(trimmed);
      }
    }

    final target = id == null
        ? MedicalServiceType()
        : siblings.firstWhere(
            (t) => t.id == id,
            orElse: () => MedicalServiceType(),
          );

    if (id == null) {
      target.sortOrder = siblings.length;
    }
    target
      ..id = id ?? target.id
      ..profileId = profileId
      ..name = trimmed
      // Renaming a seeded type keeps its seeded status; only an unseeded type
      // loses it.
      ..archived = false;

    await _isar.writeTxn(() async {
      await isarPutServiceType(target);
    });
    return target;
  }

  Future<void> isarPutServiceType(MedicalServiceType type) =>
      _isar.medicalServiceTypes.put(type);

  /// Archives a type instead of deleting it, so historical bills keep a readable
  /// reference (FR-040, R10).
  Future<void> archiveServiceType(int id) async {
    final type = await _isar.medicalServiceTypes.get(id);
    if (type == null) return;
    type.archived = true;
    await _isar.writeTxn(() async {
      await _isar.medicalServiceTypes.put(type);
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

  /// Pre-loaded so callers cannot fail the common case of a profile-less legacy
  /// row.
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
    if (bill.patientSharePercent < 0 || bill.patientSharePercent > 100) {
      throw ArgumentError.value(
        bill.patientSharePercent,
        'patientSharePercent',
        'must be between 0 and 100',
      );
    }
    // D2 — there is no reimbursement to claim on an insurer-paid bill, so an
    // insurer reply document cannot apply to one (FR-047).
    if (bill.insurerReplyPath != null &&
        bill.insurerReplyPath!.trim().isNotEmpty &&
        bill.paymentMethod == MedicalPaymentMethod.insurerPaid) {
      throw const InvalidDocumentException(
        'An insurer reply only applies to a self-paid bill. An insurer-paid '
        'bill is settled directly with the provider.',
      );
    }
    // T2 — mirrored here so a bill can never be constructed in an illegal state.
    _validateTransition(bill, bill.state);
  }

  /// Resolves the owning month and mirrors it onto the linked expense, inside the
  /// caller's transaction (FR-055, O2).
  ///
  /// Precedence, highest first:
  ///  1. a year-month already on the bill (an explicit user override),
  ///  2. the service date,
  ///  3. the month of the expense being written.
  ///
  /// The bill and its expense are written together, so they can never disagree
  /// about which month they belong to.
  void _applyOwningMonth(MedicalBill bill, String expenseYearMonth) {
    final serviceDate = bill.serviceDate;
    if (bill.yearMonth.isNotEmpty) return;
    bill.yearMonth =
        serviceDate == null ? expenseYearMonth : _yearMonthOf(serviceDate);
  }

  /// Creates or refreshes the linked expense inside the caller's transaction.
  ///
  /// `Expense.amount` is set from [MedicalBill.fundsImpact], which *is* the
  /// money-impact table, so the bill and the budget can never disagree about
  /// what a bill cost (R07). M2 — the reduction is applied here, at entry, not
  /// deferred to a month-end event.
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

    // O1 — the service month owns the bill, not the month it happened to be
    // entered in.
    final yearMonth =
        bill.yearMonth.isNotEmpty ? bill.yearMonth : context.yearMonth;
    _applyOwningMonth(bill, yearMonth);

    final expense = stored ??
        Expense(
          profileId: context.profileId,
          yearMonth: bill.yearMonth,
          title: title,
          amount: bill.fundsImpact,
          currency: context.primaryCurrency,
          categoryId: medicalCategoryId,
          date: bill.serviceDate ?? DateTime.now(),
          budgetId: context.budgetId,
        );

    expense
      ..profileId = context.profileId
      // O2 — mirrored in the same transaction, never independently derived.
      ..yearMonth = bill.yearMonth
      ..budgetId = context.budgetId
      ..title = title
      // R-007 — the expense amount *is* the money impact.
      ..amount = bill.fundsImpact
      // Medical bills are always tracked in the budget's primary currency, so
      // no conversion applies and the rate stays locked at 1.0.
      ..currency = context.primaryCurrency
      ..exchangeRateToPrimary = 1.0
      ..categoryId = medicalCategoryId
      ..type = ExpenseType.medical
      // R-1 — only a self-paid bill can be reimbursed, so only a self-paid bill
      // offers the user a reimbursement.
      ..isReimbursable = bill.canBeReimbursed
      // M4 — a planned bill belongs to the planned pool, never to payments.
      // Derived from the bill's state rather than inherited from the stored row,
      // otherwise moving back to `planned` would leave the expense still paid.
      ..status = status ??
          (bill.state == MedicalBillState.planned
              ? ExpenseStatus.planned
              : ExpenseStatus.paid)
      ..date = bill.serviceDate ?? DateTime.now()
      ..notes = _notesFor(bill);

    if (expense.status == ExpenseStatus.paid) {
      expense.paidAt ??= DateTime.now();
    } else {
      expense.paidAt = null;
    }

    await _isar.expenses.put(expense);
    return expense;
  }

  /// Human-readable provenance shown on the linked expense.
  static String _notesFor(MedicalBill bill) {
    if (bill.paymentMethod == MedicalPaymentMethod.selfPaid) {
      return 'Self-paid';
    }
    return '${bill.patientSharePercent.toStringAsFixed(0)}% patient share';
  }

  /// Rebuilds the context needed to re-sync a bill's expense when only the bill
  /// is in hand, by reading the month back off its own linked expense.
  Future<MedicalBillContext?> _contextForExistingBill(MedicalBill bill) async {
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) return null;
    final expense = await _isar.expenses.get(expenseId);
    if (expense == null) return null;
    return MedicalBillContext(
      profileId: expense.profileId,
      budgetId: expense.budgetId,
      yearMonth: expense.yearMonth,
      primaryCurrency: expense.currency,
    );
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
}

/// `YYYY-MM` for a date, used for month attribution (FR-055).
String _yearMonthOf(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}';

/// `YYYY-MM` for a date offset by [months] from [from].
String shiftYearMonth(DateTime from, int months) =>
    _yearMonthOf(DateTime(from.year, from.month + months));
