import 'package:flutter/material.dart';

import 'app_modal_tokens.dart';

/// Presents the shared themed popup menu.
///
/// The actual appearance comes from [ThemeData.popupMenuTheme]; this wrapper
/// gives call sites one import and one place to add future menu-wide
/// behaviour without restyling each menu locally.
Future<T?> showAppMenu<T>({
  required BuildContext context,
  RelativeRect? position,
  PopupMenuPositionBuilder? positionBuilder,
  required List<PopupMenuEntry<T>> items,
  T? initialValue,
  double? elevation,
  Color? shadowColor,
  Color? surfaceTintColor,
  String? semanticLabel,
  ShapeBorder? shape,
  EdgeInsetsGeometry? menuPadding,
  Color? color,
  bool useRootNavigator = false,
  BoxConstraints? constraints,
  Clip clipBehavior = Clip.antiAlias,
  RouteSettings? routeSettings,
  AnimationStyle? popUpAnimationStyle,
  bool? requestFocus,
}) {
  final theme = Theme.of(context), scheme = theme.colorScheme;
  return showMenu<T>(
    context: context,
    position: position,
    positionBuilder: positionBuilder,
    items: items,
    initialValue: initialValue,
    elevation: elevation ?? 3,
    shadowColor: shadowColor,
    surfaceTintColor: surfaceTintColor ?? Colors.transparent,
    semanticLabel: semanticLabel,
    shape: shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppModalTokens.menuRadius),
        ),
    menuPadding: menuPadding,
    color: color ?? scheme.surfaceContainerHigh,
    useRootNavigator: useRootNavigator,
    constraints: constraints,
    clipBehavior: clipBehavior,
    routeSettings: routeSettings,
    popUpAnimationStyle: popUpAnimationStyle,
    requestFocus: requestFocus,
  );
}
