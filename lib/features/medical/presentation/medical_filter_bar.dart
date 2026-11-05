import 'package:flutter/material.dart';

import '../providers/medical_providers.dart';
import 'medical_bill_view_state.dart';
import 'medical_theme.dart';

/// Search, group tabs, arrangement and month filters for the Medical inbox.
class MedicalFilterBar extends StatefulWidget {
  const MedicalFilterBar({
    super.key,
    required this.filters,
    required this.inbox,
    required this.onChanged,
    required this.onClear,
  });

  final MedicalInboxFilters filters;
  final MedicalInbox? inbox;
  final ValueChanged<MedicalInboxFilters> onChanged;
  final VoidCallback onClear;

  @override
  State<MedicalFilterBar> createState() => _MedicalFilterBarState();
}

class _MedicalFilterBarState extends State<MedicalFilterBar> {
  late final TextEditingController _search;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.filters.query);
  }

  @override
  void didUpdateWidget(covariant MedicalFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && _search.text != widget.filters.query) {
      _search.text = widget.filters.query;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.filters;
    final data = widget.inbox;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          MedicalTheme.screenGutter, 8, MedicalTheme.screenGutter, 4),
      child: Card(
        elevation: 0,
        color: MedicalTheme.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MedicalTheme.cardRadius),
          side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(MedicalTheme.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('medicalInboxSearchField'),
                controller: _search,
                focusNode: _focus,
                decoration: InputDecoration(
                  hintText: 'Search provider, person or service',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: filters.query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _search.clear();
                            widget.onChanged(filters.copyWith(query: ''));
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(MedicalTheme.inputRadius)),
                  isDense: true,
                ),
                onChanged: (value) =>
                    widget.onChanged(filters.copyWith(query: value)),
              ),
              const SizedBox(height: 14),
              Text(
                'SHOW',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: MedicalTheme.subtleText(context),
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final options = [
                    for (final group in MedicalInboxGroup.values)
                      _groupOption(context, group),
                  ];
                  if (constraints.maxWidth < 360) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < options.length; i++) ...[
                          options[i],
                          if (i != options.length - 1)
                            const SizedBox(height: 8),
                        ],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      for (var i = 0; i < options.length; i++) ...[
                        Expanded(child: options[i]),
                        if (i != options.length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final arrangement =
                      DropdownButtonFormField<MedicalInboxArrangement>(
                    key: const Key('medicalInboxArrangementField'),
                    initialValue: filters.arrangement,
                    isExpanded: true,
                    decoration: InputDecoration(
                        labelText: 'Arrangement',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                MedicalTheme.inputRadius))),
                    items: const [
                      DropdownMenuItem(
                          value: MedicalInboxArrangement.all,
                          child: Text('All', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(
                          value: MedicalInboxArrangement.selfPay,
                          child: Text('I pay the provider',
                              overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(
                          value: MedicalInboxArrangement.insurerPaid,
                          child: Text('Insurance pays the provider',
                              overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        widget.onChanged(filters.copyWith(arrangement: value));
                      }
                    },
                  );
                  final month = DropdownButtonFormField<String?>(
                    key: const Key('medicalInboxMonthField'),
                    initialValue: filters.month,
                    isExpanded: true,
                    decoration: InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                MedicalTheme.inputRadius))),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All months',
                              overflow: TextOverflow.ellipsis)),
                      for (final value
                          in data?.monthOptions ?? const <String>[])
                        DropdownMenuItem<String?>(
                            value: value,
                            child:
                                Text(value, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (value) =>
                        widget.onChanged(filters.copyWith(month: value)),
                  );
                  if (constraints.maxWidth < 420) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        arrangement,
                        const SizedBox(height: 8),
                        month,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: arrangement),
                      const SizedBox(width: 8),
                      Expanded(child: month),
                    ],
                  );
                },
              ),
              if (!filters.isDefault)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('medicalInboxClearFilters'),
                    style:
                        TextButton.styleFrom(minimumSize: const Size(48, 48)),
                    onPressed: () {
                      _search.clear();
                      widget.onClear();
                    },
                    child: const Text('Clear filters'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupOption(BuildContext context, MedicalInboxGroup group) {
    final selected = widget.filters.group == group;
    final color = MedicalTheme.inboxGroupColor(context, group);
    final count = widget.inbox?.count(group) ?? 0;
    return _GroupFilterOption(
      key: Key(
          'medicalInboxGroup${group.name[0].toUpperCase()}${group.name.substring(1)}'),
      label: _groupLabel(group),
      count: count,
      selected: selected,
      color: color,
      icon: MedicalTheme.inboxGroupIcon(group),
      onTap: () => widget.onChanged(widget.filters.copyWith(group: group)),
    );
  }

  static String _groupLabel(MedicalInboxGroup group) => switch (group) {
        MedicalInboxGroup.needsYou => 'Needs you',
        MedicalInboxGroup.waiting => 'Waiting',
        MedicalInboxGroup.closed => 'Closed',
      };
}

class _GroupFilterOption extends StatelessWidget {
  const _GroupFilterOption({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Material(
      color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: selected ? color.withValues(alpha: 0.55) : outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: selected ? 0.18 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? color : null,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 26),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: selected ? color : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
