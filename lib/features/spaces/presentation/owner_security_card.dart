import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/shared_space.dart';
import '../../security/domain/away_time.dart';
import '../../security/presentation/lock_keys.dart';

/// Owner card: the security requirement the Owner imposes on every member
/// (FR-027, FR-028, FR-030). Only the Owner sees it; the member's own
/// stricter choice is composed in `effectiveLockProvider`.
class OwnerSecurityCard extends ConsumerWidget {
  const OwnerSecurityCard({super.key, required this.space});

  final SharedSpace space;

  Future<void> _save(
      BuildContext context, WidgetRef ref, SharedSpace updated) async {
    final isar = IsarHelper.instance;
    await isar.writeTxn(() async {
      await isar.sharedSpaces.put(updated);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy & security', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key(LockKeys.spaceRequirePinSwitch),
              contentPadding: EdgeInsets.zero,
              value: space.requirePin,
              onChanged: (value) async {
                space.requirePin = value;
                await _save(context, ref, space);
              },
              title: const Text('Require a PIN for everyone'),
              subtitle: const Text(
                'Every member must unlock with a PIN before seeing this space.',
              ),
            ),
            SwitchListTile(
              key: const Key(LockKeys.spaceForbidBiometricsSwitch),
              contentPadding: EdgeInsets.zero,
              value: space.forbidBiometrics,
              onChanged: (value) async {
                space.forbidBiometrics = value;
                await _save(context, ref, space);
              },
              title: const Text('Forbid the biometric shortcut'),
              subtitle: const Text(
                'Members may not use a fingerprint to re-unlock this space.',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Away-time for the space'),
              subtitle: Text(
                space.awayTime == null
                    ? 'Members choose their own'
                    : space.awayTime!.label,
              ),
              trailing: DropdownButton<AwayTime?>(
                key: const Key(LockKeys.spaceAwayTimeDropdown),
                value: space.awayTime,
                items: [
                  const DropdownMenuItem<AwayTime?>(
                    value: null,
                    child: Text('Members choose'),
                  ),
                  for (final a in AwayTime.values)
                    DropdownMenuItem<AwayTime?>(
                      value: a,
                      child: Text(a.label),
                    ),
                ],
                onChanged: (value) async {
                  space.awayTime = value;
                  await _save(context, ref, space);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
