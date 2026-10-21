import 'package:flutter/material.dart';

import 'lock_keys.dart';

/// The shared numeric keypad: a masked entry line and a 0-9 grid (FR-036).
///
/// One widget so the lock's PIN screen and the Settings PIN setup show the same
/// thing, behave the same way under a screen reader, and cannot drift apart. The
/// entry is rendered as dots — the digits themselves are never painted, so a
/// shoulder-surfer sees only how many were typed.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.onSubmit,
    this.maxLength = 8,
  });

  /// The digits typed so far.
  final String value;

  /// Called with the new value on every digit or backspace.
  final ValueChanged<String> onChanged;

  /// When `false`, every key is disabled (a lockout wait is running).
  final bool enabled;

  /// Called by the confirm key; `null` disables that key.
  final VoidCallback? onSubmit;

  /// The longest entry the keypad will build (FR-007's upper bound).
  final int maxLength;

  void _append(String digit) {
    if (!enabled || value.length >= maxLength) return;
    onChanged('$value$digit');
  }

  void _backspace() {
    if (!enabled || value.isEmpty) return;
    onChanged(value.substring(0, value.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const Key(LockKeys.pinKeypad),
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'PIN entry, ${value.length} digits',
          readOnly: true,
          child: Text(
            key: const Key(LockKeys.pinDisplay),
            value.isEmpty ? '' : '•' * value.length,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          _row(context, row.map(_digitButton).toList()),
        _row(context, [
          _actionButton(
            key: const Key(LockKeys.pinBackspace),
            icon: Icons.backspace_outlined,
            label: 'Delete',
            onPressed: enabled && value.isNotEmpty ? _backspace : null,
          ),
          _digitButton('0'),
          _actionButton(
            key: const Key(LockKeys.pinSubmit),
            icon: Icons.check,
            label: 'Confirm PIN',
            onPressed: enabled && value.isNotEmpty && onSubmit != null
                ? onSubmit
                : null,
          ),
        ]),
      ],
    );
  }

  Widget _row(BuildContext context, List<Widget> children) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final child in children)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: child,
              ),
          ],
        ),
      );

  Widget _digitButton(String digit) => Semantics(
        label: 'Digit $digit',
        button: true,
        child: SizedBox(
          width: 72,
          height: 56,
          child: OutlinedButton(
            key: Key('pinKey_$digit'),
            onPressed: enabled ? () => _append(digit) : null,
            child: Text(digit, style: const TextStyle(fontSize: 20)),
          ),
        ),
      );

  Widget _actionButton({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) =>
      Semantics(
        label: label,
        button: true,
        child: SizedBox(
          width: 72,
          height: 56,
          child: IconButton.filledTonal(
            key: key,
            onPressed: onPressed,
            icon: Icon(icon),
            tooltip: label,
          ),
        ),
      );
}
