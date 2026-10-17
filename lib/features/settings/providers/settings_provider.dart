import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';

/// The active context's main currency — the default display currency for every
/// month and every screen (FR-009, context-router §4-I5).
///
/// In a shared context this is the space's shared currency; in a personal
/// context it is the active profile's main currency. Watches the live rows, so
/// changing either re-renders every dependent screen within a frame. Falls back
/// to HUF until a context exists.
final mainCurrencyProvider = Provider<CurrencyCode>((ref) {
  final spaceId = ref.watch(activeSpaceIdProvider);
  if (spaceId != null) {
    return ref.watch(activeSpaceProvider).value?.currency.code ??
        CurrencyCode.huf;
  }
  final profile = ref.watch(activeProfileProvider).valueOrNull;
  return profile?.primaryCurrency.code ?? CurrencyCode.huf;
});

/// The active profile's theme preference — `system` (follow the operating
/// system) until the user opts into one mode (Phase 9-E).
///
/// Watches the live profile stream, so changing the theme re-renders every
/// screen within a frame (T059/T062).
final appThemeModeProvider = Provider<AppThemeMode>((ref) {
  final profile = ref.watch(activeProfileProvider).valueOrNull;
  return profile?.themeMode ?? AppThemeMode.system;
});

/// The single write path for the profile's main currency.
///
/// The previous build let the dashboard mutate `MonthlyBudget.currency`
/// directly, so the choice was silently scoped to one month and the profile was
/// never updated (defect D5). Writing through here keeps the profile
/// authoritative; per-month viewing is a separate, display-only concern (US4).
final mainCurrencyControllerProvider = Provider<MainCurrencyController>((ref) {
  return MainCurrencyController(IsarHelper.instance);
});

class MainCurrencyController {
  MainCurrencyController(this._isar);

  final Isar _isar;

  /// Persists [currency] as [profileId]'s main currency (the active profile —
  /// US1 — falling back to the lowest-id one when none is named).
  ///
  /// Display-only: no stored amount, rate or month seal is read or written
  /// (FR-010).
  Future<void> setMainCurrency(
    PrimaryCurrency currency, {
    int? profileId,
  }) {
    return _isar.writeTxn(() async {
      final profile = profileId != null
          ? await _isar.userProfiles.get(profileId)
          : await _isar.userProfiles.where().findFirst();
      if (profile == null) return;
      profile.primaryCurrency = currency;
      profile.updatedAt = DateTime.now();
      await _isar.userProfiles.put(profile);
    });
  }
}

/// The single write path for the profile's theme preference (Phase 9-E).
final appThemeControllerProvider = Provider<AppThemeController>((ref) {
  return AppThemeController(IsarHelper.instance);
});

class AppThemeController {
  AppThemeController(this._isar);

  final Isar _isar;

  /// Persists [mode] as [profileId]'s theme preference (the active profile —
  /// US1 — falling back to the lowest-id one when none is named).
  Future<void> setThemeMode(AppThemeMode mode, {int? profileId}) {
    return _isar.writeTxn(() async {
      final profile = profileId != null
          ? await _isar.userProfiles.get(profileId)
          : await _isar.userProfiles.where().findFirst();
      if (profile == null) return;
      profile.themeMode = mode;
      profile.updatedAt = DateTime.now();
      await _isar.userProfiles.put(profile);
    });
  }
}

/// Whether saving into a **shared** space asks for confirmation first (US6,
/// T056). Defaults to `true` until the user opts out in Settings, so a shared
/// save is confirmed by design; personal saves never prompt regardless.
final confirmSharedSaveOnProvider = Provider<bool>((ref) {
  final profile = ref.watch(activeProfileProvider).valueOrNull;
  return profile?.confirmSharedSave ?? true;
});

/// The single write path for the shared-save confirmation preference (US6).
final confirmSharedSaveControllerProvider =
    Provider<ConfirmSharedSaveController>((ref) {
  return ConfirmSharedSaveController(IsarHelper.instance);
});

class ConfirmSharedSaveController {
  ConfirmSharedSaveController(this._isar);

  final Isar _isar;

  /// Persists [enabled] as [profileId]'s shared-save confirmation preference
  /// (the active profile — US1 — falling back to the lowest-id one when none is
  /// named).
  Future<void> setConfirmSharedSave(bool enabled, {int? profileId}) {
    return _isar.writeTxn(() async {
      final profile = profileId != null
          ? await _isar.userProfiles.get(profileId)
          : await _isar.userProfiles.where().findFirst();
      if (profile == null) return;
      profile.confirmSharedSave = enabled;
      profile.updatedAt = DateTime.now();
      await _isar.userProfiles.put(profile);
    });
  }
}
