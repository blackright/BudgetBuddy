import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/app_settings.dart';
import '../../sync/domain/sync_guid.dart';
import '../domain/onboarding_state.dart';

final _newSetupFlowProvider = Provider<String>((ref) => newSyncGuid());
final _setupChangesProvider = StreamProvider<void>((ref) {
  return IsarHelper.maybeInstance?.appSettings.watchObjectLazy(1) ??
      const Stream<void>.empty();
});

/// Only the flow identity is exposed to authentication. Ordinary draft saves
/// keep that identity; deletion, replacement or malformed progress closes it.
final setupFlowProvider = Provider<String>((ref) {
  ref.watch(_setupChangesProvider);
  final raw =
      IsarHelper.maybeInstance?.appSettings.getSync(1)?.onboardingStateJson;
  if (raw == null) return ref.watch(_newSetupFlowProvider);
  try {
    return OnboardingState.decode(raw).flowId;
  } on OnboardingStateException {
    return 'recovery';
  }
});
