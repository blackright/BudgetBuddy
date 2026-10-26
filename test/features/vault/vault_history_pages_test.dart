import 'dart:convert';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/presentation/vault_history.dart';
import 'package:budget_buddy/features/vault/presentation/vault_history_pages.dart';
import 'package:budget_buddy/features/vault/presentation/vault_transfer_dialog.dart';
import 'package:budget_buddy/features/vault/providers/vault_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

VaultEntry row(int id, {String? month}) => VaultEntry()
  ..id = id
  ..operationKey = 'entry-$id'
  ..profileId = 1
  ..kind = 'opening'
  ..yearMonth = month
  ..createdAt = DateTime(2026, 10, 24, 12, id)
  ..amountMinor = id
  ..balanceAfterMinor = id
  ..currency = 'huf';

Widget screen(List<VaultEntry> entries, {int owner = 1}) => MaterialApp(
    home: Scaffold(
        body: SingleChildScrollView(
            child: VaultHistoryPages(
                key: ValueKey(owner),
                entries: entries,
                itemBuilder: (entry) => Text(entry.operationKey)))));

Future<void> press(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> select(WidgetTester tester, String key, String label) async {
  await press(tester, key);
  await tester.ensureVisible(find.text(label).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });
  tearDown(() {
    WidgetController.hitTestWarningShouldBeFatal = false;
  });

  testWidgets('phone width supports filters and exactly twenty entries',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(screen([for (var i = 1; i <= 20; i++) row(i)]));
    expect(find.text('Page 1 of 1 · 20 entries'), findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('vaultHistoryNext')))
            .onPressed,
        isNull);
    await select(tester, 'vaultHistoryMonth', 'October');
    expect(find.text('Page 1 of 1 · 20 entries'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'reversal links survive different pages and original stays reversed',
      (tester) async {
    final original = row(1, month: '2026-10')
      ..kind = 'deposit'
      ..amountMinor = 100
      ..balanceAfterMinor = 100;
    final reversal = row(22, month: '2026-10')
      ..kind = 'reversal'
      ..amountMinor = -100
      ..balanceAfterMinor = 0;
    for (final entry in [original, reversal]) {
      entry.breakdownJson = jsonEncode({
        'version': 1,
        'vaultDelta': entry.amountMinor,
        'monthDelta': -entry.amountMinor,
        'month': entry.yearMonth,
        'currency': 'huf',
        'vaultBefore': entry.kind == 'deposit' ? 0 : 100,
        'bankBefore': 1000,
        'bankAfter': 1000 - entry.amountMinor,
        'reserveBefore': 1000,
        'reserveAfter': 1000 - entry.amountMinor,
        'note': 'Correction',
        if (entry.kind == 'reversal') 'reverses': original.operationKey,
      });
    }
    final entries = [original, for (var i = 2; i <= 21; i++) row(i), reversal];
    await tester.pumpWidget(ProviderScope(
        overrides: [
          vaultHistoryProvider.overrideWith((ref) => Stream.value(entries)),
        ],
        child: const MaterialApp(
            home:
                Scaffold(body: SingleChildScrollView(child: VaultHistory())))));
    await tester.pumpAndSettle();
    var tile =
        tester.widget<VaultTransferHistory>(find.byType(VaultTransferHistory));
    expect(tile.entry, same(reversal));
    expect(tile.reversedOriginal, same(original));
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Reverses deposit of'), findsOneWidget);
    await press(tester, 'vaultHistoryNext');
    tile =
        tester.widget<VaultTransferHistory>(find.byType(VaultTransferHistory));
    expect(tile.entry, same(original));
    expect(tile.reversed, isTrue);
    expect(find.text('Reverse full transfer'), findsNothing);
  });
  testWidgets(
      '20 entries per page with complete boundaries and no source edits',
      (tester) async {
    final entries = [for (var i = 1; i <= 45; i++) row(i)];
    await tester.pumpWidget(screen(entries));
    expect(find.text('Page 1 of 3 · 45 entries'), findsOneWidget);
    expect(find.text('entry-45'), findsOneWidget);
    expect(find.text('entry-26'), findsOneWidget);
    expect(find.text('entry-25'), findsNothing);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const Key('vaultHistoryPrevious')))
            .onPressed,
        isNull);
    await press(tester, 'vaultHistoryNext');
    expect(find.text('Page 2 of 3 · 45 entries'), findsOneWidget);
    expect(find.text('entry-25'), findsOneWidget);
    expect(find.text('entry-6'), findsOneWidget);
    expect(find.text('entry-26'), findsNothing);
    await press(tester, 'vaultHistoryNext');
    expect(find.text('Page 3 of 3 · 45 entries'), findsOneWidget);
    expect(find.text('entry-5'), findsOneWidget);
    expect(find.text('entry-1'), findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('vaultHistoryNext')))
            .onPressed,
        isNull);
    await press(tester, 'vaultHistoryPrevious');
    expect(find.text('Page 2 of 3 · 45 entries'), findsOneWidget);
    expect(entries.map((e) => e.id),
        orderedEquals(List.generate(45, (i) => i + 1)));
    expect(entries.map((e) => e.amountMinor),
        orderedEquals(List.generate(45, (i) => i + 1)));
  });

  testWidgets('finds five-year-old source month and resets page on filters',
      (tester) async {
    final entries = [
      for (var i = 1; i <= 25; i++) row(i, month: '2026-10'),
      row(26, month: '2021-03'),
      row(27, month: '2021-04')
    ];
    await tester.pumpWidget(screen(entries));
    await press(tester, 'vaultHistoryNext');
    await select(tester, 'vaultHistoryYear', '2021');
    expect(find.text('Page 1 of 1 · 2 entries'), findsOneWidget);
    await select(tester, 'vaultHistoryMonth', 'March');
    expect(find.text('entry-26'), findsOneWidget);
    expect(find.text('entry-27'), findsNothing);
    expect(find.text('Page 1 of 1 · 1 entries'), findsOneWidget);
    await select(tester, 'vaultHistoryMonth', 'February');
    expect(find.text('No history matches these filters.'), findsOneWidget);
    expect(find.text('Page 0 of 0 · 0 entries'), findsOneWidget);
    await select(tester, 'vaultHistoryYear', 'All years');
    expect(find.text('All months'), findsOneWidget);
    expect(find.text('Page 1 of 2 · 27 entries'), findsOneWidget);
  });

  testWidgets('live removals clamp page and additions update counts',
      (tester) async {
    final entries = [for (var i = 1; i <= 21; i++) row(i)];
    await tester.pumpWidget(screen(entries));
    await press(tester, 'vaultHistoryNext');
    await tester.pumpWidget(screen(entries.sublist(1)));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of 1 · 20 entries'), findsOneWidget);
    await tester.pumpWidget(screen([...entries, row(22)]));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of 2 · 22 entries'), findsOneWidget);
    expect(find.text('entry-22'), findsOneWidget);
  });

  testWidgets('profile key resets filters and pages without retaining old rows',
      (tester) async {
    await tester.pumpWidget(screen([row(1, month: '2021-03')]));
    await select(tester, 'vaultHistoryYear', '2021');
    await select(tester, 'vaultHistoryMonth', 'March');
    await tester.pumpWidget(screen([row(2, month: '2026-10')], owner: 2));
    await tester.pumpAndSettle();
    expect(find.text('All years'), findsOneWidget);
    expect(find.text('All months'), findsOneWidget);
    expect(find.text('entry-1'), findsNothing);
    expect(find.text('entry-2'), findsOneWidget);
  });

  testWidgets('opening fallback month, live empty selection, and empty ledger',
      (tester) async {
    await tester.pumpWidget(screen([row(1)]));
    await select(tester, 'vaultHistoryYear', '2026');
    await select(tester, 'vaultHistoryMonth', 'October');
    expect(find.text('entry-1'), findsOneWidget);
    await tester.pumpWidget(screen([row(2, month: '2021-03')]));
    await tester.pumpAndSettle();
    expect(find.text('No history matches these filters.'), findsOneWidget);
    await tester.pumpWidget(screen([]));
    await tester.pumpAndSettle();
    expect(find.text('No contributions recorded yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
