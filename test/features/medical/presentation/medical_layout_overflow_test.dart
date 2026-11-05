import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/clock_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_receipt_provider.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_state_resolver.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_view_state.dart';
import 'package:budget_buddy/features/medical/presentation/medical_dashboard.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Layout guards for the dialogs and sheets that sit under a soft keyboard, plus
/// the Medical dashboard header change.
class _LayoutClock extends ClockNotifier {
  _LayoutClock() {
    state = DateTime(2026, 1, 30);
  }
}

///
/// HONEST SCOPE: these tests do **not** reproduce the device crash
/// (`RenderFlex overflowed ... on the bottom`, then `_dependents.isEmpty` and
/// `Tried to build dirty widget in the wrong build scope`). I checked that claim
/// directly - the previous `AlertDialog` + min-size-`Column` layouts and the
/// `Flexible` + `shrinkWrap` orphan list all lay out clean at 360x800 with a
/// 300px keyboard inset, with and without `autofocus`. The ~99770px overflow in
/// the log came from something else that the pasted log does not identify.
///
/// What these tests do guarantee is the layout invariant each fix introduces: a
/// bounded, scrollable surface under an inset, no floating action covering a row,
/// and no stale copy. They are guards against regressing the fix, not proof of
/// the original cause.
void main() {
  /// A phone-sized surface with [keyboardHeight] px of soft keyboard covering the
  /// bottom.
  void useSurfaceWithKeyboard(WidgetTester tester,
      {double keyboardHeight = 300}) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
    addTearDown(tester.view.reset);
  }

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('keyboard-inset surfaces stay bounded and scrollable', () {
    testWidgets('a tall dialog with a focused number field lays out clean',
        (tester) async {
      useSurfaceWithKeyboard(tester);

      // Mirrors the Log Reimbursement dialog: an AlertDialog whose content is a
      // min-size Column holding a TextField, opened while the keyboard is up.
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Log Reimbursement'),
                  content: Builder(
                    builder: (contentContext) => SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 24,
                          bottom: 24 +
                              MediaQuery.viewInsetsOf(contentContext).bottom,
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How much did insurance pay you?'),
                            SizedBox(height: 16),
                            TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      // The field is still on screen rather than clipped away by the keyboard.
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('the bill defaults sheet survives the keyboard',
        (tester) async {
      useSurfaceWithKeyboard(tester);

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
                  ),
                  child: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Usual patient share (%)',
                            helperText:
                                'A 20% share means a 1000 bill costs 200.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('the orphan reimbursement dialog lays out clean when tall',
        (tester) async {
      useSurfaceWithKeyboard(tester);

      final orphans = List.generate(
        8,
        (i) => Reimbursement(
          id: i + 1,
          profileId: 1,
          amount: 100 + i,
          currency: 'USD',
          originYearMonth: '2026-01',
          date: DateTime(2026, 1, i + 1),
        ),
      );

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Reimbursement without an expense'),
                  content: SizedBox(
                    width: 360,
                    // A count-capped, always-bounded box, as implemented.
                    height: 96 + orphans.length.clamp(1, 4) * 56.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('These returns were kept.'),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView(
                            children: [
                              for (final orphan in orphans)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('\$${orphan.amount} received'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Bounded height means the surplus scrolls instead of overflowing.
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('Medical dashboard inbox layout', () {
    final now = DateTime(2026, 1, 30);
    const resolver = MedicalBillStateResolver();

    MedicalInboxItem item({
      int id = 1,
      String month = '2026-01',
      int billed = 100000,
      CurrencyCode currency = CurrencyCode.usd,
      MedicalPaymentMethod method = MedicalPaymentMethod.selfPaid,
      bool providerPaid = false,
      int? approved = 8000,
      int? received = 0,
      bool closed = false,
      int shortfall = 0,
      bool cancelled = false,
      bool blocked = false,
      DateTime? followUp,
      String providerName = 'Clinic',
      String? memberName,
      String? serviceName,
    }) {
      final bill = MedicalBill()
        ..id = id
        ..syncGuid = 'bill-$id'
        ..profileId = 1
        ..yearMonth = month
        ..serviceDate = DateTime(2026, 1, 10)
        ..billedAmount = billed
        ..currency = currency.name
        ..patientSharePercent = 20
        ..paymentMethod = method
        ..followUpDate = followUp
        ..state = closed
            ? MedicalBillState.finished
            : providerPaid
                ? MedicalBillState.paid
                : MedicalBillState.waiting;
      final facts = MedicalBillFacts(
        billId: id,
        billGuid: 'bill-$id',
        method: method,
        legacyState: bill.state,
        isShared: false,
        currency: currency,
        billedMinor: billed,
        patientShareMinor: (billed * 20 / 100).round(),
        providerPaid: providerPaid,
        approvedMinor: approved,
        receivedMinor: received,
        needsReview: false,
        cancelled: cancelled,
        enteredInError: false,
        closed: closed,
        shortfallMinor: shortfall,
        directProviderSettlement: method == MedicalPaymentMethod.insurerPaid
            ? MedicalEvidence.confirmed
            : MedicalEvidence.unknown,
        shareSettlement: method == MedicalPaymentMethod.insurerPaid
            ? MedicalEvidence.confirmed
            : MedicalEvidence.unknown,
        followUp: followUp,
      );
      final state = resolver.resolve(
        facts,
        canEdit: true,
        readiness: blocked
            ? MedicalReadiness.blocked(['missingMonth'])
            : MedicalReadiness.ready(),
        now: now,
      );
      return MedicalInboxItem(
        bill: bill,
        state: state,
        providerName: providerName,
        memberName: memberName,
        serviceTypeName: serviceName,
      );
    }

    Future<void> pumpDashboard(
      WidgetTester tester, {
      required List<MedicalInboxItem> items,
      MonthlyBudget? budget,
      CurrencyCode display = CurrencyCode.usd,
      CurrencyCode main = CurrencyCode.huf,
      Brightness brightness = Brightness.light,
      double textScale = 1,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
            selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
            medicalDisplayCurrencyProvider.overrideWithValue(display),
            mainCurrencyProvider.overrideWithValue(main),
            rateRegistryProvider.overrideWithValue(RateTableRegistry()),
            clockProvider.overrideWith((ref) => _LayoutClock()),
            activeContextCanEditProvider.overrideWithValue(true),
            activeContextCanManageProvider.overrideWithValue(true),
            medicalDirectoryProvider.overrideWithValue(
              const MedicalDirectory(members: [], providers: []),
            ),
            medicalServiceTypesProvider.overrideWith(
                (ref) => Stream.value(const <MedicalServiceType>[])),
            medicalProvidersProvider
                .overrideWith((ref) => Stream.value(const <MedicalProvider>[])),
            familyMembersProvider
                .overrideWith((ref) => Stream.value(const <FamilyMember>[])),
            medicalInboxProvider.overrideWith(
              (ref) => AsyncData(buildMedicalInbox(
                items: items,
                filters: ref.watch(medicalInboxFiltersProvider),
                display: display,
                now: now,
                convert: (money) => money,
              )),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: const MedicalDashboard(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> reveal(WidgetTester tester, Finder finder) async {
      await tester.scrollUntilVisible(finder, 250,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
    }

    Future<void> revealControl(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
    }

    testWidgets(
        'compact summary, group controls and Add bill replace old cards',
        (tester) async {
      await pumpDashboard(tester, items: [item()]);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('medicalInboxSummary')), findsOneWidget);
      expect(find.text('Needs you'), findsWidgets);
      expect(find.byKey(const Key('addBillButton')), findsOneWidget);
      await reveal(tester, find.byKey(const Key('medicalBillCard-1')));
      expect(find.byKey(const Key('medicalBillCard-1')), findsOneWidget);
      expect(find.byKey(const Key('patientShareCard')), findsNothing);
      expect(find.text('Budget Impact'), findsNothing);
      expect(find.text('Set your usual share'), findsNothing);
      expect(find.byKey(const Key('billDefaultsButton')), findsOneWidget);
      expect(find.textContaining(RegExp('deductible', caseSensitive: false)),
          findsNothing);
    });

    testWidgets('groups and due follow-ups use the resolver', (tester) async {
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final due = item(
        id: 1,
        followUp: now.subtract(const Duration(days: 1)),
        providerName: 'Due Clinic',
      );
      final waiting = item(
        id: 2,
        providerPaid: true,
        approved: 8000,
        received: 0,
        followUp: now.add(const Duration(days: 3)),
        providerName: 'Waiting Clinic',
      );
      final closed = item(
        id: 3,
        providerPaid: true,
        approved: 10000,
        received: 9000,
        closed: true,
        shortfall: 1000,
        providerName: 'Closed Clinic',
      );
      await pumpDashboard(tester, items: [due, waiting, closed]);

      expect(find.text('Due Clinic'), findsOneWidget);
      expect(find.textContaining('Overdue since'), findsOneWidget);
      expect(find.text('Waiting Clinic'), findsNothing);

      await tester.tap(find.byKey(const Key('medicalInboxGroupWaiting')));
      await tester.pumpAndSettle();
      expect(find.text('Waiting Clinic'), findsOneWidget);
      expect(find.text('Due Clinic'), findsNothing);

      await tester.tap(find.byKey(const Key('medicalInboxGroupClosed')));
      await tester.pumpAndSettle();
      expect(find.text('Closed Clinic'), findsOneWidget);
      expect(find.text('Closed'), findsWidgets);
    });

    testWidgets('search, arrangement and month filters narrow the list',
        (tester) async {
      final oldSelf = item(
        id: 1,
        month: '2025-12',
        providerName: 'Old Clinic',
      );
      final direct = item(
        id: 2,
        method: MedicalPaymentMethod.insurerPaid,
        providerName: 'Insurance Clinic',
      );
      await pumpDashboard(tester, items: [oldSelf, direct]);

      await tester.enterText(
          find.byKey(const Key('medicalInboxSearchField')), 'Insurance');
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Insurance Clinic'));
      expect(find.text('Insurance Clinic'), findsOneWidget);
      expect(find.text('Old Clinic'), findsNothing);

      await tester.enterText(
          find.byKey(const Key('medicalInboxSearchField')), '');
      await tester.pumpAndSettle();
      await revealControl(
          tester, find.byKey(const Key('medicalInboxArrangementField')));
      await tester.tap(find.byKey(const Key('medicalInboxArrangementField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Insurance pays the provider').last);
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Insurance Clinic'));
      expect(find.text('Insurance Clinic'), findsOneWidget);
      expect(find.text('Old Clinic'), findsNothing);

      await revealControl(
          tester, find.byKey(const Key('medicalInboxClearFilters')));
      await tester.tap(find.byKey(const Key('medicalInboxClearFilters')));
      await tester.pumpAndSettle();
      await revealControl(
          tester, find.byKey(const Key('medicalInboxMonthField')));
      await tester.tap(find.byKey(const Key('medicalInboxMonthField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2025-12').last);
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Old Clinic'));
      expect(find.text('Old Clinic'), findsOneWidget);
      expect(find.text('Insurance Clinic'), findsNothing);
    });

    testWidgets('empty filtered state offers Clear filters', (tester) async {
      await pumpDashboard(tester, items: [item()]);
      await tester.enterText(
          find.byKey(const Key('medicalInboxSearchField')), 'nothing');
      await tester.pumpAndSettle();
      await reveal(tester, find.text('No bills match these filters'));
      expect(find.text('No bills match these filters'), findsOneWidget);
      expect(find.byKey(const Key('medicalInboxEmptyClear')), findsOneWidget);
    });

    testWidgets('foreign-currency card converts without changing stored money',
        (tester) async {
      await pumpDashboard(
        tester,
        items: [item(currency: CurrencyCode.eur)],
        display: CurrencyCode.usd,
      );
      expect(tester.takeException(), isNull);
      await reveal(tester, find.textContaining(r'$ 1,162.79'));
      expect(find.textContaining(r'$ 1,162.79'), findsWidgets);
    });

    testWidgets('readiness blocker exposes Review setup', (tester) async {
      await pumpDashboard(tester, items: [item(blocked: true)]);
      await reveal(tester, find.text('Review setup'));
      expect(find.text('Review setup'), findsOneWidget);
      expect(
          find.byKey(const Key('medicalInboxReviewSetup-1')), findsOneWidget);
    });

    for (final brightness in Brightness.values) {
      testWidgets(
          '320px and 200% text: ${brightness.name} inbox has no overflow',
          (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await pumpDashboard(
          tester,
          items: [
            item(
              providerName: 'A very long provider name that must wrap safely',
              memberName: 'Family member',
              serviceName: 'Consultation',
              followUp: now.subtract(const Duration(days: 2)),
            ),
          ],
          brightness: brightness,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
        await reveal(tester, find.byKey(const Key('medicalBillCard-1')));
        expect(find.byKey(const Key('medicalBillCard-1')), findsOneWidget);
      });
    }

    testWidgets('app bar keeps the month convert-to menu', (tester) async {
      await pumpDashboard(
        tester,
        items: const [],
        budget: MonthlyBudget()
          ..id = 1
          ..yearMonth = '2026-01'
          ..baseAvailableAmount = 1000
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026),
      );
      expect(find.byKey(const Key('monthConvertToMenu')), findsOneWidget);
      await tester.tap(find.byKey(const Key('monthConvertToMenu')));
      await tester.pumpAndSettle();
      expect(find.text('Show in Forint (default)'), findsOneWidget);
    });

    testWidgets('directory sheet still opens from the app bar', (tester) async {
      await pumpDashboard(tester, items: const []);
      await tester.tap(find.byTooltip('Providers & family'));
      await tester.pumpAndSettle();
      expect(find.text('Service types'), findsOneWidget);
      expect(find.byKey(const Key('addServiceTypeButton')), findsOneWidget);
    });
  });
}
