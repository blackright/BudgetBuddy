import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/features/finance/presentation/audit_record_card.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/settings/presentation/audit_diagnostics_section.dart';
import 'package:budget_buddy/features/settings/providers/audit_diagnostics_provider.dart';

void main() {
  testWidgets(
      'Diagnostics reveals technical evidence only on opt-in and hides an open section immediately',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final row = AuditEvent()
      ..id = 1
      ..syncGuid = 'record-reference'
      ..objectType = 'Expense'
      ..action = 'expense.create'
      ..timestamp = DateTime(2026, 10, 24)
      ..createdAt = DateTime(2026)
      ..userIdentity = 'Owner'
      ..hash = 'original-hash'
      ..previousHash = ''
      ..newValue = '{"title":"Groceries"}';
    final original = row.newValue;
    final store = InMemorySecretStore();
    final container = ProviderContainer(
        overrides: [auditDiagnosticsStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            home: Scaffold(
                body: ListView(children: [
          const AuditDiagnosticsSection(),
          AuditRecordCard(
              event: row,
              expanded: true,
              onExpansionChanged: (_) {},
              author: 'Owner'),
        ])))));
    await tester.pumpAndSettle();
    expect(find.text('Technical details'), findsNothing);
    expect(find.textContaining('original-hash'), findsNothing);
    await tester.tap(find.byKey(const Key('audit-diagnostics-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Technical details'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Technical details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    expect(find.textContaining('original-hash'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, 4000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('audit-diagnostics-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Technical details'), findsNothing);
    expect(find.textContaining('original-hash'), findsNothing);
    expect(row.hash, 'original-hash');
    expect(row.newValue, original);
    expect(await store.read(auditDiagnosticsPreferenceKey), 'false');
    expect(tester.takeException(), isNull);
  });
}
