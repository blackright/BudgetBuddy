import 'package:flutter/material.dart';

import 'app_modal_tokens.dart';

/// Presents a themed dialog route.
///
/// This mirrors [showDialog] so overlay call sites can migrate without changing
/// their navigation, result or dismissal behaviour.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  bool fullscreenDialog = false,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior: traversalEdgeBehavior,
    fullscreenDialog: fullscreenDialog,
  );
}

/// The shared alert dialog surface.
///
/// It is an [AlertDialog] underneath, so existing `find.byType(AlertDialog)`
/// checks and every caller parameter keep working. Only the visual defaults are
/// supplied here; content, actions and result handling stay with the caller.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.icon,
    this.iconPadding,
    this.iconColor,
    this.title,
    this.titlePadding,
    this.titleTextStyle,
    this.content,
    this.contentPadding,
    this.contentTextStyle,
    this.actions,
    this.actionsPadding,
    this.actionsAlignment,
    this.actionsOverflowAlignment,
    this.actionsOverflowDirection,
    this.actionsOverflowButtonSpacing,
    this.buttonPadding,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.semanticLabel,
    this.insetPadding,
    this.clipBehavior,
    this.shape,
    this.alignment,
    this.constraints,
    this.scrollable = false,
  });

  final Widget? icon;
  final EdgeInsetsGeometry? iconPadding;
  final Color? iconColor;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final TextStyle? titleTextStyle;
  final Widget? content;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? contentTextStyle;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? actionsPadding;
  final MainAxisAlignment? actionsAlignment;
  final OverflowBarAlignment? actionsOverflowAlignment;
  final VerticalDirection? actionsOverflowDirection;
  final double? actionsOverflowButtonSpacing;
  final EdgeInsetsGeometry? buttonPadding;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final String? semanticLabel;
  final EdgeInsets? insetPadding;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    return AlertDialog(
      icon: icon,
      iconPadding: iconPadding,
      iconColor: iconColor ?? scheme.primary,
      title: title,
      titlePadding: titlePadding,
      titleTextStyle: titleTextStyle ??
          theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
      content: content,
      contentPadding: contentPadding,
      contentTextStyle: contentTextStyle ??
          theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
      actions: actions,
      actionsPadding: actionsPadding ?? AppModalTokens.dialogActionsPadding,
      actionsAlignment: actionsAlignment,
      actionsOverflowAlignment: actionsOverflowAlignment,
      actionsOverflowDirection: actionsOverflowDirection,
      actionsOverflowButtonSpacing: actionsOverflowButtonSpacing,
      buttonPadding: buttonPadding,
      backgroundColor: backgroundColor ?? scheme.surfaceContainerHigh,
      elevation: elevation ?? 3,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      semanticLabel: semanticLabel,
      insetPadding: insetPadding ?? AppModalTokens.dialogInsetPadding,
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppModalTokens.dialogRadius),
          ),
      alignment: alignment,
      constraints: constraints ??
          const BoxConstraints(maxWidth: AppModalTokens.dialogMaxWidth),
      scrollable: scrollable,
    );
  }
}

/// The shared simple-dialog surface for a list of choices.
///
/// It stays a [SimpleDialog] underneath so existing type-based checks and
/// `Navigator.pop` result handling remain valid.
class AppSimpleDialog extends StatelessWidget {
  const AppSimpleDialog({
    super.key,
    this.title,
    this.titlePadding,
    this.titleTextStyle,
    this.children,
    this.contentPadding,
    this.contentTextStyle,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.semanticLabel,
    this.insetPadding,
    this.clipBehavior,
    this.shape,
    this.alignment,
    this.constraints,
  });

  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final TextStyle? titleTextStyle;
  final List<Widget>? children;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? contentTextStyle;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final String? semanticLabel;
  final EdgeInsets? insetPadding;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    return SimpleDialog(
      title: title,
      titlePadding: titlePadding ?? const EdgeInsets.fromLTRB(24, 24, 24, 0),
      titleTextStyle: titleTextStyle ??
          theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
      contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(0, 12, 0, 16),
      contentTextStyle: contentTextStyle ??
          theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      backgroundColor: backgroundColor ?? scheme.surfaceContainerHigh,
      elevation: elevation ?? 3,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      semanticLabel: semanticLabel,
      insetPadding: insetPadding ?? AppModalTokens.dialogInsetPadding,
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppModalTokens.dialogRadius),
          ),
      alignment: alignment,
      constraints: constraints ??
          const BoxConstraints(maxWidth: AppModalTokens.dialogMaxWidth),
      children: children,
    );
  }
}
