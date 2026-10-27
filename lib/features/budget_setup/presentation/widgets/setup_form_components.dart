import 'package:flutter/material.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../shared/presentation/widgets/money_field.dart';

class SetupSurface extends StatelessWidget {
  const SetupSurface({super.key, required this.child, this.highlight = false});
  final Widget child;
  final bool highlight;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: highlight
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: .45)
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: .6))),
      child: child);
}

/// Controllers hold raw grouped text; exact parsing belongs to the domain,
/// not MoneyField's legacy double callback. Preserve cursor edits and dispose.
class SetupInput extends StatefulWidget {
  const SetupInput(
      {super.key,
      required this.label,
      required this.text,
      required this.onChanged,
      this.currency,
      this.error,
      this.helper,
      this.notes = false});
  final String label, text;
  final ValueChanged<String> onChanged;
  final CurrencyCode? currency;
  final String? error, helper;
  final bool notes;
  @override
  State<SetupInput> createState() => _SetupInputState();
}

class _SetupInputState extends State<SetupInput> {
  late final TextEditingController controller =
      TextEditingController(text: widget.text);
  @override
  void didUpdateWidget(covariant SetupInput old) {
    super.didUpdateWidget(old);
    if (controller.text != widget.text) {
      controller.value = TextEditingValue(
          text: widget.text,
          selection: TextSelection.collapsed(offset: widget.text.length));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
        labelText: widget.label,
        helperText: widget.helper,
        errorText: widget.error,
        errorMaxLines: 4,
        helperMaxLines: 3,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface);
    Widget field;
    if (widget.currency != null) {
      field = MoneyField(
          controller: controller,
          fractionDigits: widget.currency!.exponent,
          decoration: decoration.copyWith(
              prefixText: '${widget.currency!.name.toUpperCase()} '),
          onChanged: (_) => widget.onChanged(controller.text));
    } else {
      field = TextField(
          controller: controller,
          decoration: decoration,
          maxLines: widget.notes ? 3 : 1,
          textCapitalization: TextCapitalization.sentences,
          onChanged: widget.onChanged);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      field,
      if (widget.error != null)
        Semantics(
            liveRegion: true,
            label: widget.error,
            child: const SizedBox.shrink()),
    ]);
  }
}

Future<bool> confirmDraftRemoval(BuildContext context,
        {required String title, required String message}) async =>
    await showDialog<bool>(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(message), actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep entries')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'))
            ])) ??
    false;

/// Local presentation policy; never persists or changes the user's theme/font.
class SetupPresentation extends StatelessWidget {
  const SetupPresentation({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const minimum = WidgetStatePropertyAll(Size(48, 48));
    return Theme(
        data: theme.copyWith(
          materialTapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.standard,
          filledButtonTheme: FilledButtonThemeData(
              style: (theme.filledButtonTheme.style ?? const ButtonStyle())
                  .copyWith(minimumSize: minimum)),
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: (theme.outlinedButtonTheme.style ?? const ButtonStyle())
                  .copyWith(minimumSize: minimum)),
          textButtonTheme: TextButtonThemeData(
              style: (theme.textButtonTheme.style ?? const ButtonStyle())
                  .copyWith(minimumSize: minimum)),
        ),
        child: FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(), child: child));
  }
}

/// Prefer a vertical action group when large text makes a row impractical.
class SetupActions extends StatelessWidget {
  const SetupActions({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final stacked = box.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(16) > 24;
        return stacked
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      children[i]
                    ]
                  ])
            : Row(children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: children[i])
                ]
              ]);
      });
}

/// Run after an explicit failed Continue, after any invalid source is expanded.
/// Reuses actual editable/dropdown focus nodes, including MoneyField's node.
void focusFirstSetupError(BuildContext context) {
  Element? target;
  void scan(Element element) {
    if (target != null) return;
    final w = element.widget;
    if (w is SetupValidationTarget && w.error != null) {
      target = element;
      return;
    }
    if (w is InputDecorator && w.decoration.errorText != null) {
      target = element;
      return;
    }
    if (w is SetupInput && w.error != null) {
      target = element;
      return;
    }
    element.visitChildren(scan);
  }

  context.visitChildElements(scan);
  if (target == null) return;
  FocusNode? node;
  void findFocus(Element element) {
    if (node != null) return;
    final widget = element.widget;
    if (widget is EditableText) {
      node = widget.focusNode;
      return;
    }
    if (widget is Focus && widget.focusNode?.canRequestFocus == true) {
      node = widget.focusNode;
    }
    element.visitChildren(findFocus);
  }

  target!.visitChildren(findFocus);
  node?.requestFocus();
  Scrollable.ensureVisible(target!, alignment: .15);
}

/// An error for a date/choice group still needs a reachable focus destination.
class SetupValidationTarget extends StatefulWidget {
  const SetupValidationTarget(
      {super.key, required this.error, required this.child});
  final String? error;
  final Widget child;
  @override
  State<SetupValidationTarget> createState() => _SetupValidationTargetState();
}

class _SetupValidationTargetState extends State<SetupValidationTarget> {
  final node = FocusNode();
  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
      focusNode: node,
      skipTraversal: widget.error == null,
      child: Semantics(
          liveRegion: widget.error != null,
          label: widget.error,
          child: widget.child));
}
