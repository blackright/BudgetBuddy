import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../../settings/providers/settings_provider.dart';
import '../../medical/presentation/medical_theme.dart';
import '../providers/finance_providers.dart';
import '../repositories/month_finance_repository.dart';

/// Income settings: the profile-wide default salary and a per-month override.
///
/// Two separate controls because they answer different questions. The default
/// applies to every month that has no opinion of its own; the override pins one
/// specific month, which is how an irregular month — bonus, holiday, unpaid
/// stretch — is handled without editing history (FR-001, FR-005).
///
/// The header names the active profile so it is never mistaken for a global
/// figure (FR-005, US3). Each field carries a `syncKey` bound to the active
/// profile, the selected month and the active context, so switching any of them
/// re-syncs the text to the new context instead of leaving the last context's
/// number behind (FR-010).
class NetSalarySection extends ConsumerWidget {
  const NetSalarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final repository = ref.watch(monthFinanceRepositoryProvider);
    final resolved = ref.watch(resolvedIncomeProvider);
    final profile = ref.watch(activeProfileProvider).value;
    final spaceId = ref.watch(activeSpaceIdProvider);
    // Salary is kept in the profile's main currency; show its symbol on entry
    // rather than a hardcoded default (FR-009, defect D5).
    final currency = ref.watch(mainCurrencyProvider);
    // Identity of the data behind these fields: changing any part re-syncs them.
    final syncKey = (profile?.id, yearMonth, spaceId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My income', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              profile?.name ?? '',
              key: const Key('incomeProfileName'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'What you actually take home, after tax.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('Default salary',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            MoneyField(
              key: const Key('defaultSalaryField'),
              initialValue: ref.watch(defaultNetSalaryProvider),
              fractionDigits: 2,
              syncKey: syncKey,
              helperText: 'Applies to every month without its own amount.',
              prefixText: '${currency.symbol} ',
              onSubmitted: (amount) => repository.saveDefaultNetSalary(
                amount ?? 0.0,
                profileId: profile?.id,
              ),
            ),
            const Divider(height: 28),
            Text('${monthLabel(yearMonth)} only',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            MoneyField(
              key: const Key('monthOverrideField'),
              initialValue: resolved.usesOverride ? resolved.amount : null,
              fractionDigits: 2,
              syncKey: syncKey,
              helperText: resolved.usesOverride
                  ? 'Currently overridden for this month.'
                  : 'Leave empty to follow the default salary.',
              prefixText: '${currency.symbol} ',
              onSubmitted: (amount) =>
                  repository.saveNetSalaryOverride(yearMonth, amount),
            ),
            const SizedBox(height: 12),
            Text(
              'Income used for this month: ${MedicalTheme.moneyMajor(currency, resolved.amount)}'
              '${resolved.usesOverride ? ' (override)' : ' (default)'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
