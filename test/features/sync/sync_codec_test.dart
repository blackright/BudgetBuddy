import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/family_member_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/insurance_profile_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_bill_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_provider_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_service_type_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/monthly_budget_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/reimbursement_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/shared_member_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/shared_space_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// A full, non-default sample of every field, so a dropped field fails loudly.
SharedSpace _space() => SharedSpace()
  ..id = 7
  ..name = 'Home'
  ..avatar = '🏠'
  ..currency = PrimaryCurrency.usd
  ..defaultIncome = 250000
  ..createdByProfileId = 3
  ..createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5);

SharedMember _member() => SharedMember()
  ..id = 11
  ..sharedSpaceId = 7
  ..profileId = 3
  ..role = SharedMemberRole.editor
  ..joinedAt = DateTime.utc(2026, 1, 2, 3, 4, 5)
  ..version = 4
  ..updatedAt = DateTime.utc(2026, 2, 3, 4, 5, 6)
  ..authorIdentityId = 'fp-abc'
  ..signature = 'sig-xyz'
  ..revokedAt = DateTime.utc(2026, 3, 4, 5, 6, 7);

MonthlyBudget _budget() => MonthlyBudget()
  ..id = 21
  ..yearMonth = '2026-03'
  ..sharedSpaceId = 7
  ..sharedIncomeOverride = 300000
  ..baseAvailableAmount = 12345.67
  ..openingBalanceConfirmed = true
  ..currency = 'usd'
  ..createdAt = DateTime.utc(2026, 3, 1)
  ..updatedAt = DateTime.utc(2026, 3, 2);

Expense _expense() => Expense(
      id: 31,
      profileId: 3,
      sharedSpaceId: 7,
      yearMonth: '2026-03',
      type: ExpenseType.standard,
      title: 'Groceries',
      amount: 54321,
      currency: 'usd',
      categoryId: 'food',
      status: ExpenseStatus.paid,
      isReimbursable: true,
      guiltLevel: GuiltLevel.essential,
      date: DateTime.utc(2026, 3, 5, 6, 7, 8),
      receiptPath: '/receipts/r.jpg',
      notes: 'weekly shop',
      budgetId: 21,
      paidAt: DateTime.utc(2026, 3, 6),
    );

Reimbursement _reimbursement() => Reimbursement(
      id: 41,
      profileId: 3,
      sharedSpaceId: 7,
      expenseId: 31,
      originYearMonth: '2026-03',
      orphaned: false,
      amount: 1234,
      currency: 'usd',
      date: DateTime.utc(2026, 3, 10),
      note: 'insurer refund',
    );

MedicalBill _bill() => MedicalBill()
  ..id = 51
  ..sharedSpaceId = 7
  ..linkedExpenseId = 31
  ..familyMemberId = 61
  ..providerId = 71
  ..serviceTypeId = 81
  ..paymentMethod = MedicalPaymentMethod.selfPaid
  ..patientSharePercent = 25.0
  ..state = MedicalBillState.waiting
  ..yearMonth = '2026-03'
  ..serviceDate = DateTime.utc(2026, 3, 5)
  ..billedAmount = 99999
  ..currency = 'usd'
  ..billPhotoPath = '/bills/b.jpg'
  ..insurerReplyPath = '/bills/i.pdf'
  ..followUpDate = DateTime.utc(2026, 4, 1)
  ..calendarEventId = 'evt-1'
  ..reimbursedAmount = 5000;

FamilyMember _familyMember() => FamilyMember()
  ..id = 61
  ..sharedSpaceId = 7
  ..name = 'Kid'
  ..relation = 'Child';

MedicalProvider _provider() => MedicalProvider()
  ..id = 71
  ..sharedSpaceId = 7
  ..name = 'Dr. Smith'
  ..specialty = 'Cardiology'
  ..autoCreated = false;

MedicalServiceType _serviceType() => MedicalServiceType()
  ..id = 81
  ..sharedSpaceId = 7
  ..name = 'Lab Work'
  ..isDefault = true
  ..sortOrder = 2
  ..archived = false;

InsuranceProfile _insuranceProfile() => InsuranceProfile()
  ..id = 91
  ..sharedSpaceId = 7
  ..defaultPatientPercent = 30.0
  ..insurerName = 'Blue Cross'
  ..planName = 'PPO 500';

/// Encodes, decodes and re-encodes; a lossless codec reproduces the payload.
void expectLossless<T>(SyncCodec<T> codec, T entity) {
  final payload = codec.toPayload(entity);
  final decoded = codec.fromPayload(payload);
  expect(codec.toPayload(decoded), payload,
      reason: '${codec.entityType} round-trip changed the canonical payload');
}

void main() {
  group('SyncCodec round-trip is lossless (FR-010)', () {
    test('SharedSpace',
        () => expectLossless(const SharedSpaceCodec(), _space()));
    test('SharedMember',
        () => expectLossless(const SharedMemberCodec(), _member()));
    test('MonthlyBudget',
        () => expectLossless(const MonthlyBudgetCodec(), _budget()));
    test('Expense', () => expectLossless(const ExpenseCodec(), _expense()));
    test('Reimbursement',
        () => expectLossless(const ReimbursementCodec(), _reimbursement()));
    test(
        'MedicalBill', () => expectLossless(const MedicalBillCodec(), _bill()));
    test('FamilyMember',
        () => expectLossless(const FamilyMemberCodec(), _familyMember()));
    test('MedicalProvider',
        () => expectLossless(const MedicalProviderCodec(), _provider()));
    test('MedicalServiceType',
        () => expectLossless(const MedicalServiceTypeCodec(), _serviceType()));
    test(
        'InsuranceProfile',
        () =>
            expectLossless(const InsuranceProfileCodec(), _insuranceProfile()));
  });

  group('money fields survive byte-for-byte (FR-015, data-model §4.3)', () {
    test('whole minor units decode back to the same int', () {
      final expense = _expense();
      final decodedExpense = const ExpenseCodec()
          .fromPayload(const ExpenseCodec().toPayload(expense));
      expect(decodedExpense.amount, expense.amount);

      final reimbursement = _reimbursement();
      final decodedReimbursement = const ReimbursementCodec()
          .fromPayload(const ReimbursementCodec().toPayload(reimbursement));
      expect(decodedReimbursement.amount, reimbursement.amount);

      final bill = _bill();
      final decodedBill = const MedicalBillCodec()
          .fromPayload(const MedicalBillCodec().toPayload(bill));
      expect(decodedBill.billedAmount, bill.billedAmount);
      expect(decodedBill.reimbursedAmount, bill.reimbursedAmount);

      final space = _space();
      final decodedSpace = const SharedSpaceCodec()
          .fromPayload(const SharedSpaceCodec().toPayload(space));
      expect(decodedSpace.defaultIncome, space.defaultIncome);
    });

    test('the opening balance double is preserved exactly', () {
      final budget = _budget();
      final decoded = const MonthlyBudgetCodec()
          .fromPayload(const MonthlyBudgetCodec().toPayload(budget));
      expect(decoded.baseAvailableAmount, budget.baseAvailableAmount);
    });
  });

  group('the registry covers exactly the exchanged entity types', () {
    test('every codec entity type resolves, an unknown one does not', () {
      for (final codec in syncCodecs) {
        expect(codecForEntityType(codec.entityType), isNotNull,
            reason: '${codec.entityType} should resolve');
      }
      expect(codecForEntityType('NotAThing'), isNull);
      expect(syncCodecs, hasLength(10));
    });
  });
}
