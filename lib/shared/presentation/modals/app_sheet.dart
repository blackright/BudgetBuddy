import 'package:flutter/material.dart';

import 'app_modal_tokens.dart';

/// Presents the shared modal sheet route.
///
/// This mirrors [showModalBottomSheet] while setting the app defaults: a
/// scroll-controlled, safe-area-aware sheet with a theme drag handle and a
/// bounded width on large screens.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Color? backgroundColor,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints = AppModalTokens.sheetConstraints,
  Color? barrierColor,
  bool isScrollControlled = true,
  double scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle = true,
  bool useSafeArea = true,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
  AnimationStyle? sheetAnimationStyle,
  bool? requestFocus,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    backgroundColor: backgroundColor,
    barrierLabel: barrierLabel,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
    sheetAnimationStyle: sheetAnimationStyle,
    requestFocus: requestFocus,
  );
}

/// The shared sheet shell: a clear header, a scrollable body and a sticky
/// footer that stays reachable while the keyboard is open.
class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    this.title,
    this.subtitle,
    this.titleStyle,
    this.leading,
    required this.body,
    this.footer,
    this.showCloseButton = true,
    this.closeTooltip = 'Close',
    this.onClose,
    this.bodyScrollable = true,
  });

  static const closeKey = Key('appSheetClose');
  static const titleKey = Key('appSheetTitle');
  static const bodyKey = Key('appSheetBody');
  static const footerKey = Key('appSheetFooter');

  final String? title;
  final String? subtitle;

  /// Overrides the default `titleLarge` header style. The title colour still
  /// follows the active scheme so dark mode remains legible.
  final TextStyle? titleStyle;
  final Widget? leading;
  final Widget body;
  final Widget? footer;
  final bool showCloseButton;
  final String closeTooltip;
  final VoidCallback? onClose;

  /// Set to `false` when [body] owns its scroll view (for example a searchable
  /// picker list with an `Expanded` result list).
  final bool bodyScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom > media.padding.bottom
        ? media.viewInsets.bottom
        : media.padding.bottom;
    final hasHeader =
        title != null || subtitle != null || leading != null || showCloseButton;

    return AnimatedPadding(
      duration: media.disableAnimations
          ? Duration.zero
          : AppModalTokens.keyboardInsetDuration,
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: LayoutBuilder(builder: (context, constraints) {
        // A very long title at 200% text must not consume the whole sheet and
        // push the body/footer out of view. The header keeps its natural height
        // when it fits and becomes scrollable when it does not.
        final maxHeaderHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight * 0.45 : 240.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHeader)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeaderHeight),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: AppModalTokens.sheetHeaderPadding,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (leading != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: leading,
                          ),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                Semantics(
                                  header: true,
                                  child: Text(
                                    title!,
                                    key: titleKey,
                                    style: titleStyle?.copyWith(
                                          color: scheme.onSurface,
                                        ) ??
                                        theme.textTheme.titleLarge?.copyWith(
                                          color: scheme.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (showCloseButton)
                          IconButton(
                            key: closeKey,
                            tooltip: closeTooltip,
                            onPressed: onClose ??
                                () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.close),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            Flexible(
              child: bodyScrollable
                  ? SingleChildScrollView(
                      key: bodyKey,
                      padding: AppModalTokens.sheetBodyPadding,
                      child: body,
                    )
                  : KeyedSubtree(key: bodyKey, child: body),
            ),
            if (footer != null)
              Container(
                key: footerKey,
                padding: AppModalTokens.sheetFooterPadding,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  border: Border(
                    top: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
                child: footer,
              ),
          ],
        );
      }),
    );
  }
}
