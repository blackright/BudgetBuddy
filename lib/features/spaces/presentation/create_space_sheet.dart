import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/user_profile.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/bring_in_past.dart';

export '../models/bring_in_past.dart';

/// The value a completed [CreateSpaceSheet] returns to the caller.
class SpaceDraft {
  const SpaceDraft({
    required this.name,
    required this.avatar,
    required this.currency,
    required this.defaultIncome,
    required this.bringIn,
  });

  final String name;
  final String avatar;
  final PrimaryCurrency currency;

  /// "Our income" default in whole minor units of [currency].
  final int defaultIncome;
  final BringInPast bringIn;
}

/// US2: the "New space" sheet (name, emoji avatar, shared currency, "Our
/// income", bring-in-past choice). Returns a [SpaceDraft]; the caller creates
/// the space through `SpacesRepository.createSpace`.
///
/// Stateful on purpose: it owns its text controllers, exactly like the profile
/// dialog (T026 regression), so an in-flight exit transition never rebuilds a
/// field against a disposed controller.
class CreateSpaceSheet extends ConsumerStatefulWidget {
  const CreateSpaceSheet({super.key});

  @override
  ConsumerState<CreateSpaceSheet> createState() => _CreateSpaceSheetState();
}

class _CreateSpaceSheetState extends ConsumerState<CreateSpaceSheet> {
  static const _avatars = [
    '👨‍👩‍👧',
    '🏠',
    '🏦',
    '❤️',
    '🎒',
    '🐶',
    '⚽',
    '🎉',
  ];

  final _name = TextEditingController();
  final _income = TextEditingController();
  String _avatar = _avatars.first;
  late PrimaryCurrency _currency = ref.read(mainCurrencyProvider).primary;
  BringInPast _bringIn = BringInPast.thisMonth;

  @override
  void dispose() {
    _name.dispose();
    _income.dispose();
    super.dispose();
  }

  int? _parseIncomeMinor() {
    final raw = _income.text.trim().replaceAll(',', '');
    if (raw.isEmpty) return 0;
    final major = double.tryParse(raw);
    if (major == null || major < 0) return null;
    return (major * _currency.code.minorUnitsPerMajor).round();
  }

  void _create() {
    final name = _name.text.trim();
    final income = _parseIncomeMinor();
    if (name.isEmpty || income == null) return;
    Navigator.of(context).pop(
      SpaceDraft(
        name: name,
        avatar: _avatar,
        currency: _currency,
        defaultIncome: income,
        bringIn: _bringIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New shared space',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'A room for a whole month\'s money you manage together.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('spaceNameField'),
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Space name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _create(),
              ),
              const SizedBox(height: 16),
              Text('Avatar', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final emoji in _avatars)
                    ChoiceChip(
                      key: Key('spaceAvatar_$emoji'),
                      selected: _avatar == emoji,
                      onSelected: (_) => setState(() => _avatar = emoji),
                      label: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PrimaryCurrency>(
                key: const Key('spaceCurrencyDropdown'),
                initialValue: _currency,
                decoration: const InputDecoration(
                  labelText: 'Shared currency',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final currency in PrimaryCurrency.values)
                    DropdownMenuItem(
                      value: currency,
                      child: Text(currency.code.displayName),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _currency = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('spaceIncomeField'),
                controller: _income,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Our income',
                  helperText:
                      'What the space takes home together per month, in '
                      '${_currency.code.symbol}.',
                  prefixText: '${_currency.code.symbol} ',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Bring in the past',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<BringInPast>(
                segments: const [
                  ButtonSegment(
                    value: BringInPast.thisMonth,
                    label: Text('This month'),
                  ),
                  ButtonSegment(
                    value: BringInPast.thisYear,
                    label: Text('This year'),
                  ),
                  ButtonSegment(
                    value: BringInPast.everything,
                    label: Text('Everything'),
                  ),
                ],
                selected: {_bringIn},
                onSelectionChanged: (selection) =>
                    setState(() => _bringIn = selection.first),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('createSpaceButton'),
                  onPressed: _create,
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
