import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../finance/presentation/net_salary_section.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../../finance/providers/income_source_providers.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../settings/providers/app_settings_providers.dart';
import '../../identity/presentation/identity_section.dart';
import '../../pairing/presentation/paired_devices_section.dart';
import '../../pairing/presentation/people_section.dart';
import '../../security/presentation/security_section.dart';
import '../../security/providers/lock_providers.dart';
import '../../spaces/presentation/space_settings_section.dart';
import '../../spaces/presentation/spaces_list_section.dart';
import 'font_setting_section.dart';
import 'profile_switcher_section.dart';
import 'shared_save_setting_section.dart';
import 'theme_setting_section.dart';
import 'audit_diagnostics_section.dart';

/// The Settings tab, grouped by **what the setting is about**.
///
/// The order used to be the order the features were built in, which left the app
/// lock between the identity card and the People list and put the theme next to
/// the salary. Nothing about the cards themselves changed here — same widgets,
/// same keys, same behaviour — only the order and the headings above them.
///
/// Every group has a card that always paints, so no heading can stand alone:
/// "Your profile" always has the identity card, "Sharing" always has the shared
/// save preference (the app never has zero profiles — setup creates the first
/// one and the last one cannot be deleted), and "Money" and "Appearance" always
/// have theirs. "Privacy & security" is the exception: its only card hides when
/// there is no active subject to lock, so the group is skipped with its card and
/// the heading can never be orphaned.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSubject = ref.watch(lockSubjectProvider) != null;
    final incomeSources = ref.watch(incomeSourcesProvider).value ?? const [];
    final isShared = ref.watch(budgetContextProvider).isShared;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Section(
            title: 'Spaces',
            cards: [SpacesListSection()],
          ),
          const _Section(
            title: 'Your profile',
            cards: [ProfileSwitcherSection(), IdentitySection()],
          ),
          // US1: the app lock card — shown for the active subject (profile or
          // shared space), so the heading arrives with it.
          if (hasSubject)
            const _Section(
              title: 'Privacy & security',
              cards: [SecuritySection()],
            ),
          // US2/US3/US6/US7: the space is only there in a shared context; the
          // people list, the paired devices and the save preference are not.
          const _Section(
            title: 'Sharing',
            cards: [
              SpaceSettingsSection(),
              PeopleSection(),
              PairedDevicesSection(),
              SharedSaveSettingSection(),
            ],
          ),
          if (incomeSources.isEmpty)
            const _Section(
              title: 'Money',
              cards: [NetSalarySection()],
            ),
          const _Section(
            title: 'Income',
            cards: [_IncomeSourcesCard()],
          ),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: const Text('Month-End'),
                  subtitle:
                      const Text('Review Reset and Carry Forward policies'),
                  onTap: () => context.push('/month_end'))),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Audit History'),
                  onTap: () => context.push('/audit_history'))),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.summarize_outlined),
                  title: const Text('Reports'),
                  subtitle: const Text(
                      'Monthly statements, insights and PDF/CSV exports'),
                  onTap: () => context.push('/reports'))),
          if (ref.watch(activeContextCanEditProvider))
            Card(
                child: ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Bulk Entry'),
              subtitle:
                  const Text('Enter several expenses for the selected month'),
              onTap: () => context.push('/bulk_entry'),
            )),
          const _Section(
            title: 'Profiles',
            cards: [_ProfilesCard()],
          ),
          // Personal-only: a shared space has no vault, so the entry is hidden
          // there rather than leading to a blocked screen.
          if (!isShared)
            const _Section(
              title: 'Savings',
              cards: [_VaultCard()],
            ),
          const _Section(
            title: 'Transfers',
            cards: [_TransfersCard(), _TransferToggleCard()],
          ),
          const _Section(
            title: 'Appearance',
            cards: [ThemeSettingSection(), FontSettingSection()],
          ),
          _Section(title: 'Help & learning', cards: [
            Card(
                child: ListTile(
              key: const Key('replayIntroduction'),
              leading: const Icon(Icons.auto_stories_outlined),
              title: const Text('Replay introduction'),
              subtitle: const Text(
                  'Explore the basics without changing your records'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/introduction'),
            ))
          ]),
          const _Section(
            title: 'Diagnostics',
            cards: [AuditDiagnosticsSection()],
          ),
        ],
      ),
    );
  }
}

/// A small card that opens the Income Sources screen.
class _IncomeSourcesCard extends StatelessWidget {
  const _IncomeSourcesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.attach_money),
        title: const Text('Income Sources'),
        subtitle: const Text('Manage salary, freelance, and other income'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/income_sources'),
      ),
    );
  }
}

/// A small card that opens the personal Savings Vault (hidden in shared spaces).
class _VaultCard extends StatelessWidget {
  const _VaultCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.savings_outlined),
        title: const Text('Savings Vault'),
        subtitle: const Text('Money swept out of finished months'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/vault'),
      ),
    );
  }
}

/// A small card that opens the Profiles screen.
class _ProfilesCard extends StatelessWidget {
  const _ProfilesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet),
        title: const Text('Budget & Direct Profiles'),
        subtitle: const Text('Manage budget and direct expense profiles'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/profiles'),
      ),
    );
  }
}

/// A card with a toggle for transfers.
class _TransferToggleCard extends ConsumerWidget {
  const _TransferToggleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggle = ref.watch(transferToggleProvider);
    return Card(
      child: SwitchListTile(
        title: const Text('Enable Budget Transfers'),
        subtitle: const Text('Allow moving allocation between budget profiles'),
        value: toggle,
        onChanged: (v) =>
            ref.read(appSettingsRepositoryProvider).setTransferToggle(v),
      ),
    );
  }
}

/// A card that opens the Transfers screen.
class _TransfersCard extends StatelessWidget {
  const _TransfersCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.swap_horiz),
        title: const Text('Budget Transfers'),
        subtitle: const Text('Move allocation between budget profiles'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/transfers'),
      ),
    );
  }
}

/// One group of Settings cards under its own heading.
///
/// The heading is a small tinted label rather than a card title, so it never
/// competes with the `titleMedium` title each card carries of its own.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.cards});

  final String title;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // The gap *below* a group separates it from the next heading; the gaps
      // between cards stay small, so a group reads as one block.
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      ),
    );
  }
}
