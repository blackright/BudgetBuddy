import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/onboarding_state.dart';

/// Transient arrival guard, not an authentication grant or persisted month pin.
final setupHandoffProvider =
    StateProvider<OnboardingCommitReference?>((ref) => null);

/// Explicit access to an independently valid existing profile during recovery.
final setupRecoveryProfileProvider = StateProvider<int?>((ref) => null);

/// Guard only this personal owner; unrelated established contexts keep rollover.
bool setupHandoffOwnsContext(OnboardingCommitReference? receipt,
        {required int? profileId, required bool isShared}) =>
    receipt != null && !isShared && receipt.profileId == profileId;
bool setupHandoffArrived(OnboardingCommitReference? receipt,
        {required int? profileId,
        required bool isShared,
        required int? budgetId,
        required String yearMonth}) =>
    setupHandoffOwnsContext(receipt,
        profileId: profileId, isShared: isShared) &&
    receipt!.budgetId == budgetId &&
    receipt.yearMonth == yearMonth;
