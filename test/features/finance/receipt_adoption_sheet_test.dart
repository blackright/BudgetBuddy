import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/services/financial_adoption_service.dart';
import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import 'package:budget_buddy/features/finance/presentation/receipt_adoption_sheet.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late AdoptionPreview preview;
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    preview = await FinancialAdoptionService(h.db).preview(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
  });
  tearDown(() async => h.close());

  testWidgets('review requires explicit acknowledgement; success says inactive',
      (tester) async {
    var saves = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ReceiptAdoptionSheet(
                load: () async => preview,
                save: (_, __) async {
                  saves++;
                }))));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('Confirm review'));
    await tester.tap(find.text('Confirm review'));
    await tester.pumpAndSettle();
    expect(saves, 1);
    expect(find.textContaining('Review saved on this device'), findsOneWidget);
    expect(find.textContaining('New financial rules remain inactive.'),
        findsOneWidget);
  });

  testWidgets('failed save keeps acknowledgment and retry operation identity',
      (tester) async {
    final operations = <String>[];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ReceiptAdoptionSheet(
                load: () async => preview,
                save: (_, key) async {
                  operations.add(key);
                  throw const ReceiptGuardException('stalePreview');
                }))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    for (var i = 0; i < 2; i++) {
      await tester.ensureVisible(find.text('Confirm review'));
      await tester.tap(find.text('Confirm review'));
      await tester.pumpAndSettle();
    }
    expect(operations.length, 2);
    expect(operations.toSet().length, 1);
    expect(find.textContaining('Information changed since this preview.'),
        findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isTrue);
  });

  testWidgets(
      '320 width and large text keep review controls reachable in both themes',
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
              body: ReceiptAdoptionSheet(
                  key: ValueKey(brightness),
                  load: () async => preview,
                  save: (_, __) async {}))));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.ensureVisible(find.text('Confirm review'));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('loading error has persistent retry and no guessed money',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ReceiptAdoptionSheet(
                load: () async =>
                    throw const ReceiptGuardException('ownerRequired'),
                save: (_, __) async {}))));
    await tester.pumpAndSettle();
    expect(find.text('Only the budget owner can review the start month.'),
        findsOneWidget);
    expect(find.text('Refresh review'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
