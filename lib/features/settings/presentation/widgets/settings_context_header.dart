import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/active_profile_provider.dart';
import '../../../../core/providers/active_space_provider.dart';
import '../../../../core/providers/budget_context_provider.dart';
import '../../providers/settings_provider.dart';
import '../settings_copy.dart';

/// The context header at the top of the Settings hub.
///
/// It answers who the user is acting as and which money context is active:
/// the profile avatar and name, `Personal · HUF` or `<Space> · HUF`, and a
/// single `Switch` action that opens the Profile & space surface.
class SettingsContextHeader extends ConsumerWidget {
  const SettingsContextHeader({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    final space = ref.watch(activeSpaceProvider).valueOrNull;
    final isShared = ref.watch(budgetContextProvider).isShared;
    final currency = ref.watch(mainCurrencyProvider);

    final name = profile?.name ?? SettingsCopy.profileFallback;
    final contextName = isShared
        ? (space?.displayName ?? SettingsCopy.sharedSpaceFallback)
        : SettingsCopy.personal;
    final contextLine =
        '$contextName${SettingsCopy.appearanceSeparator}${currency.code.toUpperCase()}';
    final avatar = profile?.avatar;
    final avatarText = (avatar == null || avatar.isEmpty) ? '👤' : avatar;

    return Semantics(
      container: true,
      button: true,
      label:
          '$name, $contextLine, ${SettingsCopy.switchAction} profile or space',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Text(
                    avatarText,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contextLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          SettingsCopy.switchAction,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: scheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
