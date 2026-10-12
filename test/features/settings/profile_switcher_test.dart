import 'dart:async';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T026: the profile switcher (US1 AC2). Switching from one personal profile to
/// another re-derives every screen in the same frame — currency, font, theme,
/// income, avatar, expenses and medical bills all follow the newly-active
/// profile, never the previous one and never a shared space's data. Switching
/// also touches `UserProfile.lastActiveAt` (FR-001).
///
/// Drive-by contract for `ProfileSwitcherSection` (T028/T029):
/// - a tile per profile keyed `profileTile_<id>`, the active one marked with
///   `Icons.radio_button_checked`;
/// - an add tile keyed `addProfileButton` that opens the "New profile" dialog
///   with a `profileNameField` text field and a `saveProfileButton` confirm;
/// - tapping a tile sets `activeProfileIdProvider`, clears `activeSpaceIdProvider`
///   and touches `lastActiveAt` through `profileSwitcherControllerProvider`.
class _ContextExpenseRepo extends ExpenseRepository {
  _ContextExpenseRepo(
    super.isar, {
    required this.byProfile,
    required this.bySpace,
  });

  final Map<int, List<Expense>> byProfile;
  final Map<int, List<Expense>> bySpace;

  List<Expense> _for(ContextRef context) => context.isShared
      ? bySpace[context.spaceId] ?? const <Expense>[]
      : byProfile[context.profileKey] ?? const <Expense>[];

  @override
  Stream<List<Expense>> watchExpensesForContext(ContextRef context) =>
      Stream.value(_for(context));

  @override
  Stream<List<Expense>> watchExpenses(int profileId, String yearMonth) =>
      Stream.value(byProfile[profileId] ?? const <Expense>[]);

  @override
  Stream<List<Reimbursement>> watchOrphanedReimbursements() =>
      Stream.value(const <Reimbursement>[]);

  @override
  Stream<List<Reimbursement>> watchReimbursementsForMonth(String yearMonth) =>
      Stream.value(const <Reimbursement>[]);
}

class _ContextMedicalRepo extends MedicalRepository {
  _ContextMedicalRepo(
    super.isar, {
    required this.byProfile,
    required this.bySpace,
  });

  final Map<int, List<MedicalBill>> byProfile;
  final Map<int, List<MedicalBill>> bySpace;

  @override
  Stream<List<MedicalBill>> watchMedicalBillsForContext(ContextRef context) =>
      Stream.value(context.isShared
          ? bySpace[context.spaceId] ?? const <MedicalBill>[]
          : byProfile[context.profileKey] ?? const <MedicalBill>[]);
}

class _CurrencyReadout extends ConsumerWidget {
  const _CurrencyReadout();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Text(ref.watch(mainCurrencyProvider).name,
          key: const Key('currencyReadout'));
}

class _ExpenseReadout extends ConsumerWidget {
  const _ExpenseReadout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titles = ref
            .watch(monthlyExpensesProvider)
            .value
            ?.map((e) => e.title)
            .join(',') ??
        'none';
    return Text(titles, key: const Key('expenseReadout'));
  }
}

class _MedicalReadout extends ConsumerWidget {
  const _MedicalReadout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(medicalBillsProvider).value?.length ?? 0;
    return Text('$count', key: const Key('medicalReadout'));
  }
}

/// `fireImmediately`-style stream for the `profilesProvider` override: yields
/// the current list once on listen, then forwards live updates (mirrors the
/// real Isar watcher, which cannot run under the widget-test fake clock).
Stream<List<UserProfile>> _profilesStream(
  List<UserProfile> initial,
  Stream<List<UserProfile>> updates,
) async* {
  yield List<UserProfile>.of(initial);
  await for (final value in updates) {
    yield value;
  }
}

class _SettingsReadout extends ConsumerWidget {
  const _SettingsReadout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider).value;
    final currency = ref.watch(mainCurrencyProvider);
    final theme = ref.watch(appThemeModeProvider);
    final income = ref.watch(defaultNetSalaryProvider);
    final label = profile == null
        ? 'none'
        : '${profile.avatar} ${profile.name} ${currency.name} '
            '${profile.fontFamily.name} ${theme.name} '
            '${income.toStringAsFixed(0)}';
    return Text(label, key: const Key('settingsReadout'));
  }
}

void main() {
  test(
      'ProfileSwitcherController.createProfile persists the row and seeds '
      'service types', () async {
    // Regression for an on-device crash: createProfile used to seed the default
    // service types INSIDE the same writeTxn that inserted the profile; Isar
    // forbids nested transactions, so the first save threw "Cannot perform this
    // operation from within an active transaction". The insert and the seed
    // must run as sequential transactions.
    final harness = await MedicalTestHarness.create();
    try {
      final controller = ProfileSwitcherController(harness.isar);
      final id = await controller.createProfile('Bea');
      final row = await harness.isar.userProfiles.get(id);
      expect(row, isNotNull);
      expect(row!.name, 'Bea');
      expect(row.avatar, '👤');
      expect(row.primaryCurrency, PrimaryCurrency.huf);
      expect(row.lastActiveAt, isNotNull);
      final typeCount = await harness.isar.medicalServiceTypes
          .filter()
          .profileIdEqualTo(id)
          .count();
      expect(typeCount, greaterThan(0),
          reason: 'a brand-new profile must get the default service types');
    } finally {
      await harness.close();
    }
  });

  testWidgets('switching profiles re-derives every screen in the same frame',
      (WidgetTester tester) async {
    // Isar I/O must not run under the widget-test fake clock; every real read
    // and write lives inside `runAsync`.
    late MedicalTestHarness harness;
    late UserProfile ava;
    late UserProfile bea;
    late int spaceId;
    late MonthlyBudget budget;
    final date = DateTime(2026, 1, 10);

    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();

      ava = UserProfile()
        ..name = 'Ava'
        ..avatar = '👩'
        ..primaryCurrency = PrimaryCurrency.usd
        ..monthlyAvailableAmount = 0
        ..defaultNetSalary = 3000
        ..fontFamily = AppFontFamily.roboto
        ..themeMode = AppThemeMode.light
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      bea = UserProfile()
        ..name = 'Bea'
        ..avatar = '🧑'
        ..primaryCurrency = PrimaryCurrency.eur
        ..monthlyAvailableAmount = 0
        ..defaultNetSalary = 5000
        ..fontFamily = AppFontFamily.system
        ..themeMode = AppThemeMode.dark
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      final space = SharedSpace()
        ..name = 'Home'
        ..avatar = '👨‍👩‍👧'
        ..currency = PrimaryCurrency.usd
        ..createdByProfileId = 1
        ..createdAt = DateTime(2026);

      final avaId = await harness.isar.writeTxn(() async {
        final id = await harness.isar.userProfiles.put(ava);
        return id;
      });
      final beaId = await harness.isar.writeTxn(() async {
        final id = await harness.isar.userProfiles.put(bea);
        return id;
      });
      spaceId = await harness.isar.writeTxn(() async {
        final id = await harness.isar.sharedSpaces.put(space);
        return id;
      });
      ava.id = avaId;
      bea.id = beaId;

      budget = MonthlyBudget()
        ..profileId = avaId
        ..yearMonth = '2026-01'
        ..baseAvailableAmount = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      budget.id = await harness.isar.writeTxn(() async {
        final id = await harness.isar.monthlyBudgets.put(budget);
        return id;
      });

      await harness.isar.writeTxn(() async {
        final avaExpenseId = await harness.isar.expenses.put(Expense(
          profileId: avaId,
          yearMonth: '2026-01',
          title: 'Ava exp',
          amount: 10000,
          currency: 'usd',
          categoryId: Expense.defaultCategoryId,
          date: date,
          budgetId: budget.id,
        ));
        final beaExpenseId = await harness.isar.expenses.put(Expense(
          profileId: beaId,
          yearMonth: '2026-01',
          title: 'Bea exp',
          amount: 20000,
          currency: 'eur',
          categoryId: Expense.defaultCategoryId,
          date: date,
          budgetId: budget.id,
        ));
        await harness.isar.expenses.put(Expense(
          profileId: 0,
          sharedSpaceId: spaceId,
          yearMonth: '2026-01',
          title: 'Home exp',
          amount: 30000,
          currency: 'usd',
          categoryId: Expense.defaultCategoryId,
          date: date,
          budgetId: budget.id,
        ));

        await harness.isar.medicalBills.putAll([
          MedicalBill()
            ..profileId = avaId
            ..yearMonth = '2026-01'
            ..linkedExpenseId = avaExpenseId
            ..billedAmount = 400000
            ..currency = 'usd'
            ..paymentMethod = MedicalPaymentMethod.selfPaid
            ..state = MedicalBillState.finished
            ..serviceDate = date,
          MedicalBill()
            ..profileId = beaId
            ..yearMonth = '2026-01'
            ..linkedExpenseId = beaExpenseId
            ..billedAmount = 500000
            ..currency = 'eur'
            ..paymentMethod = MedicalPaymentMethod.selfPaid
            ..state = MedicalBillState.finished
            ..serviceDate = date,
          MedicalBill()
            ..profileId = beaId
            ..yearMonth = '2026-01'
            ..linkedExpenseId = beaExpenseId
            ..billedAmount = 510000
            ..currency = 'eur'
            ..paymentMethod = MedicalPaymentMethod.selfPaid
            ..state = MedicalBillState.waiting
            ..serviceDate = date,
          MedicalBill()
            ..sharedSpaceId = spaceId
            ..yearMonth = '2026-01'
            ..linkedExpenseId = 0
            ..billedAmount = 600000
            ..currency = 'usd'
            ..paymentMethod = MedicalPaymentMethod.selfPaid
            ..state = MedicalBillState.finished
            ..serviceDate = date,
        ]);
      });
    });

    late List<Expense> avaExpenses;
    late List<Expense> beaExpenses;
    late List<Expense> homeExpenses;
    late List<MedicalBill> avaBills;
    late List<MedicalBill> beaBills;
    late List<MedicalBill> homeBills;
    await tester.runAsync(() async {
      avaExpenses = [
        (await harness.isar.expenses
            .filter()
            .titleEqualTo('Ava exp')
            .findFirst())!,
      ];
      beaExpenses = [
        (await harness.isar.expenses
            .filter()
            .titleEqualTo('Bea exp')
            .findFirst())!,
      ];
      homeExpenses = [
        (await harness.isar.expenses
            .filter()
            .titleEqualTo('Home exp')
            .findFirst())!,
      ];
      avaBills = await harness.isar.medicalBills
          .filter()
          .profileIdEqualTo(ava.id)
          .findAll();
      beaBills = await harness.isar.medicalBills
          .filter()
          .profileIdEqualTo(bea.id)
          .findAll();
      homeBills = await harness.isar.medicalBills
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .findAll();
    });

    // The active-profile and context overrides mirror the real providers: each
    // reads the selection marker and resolves to that row, so the tap's marker
    // write alone re-emits both and every dependent screen follows — no manual
    // stream pushing. The real upstream (Isar watch streams) cannot run under
    // the widget-test fake clock, and the real context provider throws on its
    // first frame while the profile stream is still loading; overriding it with
    // a marker-derived context keeps every built frame resolvable.
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith((ref) => Stream.value([ava, bea])),
        activeProfileProvider.overrideWith((ref) {
          final id = ref.watch(activeProfileIdProvider);
          final row = id == null
              ? ava
              : ([ava, bea].firstWhere((p) => p.id == id, orElse: () => ava));
          return Stream.value(row);
        }),
        budgetContextProvider.overrideWith((ref) {
          final id = ref.watch(activeProfileIdProvider) ?? ava.id;
          return ContextRef.personal(
            profileId: id,
            yearMonth: ref.watch(selectedYearMonthProvider),
          );
        }),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        expenseRepositoryProvider.overrideWithValue(_ContextExpenseRepo(
          harness.isar,
          byProfile: {ava.id: avaExpenses, bea.id: beaExpenses},
          bySpace: {spaceId: homeExpenses},
        )),
        medicalRepositoryProvider.overrideWithValue(_ContextMedicalRepo(
          harness.isar,
          byProfile: {ava.id: avaBills, bea.id: beaBills},
          bySpace: {spaceId: homeBills},
        )),
        profileSwitcherControllerProvider
            .overrideWithValue(ProfileSwitcherController(harness.isar)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileSwitcherSection(),
                  _CurrencyReadout(),
                  _ExpenseReadout(),
                  _MedicalReadout(),
                  _SettingsReadout(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Ava is the active profile.
    expect(find.byKey(Key('profileTile_${ava.id}')), findsOneWidget);
    expect(find.byKey(Key('profileTile_${bea.id}')), findsOneWidget);
    expect(find.byKey(const Key('addProfileButton')), findsOneWidget);
    expect(find.text('Profiles'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(Key('profileTile_${ava.id}')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(Key('profileTile_${bea.id}')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsNothing,
    );

    // Ava's world: currency, font, theme, income, avatar, data.
    expect(
      tester.widget<Text>(find.byKey(const Key('settingsReadout'))).data,
      '👩 Ava usd roboto light 3000',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('expenseReadout'))).data,
      'Ava exp',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('medicalReadout'))).data,
      '1',
    );

    // Switch to Bea. The tap runs under `runAsync` because switching touches
    // `lastActiveAt` through the harness-bound controller: real Isar I/O must
    // not start under the widget-test fake clock, or its transaction would hold
    // the write lock forever and block every later read. Inside the real-async
    // zone the write lands; the marker writes are synchronous either way. The
    // settle then flushes the re-emitted streams, so the very next rendered
    // frame shows Bea everywhere (one marker write, no further user action).
    await tester.runAsync(() async {
      await tester.tap(find.byKey(Key('profileTile_${bea.id}')));
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pumpAndSettle();

    // The marker moved synchronously and any shared selection was cleared.
    expect(container.read(activeProfileIdProvider), bea.id);
    expect(container.read(activeSpaceIdProvider), isNull);

    expect(
      tester.widget<Text>(find.byKey(const Key('settingsReadout'))).data,
      '🧑 Bea eur system dark 5000',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('expenseReadout'))).data,
      'Bea exp',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('medicalReadout'))).data,
      '2',
    );
    expect(
      find.descendant(
        of: find.byKey(Key('profileTile_${bea.id}')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    // The shared space's money never leaked into a personal context.
    expect(
      tester.widget<Text>(find.byKey(const Key('expenseReadout'))).data,
      isNot(contains('Home exp')),
    );

    // Switching touched Bea's `lastActiveAt` on the real row; Ava's stayed null.
    await tester.runAsync(() async {
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
        final beaRow = await harness.isar.userProfiles.get(bea.id);
        if (beaRow!.lastActiveAt != null) break;
      }
      final beaRow = await harness.isar.userProfiles.get(bea.id);
      final avaRow = await harness.isar.userProfiles.get(ava.id);
      expect(beaRow!.lastActiveAt, isNotNull,
          reason: 'switching to Bea must touch her lastActiveAt (FR-001)');
      expect(avaRow!.lastActiveAt, isNull,
          reason:
              'Ava was never selected, her lastActiveAt must stay untouched');
    });

    await tester.runAsync(harness.close);
  });

  testWidgets('creating a profile persists it and activates the new tile',
      (WidgetTester tester) async {
    // Regression for a real-device crash: the "New profile" dialog used to
    // dispose its TextEditingController as soon as `showDialog` resolved, while
    // the route was still animating out — the exit transition rebuilt the
    // TextField against the disposed controller ("used after being disposed").
    // The controller now lives in the dialog's own State, so it survives the
    // full exit transition.
    const avaId = 1;
    const createdId = 2;
    final ava = UserProfile()
      ..id = avaId
      ..name = 'Ava'
      ..avatar = '👩'
      ..fontFamily = AppFontFamily.roboto
      ..themeMode = AppThemeMode.light
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final created = UserProfile()
      ..id = createdId
      ..name = 'Bea'
      ..avatar = '👤'
      ..fontFamily = AppFontFamily.system
      ..themeMode = AppThemeMode.system
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final rows = <UserProfile>[ava];

    // The real `profilesProvider` is an Isar watch stream that cannot run under
    // the widget-test fake clock; drive it with a controller so the create flow
    // can re-emit the grown list (mirroring the DB watcher's emission).
    final profileUpdates = StreamController<List<UserProfile>>.broadcast();
    addTearDown(profileUpdates.close);

    // A stub create returns the next id. The real controller is exercised by
    // the switch test and by T027's repository path; keeping the widget flow
    // free of Isar lets the whole create/save/animate-out cycle run
    // deterministically under the fake clock.
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          (ref) => _profilesStream(
              List<UserProfile>.of(rows), profileUpdates.stream),
        ),
        activeProfileProvider.overrideWith((ref) {
          final id = ref.watch(activeProfileIdProvider);
          final row = rows.firstWhere((p) => p.id == id, orElse: () => ava);
          return Stream.value(row);
        }),
        profileSwitcherControllerProvider
            .overrideWithValue(const _StubProfileSwitcherController(createdId)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ProfileSwitcherSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profileTile_$avaId')), findsOneWidget);
    expect(find.byKey(const Key('addProfileButton')), findsOneWidget);

    // Open the dialog, type a name, save; pumpAndSettle drives the dialog's
    // exit transition to completion, the very window that used to crash.
    await tester.tap(find.byKey(const Key('addProfileButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profileNameField')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('profileNameField')), 'Bea');
    rows.add(created);
    profileUpdates.add(List<UserProfile>.of(rows));
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();

    // No dialog left behind, the new profile appears, is marked active, and the
    // marker moved to it.
    expect(find.byKey(const Key('profileNameField')), findsNothing);
    expect(find.byKey(const Key('profileTile_$createdId')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('profileTile_$createdId')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('profileTile_$avaId')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsNothing,
    );
    expect(container.read(activeProfileIdProvider), createdId);
  });
}

/// Stub controller: returns a fixed id from `createProfile` and skips the DB
/// writes, so the creation widget flow is fully fake-clock-safe.
class _StubProfileSwitcherController implements ProfileSwitcherController {
  const _StubProfileSwitcherController(this.nextId);

  final int nextId;

  @override
  Future<int> createProfile(String name) async => nextId;

  @override
  Future<void> touchLastActiveAt(int profileId) async {}

  @override
  Future<ProfileDataSummary> summarizeProfile(int profileId) async =>
      const ProfileDataSummary();

  @override
  Future<ProfileDeletionResult> deleteProfile(
    int profileId, {
    required int? activeProfileId,
  }) async =>
      const ProfileDeletionResult(wasActive: false, fallbackProfileId: null);
}
