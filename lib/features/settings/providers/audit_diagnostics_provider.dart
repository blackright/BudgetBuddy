import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../identity/repositories/secret_store.dart';

/// Device-local display preference, separate from identity keys and sync data.
const auditDiagnosticsPreferenceKey = 'budgetbuddy.ui.auditDiagnostics.v1';

final auditDiagnosticsStoreProvider =
    Provider<SecretStore>((ref) => const FlutterSecureStorageSecretStore());

final auditDiagnosticsControllerProvider =
    StateNotifierProvider<AuditDiagnosticsController, AsyncValue<bool>>((ref) {
  return AuditDiagnosticsController(ref.watch(auditDiagnosticsStoreProvider));
});

/// Hidden until the preference loads successfully; never a permission bypass.
final auditDiagnosticsEnabledProvider = Provider<bool>((ref) =>
    ref.watch(auditDiagnosticsControllerProvider).asData?.value ?? false);

class AuditDiagnosticsController extends StateNotifier<AsyncValue<bool>> {
  AuditDiagnosticsController(this.store) : super(const AsyncValue.loading()) {
    unawaited(reload());
  }
  final SecretStore store;
  bool _writing = false;

  Future<void> reload() async {
    if (_writing || !mounted) return;
    state = const AsyncValue.loading();
    try {
      final value = await store.read(auditDiagnosticsPreferenceKey);
      if (mounted) state = AsyncValue.data(value == 'true');
    } catch (error, stack) {
      if (mounted) state = AsyncValue.error(error, stack);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (_writing || state.isLoading || !state.hasValue) {
      throw StateError('Wait for the diagnostics preference to load.');
    }
    _writing = true;
    state = const AsyncValue.loading();
    try {
      await store.write(auditDiagnosticsPreferenceKey, enabled.toString());
      if (mounted) state = AsyncValue.data(enabled);
    } catch (error, stack) {
      if (mounted) state = AsyncValue.error(error, stack);
      rethrow;
    } finally {
      _writing = false;
    }
  }
}
