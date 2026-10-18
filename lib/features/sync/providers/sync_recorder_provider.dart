import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/providers/identity_provider.dart';
import '../domain/hlc.dart';
import '../repositories/sync_recorder.dart';
import 'sync_session_provider.dart';

/// The change-log recorder wired into the shared-space repositories (FR-006).
///
/// The [SyncRecorder] gains a signer the moment a [SyncSession] exists (the
/// identity is unlocked); while locked — or before onboarding — it stays inert
/// and every `record(...)` call is a no-op, so 011 behaviour is unchanged
/// (research R2).
///
/// `spacesRepositoryProvider` watches this provider, so it rebuilds with the
/// signing recorder automatically once the session appears.
final syncRecorderProvider = Provider<SyncRecorder>((ref) {
  final deviceId = ref.watch(deviceIdProvider).valueOrNull ?? '';
  final session = ref.watch(syncSessionProvider).valueOrNull;
  return SyncRecorder(
    IsarHelper.instance,
    signer: session?.signer,
    clock: HlcClock(deviceId: deviceId),
  );
});
