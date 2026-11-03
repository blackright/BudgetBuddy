import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/services/balance_checkpoint_service.dart';
import 'package:budget_buddy/core/services/financial_adoption_service.dart';
import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import 'package:budget_buddy/features/finance/presentation/balance_checkpoint_sheet.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late BalanceCheckpointService service;
  late CheckpointSources sources;
  Future<CheckpointPreview>? pendingPreview;
  final now = DateTime.utc(2026, 10, 28, 16);
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    final adoption = FinancialAdoptionService(h.db, clock: () => now);
    final p = await adoption.preview(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
    await adoption.confirm(
        preview: p, operationKey: 'start', isAccessCurrent: () => true);
    service = BalanceCheckpointService(h.db, clock: () => now);
    sources = await service.load(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
  });
  tearDown(() async => h.close());
  Widget sheet({Future<void> Function(CheckpointPreview, String)? save}) =>
      BalanceCheckpointSheet(
          load: () async =>
              CheckpointSheetData(sources, 'Europe/Budapest', now),
          preview: (s, d) {
            final pending = service.preview(
                sources: s, draft: d, isAccessCurrent: () => true);
            pendingPreview = pending;
            return pending;
          },
          save: save ?? (_, __) async {});
  test(
      'amount parsing is exact and grouped; fractional HUF and overflow rejected',
      () {
    expect(parseCheckpointAmount('1,000,000', CurrencyCode.huf), 1000000);
    expect(parseCheckpointAmount('1,000.01', CurrencyCode.eur), 100001);
    expect(parseCheckpointAmount('12.01', CurrencyCode.huf), isNull);
    expect(parseCheckpointAmount('9007199254740992', CurrencyCode.huf), isNull);
  });
  testWidgets('first invalid field receives focus without discarding values',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: sheet())));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('checkpointAmount')), '');
    await tester.ensureVisible(find.text('Preview balance'));
    await tester.tap(find.text('Preview balance'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.descendant(
        of: find.byKey(const Key('checkpointAmount')),
        matching: find.byType(TextField)));
    expect(field.focusNode!.hasFocus, isTrue);
    expect(find.text('Enter a valid amount; zero is allowed.'), findsOneWidget);
  });
  testWidgets(
      'cash preview and explicit confirmation; failed save retains data and retry key',
      (tester) async {
    final keys = <String>[];
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: sheet(save: (p, key) async {
      keys.add(key);
      throw const ReceiptGuardException('stalePreview');
    }))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('checkpointScope')), 'My bank');
    await tester.ensureVisible(find.text('Preview balance'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Preview balance'));
      // Let native Isar complete outside Flutter's simulated timer zone.
      await pendingPreview;
    });
    await tester.pumpAndSettle();
    expect(find.text('Cash balance after later movements'), findsOneWidget);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    for (var i = 0; i < 2; i++) {
      await tester.ensureVisible(find.text('Confirm balance review'));
      await tester.tap(find.text('Confirm balance review'));
      await tester.pumpAndSettle();
    }
    expect(keys.length, 2);
    expect(keys.toSet().length, 1);
    expect(
        find.text(
            'Recorded information changed. Refresh the payments and review again before saving.'),
        findsOneWidget);
    expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('checkpointScope')))
            .controller!
            .text,
        'My bank');
  });
  testWidgets(
      '320px and 200 percent text keep controls reachable in both themes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: brightness),
          builder: (_, child) => MediaQuery(
              data: const MediaQueryData(
                  size: Size(320, 760), textScaler: TextScaler.linear(2)),
              child: child!),
          home: Scaffold(
              body: KeyedSubtree(key: ValueKey(brightness), child: sheet()))));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Preview balance'));
      expect(tester.takeException(), isNull);
    }
  });
}
