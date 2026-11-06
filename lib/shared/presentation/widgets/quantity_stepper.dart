import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controlled whole-number quantity control shared by the expense editors.
///
/// The minus/plus buttons and direct entry all report through [onChanged].
/// Validation remains with the caller so the same control can show a form-level
/// error in single entry and a per-item error in bulk entry.
class QuantityStepper extends StatefulWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.label = 'Quantity',
    this.decrementKey,
    this.incrementKey,
    this.inputKey,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String? errorText;
  final bool enabled;
  final String label;
  final Key? decrementKey;
  final Key? incrementKey;
  final Key? inputKey;

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.value}');
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) return;
    final parsed = int.tryParse(_controller.text);
    if (parsed == widget.value) return;
    if (_focus.hasFocus && _controller.text.isEmpty) return;
    _setText('${widget.value}');
  }

  @override
  void dispose() {
    _focus.removeListener(_handleFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _setText(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _handleFocusChange() {
    if (_focus.hasFocus) return;
    final parsed = int.tryParse(_controller.text);
    if (parsed == null || parsed < 1) {
      _setText('1');
      widget.onChanged(1);
      return;
    }
    if (parsed > 999) {
      _setText('999');
      widget.onChanged(999);
      return;
    }
    _setText('$parsed');
  }

  void _onTextChanged(String text) {
    final parsed = int.tryParse(text);
    widget.onChanged(parsed ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final bool canDecrease = widget.enabled && widget.value > 1;
    final bool canIncrease = widget.enabled && widget.value < 999;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label,
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: widget.errorText == null
                    ? scheme.outlineVariant
                    : scheme.error),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              key: widget.decrementKey,
              tooltip: 'Decrease quantity',
              onPressed:
                  canDecrease ? () => widget.onChanged(widget.value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 56,
              child: TextField(
                key: widget.inputKey,
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: _onTextChanged,
              ),
            ),
            IconButton(
              key: widget.incrementKey,
              tooltip: 'Increase quantity',
              onPressed:
                  canIncrease ? () => widget.onChanged(widget.value + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ]),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
      ],
    );
  }
}
