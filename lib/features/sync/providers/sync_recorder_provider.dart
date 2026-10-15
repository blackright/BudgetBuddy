import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/providers/identity_provider.dart';
import '../domain/hlc.dart';
import '../repositories/sync_recorder.dart';

/// The change-log recorder wired into the shared-space repositories (FR-006).
///
/// The [SyncRecorder] is present from the start but inert until a [ChangeSigner]
/// is attached — that happens once an identity is unlocked (US1 it is created,
/// US4 it signs membership). Until then every `record(...)` call is a no-op, so
/// 011 behaviour is completely unchanged.
final syncRecorderProvider = Provider<SyncRecorder>((ref) {
  final deviceId = ref.watch(deviceIdProvider).valueOrNull ?? '';
  return SyncRecorder(
    IsarHelper.instance,
    clock: HlcClock(deviceId: deviceId),
  );
});
