import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../input_formatters/thousands_separator_input_formatter.dart';
import '../money_format.dart';

/// The one money-entry field the whole app uses (FR-007).
///
/// It wraps a [TextFormField] and adds the shared behaviour every amount box
/// needs, so screens stop re-implementing it:
/// - **Thousands grouping** while typing (`1000000` → `1,000,000`) via
///   [ThousandsSeparatorInputFormatter].
/// - **Select-all-on-focus** when the field already holds text, so a prefilled
///   `0.00` (or a previous amount) is replaced by the first keystroke instead
///   of being typed into (FR-003, FR-004).
/// - **Re-sync on context change** through [syncKey]: when the identity behind
///   the field changes (active profile, selected month, personal↔shared
///   space), the text is refreshed from [initialValue] so the previous
///   context's number never lingers (FR-010).
/// - **One parser**: [onChanged]/[onSubmitted] report a `double?` parsed by
///   [parseMoneyInput], so grouping never corrupts the value (FR-002).
///
/// Percentage fields must NOT use this widget (they get select-all-on-focus but
/// no grouping, FR-009) — see `selectAllOnFocus`.
class MoneyField extends StatefulWidget {
  const MoneyField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.helperText,
    this.hintText,
    this.prefixText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.syncKey,
    this.enabled = true,
    this.autofocus = false,
    this.fractionDigits,
    this.formatInitial,
    this.textInputAction,
    this.decoration,
  });

  /// External controller. When `null` the field owns and disposes its own.
  final TextEditingController? controller;

  /// Seed value (major units) used when the field owns its controller and to
  /// re-sync when [syncKey] changes. `null` renders an empty field.
  final double? initialValue;

  final String? label;
  final String? helperText;
  final String? hintText;

  /// Rendered inside the field, e.g. `'€ '`.
  final String? prefixText;

  /// Receives the raw text, like a normal [FormFieldValidator].
  final FormFieldValidator<String>? validator;

  /// Reports the parsed amount (`null` when blank/invalid).
  final ValueChanged<double?>? onChanged;

  /// Reports the parsed amount when the user submits.
  final ValueChanged<double?>? onSubmitted;

  /// Fired alongside [onSubmitted] (e.g. to save on keyboard "done").
  final VoidCallback? onEditingComplete;

  /// Identifies the context behind the field (profile id, month, space). When it
  /// changes between rebuilds the text is refreshed from [initialValue].
  final Object? syncKey;

  final bool enabled;
  final bool autofocus;

  /// Fixed decimal places for [initialValue]; `null` trims trailing zeros (max
  /// two). Ignored when [formatInitial] is given.
  final int? fractionDigits;

  /// Full control over how [initialValue] is rendered.
  final String Function(double value)? formatInitial;

  final TextInputAction? textInputAction;

  /// Replaces the decoration built from [label]/[helperText]/[prefixText].
  final InputDecoration? decoration;

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  late TextEditingController _controller;
  late bool _ownsController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
    _focusNode.addListener(_handleFocusChange);
  }

  void _attachController(TextEditingController? external) {
    _ownsController = external == null;
    _controller = external ?? TextEditingController();
    if (_ownsController) _controller.text = _formatValue(widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant MoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      _attachController(widget.controller);
      return;
    }

    // Re-sync only when the underlying context changes — never on an unrelated
    // rebuild, so text the user is typing is not overwritten.
    if (widget.syncKey != oldWidget.syncKey) {
      final text = _formatValue(widget.initialValue);
      if (_controller.text != text) {
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus || _controller.text.isEmpty) return;
    // Select on focus after the frame so the tap's own caret placement does not
    // overwrite it. A second tap (already focused) still lets the user position
    // the caret normally.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focusNode.hasFocus || !_controller.text.isNotEmpty) {
        return;
      }
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  String _formatValue(double? value) {
    if (value == null) return '';
    if (widget.formatInitial != null) return widget.formatInitial!(value);
    final digits = widget.fractionDigits;
    final pattern = digits == null
        ? '#,##0.##'
        : digits <= 0
            ? '#,##0'
            : '#,##0.${'0' * digits}';
    return NumberFormat(pattern, 'en_US').format(value);
  }

  void _handleChanged(String text) =>
      widget.onChanged?.call(parseMoneyInput(text));

  void _handleSubmitted(String text) {
    widget.onSubmitted?.call(parseMoneyInput(text));
    widget.onEditingComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.decoration ??
        InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
          helperText: widget.helperText,
          helperMaxLines: 2,
          hintText: widget.hintText,
          prefixText: widget.prefixText,
        );

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: widget.textInputAction,
      inputFormatters: const [ThousandsSeparatorInputFormatter()],
      decoration: decoration,
      validator: widget.validator,
      onChanged: _handleChanged,
      onFieldSubmitted: _handleSubmitted,
    );
  }
}

/// Selects the whole text of [controller] every time it gains focus, without
/// grouping (FR-009 — percentage fields).
///
/// Attach one to a `TextField`/`TextFormField` that is not a [MoneyField]:
///
/// ```dart
/// final node = selectAllOnFocus();
/// // ... FocusNode node = selectAllOnFocus(controller);
/// ```
FocusNode selectAllOnFocus(TextEditingController controller) {
  final node = FocusNode();
  node.addListener(() {
    if (!node.hasFocus || controller.text.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!node.hasFocus || controller.text.isEmpty) return;
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
    });
  });
  return node;
}
