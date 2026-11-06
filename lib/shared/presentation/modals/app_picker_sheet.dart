import 'package:flutter/material.dart';

import 'app_sheet.dart';

/// One choice in an [AppPickerSheet].
class AppPickerEntry<T> {
  const AppPickerEntry({
    required this.value,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.searchText,
    this.enabled = true,
  });

  final T value;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  /// Extra text included in the search filter when the title is not enough.
  final String? searchText;

  final bool enabled;
}

/// Shows the shared searchable picker and returns the chosen value.
Future<T?> showAppPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<AppPickerEntry<T>> items,
  String? subtitle,
  String searchHint = 'Search',
  String emptyText = 'Nothing to choose',
  T? selected,
  bool loading = false,
  String? errorText,
  VoidCallback? onRetry,
  Widget Function(BuildContext, AppPickerEntry<T>)? entryBuilder,
}) {
  return showAppSheet<T>(
    context,
    builder: (_) => AppPickerSheet<T>(
      title: title,
      subtitle: subtitle,
      items: items,
      searchHint: searchHint,
      emptyText: emptyText,
      selected: selected,
      loading: loading,
      errorText: errorText,
      onRetry: onRetry,
      entryBuilder: entryBuilder,
    ),
  );
}

/// A searchable selection list using the shared sheet shell.
class AppPickerSheet<T> extends StatefulWidget {
  const AppPickerSheet({
    super.key,
    required this.title,
    required this.items,
    this.subtitle,
    this.searchHint = 'Search',
    this.emptyText = 'Nothing to choose',
    this.selected,
    this.loading = false,
    this.errorText,
    this.onRetry,
    this.entryBuilder,
  });

  static const searchKey = Key('appPickerSearch');
  static const emptyKey = Key('appPickerEmpty');
  static const retryKey = Key('appPickerRetry');

  final String title;
  final String? subtitle;
  final List<AppPickerEntry<T>> items;
  final String searchHint;
  final String emptyText;
  final T? selected;
  final bool loading;
  final String? errorText;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext, AppPickerEntry<T>)? entryBuilder;

  @override
  State<AppPickerSheet<T>> createState() => _AppPickerSheetState<T>();
}

class _AppPickerSheetState<T> extends State<AppPickerSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(AppPickerEntry<T> entry) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    final haystack =
        '${entry.searchText ?? ''} ${entry.title} ${entry.subtitle ?? ''}'
            .toLowerCase();
    return haystack.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final visible = widget.items.where(_matches).toList();

    return AppSheet(
      title: widget.title,
      subtitle: widget.subtitle,
      bodyScrollable: false,
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextField(
                key: AppPickerSheet.searchKey,
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: widget.searchHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(child: _content(theme, scheme, visible)),
          ],
        ),
      ),
    );
  }

  Widget _content(
      ThemeData theme, ColorScheme scheme, List<AppPickerEntry<T>> visible) {
    if (widget.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (widget.errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.errorText!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  key: AppPickerSheet.retryKey,
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (visible.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.emptyText,
            key: AppPickerSheet.emptyKey,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final entry = visible[index];
        final selected = entry.value == widget.selected;
        final content = widget.entryBuilder?.call(context, entry) ??
            ListTile(
              leading: entry.leading,
              title: Text(entry.title),
              subtitle: entry.subtitle == null ? null : Text(entry.subtitle!),
              trailing:
                  entry.trailing ?? (selected ? const Icon(Icons.check) : null),
              enabled: entry.enabled,
              onTap: entry.enabled
                  ? () => Navigator.of(context).pop(entry.value)
                  : null,
            );
        return KeyedSubtree(
          key: ValueKey('appPickerItem-${entry.value}'),
          child: widget.entryBuilder == null
              ? content
              : InkWell(
                  onTap: entry.enabled
                      ? () => Navigator.of(context).pop(entry.value)
                      : null,
                  child: content,
                ),
        );
      },
    );
  }
}
