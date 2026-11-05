import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../identity/providers/device_auth_session.dart';
import '../../security/providers/lock_providers.dart';

/// Bind a review/confirmation to the native session, owner, month and actor
/// that opened it. A later switch or lock must invalidate the pending command.
bool Function() medicalAccessCheck(BuildContext context, WidgetRef ref) {
  final selected = ref.read(budgetContextProvider);
  final actor = ref.read(actingProfileIdProvider);
  final native = ref.read(deviceAuthSessionProvider);
  final session = ref.read(deviceAuthSessionProvider.notifier);
  return () {
    if (!context.mounted || !session.isCurrent(native.generation)) return false;
    try {
      final current = ref.read(budgetContextProvider);
      return ref.read(deviceAuthSessionProvider).authenticated &&
          !ref.read(lockControllerProvider).isLocked &&
          ref.read(actingProfileIdProvider) == actor &&
          current.profileId == selected.profileId &&
          current.spaceId == selected.spaceId &&
          current.yearMonth == selected.yearMonth;
    } on StateError {
      return false;
    }
  };
}
