import 'package:flutter/material.dart';
import '../models/vault_entry.dart';

/// Presentation only. The complete ledger remains available to integrity checks
/// and the item builder, including reversal references outside the visible page.
class VaultHistoryPages extends StatefulWidget {
  const VaultHistoryPages(
      {super.key, required this.entries, required this.itemBuilder});
  final List<VaultEntry> entries;
  final Widget Function(VaultEntry) itemBuilder;

  @override
  State<VaultHistoryPages> createState() => _VaultHistoryPagesState();
}

class _VaultHistoryPagesState extends State<VaultHistoryPages> {
  static const _pageSize = 20;
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final _header = GlobalKey();
  int _year = 0, _month = 0, _page = 0;

  /// Contributions belong to their recorded month, not the later sweep date.
  (int, int) _period(VaultEntry entry) {
    final month = entry.yearMonth;
    if (month != null &&
        RegExp(r'^[1-9]\d{3}-(0[1-9]|1[0-2])$').hasMatch(month)) {
      return (int.parse(month.substring(0, 4)), int.parse(month.substring(5)));
    }
    final local = entry.createdAt.toLocal();
    return (local.year, local.month);
  }

  void _change(VoidCallback update) {
    setState(update);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _header.currentContext;
      if (mounted && context != null) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 200));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = [...widget.entries]..sort((a, b) {
        final time = b.createdAt.compareTo(a.createdAt);
        if (time != 0) return time;
        final month = (b.yearMonth ?? '').compareTo(a.yearMonth ?? '');
        return month != 0 ? month : b.id.compareTo(a.id);
      });
    final years = entries.map((e) => _period(e).$1).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    // Retain a selected year after live removal so the empty result is clear.
    if (_year != 0 && !years.contains(_year)) {
      years.add(_year);
      years.sort((a, b) => b.compareTo(a));
    }
    final matches = entries.where((entry) {
      final (year, month) = _period(entry);
      return (_year == 0 || _year == year) && (_month == 0 || _month == month);
    }).toList();
    final pages = (matches.length + _pageSize - 1) ~/ _pageSize;
    final page = pages == 0 ? 0 : _page.clamp(0, pages - 1);
    _page = page;
    final visible = matches.skip(page * _pageSize).take(_pageSize);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(key: _header, spacing: 20, runSpacing: 8, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Year'),
          DropdownButton<int>(
              key: const Key('vaultHistoryYear'),
              value: _year,
              items: [
                const DropdownMenuItem(value: 0, child: Text('All years')),
                for (final year in years)
                  DropdownMenuItem(value: year, child: Text('$year')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _change(() {
                    _year = value;
                    _month = 0;
                    _page = 0;
                  });
                }
              }),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Month'),
          DropdownButton<int>(
              key: const Key('vaultHistoryMonth'),
              value: _month,
              items: [
                const DropdownMenuItem(value: 0, child: Text('All months')),
                for (var i = 0; i < 12; i++)
                  DropdownMenuItem(value: i + 1, child: Text(_months[i])),
              ],
              onChanged: (value) {
                if (value != null) {
                  _change(() {
                    _month = value;
                    _page = 0;
                  });
                }
              }),
        ]),
      ]),
      const Text('Newest first · Filters use the recorded month.'),
      if (matches.isEmpty)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(entries.isEmpty
                ? 'No contributions recorded yet.'
                : 'No history matches these filters.')),
      for (final entry in visible)
        KeyedSubtree(
            key: ValueKey(entry.operationKey),
            child: widget.itemBuilder(entry)),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
              'Page ${pages == 0 ? 0 : page + 1} of $pages · ${matches.length} entries',
              key: const Key('vaultHistoryPage'),
              textAlign: TextAlign.center)),
      Wrap(alignment: WrapAlignment.center, spacing: 16, children: [
        OutlinedButton.icon(
            key: const Key('vaultHistoryPrevious'),
            onPressed: page > 0 ? () => _change(() => _page = page - 1) : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous')),
        OutlinedButton.icon(
            key: const Key('vaultHistoryNext'),
            onPressed:
                page + 1 < pages ? () => _change(() => _page = page + 1) : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next')),
      ]),
    ]);
  }
}
