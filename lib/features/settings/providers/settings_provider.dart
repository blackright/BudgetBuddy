import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/user_profile.dart';

class SettingsState {
  final PrimaryCurrency? currency;
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    this.currency,
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    PrimaryCurrency? currency,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      currency: currency ?? this.currency,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final isar = IsarHelper.instance;
      final profile = await isar.userProfiles.where().findFirst();
      if (profile != null) {
        state =
            state.copyWith(currency: profile.primaryCurrency, isLoading: false);
      } else {
        state = state.copyWith(
            isLoading: false, errorMessage: 'User profile not found');
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Error loading settings: $e');
    }
  }

  Future<bool> updateCurrency(PrimaryCurrency newCurrency) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final isar = IsarHelper.instance;
      final profile = await isar.userProfiles.where().findFirst();

      if (profile != null) {
        profile.primaryCurrency = newCurrency;
        profile.updatedAt = DateTime.now();

        await isar.writeTxn(() async {
          await isar.userProfiles.put(profile);
        });

        state = state.copyWith(currency: newCurrency, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
            isLoading: false, errorMessage: 'User profile not found');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Error updating currency: $e');
      return false;
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
