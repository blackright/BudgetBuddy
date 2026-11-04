import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_form.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import '../../support/receipt_financial_harness.dart';

class _Session extends DeviceAuthSession {
  @override
  NativeAuthSnapshot build() => const NativeAuthSnapshot(
      generation: 1,
      binding: NativeAccessBinding(key: 'phase-b-fixture'),
      authenticated: true);
  @override
  bool isCurrent(int generation) =>
      generation == state.generation && state.authenticated;
}

class _Lock extends LockController {
  @override
  LockSnapshot build() => const LockSnapshot();
}

class _Repository extends MedicalRepository {
  _Repository(super.db, {required super.actingProfileId});
  Completer<void>? saved;
  Completer<void>? historyLoaded;
  @override
  Future<MedicalReceiptHistory> receiptHistory(int billId,
      {required bool Function() isAccessCurrent}) async {
    final result =
        await super.receiptHistory(billId, isAccessCurrent: isAccessCurrent);
    historyLoaded?.complete();
    return result;
  }

  @override
  Future<MedicalBill> saveBill(MedicalBill bill, MedicalBillContext context,
      {ExpenseStatus? status, bool Function()? isAccessCurrent}) async {
    try {
      final result = await super.saveBill(bill, context,
          status: status, isAccessCurrent: isAccessCurrent);
      saved?.complete();
      return result;
    } catch (error, stack) {
      saved?.completeError(error, stack);
      rethrow;
    }
  }
}

void main() {
  late ReceiptFinancialHarness h;
  late _Repository repository;
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    IsarHelper.instance = h.db;
  });
  tearDown(() async {
    await h.close();
  });

  Future<void> pump(
    WidgetTester tester, {
    MedicalBill? bill,
    InsuranceProfile? defaultProfile,
    Stream<InsuranceProfile?>? defaultStream,
    List<MedicalProvider> providers = const [],
    List<FamilyMember> members = const [],
    List<MedicalServiceType> serviceTypes = const [],
    double textScale = 1,
    ThemeMode theme = ThemeMode.light,
  }) async {
    final profile = h.db.userProfiles.getSync(h.ownerId);
    repository = _Repository(h.db, actingProfileId: h.ownerId);
    final router = GoRouter(initialLocation: '/bill', routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('Saved home')),
          routes: [
            GoRoute(
                path: 'bill',
                builder: (_, __) => Consumer(builder: (context, ref, child) {
                      // The app shell holds this stream open; preserve that real entry
                      // condition in the isolated form fixture too.
                      ref.watch(activeProfileProvider);
                      return MedicalBillForm(existingBill: bill);
                    }))
          ]),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
          activeProfileIdProvider.overrideWith((ref) => h.ownerId),
          actingProfileIdProvider.overrideWithValue(h.ownerId),
          activeSpaceIdProvider.overrideWith((ref) => null),
          activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
          budgetContextProvider.overrideWithValue(h.context()),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          medicalBillContextProvider.overrideWithValue(MedicalBillContext(
              profileId: h.ownerId,
              budgetId: h.budgetId,
              yearMonth: '2026-10',
              primaryCurrency: 'huf')),
          medicalRepositoryProvider.overrideWithValue(repository),
          medicalProvidersProvider
              .overrideWith((ref) => Stream.value(providers)),
          familyMembersProvider.overrideWith((ref) => Stream.value(members)),
          medicalServiceTypesProvider
              .overrideWith((ref) => Stream.value(serviceTypes)),
          insuranceProfileProvider.overrideWith(
              (ref) => defaultStream ?? Stream.value(defaultProfile)),
          deviceAuthSessionProvider.overrideWith(_Session.new),
          lockControllerProvider.overrideWith(_Lock.new),
        ],
        child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: theme,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!))));
    await tester.pumpAndSettle();
  }

  /// Seeds the directory the way the app would, then hands the rows to the form.
  Future<
      ({
        MedicalProvider provider,
        FamilyMember member,
        MedicalServiceType service,
      })> seedDirectory(WidgetTester tester) async {
    final result = await tester.runAsync(() async {
      final repo = MedicalRepository(h.db, actingProfileId: h.ownerId);
      final provider = await repo.findOrCreateProvider(
          profileId: h.ownerId, name: 'Dr Phase C');
      final member = await repo.saveFamilyMember(
          profileId: h.ownerId, name: 'Alex', relation: 'Family');
      final service = await repo.saveServiceType(
          profileId: h.ownerId, name: 'Phase C Service');
      return (provider: provider, member: member, service: service);
    });
    return result!;
  }

  Future<void> chooseInsurer(WidgetTester tester) async {
    final target = find.text('Insurance pays the provider');
    final scrollable = find.byType(Scrollable).first;
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(target, 250, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> chooseSelfPay(WidgetTester tester) async {
    final target = find.text('I pay the provider');
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(target, -250,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> fillAmount(WidgetTester tester,
      {String amount = '10000'}) async {
    final field = find.descendant(
        of: find.byKey(const Key('medicalBilledAmountField')),
        matching: find.byType(TextFormField));
    if (field.evaluate().isEmpty) {
      await tester.scrollUntilVisible(field, -250,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(field);
    await tester.enterText(field, amount);
    await tester.pump();
  }

  Future<void> fillCoverage(WidgetTester tester, String value) async {
    final field = find.byKey(const Key('insuranceCoverageField'));
    if (field.evaluate().isEmpty) {
      await tester.scrollUntilVisible(field, -250,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    await tester.pump();
  }

  Future<void> openSection(WidgetTester tester, String title) async {
    const markers = {
      'Bill details': 'insuranceCoverageField',
      'Provider & person': 'providerField',
      'Dates & reminders': 'budgetPeriodField',
      'Documents': 'billPhotoTile',
    };
    final marker = markers[title];
    if (marker != null && find.byKey(Key(marker)).evaluate().isNotEmpty) {
      return; // already expanded
    }
    final header = find.text(title);
    await tester.scrollUntilVisible(header, 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    // Invoke the ExpansionTile header directly: tapping by coordinates can land
    // on the sticky Save bar when the section sits at the bottom edge.
    final tile = tester.widget<ListTile>(
        find.ancestor(of: header, matching: find.byType(ListTile)).first);
    tile.onTap?.call();
    await tester.pumpAndSettle();
  }

  Future<void> pickOption(
      WidgetTester tester, String fieldKey, String option) async {
    final field = find.byKey(Key(fieldKey));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(option).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectDirectory(
    WidgetTester tester,
    ({
      MedicalProvider provider,
      FamilyMember member,
      MedicalServiceType service,
    }) directory,
  ) async {
    await openSection(tester, 'Provider & person');
    await pickOption(tester, 'providerField', directory.provider.name);
    await pickOption(tester, 'serviceTypeField', directory.service.name);
    await pickOption(tester, 'patientField', directory.member.name);
  }

  Future<void> save(WidgetTester tester, {bool expectSave = true}) async {
    if (expectSave) {
      await tester.runAsync(() async {
        repository.saved = Completer<void>();
        await tester.tap(find.byTooltip('Save'));
        await repository.saved!.future.timeout(const Duration(seconds: 5),
            onTimeout: () {
          fail(
              'Save did not reach the repository: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).join(' | ')}');
        });
        // Let the post-save reminder write complete on the real event loop.
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      for (var attempt = 0;
          attempt < 40 && find.text('Saved home').evaluate().isEmpty;
          attempt++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
      }
    } else {
      await tester.tap(find.byTooltip('Save'));
    }
    await tester.pumpAndSettle();
  }

  Future<MedicalBill> existing(
    WidgetTester tester, {
    String? reply,
    MedicalBillState state = MedicalBillState.paid,
  }) async {
    return (await tester.runAsync(() =>
        MedicalRepository(h.db, actingProfileId: h.ownerId).saveBill(
            MedicalBill()
              ..profileId = h.ownerId
              ..yearMonth = '2026-10'
              ..currency = 'huf'
              ..billedAmount = 10000
              ..patientSharePercent = 20
              ..state = state
              ..serviceDate = DateTime(2026, 10, 12)
              ..insurerReplyPath = reply,
            MedicalBillContext(
                profileId: h.ownerId,
                budgetId: h.budgetId,
                yearMonth: '2026-10',
                primaryCurrency: 'huf'),
            status: ExpenseStatus.paid,
            isAccessCurrent: () => true)))!;
  }

  testWidgets('creation shows planning fields and no lifecycle controls',
      (tester) async {
    await pump(tester);
    expect(find.text('Who pays the provider?'), findsOneWidget);
    expect(find.text('I pay the provider'), findsOneWidget);
    expect(find.text('Insurance pays the provider'), findsOneWidget);
    expect(find.byKey(const Key('insuranceCoverageField')), findsOneWidget);
    expect(find.byKey(const Key('providerPaidQuestion')), findsNothing);
    expect(find.byKey(const Key('billStateField')), findsNothing);
    expect(find.byKey(const Key('recordInsuranceDeclined')), findsNothing);
    expect(find.byKey(const Key('insurerReplyTile')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('self-pay creates one planned bill with no money movement',
      (tester) async {
    final directory = await seedDirectory(tester);
    await pump(tester,
        providers: [directory.provider],
        members: [directory.member],
        serviceTypes: [directory.service]);
    await fillAmount(tester);
    await selectDirectory(tester, directory);
    await save(tester);

    final bill = (h.db.medicalBills.where().findAllSync()).single;
    final expense = (h.db.expenses.where().findAllSync()).single;
    expect(bill.linkedExpenseId, expense.id);
    expect(bill.billedAmount, 10000);
    expect(bill.state, MedicalBillState.planned);
    expect(expense.status, ExpenseStatus.planned);
    expect(expense.amount, 0);
    expect(h.db.medicalSettlements.countSync(), 0);
    expect(h.db.reimbursements.countSync(), 0);
    expect(h.db.medicalApprovals.countSync(), 0);
    expect(bill.followUpDate, isNotNull);
    expect(find.text('Saved home'), findsOneWidget);
  });

  testWidgets('insurance-pays creates a planned bill with no refund or event',
      (tester) async {
    final directory = await seedDirectory(tester);
    await pump(tester,
        providers: [directory.provider],
        members: [directory.member],
        serviceTypes: [directory.service]);
    await chooseInsurer(tester);
    await fillAmount(tester);
    await selectDirectory(tester, directory);
    await save(tester);

    final bill = (h.db.medicalBills.where().findAllSync()).single;
    final expense = (h.db.expenses.where().findAllSync()).single;
    expect(bill.paymentMethod, MedicalPaymentMethod.insurerPaid);
    expect(bill.state, MedicalBillState.planned);
    expect(expense.status, ExpenseStatus.planned);
    expect(expense.amount, 0);
    expect(bill.reimbursedAmount, 0);
    expect(h.db.medicalSettlements.countSync(), 0);
    expect(h.db.expenses.countSync(), 1);
  });

  testWidgets('coverage defaults from the profile and share is calculated',
      (tester) async {
    await pump(tester,
        defaultProfile: InsuranceProfile()..defaultPatientPercent = 20);
    final field = tester
        .widget<TextFormField>(find.byKey(const Key('insuranceCoverageField')));
    expect(field.controller!.text, '80');
    await tester.scrollUntilVisible(
        find.byKey(const Key('yourShareEstimateRow')), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('yourShareEstimateRow')), findsOneWidget);
    expect(find.textContaining('20%'), findsWidgets);
  });

  for (final coverage in ['0', '100']) {
    testWidgets('coverage $coverage round trips as the inverse share',
        (tester) async {
      final directory = await seedDirectory(tester);
      await pump(tester,
          providers: [directory.provider],
          members: [directory.member],
          serviceTypes: [directory.service]);
      await fillAmount(tester);
      await fillCoverage(tester, coverage);
      await selectDirectory(tester, directory);
      await save(tester);
      final bill = (h.db.medicalBills.where().findAllSync()).single;
      final expectedShare = 100 - double.parse(coverage);
      expect(bill.patientSharePercent, expectedShare);
      expect(bill.reimbursedAmount, 0);
      expect(bill.state, MedicalBillState.planned);
    });
  }

  testWidgets('invalid coverage is rejected and the input is preserved',
      (tester) async {
    await pump(tester);
    await fillAmount(tester);
    await fillCoverage(tester, '101');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await save(tester, expectSave: false);
    expect(h.db.medicalBills.countSync(), 0);
    await openSection(tester, 'Bill details');
    expect(find.text('Must be between 0 and 100'), findsOneWidget);
    final field = tester
        .widget<TextFormField>(find.byKey(const Key('insuranceCoverageField')));
    expect(field.controller!.text, '101');
  });

  testWidgets('missing required directory fields block creation',
      (tester) async {
    await pump(tester);
    await fillAmount(tester);
    await save(tester, expectSave: false);
    expect(h.db.medicalBills.countSync(), 0);
    expect(find.textContaining('Select a patient, a provider'), findsOneWidget);
  });

  testWidgets('switching the payment model preserves shared inputs',
      (tester) async {
    final directory = await seedDirectory(tester);
    await pump(tester,
        providers: [directory.provider],
        members: [directory.member],
        serviceTypes: [directory.service]);
    await fillAmount(tester);
    await fillCoverage(tester, '70');
    await selectDirectory(tester, directory);
    await chooseInsurer(tester);
    await tester.scrollUntilVisible(
        find.byKey(const Key('insurancePaysProviderRow')), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('insurancePaysProviderRow')), findsOneWidget);
    expect(find.byKey(const Key('expectedRefundRow')), findsNothing);
    await chooseSelfPay(tester);
    await tester.scrollUntilVisible(
        find.byKey(const Key('expectedRefundRow')), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('expectedRefundRow')), findsOneWidget);
    expect(find.byKey(const Key('insurancePaysProviderRow')), findsNothing);
    await tester.scrollUntilVisible(
        find.byKey(const Key('medicalBilledAmountField')), -250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    final amount = tester
        .widget<TextFormField>(find.descendant(
            of: find.byKey(const Key('medicalBilledAmountField')),
            matching: find.byType(TextFormField)))
        .controller!
        .text;
    expect(amount, '10,000');
    final coverage = tester
        .widget<TextFormField>(find.byKey(const Key('insuranceCoverageField')))
        .controller!
        .text;
    expect(coverage, '70');
  });

  testWidgets('reminder defaults to three days and can be disabled',
      (tester) async {
    await pump(tester);
    await openSection(tester, 'Dates & reminders');
    expect(find.text('No reminder'), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('followUpReminderTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('followUpReminderTile')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('noReminderAction')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('noReminderAction')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('noReminderAction')));
    await tester.pumpAndSettle();
    expect(find.text('No reminder'), findsOneWidget);
  });

  testWidgets('a historical budget period is saved unchanged', (tester) async {
    final directory = await seedDirectory(tester);
    await pump(tester,
        providers: [directory.provider],
        members: [directory.member],
        serviceTypes: [directory.service]);
    await fillAmount(tester);
    await selectDirectory(tester, directory);
    await openSection(tester, 'Dates & reminders');
    await tester.tap(find.byKey(const Key('budgetPeriodField')));
    await tester.pumpAndSettle();
    await pickOption(tester, 'budgetPeriodMonth', 'March');
    await pickOption(tester, 'budgetPeriodYear', '2024');
    await tester.tap(find.byKey(const Key('budgetPeriodConfirm')));
    await tester.pumpAndSettle();
    await save(tester);
    expect(h.db.medicalBills.where().findAllSync().single.yearMonth, '2024-03');
  });

  testWidgets('inline patient, provider and service type are selected at once',
      (tester) async {
    await pump(tester);
    await openSection(tester, 'Provider & person');

    Future<void> addInline(String actionKey, String label, String name) async {
      await tester.ensureVisible(find.byKey(Key(actionKey)));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.byKey(Key(actionKey)));
      });
      await tester.pumpAndSettle();
      final field = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == label);
      await tester.enterText(field, name);
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Add'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      for (var attempt = 0;
          attempt < 40 && find.textContaining(name).evaluate().isEmpty;
          attempt++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
      }
      expect(find.textContaining(name), findsWidgets);
    }

    await addInline('addProviderAction', 'Provider name', 'Dr Inline');
    await addInline('addServiceTypeAction', 'Service type name', 'Inline Care');
    await addInline('addPatientAction', 'Patient name', 'Inline Patient');

    await fillAmount(tester);
    await save(tester);
    final bill = h.db.medicalBills.where().findAllSync().single;
    expect(h.db.medicalProviders.getSync(bill.providerId!)!.name, 'Dr Inline');
    expect(h.db.familyMembers.getSync(bill.familyMemberId!)!.name,
        'Inline Patient');
    expect(h.db.medicalServiceTypes.getSync(bill.serviceTypeId!)!.name,
        'Inline Care');
  });

  testWidgets('editing keeps the stored state and no lifecycle picker appears',
      (tester) async {
    final bill = await existing(tester, reply: 'insurance-reply.pdf');
    await pump(tester, bill: bill);
    expect(find.byKey(const Key('providerPaidQuestion')), findsNothing);
    expect(find.byKey(const Key('billStateField')), findsNothing);
    await openSection(tester, 'Documents');
    expect(find.byKey(const Key('insurerReplyTile')), findsOneWidget);
    await save(tester);
    final stored = h.db.medicalBills.getSync(bill.id)!;
    expect(stored.state, MedicalBillState.paid);
    expect(stored.insurerReplyPath, 'insurance-reply.pdf');
    expect(h.db.expenses.countSync(), 1);
  });

  testWidgets('reply removal requires explicit confirmation before direct save',
      (tester) async {
    final bill = await existing(tester, reply: 'insurance-reply.pdf');
    await pump(tester, bill: bill);
    await chooseInsurer(tester);
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Save'));
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      repository.saved = Completer<void>();
      await tester.tap(find.text('Remove reply and save'));
      await repository.saved!.future.timeout(const Duration(seconds: 5));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    final stored = h.db.medicalBills.getSync(bill.id)!;
    expect(stored.insurerReplyPath, isNull);
    expect(stored.paymentMethod, MedicalPaymentMethod.insurerPaid);
    expect(h.db.expenses.countSync(), 1);
  });

  testWidgets('budget period and original currency survive an ordinary edit',
      (tester) async {
    final bill = await existing(tester);
    await tester.runAsync(() async {
      await h.db.writeTxn(() async {
        bill.yearMonth = '2026-09';
        bill.followUpDate = DateTime(2027, 1, 2);
        bill.calendarEventId = 'fixture-calendar-event';
        bill.billPhotoPath = 'fixture-bill.jpg';
        await h.db.medicalBills.put(bill);
        final expense = (await h.db.expenses.get(bill.linkedExpenseId!))!;
        expense.yearMonth = '2026-09';
        await h.db.expenses.put(expense);
      });
    });
    await pump(tester, bill: bill);
    await save(tester);
    final stored = h.db.medicalBills.getSync(bill.id)!;
    expect(stored.yearMonth, '2026-09');
    expect(stored.currency, 'huf');
    expect(stored.billedAmount, 10000);
    expect(stored.followUpDate, DateTime(2027, 1, 2));
    expect(stored.calendarEventId, 'fixture-calendar-event');
    expect(stored.billPhotoPath, 'fixture-bill.jpg');
    expect(stored.serviceDate, DateTime(2026, 10, 12));
  });

  testWidgets('approved document-only edit leaves the booked expense untouched',
      (tester) async {
    final bill = await existing(tester, reply: 'insurance-reply.pdf');
    await tester.runAsync(() => MedicalReceiptService(h.db).approve(
        billId: bill.id,
        actorId: h.ownerId,
        amountMinor: 8000,
        decisionDate: DateTime(2026, 10, 12),
        operationKey: 'fixture-approval',
        isAccessCurrent: () => true));
    final before = jsonEncode(h.db.expenses.where().exportJsonSync());
    await pump(tester, bill: bill);
    await openSection(tester, 'Documents');
    await tester.ensureVisible(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    await save(tester);
    expect(jsonEncode(h.db.expenses.where().exportJsonSync()), before);
    expect(h.db.medicalApprovals.countSync(), 1);
    expect(h.db.medicalBills.getSync(bill.id)!.insurerReplyPath, isNull);
  });

  testWidgets(
      'approved financial edit requires review and cancellation keeps stored money',
      (tester) async {
    final bill = await existing(tester);
    await tester.runAsync(() => MedicalReceiptService(h.db).approve(
        billId: bill.id,
        actorId: h.ownerId,
        amountMinor: 8000,
        decisionDate: DateTime(2026, 10, 12),
        operationKey: 'protected',
        isAccessCurrent: () => true));
    await pump(tester, bill: bill);
    final field = find.descendant(
        of: find.byKey(const Key('medicalBilledAmountField')),
        matching: find.byType(TextFormField));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, '12000');
    await tester.runAsync(() async {
      repository.historyLoaded = Completer<void>();
      await tester.tap(find.byTooltip('Save'));
      await repository.historyLoaded!.future
          .timeout(const Duration(seconds: 5));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(find.text('Review approved bill correction'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text('Keep unchanged'));
    });
    await tester.pumpAndSettle();
    expect(h.db.medicalBills.getSync(bill.id)!.billedAmount, 10000);
    expect(h.db.expenses.getSync(bill.linkedExpenseId!)!.amount, 10000);
  });

  testWidgets('a saved declined bill remains declined during editing',
      (tester) async {
    final bill = await existing(tester, state: MedicalBillState.rejected);
    await pump(tester, bill: bill);
    await save(tester);
    expect(
        h.db.medicalBills.getSync(bill.id)!.state, MedicalBillState.rejected);
  });

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('new form fits 320px and 200 percent text in $theme',
        (tester) async {
      tester.view.physicalSize = const Size(320, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pump(tester, textScale: 2, theme: theme);
      await chooseInsurer(tester);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('Bill estimate'), 250,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('repeated save taps cannot create duplicate bills or expenses',
      (tester) async {
    final directory = await seedDirectory(tester);
    await pump(tester,
        providers: [directory.provider],
        members: [directory.member],
        serviceTypes: [directory.service]);
    await fillAmount(tester);
    await selectDirectory(tester, directory);
    await tester.runAsync(() async {
      repository.saved = Completer<void>();
      await tester.tap(find.byTooltip('Save'));
      await tester.tap(find.byTooltip('Save'));
      await repository.saved!.future.timeout(const Duration(seconds: 5));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(h.db.medicalBills.countSync(), 1);
    expect(h.db.expenses.countSync(), 1);
    expect(h.db.medicalClaimActivitys.countSync(), 1);
  });
}
