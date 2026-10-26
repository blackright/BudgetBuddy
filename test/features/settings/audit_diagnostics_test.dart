import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/settings/providers/audit_diagnostics_provider.dart';

class FailingDiagnosticsStore extends InMemorySecretStore {
  bool failRead = false, failWrite = false;
  @override
  Future<String?> read(String key) async {
    if (failRead) throw StateError('Read unavailable');
    return super.read(key);
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrite) throw StateError('Write unavailable');
    await super.write(key, value);
  }
}

class WaitingDiagnosticsStore extends InMemorySecretStore {
  final writeGate = Completer<void>();
  @override
  Future<void> write(String key, String value) async {
    await writeGate.future;
    await super.write(key, value);
  }
}

void main() {
  ProviderContainer open(SecretStore store) {
    final container = ProviderContainer(
        overrides: [auditDiagnosticsStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);
    container.listen(auditDiagnosticsControllerProvider, (_, __) {});
    return container;
  }

  Future<void> loaded(ProviderContainer container) async {
    for (var i = 0; i < 30; i++) {
      if (!container.read(auditDiagnosticsControllerProvider).isLoading) return;
      await Future<void>.delayed(Duration.zero);
    }
    fail('Diagnostics preference did not finish loading.');
  }

  test('off by default; persisted enable/disable survives recreated settings',
      () async {
    final store = InMemorySecretStore();
    await store.write('unrelated-identity-key', 'unchanged');
    final first = open(store);
    expect(first.read(auditDiagnosticsEnabledProvider), isFalse);
    await loaded(first);
    expect(first.read(auditDiagnosticsEnabledProvider), isFalse);
    await first
        .read(auditDiagnosticsControllerProvider.notifier)
        .setEnabled(true);
    final second = open(store);
    await loaded(second);
    expect(second.read(auditDiagnosticsEnabledProvider), isTrue);
    await second
        .read(auditDiagnosticsControllerProvider.notifier)
        .setEnabled(false);
    final third = open(store);
    await loaded(third);
    expect(third.read(auditDiagnosticsEnabledProvider), isFalse);
    expect(await store.read('unrelated-identity-key'), 'unchanged');
  });
  test(
      'read/write errors hide technical details and retry reads actual stored preference',
      () async {
    final store = FailingDiagnosticsStore();
    await store.write(auditDiagnosticsPreferenceKey, 'true');
    store.failRead = true;
    final container = open(store);
    await loaded(container);
    expect(container.read(auditDiagnosticsEnabledProvider), isFalse);
    expect(container.read(auditDiagnosticsControllerProvider).hasError, isTrue);
    store.failRead = false;
    final controller =
        container.read(auditDiagnosticsControllerProvider.notifier);
    await controller.reload();
    expect(container.read(auditDiagnosticsEnabledProvider), isTrue);
    store.failWrite = true;
    await expectLater(controller.setEnabled(false), throwsStateError);
    expect(container.read(auditDiagnosticsEnabledProvider), isFalse);
    store.failWrite = false;
    await controller.reload();
    expect(container.read(auditDiagnosticsEnabledProvider), isTrue);
  });
  test('unknown stored preference is off and overlapping writes cannot race',
      () async {
    final unknown = InMemorySecretStore();
    await unknown.write(auditDiagnosticsPreferenceKey, 'unexpected');
    final invalid = open(unknown);
    await loaded(invalid);
    expect(invalid.read(auditDiagnosticsEnabledProvider), isFalse);
    final store = WaitingDiagnosticsStore();
    final container = open(store);
    await loaded(container);
    final controller =
        container.read(auditDiagnosticsControllerProvider.notifier);
    final saving = controller.setEnabled(true);
    await expectLater(controller.setEnabled(false), throwsStateError);
    expect(container.read(auditDiagnosticsEnabledProvider), isFalse);
    store.writeGate.complete();
    await saving;
    expect(container.read(auditDiagnosticsEnabledProvider), isTrue);
    expect(await store.read(auditDiagnosticsPreferenceKey), 'true');
  });
}
