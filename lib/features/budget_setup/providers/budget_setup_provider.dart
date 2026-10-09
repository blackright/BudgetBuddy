import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/monthly_budget.dart';
import '../../medical/repositories/medical_repository.dart';

class BudgetSetupState {
  final double? amount;
  final PrimaryCurrency? currency;
  final String? yearMonth;
  final String? errorMessage;
  final bool isSaving;

  const BudgetSetupState({
    this.amount,
    this.currency,
    this.yearMonth,
    this.errorMessage,
    this.isSaving = false,
  });

  BudgetSetupState copyWith({
    double? amount,
    PrimaryCurrency? currency,
    String? yearMonth,
    String? errorMessage,
    bool? isSaving,
    bool clearError = false,
  }) {
    return BudgetSetupState(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      yearMonth: yearMonth ?? this.yearMonth,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  bool get isValid =>
      amount != null &&
      amount! > 0 &&
      currency != null &&
      yearMonth != null &&
      yearMonth!.isNotEmpty;
}

class BudgetSetupNotifier extends StateNotifier<BudgetSetupState> {
  BudgetSetupNotifier() : super(const BudgetSetupState());

  void setAmount(double amount) {
    if (amount <= 0) {
      state = state.copyWith(
          amount: amount, errorMessage: 'Amount must be greater than 0');
    } else {
      state = state.copyWith(amount: amount, clearError: true);
    }
  }

  void setCurrency(PrimaryCurrency currency) {
    state = state.copyWith(currency: currency, clearError: true);
  }

  void setYearMonth(String yearMonth) {
    state = state.copyWith(yearMonth: yearMonth, clearError: true);
  }

  Future<void> loadAutoFillData() async {
    final isar = IsarHelper.instance;
    final profile = await isar.userProfiles.where().findFirst();
    if (profile != null) {
      state = state.copyWith(
        amount: profile.monthlyAvailableAmount,
        currency: profile.primaryCurrency,
      );
    }
  }

  Future<bool> saveBudget() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'Please fill all fields correctly');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final isar = IsarHelper.instance;
      final existingProfile = await isar.userProfiles.where().findFirst();

      final userProfile = existingProfile ?? UserProfile()
        ..name = 'User' // Default name if new
        ..createdAt = DateTime.now();

      userProfile
        ..primaryCurrency = state.currency!
        ..monthlyAvailableAmount = state.amount!
        ..updatedAt = DateTime.now();

      // Ensure there's only one user profile by keeping id = 1 if it exists
      if (existingProfile == null) {
        userProfile.id = 1;
      }

      // The chosen currency becomes the profile's main currency; the month itself
      // carries no convert-to override, so it follows that main currency
      // (FR-009, FR-011).
      final monthlyBudget = MonthlyBudget()
        ..yearMonth = state.yearMonth!
        ..baseAvailableAmount = state.amount!
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.userProfiles.put(userProfile);

        // Handle MonthlyBudget (upsert based on yearMonth)
        // Since id is autoIncrement, to truly upsert we would need to check if a budget already exists.
        final existingBudget = await isar.monthlyBudgets
            .filter()
            .yearMonthEqualTo(state.yearMonth!)
            .findFirst();
        if (existingBudget != null) {
          monthlyBudget.id = existingBudget.id;
          monthlyBudget.createdAt = existingBudget.createdAt;
        }
        await isar.monthlyBudgets.put(monthlyBudget);
      });

      // A profile created here is brand new, so give it the default medical
      // service types (FR-039). Migration step 0 only covers profiles that
      // predate the schema bump; without this a first-run profile would start
      // with an empty service-type picker.
      if (existingProfile == null) {
        await MedicalRepository(isar).ensureDefaultServiceTypes(userProfile.id);
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isSaving: false, errorMessage: 'Failed to save budget: $e');
      return false;
    }
  }
}

final budgetSetupProvider =
    StateNotifierProvider<BudgetSetupNotifier, BudgetSetupState>((ref) {
  return BudgetSetupNotifier();
});
