import 'package:isar/isar.dart';

import '../models/expense.dart';
import '../models/medical_appeal.dart';
import '../models/medical_approval.dart';
import '../models/medical_bill.dart';
import '../models/medical_settlement_event.dart';
import '../services/medical_bill_basis.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/sync/repositories/sync_recorder.dart';
import 'medical_management_reducer.dart';

/// Typed refusal from a management command.
class MedicalManagementException implements Exception {
  const MedicalManagementException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'MedicalManagementException($code): $message';
}

/// The three outcomes allowed for an insurance request.
enum MedicalDecision { approved, rejected, cancelled }

/// Shared command infrastructure for Bill Management.
///
/// Phase 2 provides reads and stage resolution. Phase 3 adds the user-paid
/// commands. Every command runs in one Isar transaction and updates the new
/// trackers plus the legacy compatibility fields together.
class MedicalManagementService {
  MedicalManagementService({
    required Isar db,
    required int? actingProfileId,
    SyncRecorder? recorder,
    MedicalManagementReducer reducer = const MedicalManagementReducer(),
    DateTime Function()? clock,
  })  : _db = db,
        _actingProfileId = actingProfileId,
        _recorder = recorder,
        _reducer = reducer,
        _clock = clock ?? DateTime.now;

  final Isar _db;
  final int? _actingProfileId;
  final SyncRecorder? _recorder;
  final MedicalManagementReducer _reducer;
  final DateTime Function() _clock;

  /// Loads the bill and resolves its current management stage.
  Future<MedicalManagementState> load(
    int billId, {
    required bool Function() isAccessCurrent,
    bool canEdit = true,
  }) async {
    final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
    return _reducer.resolve(bill, canEdit: canEdit);
  }

  /// Returns the bill only when access is current and the acting user may see
  /// its owner/space. A missing or foreign row is reported as not found.
  Future<MedicalBill> requireBill(
    int billId, {
    required bool Function() isAccessCurrent,
  }) async {
    if (!isAccessCurrent()) {
      throw const MedicalManagementException(
          'accessChanged', 'Access changed. Reopen this bill.');
    }
    final bill = await _db.medicalBills.get(billId);
    if (bill == null) {
      throw const MedicalManagementException(
          'billMissing', 'This medical bill no longer exists.');
    }
    if (!_canSee(bill)) {
      throw const MedicalManagementException(
          'wrongOwner', 'This bill belongs to another profile or space.');
    }
    return bill;
  }

  /// Refuses to act on a closed, cancelled or Needs-review bill.
  void ensureOpen(MedicalBill bill) {
    if (bill.needsReview) {
      throw const MedicalManagementException(
          'legacyFrozen', 'This bill needs review before it can change.');
    }
    if (bill.overallStatus == MedicalOverallStatus.closed) {
      throw const MedicalManagementException(
          'billClosed', 'Reopen this bill before recording a new event.');
    }
    if (bill.overallStatus == MedicalOverallStatus.cancelled) {
      throw const MedicalManagementException(
          'billCancelled', 'This bill was cancelled.');
    }
  }

  /// User-paid submission: confirms the provider payment and the request.
  Future<MedicalBill> submitRequest({
    required int billId,
    required int providerAmountMinor,
    required DateTime paymentDate,
    required String paymentMonth,
    required DateTime submissionDate,
    String? reference,
    List<String> documentPaths = const [],
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    _requireMonth(paymentMonth);
    if (providerAmountMinor <= 0) {
      throw const MedicalManagementException(
          'invalidAmount', 'The provider payment must be greater than zero.');
    }
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.paymentMethod != MedicalPaymentMethod.selfPaid) {
        throw const MedicalManagementException(
            'wrongPaymentModel', 'This command is only for user-paid bills.');
      }
      final identity = _identity('submit', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      if (bill.insuranceRequestStatus !=
          MedicalInsuranceRequestStatus.notSubmitted) {
        throw const MedicalManagementException(
            'requestAlreadySubmitted', 'The request was already submitted.');
      }
      final expense = await _expense(bill);
      final now = _clock();
      expense
        ..amount = providerAmountMinor
        ..status = ExpenseStatus.paid
        ..paidAt = paymentDate.toUtc()
        ..cashYearMonth = paymentMonth
        ..isReimbursable = true;
      await _putExpense(expense);
      bill
        ..providerPaymentStatus = MedicalProviderPaymentStatus.paid
        ..insuranceRequestStatus = MedicalInsuranceRequestStatus.receiptPending
        ..submissionDate = submissionDate.toUtc()
        ..insuranceReference = reference
        ..salarySettlementType = MedicalSalarySettlementType.insuranceRefund
        ..settlementAmountMinor = bill.insurerPaidAmount
        ..lastUpdatedAt = now
        ..state = MedicalBillState.paid;
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'submitted',
        recordedAt: now,
        transactionMonth: paymentMonth,
        documentPaths: documentPaths,
        reference: reference,
        beforeMinor: bill.billedAmount,
        afterMinor: providerAmountMinor,
        identity: identity,
      );
      return bill;
    });
  }

  /// Insurance-paid submission: no provider payment and no money movement.
  Future<MedicalBill> submitInsuranceRequest({
    required int billId,
    required DateTime submissionDate,
    String? reference,
    List<String> documentPaths = const [],
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.paymentMethod != MedicalPaymentMethod.insurerPaid) {
        throw const MedicalManagementException('wrongPaymentModel',
            'This command is only for insurance-paid bills.');
      }
      final identity = _identity('submit', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      if (bill.insuranceRequestStatus !=
          MedicalInsuranceRequestStatus.notSubmitted) {
        throw const MedicalManagementException(
            'requestAlreadySubmitted', 'The request was already submitted.');
      }
      bill
        ..providerPaymentStatus = MedicalProviderPaymentStatus.notRequired
        ..insuranceRequestStatus = MedicalInsuranceRequestStatus.receiptPending
        ..submissionDate = submissionDate.toUtc()
        ..insuranceReference = reference
        ..salarySettlementType = MedicalSalarySettlementType.userShareDeduction
        ..settlementAmountMinor = bill.patientShareAmount
        ..lastUpdatedAt = _clock();
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'submitted',
        recordedAt: _clock(),
        documentPaths: documentPaths,
        reference: reference,
        beforeMinor: bill.patientShareAmount,
        afterMinor: bill.insurerPaidAmount,
        identity: identity,
      );
      return bill;
    });
  }

  Future<MedicalBill> confirmReceipt({
    required int billId,
    required DateTime receiptDate,
    List<String> documentPaths = const [],
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (!{
        MedicalInsuranceRequestStatus.submitted,
        MedicalInsuranceRequestStatus.receiptPending,
      }.contains(bill.insuranceRequestStatus)) {
        throw const MedicalManagementException(
            'invalidStage', 'This request is not awaiting receipt.');
      }
      final identity = _identity('receipt', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..insuranceRequestStatus = MedicalInsuranceRequestStatus.inProgress
        ..receiptConfirmedDate = receiptDate.toUtc()
        ..lastUpdatedAt = _clock();
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'receiptConfirmed',
        recordedAt: _clock(),
        documentPaths: documentPaths,
        identity: identity,
      );
      return bill;
    });
  }

  Future<MedicalBill> keepReceiptPending({
    required int billId,
    required String operationKey,
    required bool Function() isAccessCurrent,
    String? note,
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      final identity = _identity('receiptPending', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..insuranceRequestStatus = MedicalInsuranceRequestStatus.receiptPending
        ..lastUpdatedAt = _clock();
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'receiptPending',
        recordedAt: _clock(),
        reason: note ?? '',
        identity: identity,
      );
      return bill;
    });
  }

  Future<MedicalBill> recordDecision({
    required int billId,
    required MedicalDecision decision,
    required DateTime decisionDate,
    List<String> documentPaths = const [],
    String? reference,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.insuranceRequestStatus !=
          MedicalInsuranceRequestStatus.inProgress) {
        throw const MedicalManagementException(
            'invalidStage', 'Only an in-progress request can be decided.');
      }
      final identity = _identity('decision', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..insuranceRequestStatus = switch (decision) {
          MedicalDecision.approved => MedicalInsuranceRequestStatus.approved,
          MedicalDecision.rejected => MedicalInsuranceRequestStatus.rejected,
          MedicalDecision.cancelled =>
            MedicalInsuranceRequestStatus.requestCancelled,
        }
        ..lastUpdatedAt = _clock();
      if (decision == MedicalDecision.rejected) {
        bill.state = MedicalBillState.rejected;
      } else if (decision == MedicalDecision.approved) {
        bill.state = MedicalBillState.waiting;
      }
      await _putBill(bill);
      await _activity(
        bill,
        kind: switch (decision) {
          MedicalDecision.approved => 'approved',
          MedicalDecision.rejected => 'rejected',
          MedicalDecision.cancelled => 'requestCancelled',
        },
        recordedAt: decisionDate.toUtc(),
        documentPaths: documentPaths,
        reference: reference,
        identity: identity,
      );
      return bill;
    });
  }

  /// Records the editable approved split and moves to the refund/deduction wait.
  Future<MedicalBill> reviewApprovedAmounts({
    required int billId,
    required int approvedBillMinor,
    required int approvedShareMinor,
    required int approvedInsuranceMinor,
    required String? expectedSalaryMonth,
    required String operationKey,
    required bool Function() isAccessCurrent,
    List<String> documentPaths = const [],
  }) async {
    if (approvedBillMinor <= 0 ||
        approvedShareMinor < 0 ||
        approvedInsuranceMinor <= 0 ||
        approvedShareMinor + approvedInsuranceMinor != approvedBillMinor) {
      throw const MedicalManagementException('approvalInvariant',
          'Approved share plus approved insurance must equal the approved bill.');
    }
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (!{
        MedicalInsuranceRequestStatus.approved,
        MedicalInsuranceRequestStatus.appealApproved,
      }.contains(bill.insuranceRequestStatus)) {
        throw const MedicalManagementException(
            'invalidStage', 'Review is only available after approval.');
      }
      final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
      final zeroShare = direct && approvedShareMinor == 0;
      if (!zeroShare) {
        if (expectedSalaryMonth == null) {
          throw const MedicalManagementException(
              'invalidMonth', 'Choose the expected salary month.');
        }
        _requireMonth(expectedSalaryMonth);
      }
      final identity = _identity('approval', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final now = _clock();
      await _writeApproval(
        bill,
        approvedBillMinor: approvedBillMinor,
        approvedShareMinor: approvedShareMinor,
        approvedInsuranceMinor: approvedInsuranceMinor,
        decisionDate: now,
        identity: identity,
      );
      bill
        ..salarySettlementType = direct
            ? MedicalSalarySettlementType.userShareDeduction
            : MedicalSalarySettlementType.insuranceRefund
        ..salarySettlementStatus = zeroShare
            ? MedicalSalarySettlementStatus.notRequired
            : MedicalSalarySettlementStatus.waitingForPayslip
        ..settlementAmountMinor =
            direct ? approvedShareMinor : approvedInsuranceMinor
        ..expectedSalaryMonth = zeroShare ? null : expectedSalaryMonth
        ..lastUpdatedAt = now
        ..state = MedicalBillState.waiting;
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'approved',
        recordedAt: now,
        documentPaths: documentPaths,
        afterMinor: direct ? approvedShareMinor : approvedInsuranceMinor,
        identity: identity,
      );
      return bill;
    });
  }

  /// Confirms the full share taken from salary in the actual month.
  Future<MedicalBill> recordDeductionConfirmed({
    required int billId,
    required int amountMinor,
    required String actualSalaryMonth,
    required DateTime deductionDate,
    required String operationKey,
    required bool Function() isAccessCurrent,
    List<String> documentPaths = const [],
  }) async {
    _requireMonth(actualSalaryMonth);
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.paymentMethod != MedicalPaymentMethod.insurerPaid) {
        throw const MedicalManagementException('wrongPaymentModel',
            'This command is only for insurance-paid bills.');
      }
      if (bill.salarySettlementStatus !=
              MedicalSalarySettlementStatus.waitingForPayslip &&
          bill.salarySettlementStatus !=
              MedicalSalarySettlementStatus.notDeducted) {
        throw const MedicalManagementException('settlementNotWaiting',
            'There is no deduction awaiting confirmation.');
      }
      if (bill.settlementAmountMinor == null ||
          amountMinor != bill.settlementAmountMinor ||
          amountMinor <= 0) {
        throw const MedicalManagementException('partialNotSupported',
            'This version records the full approved share only.');
      }
      final identity = _identity('deduction', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final expense = await _expense(bill);
      expense
        ..amount = amountMinor
        ..status = ExpenseStatus.paid
        ..paidAt = deductionDate.toUtc()
        ..cashYearMonth = actualSalaryMonth
        ..isReimbursable = false;
      await _putExpense(expense);
      await _writeShareSettlement(
        bill,
        expense,
        amountMinor: amountMinor,
        transactionMonth: actualSalaryMonth,
        effectiveDate: deductionDate,
        identity: identity,
      );
      bill
        ..settledAmountMinor = amountMinor
        ..actualSalaryMonth = actualSalaryMonth
        ..settledDate = deductionDate.toUtc()
        ..salarySettlementStatus = MedicalSalarySettlementStatus.deducted
        ..insuranceRequestStatus = MedicalInsuranceRequestStatus.completed
        ..lastUpdatedAt = _clock()
        ..state = MedicalBillState.paid;
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'deductionConfirmed',
        recordedAt: _clock(),
        transactionMonth: actualSalaryMonth,
        documentPaths: documentPaths,
        afterMinor: amountMinor,
        identity: identity,
      );
      return bill;
    });
  }

  Future<MedicalBill> recordNotDeducted({
    required int billId,
    required String nextExpectedMonth,
    required String operationKey,
    required bool Function() isAccessCurrent,
    String? note,
  }) async {
    _requireMonth(nextExpectedMonth);
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      final identity = _identity('notDeducted', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..salarySettlementStatus = MedicalSalarySettlementStatus.notDeducted
        ..expectedSalaryMonth = nextExpectedMonth
        ..lastUpdatedAt = _clock();
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'deductionNotShown',
        recordedAt: _clock(),
        reason: note ?? '',
        identity: identity,
      );
      return bill;
    });
  }

  /// Completes a 100%-covered insurance-paid case without a payslip.
  Future<MedicalBill> completeAt100Percent({
    required int billId,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.paymentMethod != MedicalPaymentMethod.insurerPaid ||
          bill.insuranceRequestStatus !=
              MedicalInsuranceRequestStatus.approved) {
        throw const MedicalManagementException(
            'invalidStage', 'This case is not approved at 100%.');
      }
      final approvals = await _db.medicalApprovals
          .filter()
          .billGuidEqualTo(bill.syncGuid)
          .findAll();
      if (approvals.isEmpty) {
        throw const MedicalManagementException(
            'invalidStage', 'Review a zero-share approval first.');
      }
      approvals.sort((a, b) => a.revision.compareTo(b.revision));
      if (approvals.last.approvedShareMinor != 0) {
        throw const MedicalManagementException(
            'invalidStage', 'Review a zero-share approval first.');
      }
      final identity = _identity('caseComplete', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..insuranceRequestStatus = MedicalInsuranceRequestStatus.completed
        ..salarySettlementStatus = MedicalSalarySettlementStatus.notRequired
        ..settledAmountMinor = 0
        ..settledDate = _clock().toUtc()
        ..lastUpdatedAt = _clock()
        ..state = MedicalBillState.paid;
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'caseComplete',
        recordedAt: _clock(),
        identity: identity,
      );
      return bill;
    });
  }

  /// Records the provider returning the full charge in the actual month.
  Future<MedicalBill> recordProviderRefund({
    required int billId,
    required int amountMinor,
    required String actualMonth,
    required DateTime receivedDate,
    required String operationKey,
    required bool Function() isAccessCurrent,
    List<String> documentPaths = const [],
  }) async {
    _requireMonth(actualMonth);
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.paymentMethod != MedicalPaymentMethod.selfPaid) {
        throw const MedicalManagementException(
            'wrongPaymentModel', 'Provider refunds apply to user-paid bills.');
      }
      if (bill.providerPaymentStatus != MedicalProviderPaymentStatus.paid) {
        throw const MedicalManagementException(
            'invalidStage', 'Record the provider payment first.');
      }
      final expense = await _expense(bill);
      if (amountMinor != expense.amount || amountMinor <= 0) {
        throw const MedicalManagementException('partialNotSupported',
            'This version records the full provider refund only.');
      }
      final existing = await _db.reimbursements
          .filter()
          .expenseIdEqualTo(bill.linkedExpenseId)
          .findAll();
      if (existing.any(
          (row) => row.source == ReimbursementSource.medicalProviderRefund)) {
        throw const MedicalManagementException(
            'duplicateRefund', 'A provider refund is already recorded.');
      }
      final identity = _identity('providerRefund', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final row = Reimbursement(
        profileId: bill.profileId ?? expense.profileId,
        sharedSpaceId: bill.sharedSpaceId ?? expense.sharedSpaceId,
        expenseId: bill.linkedExpenseId,
        originYearMonth: bill.yearMonth,
        creditYearMonth: actualMonth,
        source: ReimbursementSource.medicalProviderRefund,
        amount: amountMinor,
        currency: expense.currency,
        date: receivedDate,
      );
      row.id = await AuditRepository(_db,
              recorder: _recorder, actorId: _actingProfileId)
          .put(_db.reimbursements, row, id: row.id, type: 'Reimbursement');
      await _recorder?.recordReimbursement(row);
      bill
        ..providerPaymentStatus = MedicalProviderPaymentStatus.refunded
        ..lastUpdatedAt = _clock()
        ..state = MedicalBillState.paid;
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'providerRefund',
        recordedAt: _clock(),
        transactionMonth: actualMonth,
        documentPaths: documentPaths,
        afterMinor: amountMinor,
        identity: identity,
      );
      return bill;
    });
  }

  /// Reopens a closed bill with a reason, preserving every original fact.
  Future<MedicalBill> reopenBill({
    required int billId,
    required String reason,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    if (reason.trim().isEmpty) {
      throw const MedicalManagementException(
          'reasonRequired', 'A reopen reason is required.');
    }
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      if (bill.overallStatus != MedicalOverallStatus.closed) {
        throw const MedicalManagementException(
            'invalidStage', 'Only a closed bill can be reopened.');
      }
      final identity = _identity('reopen', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..overallStatus = MedicalOverallStatus.open
        ..closedAt = null
        ..lastUpdatedAt = _clock()
        ..state = MedicalBillState.paid;
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'reopened',
        recordedAt: _clock(),
        reason: reason.trim(),
        identity: identity,
      );
      return bill;
    });
  }

  /// Corrects the latest refund, deduction or provider refund with a reversal
  /// and a replacement event.
  Future<MedicalBill> correctFinancialEvent({
    required int billId,
    required int newAmountMinor,
    required String actualMonth,
    required String reason,
    required String operationKey,
    required bool Function() isAccessCurrent,
    List<String> documentPaths = const [],
  }) async {
    _requireMonth(actualMonth);
    if (reason.trim().isEmpty) {
      throw const MedicalManagementException(
          'reasonRequired', 'A correction reason is required.');
    }
    if (newAmountMinor <= 0) {
      throw const MedicalManagementException(
          'invalidAmount', 'Enter a corrected amount greater than zero.');
    }
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.overallStatus != MedicalOverallStatus.open) {
        throw const MedicalManagementException(
            'invalidStage', 'Reopen the bill before correcting it.');
      }
      final identity = _identity('correction', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
      final expense = await _expense(bill);
      final reimbursement = await _db.reimbursements
          .filter()
          .expenseIdEqualTo(bill.linkedExpenseId)
          .findAll();
      final beforeAmount = bill.settledAmountMinor ??
          reimbursement.fold<int>(0, (sum, row) => sum + row.amount);
      final now = _clock();

      if (bill.providerPaymentStatus == MedicalProviderPaymentStatus.refunded) {
        if (newAmountMinor != expense.amount) {
          throw const MedicalManagementException('partialNotSupported',
              'The full provider refund only can be corrected.');
        }
        final row = reimbursement.firstWhere(
          (value) => value.source == ReimbursementSource.medicalProviderRefund,
          orElse: () => throw const MedicalManagementException(
              'eventMissing', 'The provider refund was not found.'),
        );
        row
          ..creditYearMonth = actualMonth
          ..amount = newAmountMinor;
        await AuditRepository(_db,
                recorder: _recorder, actorId: _actingProfileId)
            .put(_db.reimbursements, row, id: row.id, type: 'Reimbursement');
        await _recorder?.recordReimbursement(row);
      } else if (direct) {
        if (bill.salarySettlementType !=
                MedicalSalarySettlementType.userShareDeduction ||
            bill.salarySettlementStatus !=
                MedicalSalarySettlementStatus.deducted) {
          throw const MedicalManagementException(
              'eventMissing', 'No confirmed deduction to correct.');
        }
        await _writeApproval(
          bill,
          approvedBillMinor: bill.billedAmount,
          approvedShareMinor: newAmountMinor,
          approvedInsuranceMinor: bill.billedAmount - newAmountMinor,
          decisionDate: now,
          identity: identity,
          reason: reason,
        );
        expense
          ..amount = newAmountMinor
          ..status = ExpenseStatus.paid
          ..paidAt = now.toUtc()
          ..cashYearMonth = actualMonth;
        await _putExpense(expense);
        bill
          ..settledAmountMinor = newAmountMinor
          ..actualSalaryMonth = actualMonth
          ..settledDate = now.toUtc();
      } else {
        if (bill.salarySettlementType !=
                MedicalSalarySettlementType.insuranceRefund ||
            bill.salarySettlementStatus !=
                MedicalSalarySettlementStatus.received) {
          throw const MedicalManagementException(
              'eventMissing', 'No confirmed refund to correct.');
        }
        await _writeApproval(
          bill,
          approvedBillMinor: bill.billedAmount,
          approvedShareMinor: bill.billedAmount - newAmountMinor,
          approvedInsuranceMinor: newAmountMinor,
          decisionDate: now,
          identity: identity,
          reason: reason,
        );
        final row = reimbursement.firstWhere(
          (value) => value.source == ReimbursementSource.medicalInsurance,
          orElse: () => throw const MedicalManagementException(
              'eventMissing', 'The refund was not found.'),
        );
        row
          ..creditYearMonth = actualMonth
          ..amount = newAmountMinor
          ..originYearMonth = bill.yearMonth;
        await AuditRepository(_db,
                recorder: _recorder, actorId: _actingProfileId)
            .put(_db.reimbursements, row, id: row.id, type: 'Reimbursement');
        await _recorder?.recordReimbursement(row);
        bill
          ..reimbursedAmount = newAmountMinor
          ..settledAmountMinor = newAmountMinor
          ..actualSalaryMonth = actualMonth
          ..settledDate = now.toUtc();
      }

      final latest = await _db.medicalSettlements
          .filter()
          .billGuidEqualTo(bill.syncGuid)
          .findAll();
      latest.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      final original = latest.isEmpty ? null : latest.last;
      await _writeCorrectionSettlement(
        bill,
        expense,
        original: original,
        amountMinor: newAmountMinor,
        transactionMonth: actualMonth,
        reason: reason,
        identity: identity,
      );
      bill
        ..lastUpdatedAt = now
        ..state = MedicalBillState.paid;
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'correction',
        recordedAt: now,
        transactionMonth: actualMonth,
        reason: reason,
        documentPaths: documentPaths,
        beforeMinor: beforeAmount,
        afterMinor: newAmountMinor,
        identity: identity,
      );
      return bill;
    });
  }

  Future<MedicalBill> recordRefundReceived({
    required int billId,
    required int amountMinor,
    required String actualSalaryMonth,
    required DateTime receivedDate,
    required String operationKey,
    required bool Function() isAccessCurrent,
    List<String> documentPaths = const [],
  }) async {
    _requireMonth(actualSalaryMonth);
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.salarySettlementStatus !=
              MedicalSalarySettlementStatus.waitingForPayslip &&
          bill.salarySettlementStatus !=
              MedicalSalarySettlementStatus.notReceived) {
        throw const MedicalManagementException(
            'settlementNotWaiting', 'There is no refund awaiting receipt.');
      }
      if (bill.settlementAmountMinor == null ||
          amountMinor != bill.settlementAmountMinor) {
        throw const MedicalManagementException('partialNotSupported',
            'This version records the full approved refund only.');
      }
      final identity = _identity('refund', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final expense = await _expense(bill);
      final reimbursement = await _upsertRefund(
        bill,
        expense,
        amountMinor: amountMinor,
        actualSalaryMonth: actualSalaryMonth,
        date: receivedDate,
      );
      bill
        ..reimbursedAmount = amountMinor
        ..settledAmountMinor = amountMinor
        ..actualSalaryMonth = actualSalaryMonth
        ..settledDate = receivedDate.toUtc()
        ..salarySettlementStatus = MedicalSalarySettlementStatus.received
        ..insuranceRequestStatus = MedicalInsuranceRequestStatus.completed
        ..lastUpdatedAt = _clock()
        ..state = MedicalBillState.paid;
      await _putBill(bill);
      await _recorder?.recordReimbursement(reimbursement);
      await _activity(
        bill,
        kind: 'refundReceived',
        recordedAt: _clock(),
        transactionMonth: actualSalaryMonth,
        documentPaths: documentPaths,
        afterMinor: amountMinor,
        identity: identity,
      );
      return bill;
    });
  }

  Future<MedicalBill> recordNotReceived({
    required int billId,
    required String nextExpectedMonth,
    required String operationKey,
    required bool Function() isAccessCurrent,
    String? note,
  }) async {
    _requireMonth(nextExpectedMonth);
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      final identity = _identity('notReceived', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..salarySettlementStatus = MedicalSalarySettlementStatus.notReceived
        ..expectedSalaryMonth = nextExpectedMonth
        ..lastUpdatedAt = _clock();
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'refundNotReceived',
        recordedAt: _clock(),
        reason: note ?? '',
        identity: identity,
      );
      return bill;
    });
  }

  /// Revises the approved amount when the payslip shows a different full amount.
  Future<MedicalBill> resolveMismatch({
    required int billId,
    required int confirmedAmountMinor,
    required String reason,
    required String expectedSalaryMonth,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    _requireMonth(expectedSalaryMonth);
    if (reason.trim().isEmpty) {
      throw const MedicalManagementException(
          'reasonRequired', 'A reason is required.');
    }
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (confirmedAmountMinor <= 0 ||
          confirmedAmountMinor > bill.billedAmount) {
        throw const MedicalManagementException(
            'invalidAmount', 'The confirmed amount is invalid.');
      }
      final identity = _identity('mismatch', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final previousAmount = bill.settlementAmountMinor ?? 0;
      final now = _clock();
      final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
      final approvedShare = direct
          ? confirmedAmountMinor
          : bill.billedAmount - confirmedAmountMinor;
      final approvedInsurance = direct
          ? bill.billedAmount - confirmedAmountMinor
          : confirmedAmountMinor;
      await _writeApproval(
        bill,
        approvedBillMinor: bill.billedAmount,
        approvedShareMinor: approvedShare,
        approvedInsuranceMinor: approvedInsurance,
        decisionDate: now,
        identity: identity,
        reason: reason,
      );
      bill
        ..salarySettlementType = direct
            ? MedicalSalarySettlementType.userShareDeduction
            : MedicalSalarySettlementType.insuranceRefund
        ..settlementAmountMinor = confirmedAmountMinor
        ..expectedSalaryMonth = expectedSalaryMonth
        ..salarySettlementStatus =
            MedicalSalarySettlementStatus.waitingForPayslip
        ..lastUpdatedAt = now;
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'correction',
        recordedAt: now,
        reason: reason,
        beforeMinor: previousAmount,
        afterMinor: confirmedAmountMinor,
        identity: identity,
      );
      return bill;
    });
  }

  /// Accepts a user-paid rejection: no refund is expected.
  Future<MedicalBill> acceptRejection({
    required int billId,
    required DateTime decisionDate,
    required String operationKey,
    required bool Function() isAccessCurrent,
    List<String> documentPaths = const [],
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.paymentMethod != MedicalPaymentMethod.selfPaid ||
          bill.insuranceRequestStatus !=
              MedicalInsuranceRequestStatus.rejected) {
        throw const MedicalManagementException('invalidStage',
            'Only a rejected user-paid request can be accepted.');
      }
      final identity = _identity('acceptRejection', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..rejectionResolution = MedicalRejectionResolution.accepted
        ..salarySettlementStatus = MedicalSalarySettlementStatus.notRequired
        ..expectedSalaryMonth = null
        ..lastUpdatedAt = _clock();
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'rejectionAccepted',
        recordedAt: decisionDate.toUtc(),
        documentPaths: documentPaths,
        identity: identity,
      );
      return bill;
    });
  }

  /// Records one repeatable appeal attempt.
  Future<MedicalBill> recordAppeal({
    required int billId,
    required DateTime submittedAt,
    String? reference,
    DateTime? expectedResponseAt,
    String notes = '',
    List<String> documentPaths = const [],
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (!{
        MedicalInsuranceRequestStatus.rejected,
        MedicalInsuranceRequestStatus.appealRejected,
      }.contains(bill.insuranceRequestStatus)) {
        throw const MedicalManagementException(
            'invalidStage', 'An appeal needs a rejected request.');
      }
      final identity = _identity('appeal', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final shared = bill.sharedSpaceId != null;
      final appeal = MedicalAppeal()
        ..billGuid = bill.syncGuid
        ..profileId = shared ? null : bill.profileId
        ..sharedSpaceId = bill.sharedSpaceId
        ..submittedAt = submittedAt.toUtc()
        ..reference = reference
        ..expectedResponseAt = expectedResponseAt?.toUtc()
        ..notes = notes
        ..documentPaths = List.of(documentPaths)
        ..outcome = MedicalAppealOutcome.pending
        ..recordedAt = _clock().toUtc()
        ..actorId = _actingProfileId ?? bill.profileId ?? 0
        ..operationIdentity = identity;
      appeal.id = await AuditRepository(_db,
              recorder: _recorder, actorId: _actingProfileId)
          .put(_db.medicalAppeals, appeal,
              id: appeal.id, type: 'MedicalAppeal', derived: false);
      await _recorder?.recordMedicalAppeal(appeal);
      bill
        ..rejectionResolution = MedicalRejectionResolution.appeal
        ..insuranceRequestStatus = MedicalInsuranceRequestStatus.appealSubmitted
        ..lastUpdatedAt = _clock();
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'appealSubmitted',
        recordedAt: submittedAt.toUtc(),
        reference: reference,
        documentPaths: documentPaths,
        identity: identity,
      );
      return bill;
    });
  }

  Future<MedicalBill> recordAppealOutcome({
    required int billId,
    required bool approved,
    required DateTime decidedAt,
    required String operationKey,
    required bool Function() isAccessCurrent,
    List<String> documentPaths = const [],
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (!{
        MedicalInsuranceRequestStatus.appealSubmitted,
        MedicalInsuranceRequestStatus.appealInProgress,
      }.contains(bill.insuranceRequestStatus)) {
        throw const MedicalManagementException(
            'invalidStage', 'There is no appeal awaiting an outcome.');
      }
      final identity = _identity('appealOutcome', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final appeals = await _db.medicalAppeals
          .filter()
          .billGuidEqualTo(bill.syncGuid)
          .findAll();
      final pending = appeals
          .where((appeal) => appeal.outcome == MedicalAppealOutcome.pending)
          .toList()
        ..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
      if (pending.isEmpty) {
        throw const MedicalManagementException(
            'appealMissing', 'The pending appeal could not be found.');
      }
      final appeal = pending.last
        ..outcome = approved
            ? MedicalAppealOutcome.approved
            : MedicalAppealOutcome.rejected
        ..decidedAt = decidedAt.toUtc();
      await AuditRepository(_db, recorder: _recorder, actorId: _actingProfileId)
          .put(_db.medicalAppeals, appeal,
              id: appeal.id, type: 'MedicalAppeal', derived: false);
      await _recorder?.recordMedicalAppeal(appeal);
      bill
        ..insuranceRequestStatus = approved
            ? MedicalInsuranceRequestStatus.appealApproved
            : MedicalInsuranceRequestStatus.appealRejected
        ..lastUpdatedAt = _clock();
      if (!approved) {
        bill.salarySettlementStatus = MedicalSalarySettlementStatus.notRequired;
      }
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'appealDecided',
        recordedAt: decidedAt.toUtc(),
        documentPaths: documentPaths,
        identity: identity,
      );
      return bill;
    });
  }

  /// Cancels the request without reversing a provider payment.
  Future<MedicalBill> cancelRequest({
    required int billId,
    required DateTime cancelledAt,
    required String reason,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    if (reason.trim().isEmpty) {
      throw const MedicalManagementException(
          'reasonRequired', 'A cancellation reason is required.');
    }
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (!{
        MedicalInsuranceRequestStatus.notSubmitted,
        MedicalInsuranceRequestStatus.submitted,
        MedicalInsuranceRequestStatus.receiptPending,
        MedicalInsuranceRequestStatus.inProgress,
        MedicalInsuranceRequestStatus.approved,
        MedicalInsuranceRequestStatus.rejected,
        MedicalInsuranceRequestStatus.appealSubmitted,
        MedicalInsuranceRequestStatus.appealInProgress,
      }.contains(bill.insuranceRequestStatus)) {
        throw const MedicalManagementException(
            'invalidStage', 'This request cannot be cancelled.');
      }
      final identity = _identity('cancelRequest', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      bill
        ..insuranceRequestStatus =
            MedicalInsuranceRequestStatus.requestCancelled
        ..salarySettlementStatus = MedicalSalarySettlementStatus.notRequired
        ..expectedSalaryMonth = null
        ..lastUpdatedAt = _clock();
      await _putBill(bill);
      await _activity(
        bill,
        kind: 'requestCancelled',
        recordedAt: cancelledAt.toUtc(),
        reason: reason,
        identity: identity,
      );
      return bill;
    });
  }

  /// Resolves an insurance-paid rejection or cancelled request.
  Future<MedicalBill> resolveInsurancePaidRejection({
    required int billId,
    required MedicalRejectionResolution resolution,
    required String operationKey,
    required bool Function() isAccessCurrent,
    String reason = '',
    int? amountMinor,
    DateTime? paymentDate,
    String? paymentMonth,
    String? expectedSalaryMonth,
    List<String> documentPaths = const [],
  }) async {
    if (resolution == MedicalRejectionResolution.none ||
        resolution == MedicalRejectionResolution.accepted) {
      throw const MedicalManagementException(
          'invalidResolution', 'Choose a valid insurance-paid resolution.');
    }
    if (paymentMonth != null) _requireMonth(paymentMonth);
    if (expectedSalaryMonth != null) _requireMonth(expectedSalaryMonth);
    if (resolution == MedicalRejectionResolution.other &&
        reason.trim().isEmpty) {
      throw const MedicalManagementException(
          'reasonRequired', 'A reason is required.');
    }
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      if (bill.paymentMethod != MedicalPaymentMethod.insurerPaid) {
        throw const MedicalManagementException('wrongPaymentModel',
            'This resolution is for insurance-paid bills.');
      }
      if (!{
        MedicalInsuranceRequestStatus.rejected,
        MedicalInsuranceRequestStatus.requestCancelled,
      }.contains(bill.insuranceRequestStatus)) {
        throw const MedicalManagementException(
            'invalidStage', 'There is no rejection to resolve.');
      }
      final identity =
          _identity('resolution:${resolution.name}', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final expense = await _expense(bill);

      switch (resolution) {
        case MedicalRejectionResolution.providerCancelled:
          bill
            ..rejectionResolution = resolution
            ..overallStatus = MedicalOverallStatus.cancelled
            ..closedAt = _clock()
            ..closeReason = reason
            ..lastUpdatedAt = _clock()
            ..state = MedicalBillState.finished;
          await _putBill(bill);
          break;
        case MedicalRejectionResolution.userPaidProvider:
          if (amountMinor == null ||
              amountMinor <= 0 ||
              paymentDate == null ||
              paymentMonth == null) {
            throw const MedicalManagementException(
                'invalidAmount', 'Enter the payment details.');
          }
          expense
            ..amount = amountMinor
            ..status = ExpenseStatus.paid
            ..paidAt = paymentDate.toUtc()
            ..cashYearMonth = paymentMonth
            ..isReimbursable = false;
          await _putExpense(expense);
          bill
            ..rejectionResolution = resolution
            ..providerPaymentStatus = MedicalProviderPaymentStatus.paid
            ..salarySettlementStatus = MedicalSalarySettlementStatus.notRequired
            ..lastUpdatedAt = _clock()
            ..state = MedicalBillState.paid;
          await _putBill(bill);
          break;
        case MedicalRejectionResolution.adjustedDeduction:
          final share = amountMinor ?? bill.patientShareAmount;
          if (share <= 0 || expectedSalaryMonth == null) {
            throw const MedicalManagementException(
                'invalidAmount', 'Enter the adjusted share and month.');
          }
          bill
            ..rejectionResolution = resolution
            ..salarySettlementType =
                MedicalSalarySettlementType.userShareDeduction
            ..settlementAmountMinor = share
            ..expectedSalaryMonth = expectedSalaryMonth
            ..salarySettlementStatus =
                MedicalSalarySettlementStatus.waitingForPayslip
            ..lastUpdatedAt = _clock();
          await _putBill(bill);
          break;
        case MedicalRejectionResolution.appeal:
          // The caller opens the appeal form; this resolution only records the
          // choice so the rejection is not silently closed.
          bill
            ..rejectionResolution = resolution
            ..lastUpdatedAt = _clock();
          await _putBill(bill);
          break;
        case MedicalRejectionResolution.other:
          bill
            ..rejectionResolution = resolution
            ..salarySettlementStatus = MedicalSalarySettlementStatus.notRequired
            ..lastUpdatedAt = _clock();
          await _putBill(bill);
          break;
        case MedicalRejectionResolution.none:
        case MedicalRejectionResolution.accepted:
          break;
      }

      await _activity(
        bill,
        kind: 'rejectionResolved',
        recordedAt: _clock(),
        reason: reason,
        documentPaths: documentPaths,
        identity: identity,
      );
      return bill;
    });
  }

  Future<MedicalBill> closeBill({
    required int billId,
    required String operationKey,
    required bool Function() isAccessCurrent,
    String reason = '',
  }) async {
    return _db.writeTxn(() async {
      final bill = await requireBill(billId, isAccessCurrent: isAccessCurrent);
      ensureOpen(bill);
      final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
      final requestResolved = bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.completed ||
          bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.requestCancelled ||
          (bill.insuranceRequestStatus ==
                  MedicalInsuranceRequestStatus.rejected &&
              bill.rejectionResolution != MedicalRejectionResolution.none) ||
          bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.appealRejected;
      if (!requestResolved) {
        throw const MedicalManagementException(
            'unresolvedClosure', 'Resolve the request before closing.');
      }
      if (direct &&
          bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.requestCancelled &&
          bill.rejectionResolution == MedicalRejectionResolution.none) {
        throw const MedicalManagementException(
            'unresolvedClosure', 'Resolve the remaining charge first.');
      }
      final finalRejection = bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.rejected ||
          bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.appealRejected ||
          bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.requestCancelled;
      final settled = direct
          ? {
              MedicalSalarySettlementStatus.deducted,
              MedicalSalarySettlementStatus.notRequired,
            }.contains(bill.salarySettlementStatus)
          : finalRejection ||
              bill.salarySettlementStatus ==
                  MedicalSalarySettlementStatus.received;
      if (!settled) {
        throw MedicalManagementException(
            'unresolvedClosure',
            direct
                ? 'Confirm the salary deduction before closing.'
                : 'Confirm the refund before closing.');
      }
      final identity = _identity('close', bill, operationKey);
      if (await _activityExists(identity)) return bill;
      final now = _clock();
      bill
        ..overallStatus = MedicalOverallStatus.closed
        ..closedAt = now
        ..closeReason = reason
        ..lastUpdatedAt = now
        ..state = MedicalBillState.finished;
      await _putBill(bill);
      await _writeClosure(bill, reason: reason, identity: identity);
      await _activity(
        bill,
        kind: 'closed',
        recordedAt: now,
        reason: reason,
        identity: identity,
      );
      return bill;
    });
  }

  /// Appends one management activity. Status-only events use this helper.
  Future<MedicalClaimActivity> appendActivity({
    required MedicalBill bill,
    required String kind,
    required DateTime recordedAt,
    required bool Function() isAccessCurrent,
    String reason = '',
    String? transactionMonth,
    List<String> documentPaths = const [],
    String? reference,
    String currency = '',
    int beforeMinor = 0,
    int afterMinor = 0,
  }) async {
    if (!isAccessCurrent()) {
      throw const MedicalManagementException(
          'accessChanged', 'Access changed. Reopen this bill.');
    }
    final shared = bill.sharedSpaceId != null;
    final row = MedicalClaimActivity()
      ..billGuid = bill.syncGuid
      ..profileId = shared ? 0 : (bill.profileId ?? 0)
      ..sharedSpaceId = bill.sharedSpaceId
      ..yearMonth = bill.yearMonth
      ..kind = kind
      ..reason = reason
      ..transactionMonth = transactionMonth
      ..documentPaths = List.of(documentPaths)
      ..reference = reference
      ..currency = currency
      ..beforeMinor = beforeMinor
      ..afterMinor = afterMinor
      ..recordedAt = recordedAt
      ..actorId = _actingProfileId ?? bill.profileId ?? 0
      ..operationIdentity =
          'medical:$kind:${bill.syncGuid}:${recordedAt.microsecondsSinceEpoch}'
      ..inputFingerprint = '${bill.syncGuid}:$kind:${bill.lastUpdatedAt}';
    await _db.writeTxn(() async {
      row.id = await _db.medicalClaimActivitys.put(row);
    });
    await _recorder?.recordMedicalClaimActivity(row);
    return row;
  }

  Future<Expense> _expense(MedicalBill bill) async {
    final id = bill.linkedExpenseId;
    if (id == null) {
      throw const MedicalManagementException(
          'expenseMissing', 'The bill has no linked expense.');
    }
    final expense = await _db.expenses.get(id);
    if (expense == null) {
      throw const MedicalManagementException(
          'expenseMissing', 'The linked expense no longer exists.');
    }
    return expense;
  }

  Future<void> _putExpense(Expense expense) async {
    await _db.expenses.put(expense);
    await _recorder?.recordExpense(expense);
  }

  Future<void> _putBill(MedicalBill bill) async {
    await _db.medicalBills.put(bill);
    await _recorder?.recordMedicalBill(bill);
  }

  Future<void> _writeApproval(
    MedicalBill bill, {
    required int approvedBillMinor,
    required int approvedShareMinor,
    required int approvedInsuranceMinor,
    required DateTime decisionDate,
    required String identity,
    String reason = '',
  }) async {
    final existing = await _db.medicalApprovals
        .filter()
        .operationIdentityEqualTo(identity)
        .findFirst();
    if (existing != null) return;
    final previous = await _db.medicalApprovals
        .filter()
        .billGuidEqualTo(bill.syncGuid)
        .findAll();
    previous.sort((a, b) => a.revision.compareTo(b.revision));
    final row = MedicalApproval()
      ..billGuid = bill.syncGuid
      ..profileId = bill.profileId
      ..sharedSpaceId = bill.sharedSpaceId
      ..yearMonth = bill.yearMonth
      ..approvedMinor = approvedInsuranceMinor
      ..approvedBillMinor = approvedBillMinor
      ..approvedShareMinor = approvedShareMinor
      ..approvedInsuranceMinor = approvedInsuranceMinor
      ..expectedBillMinor = bill.billedAmount
      ..expectedShareMinor = bill.patientShareAmount
      ..expectedInsuranceMinor = bill.insurerPaidAmount
      ..currency = bill.currency
      ..decisionDate = decisionDate.toUtc()
      ..recordedAt = _clock().toUtc()
      ..actorId = _actingProfileId ?? bill.profileId ?? 0
      ..revision = (previous.isEmpty ? 0 : previous.last.revision) + 1
      ..previousGuid = previous.isEmpty ? null : previous.last.syncGuid
      ..operationIdentity = identity
      ..inputFingerprint = medicalBillBasis(bill)
      ..basisJson = bill.sharedSpaceId == null ? medicalBillBasis(bill) : null;
    row.id = await AuditRepository(_db,
            recorder: _recorder, actorId: _actingProfileId)
        .put(_db.medicalApprovals, row,
            id: row.id, type: 'MedicalApproval', derived: false);
    await _recorder?.recordMedicalApproval(row);
  }

  Future<void> _writeClosure(
    MedicalBill bill, {
    required String reason,
    required String identity,
  }) async {
    final approval = await _db.medicalApprovals
        .filter()
        .billGuidEqualTo(bill.syncGuid)
        .findAll();
    if (approval.isEmpty) return;
    approval.sort((a, b) => a.revision.compareTo(b.revision));
    final row = MedicalClaimClosure()
      ..billGuid = bill.syncGuid
      ..approvalGuid = approval.last.syncGuid
      ..profileId = bill.profileId
      ..sharedSpaceId = bill.sharedSpaceId
      ..yearMonth = bill.yearMonth
      ..receivedMinor = bill.settledAmountMinor ?? 0
      ..shortfallMinor = 0
      ..currency = bill.currency
      ..reason = reason
      ..actorId = _actingProfileId ?? bill.profileId ?? 0
      ..recordedAt = _clock().toUtc()
      ..operationIdentity = '$identity:closure';
    await AuditRepository(_db, recorder: _recorder, actorId: _actingProfileId)
        .put(_db.medicalClaimClosures, row,
            id: row.id, type: 'MedicalClaimClosure', derived: false);
  }

  Future<void> _writeShareSettlement(
    MedicalBill bill,
    Expense expense, {
    required int amountMinor,
    required String transactionMonth,
    required DateTime effectiveDate,
    required String identity,
  }) async {
    final event = MedicalSettlementEvent()
      ..profileId = bill.profileId
      ..billGuid = bill.syncGuid
      ..kind = MedicalSettlementKind.shareSettlement
      ..confirmed = true
      ..effectiveDate = effectiveDate.toUtc()
      ..recordedAt = _clock().toUtc()
      ..transactionMonth = transactionMonth
      ..currency = expense.currency
      ..amountMinor = amountMinor
      ..basisJson = medicalBillBasis(bill)
      ..expenseId = expense.id
      ..expenseGuid = expense.syncGuid
      ..reason = ''
      ..actorId = _actingProfileId ?? bill.profileId ?? 0
      ..operationIdentity = identity
      ..inputFingerprint = medicalBillBasis(bill);
    await AuditRepository(_db, recorder: _recorder, actorId: _actingProfileId)
        .put(_db.medicalSettlements, event,
            id: event.id, type: 'MedicalSettlementEvent', derived: false);
  }

  Future<void> _writeCorrectionSettlement(
    MedicalBill bill,
    Expense expense, {
    required MedicalSettlementEvent? original,
    required int amountMinor,
    required String transactionMonth,
    required String reason,
    required String identity,
  }) async {
    final reversal = MedicalSettlementEvent()
      ..profileId = bill.profileId
      ..billGuid = bill.syncGuid
      ..kind = MedicalSettlementKind.reversal
      ..confirmed = true
      ..effectiveDate = _clock().toUtc()
      ..recordedAt = _clock().toUtc()
      ..transactionMonth = transactionMonth
      ..currency = expense.currency
      ..amountMinor = 0
      ..basisJson = medicalBillBasis(bill)
      ..expenseId = expense.id
      ..expenseGuid = expense.syncGuid
      ..supersedesGuid = original?.syncGuid
      ..reason = reason
      ..actorId = _actingProfileId ?? bill.profileId ?? 0
      ..operationIdentity = '$identity:reversal'
      ..inputFingerprint = medicalBillBasis(bill);
    await AuditRepository(_db, recorder: _recorder, actorId: _actingProfileId)
        .put(_db.medicalSettlements, reversal,
            id: reversal.id, type: 'MedicalSettlementEvent', derived: false);

    final corrected = MedicalSettlementEvent()
      ..profileId = bill.profileId
      ..billGuid = bill.syncGuid
      ..kind = MedicalSettlementKind.correction
      ..confirmed = true
      ..effectiveDate = _clock().toUtc()
      ..recordedAt = _clock().toUtc()
      ..transactionMonth = transactionMonth
      ..currency = expense.currency
      ..amountMinor = amountMinor
      ..basisJson = medicalBillBasis(bill)
      ..expenseId = expense.id
      ..expenseGuid = expense.syncGuid
      ..supersedesGuid = original?.syncGuid
      ..reason = reason
      ..actorId = _actingProfileId ?? bill.profileId ?? 0
      ..operationIdentity = '$identity:corrected'
      ..inputFingerprint = medicalBillBasis(bill);
    await AuditRepository(_db, recorder: _recorder, actorId: _actingProfileId)
        .put(_db.medicalSettlements, corrected,
            id: corrected.id, type: 'MedicalSettlementEvent', derived: false);

    if (original != null) {
      original.correctedByGuid = corrected.syncGuid;
      await AuditRepository(_db, recorder: _recorder, actorId: _actingProfileId)
          .put(_db.medicalSettlements, original,
              id: original.id, type: 'MedicalSettlementEvent', derived: false);
    }
  }

  Future<Reimbursement> _upsertRefund(
    MedicalBill bill,
    Expense expense, {
    required int amountMinor,
    required String actualSalaryMonth,
    required DateTime date,
  }) async {
    final existing = await _db.reimbursements
        .filter()
        .expenseIdEqualTo(bill.linkedExpenseId)
        .findAll();
    final row = existing.isEmpty
        ? Reimbursement(
            profileId: bill.profileId ?? expense.profileId,
            sharedSpaceId: bill.sharedSpaceId ?? expense.sharedSpaceId,
            expenseId: bill.linkedExpenseId,
            originYearMonth: bill.yearMonth,
            creditYearMonth: actualSalaryMonth,
            source: ReimbursementSource.medicalInsurance,
            amount: amountMinor,
            currency: expense.currency,
            date: date,
          )
        : (existing.first
          ..originYearMonth = bill.yearMonth
          ..creditYearMonth = actualSalaryMonth
          ..source = ReimbursementSource.medicalInsurance
          ..amount = amountMinor
          ..currency = expense.currency
          ..date = date);
    row.id = await AuditRepository(_db,
            recorder: _recorder, actorId: _actingProfileId)
        .put(_db.reimbursements, row, id: row.id, type: 'Reimbursement');
    return row;
  }

  Future<void> _activity(
    MedicalBill bill, {
    required String kind,
    required DateTime recordedAt,
    required String identity,
    String? transactionMonth,
    String? reference,
    String reason = '',
    List<String> documentPaths = const [],
    int beforeMinor = 0,
    int afterMinor = 0,
  }) async {
    final shared = bill.sharedSpaceId != null;
    final row = MedicalClaimActivity()
      ..billGuid = bill.syncGuid
      ..profileId = shared ? 0 : (bill.profileId ?? 0)
      ..sharedSpaceId = bill.sharedSpaceId
      ..yearMonth = bill.yearMonth
      ..kind = kind
      ..reason = reason
      ..transactionMonth = transactionMonth
      ..documentPaths = List.of(documentPaths)
      ..reference = reference
      ..currency = bill.currency
      ..beforeMinor = beforeMinor
      ..afterMinor = afterMinor
      ..recordedAt = recordedAt.toUtc()
      ..actorId = _actingProfileId ?? bill.profileId ?? 0
      ..operationIdentity = identity
      ..inputFingerprint = medicalBillBasis(bill);
    row.id = await AuditRepository(_db,
            recorder: _recorder, actorId: _actingProfileId)
        .put(_db.medicalClaimActivitys, row,
            id: row.id, type: 'MedicalClaimActivity', derived: false);
    await _recorder?.recordMedicalClaimActivity(row);
  }

  Future<bool> _activityExists(String identity) async {
    final row = await _db.medicalClaimActivitys
        .filter()
        .operationIdentityEqualTo(identity)
        .findFirst();
    return row != null;
  }

  String _identity(String kind, MedicalBill bill, String operationKey) {
    final key = operationKey.trim();
    if (key.isEmpty || key.length > 128) {
      throw const MedicalManagementException(
          'invalidOperation', 'Invalid operation key.');
    }
    return 'medical:$kind:${bill.syncGuid}:$key';
  }

  void _requireMonth(String value) {
    if (!RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$').hasMatch(value)) {
      throw const MedicalManagementException(
          'invalidMonth', 'Choose a valid month.');
    }
  }

  bool _canSee(MedicalBill bill) {
    if (bill.sharedSpaceId != null) {
      return _actingProfileId != null;
    }
    return _actingProfileId != null && bill.profileId == _actingProfileId;
  }
}
