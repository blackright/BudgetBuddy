import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../pairing/providers/pairing_providers.dart';
import '../../security/presentation/security_section.dart';
import '../../security/presentation/security_settings_screen.dart';
import '../../security/providers/lock_providers.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../providers/settings_provider.dart';
import 'settings_advanced_screen.dart';
import 'settings_appearance_sheet.dart';
import 'settings_budgeting_screen.dart';
import 'settings_copy.dart';
import 'settings_help_screen.dart';
import 'settings_profile_space_screen.dart';
import 'settings_sharing_screen.dart';
import 'widgets/settings_context_header.dart';
import 'widgets/settings_row.dart';

/// The Settings tab, reduced to a context header and six goal-based rows.
///
/// Each row opens a focused surface. Dense editors no longer live on this page;
/// the header and rows are the only default-view composition.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(lockSubjectProvider);
    final locked =
        ref.watch(activeLockSettingProvider).valueOrNull?.lockEnabled ?? false;
    final requiredByOwner =
        ref.watch(activeSpaceProvider).valueOrNull?.requirePin ?? false;
    final spaceCount = ref.watch(mySpacesProvider).valueOrNull?.length ?? 0;
    final peopleCount = ref.watch(pairedPeersProvider).valueOrNull?.length ?? 0;
    final themeMode = ref.watch(appThemeModeProvider);
    final fontFamily =
        ref.watch(activeProfileProvider).valueOrNull?.fontFamily ??
            AppFontFamily.system;
    final scheme = Theme.of(context).colorScheme;

    final rows = <Widget>[
      SettingsRow(
        key: const Key('settingsBudgetingRow'),
        title: SettingsCopy.budgeting,
        summary: SettingsCopy.budgetingSummary,
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => _pushScreen(context, const SettingsBudgetingScreen()),
      ),
      SettingsRow(
        key: const Key('settingsSharingRow'),
        title: SettingsCopy.sharing,
        summary: SettingsCopy.sharingSummary(
          spaces: spaceCount,
          people: peopleCount,
        ),
        icon: Icons.group_outlined,
        onTap: () => _pushScreen(context, const SettingsSharingScreen()),
      ),
      if (subject != null)
        SettingsRow(
          key: const Key('settingsSecurityRow'),
          title: SettingsCopy.security,
          summary: SettingsCopy.securitySummary(
            locked: locked,
            requiredByOwner: requiredByOwner,
          ),
          icon: Icons.lock_outline,
          trailing: Switch(
            value: locked,
            onChanged: requiredByOwner
                ? null
                : (value) => SecuritySection.requestLockChange(
                      context,
                      ref,
                      subject,
                      enable: value,
                    ),
          ),
          excludeSemantics: false,
          onTap: () => _pushScreen(
            context,
            SecuritySettingsScreen(subject: subject),
          ),
        ),
      SettingsRow(
        key: const Key('settingsAppearanceRow'),
        title: SettingsCopy.appearance,
        summary: SettingsCopy.appearanceSummary(
          themeLabel: _themeLabel(themeMode),
          fontLabel: _fontLabel(fontFamily),
        ),
        icon: Icons.palette_outlined,
        onTap: () => SettingsAppearanceSheet.show(context),
      ),
      SettingsRow(
        key: const Key('settingsHelpRow'),
        title: SettingsCopy.help,
        summary: SettingsCopy.helpSummary,
        icon: Icons.school_outlined,
        onTap: () => _pushScreen(context, const SettingsHelpScreen()),
      ),
      SettingsRow(
        key: const Key('settingsAdvancedRow'),
        title: SettingsCopy.advanced,
        summary: SettingsCopy.advancedSummary,
        icon: Icons.tune_outlined,
        onTap: () => _pushScreen(context, const SettingsAdvancedScreen()),
      ),
    ];

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
        title: const Text(SettingsCopy.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsContextHeader(
            key: const Key('settingsContextHeader'),
            onTap: () =>
                _pushScreen(context, const SettingsProfileSpaceScreen()),
          ),
          const SizedBox(height: 16),
          Material(
            key: const Key('settingsHubCard'),
            color: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 68,
                      endIndent: 16,
                      color: scheme.outlineVariant,
                    ),
                  rows[index],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _pushScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}

String _themeLabel(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return SettingsCopy.system;
    case AppThemeMode.light:
      return SettingsCopy.light;
    case AppThemeMode.dark:
      return SettingsCopy.dark;
  }
}

String _fontLabel(AppFontFamily font) {
  switch (font) {
    case AppFontFamily.system:
      return SettingsCopy.systemDefault;
    case AppFontFamily.roboto:
      return SettingsCopy.roboto;
    case AppFontFamily.inter:
      return SettingsCopy.inter;
    case AppFontFamily.openSans:
      return SettingsCopy.openSans;
  }
}
