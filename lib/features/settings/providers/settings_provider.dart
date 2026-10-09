import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';

/// The active profile's main currency — the default display currency for every
/// month and every screen (FR-009).
///
/// Watches the live profile stream, so changing the main currency re-renders
/// every dependent screen within a frame and touches nothing persisted beyond
/// the profile row (FR-010, SC-002). Falls back to HUF until a profile exists.
final mainCurrencyProvider = Provider<CurrencyCode>((ref) {
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

  /// Persists [currency] as the active profile's main currency.
  ///
  /// Display-only: no stored amount, rate or month seal is read or written
  /// (FR-010).
  Future<void> setMainCurrency(PrimaryCurrency currency) {
    return _isar.writeTxn(() async {
      final profile = await _isar.userProfiles.where().findFirst();
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

  /// Persists [mode] as the active profile's theme preference.
  Future<void> setThemeMode(AppThemeMode mode) {
    return _isar.writeTxn(() async {
      final profile = await _isar.userProfiles.where().findFirst();
      if (profile == null) return;
      profile.themeMode = mode;
      profile.updatedAt = DateTime.now();
      await _isar.userProfiles.put(profile);
    });
  }
}
