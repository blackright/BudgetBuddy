import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/isar_helper.dart';
import '../database/money_integrity.dart';
import '../providers/database_integrity_provider.dart';
import '../routing/router_providers.dart';

/// Shown instead of the app when the database holds money the current schema
/// cannot read.
///
/// The values come from a pre-`int` database reinterpreted by the step-9 type
/// cut (T-R11). They cannot be recovered, so the only safe path is a reset — the
/// alternative is rendering nonsense numbers or crashing on a `clamp`.
class DatabaseCorruptionScreen extends ConsumerStatefulWidget {
  const DatabaseCorruptionScreen({super.key, required this.issues});

  final List<MoneyIntegrityIssue> issues;

  @override
  ConsumerState<DatabaseCorruptionScreen> createState() =>
      _DatabaseCorruptionScreenState();
}

class _DatabaseCorruptionScreenState
    extends ConsumerState<DatabaseCorruptionScreen> {
  bool _resetting = false;

  Future<void> _reset() async {
    setState(() => _resetting = true);
    await resetLocalDatabase(IsarHelper.instance);
    ref.read(routerProvider).go('/setup');
    ref.invalidate(moneyIntegrityIssuesProvider);
    if (mounted) setState(() => _resetting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Your saved data needs a reset',
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'An earlier version of the app saved money in a format this '
                'version can no longer read. Those amounts cannot be '
                'recovered, and using them would show wrong numbers or crash '
                'a screen.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.issues.length} damaged '
                '${widget.issues.length == 1 ? 'value' : 'values'} found. '
                'Resetting clears them and starts fresh — you will set up your '
                'budget again.',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('resetCorruptedDataButton'),
                  onPressed: _resetting ? null : _reset,
                  child: _resetting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Reset and continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
