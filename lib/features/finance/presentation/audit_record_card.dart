import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/audit_event.dart';
import '../../vault/presentation/vault_time.dart';
import 'audit_values.dart';
import '../../settings/providers/audit_diagnostics_provider.dart';

class AuditRecordCard extends StatelessWidget {
  const AuditRecordCard(
      {super.key,
      required this.event,
      required this.expanded,
      required this.onExpansionChanged,
      required this.author});
  final AuditEvent event;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final action = event.action.toLowerCase();
    final destructive = action.contains('delete') ||
        action.contains('reversal') ||
        action.contains('conflict');
    final accent = destructive
        ? colors.error
        : action.contains('refund')
            ? colors.tertiary
            : colors.primary;
    final icon = action.contains('refund')
        ? Icons.replay_rounded
        : destructive
            ? Icons.undo_rounded
            : action.startsWith('vault')
                ? Icons.savings_outlined
                : action.startsWith('income')
                    ? Icons.account_balance_wallet_outlined
                    : action.contains('transfer')
                        ? Icons.swap_horiz_rounded
                        : action.startsWith('month')
                            ? Icons.event_available_outlined
                            : action.startsWith('sharedmember')
                                ? Icons.manage_accounts_outlined
                                : action.contains('update')
                                    ? Icons.edit_note_rounded
                                    : Icons.receipt_long_outlined;
    final amount = auditHeadlineAmount(event);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: expanded ? accent : colors.outlineVariant)),
      child: DecoratedBox(
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accent, width: 4))),
          child: ExpansionTile(
            key: ValueKey('record:${event.id}:${event.syncGuid}:$expanded'),
            initiallyExpanded: expanded,
            onExpansionChanged: onExpansionChanged,
            tilePadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            shape: const Border(),
            collapsedShape: const Border(),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: accent, size: 22)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(auditActionLabel(event.action),
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: accent)),
                      const SizedBox(height: 3),
                      Text(auditObjectName(event),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ])),
              ]),
              const SizedBox(height: 10),
              Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Badge(
                        label:
                            event.evidenceJson == null ? 'Legacy' : 'Recorded',
                        icon: event.evidenceJson == null
                            ? Icons.history
                            : Icons.description_outlined),
                    Text(formatVaultTime(event.timestamp),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant)),
                  ]),
              if (amount != null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(amount,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700))),
            ]),
            children: [_AuditDetails(event: event, author: author)],
          )),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Flexible(
            child: Text(label, style: Theme.of(context).textTheme.labelSmall))
      ]));
}

class _AuditDetails extends ConsumerStatefulWidget {
  const _AuditDetails({required this.event, required this.author});
  final AuditEvent event;
  final String author;
  @override
  ConsumerState<_AuditDetails> createState() => _AuditDetailsState();
}

class _AuditDetailsState extends ConsumerState<_AuditDetails> {
  bool allFields = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final event = widget.event, fields = auditFieldChanges(widget.event);
    final changed = fields.where((f) => f.changed).toList();
    final unchanged = fields.where((f) => !f.changed).toList();
    final hasBefore =
        event.previousValue != null && event.previousValue != 'null';
    final hasAfter = event.newValue != null && event.newValue != 'null';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Divider(height: 12),
      Container(
          key: ValueKey('audit-metadata-${event.id}:${event.syncGuid}'),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 10, runSpacing: 2, children: [
              Text('Author: ${widget.author}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text('Recorded ${formatVaultTime(event.timestamp)}',
                  semanticsLabel:
                      'Action recorded at: ${formatVaultTime(event.timestamp)}',
                  style: theme.textTheme.bodySmall),
            ]),
            if (event.evidenceJson == null)
              Text('Legacy — not fully verified',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant)),
          ])),
      const SizedBox(height: 10),
      Wrap(
          spacing: 8,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('What changed',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            if (changed.isNotEmpty)
              Text('${changed.length} fields',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant)),
          ]),
      if (changed.isEmpty)
        Text('No field changes are available in this record.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant)),
      if (!hasBefore && hasAfter)
        const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('New record. No previous snapshot was recorded.')),
      if (hasBefore && !hasAfter)
        const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Record removed. Showing its last recorded values.')),
      for (final section in [
        'Money',
        'Record details',
        'Dates',
        'Other details'
      ])
        if (changed.any((f) => f.section == section)) ...[
          _SectionHeading(label: section),
          for (final field in changed.where((f) => f.section == section))
            _ChangeRow(
                field: field, showBefore: hasBefore, showAfter: hasAfter),
        ],
      if (unchanged.isNotEmpty) ...[
        Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
                onPressed: () => setState(() => allFields = !allFields),
                icon: Icon(allFields ? Icons.unfold_less : Icons.unfold_more),
                label: Text(allFields
                    ? 'Hide unchanged fields'
                    : 'Show all recorded fields'))),
        if (allFields)
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Unchanged recorded fields',
                        style: theme.textTheme.labelLarge),
                    for (final field in unchanged)
                      Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child:
                              SelectableText('${field.label}: ${field.after}')),
                  ])),
      ],
      if (ref.watch(auditDiagnosticsEnabledProvider)) ...[
        const SizedBox(height: 12),
        ExpansionTile(
          key: ValueKey('technical:${event.id}:${event.syncGuid}'),
          tilePadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          title: const Text('Technical details'),
          leading: const Icon(Icons.code_rounded, size: 20),
          children: [
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12)),
                child: SelectableText(
                    const JsonEncoder.withIndent('  ').convert({
                      'action': event.action,
                      'objectType': event.objectType,
                      'eventReference': event.syncGuid,
                      'authorIdentity': event.userIdentity,
                      'originalBefore': event.previousValue,
                      'originalAfter': event.newValue,
                      'evidence': event.evidenceJson,
                      'hash': event.hash,
                      'previousHash': event.previousHash,
                      'signature': event.signature,
                    }),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontFamily: 'monospace')))
          ],
        ),
      ],
    ]);
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Row(children: [
        Icon(
            switch (label) {
              'Money' => Icons.payments_outlined,
              'Dates' => Icons.event_outlined,
              _ => Icons.subject_rounded
            },
            size: 18,
            color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge))
      ]));
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow(
      {required this.field, required this.showBefore, required this.showAfter});
  final AuditFieldChange field;
  final bool showBefore, showAfter;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final longValue = field.key == 'notes' ||
        field.before.contains('\n') ||
        field.after.contains('\n') ||
        field.before.length > 160 ||
        field.after.length > 160;
    final comparison = showBefore && showAfter;
    final semantic = comparison
        ? '${field.label}. Before: ${field.before}. After: ${field.after}.'
        : '${field.label}: ${showAfter ? field.after : field.before}';
    return Container(
        key: ValueKey('audit-change-${field.key}'),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8)),
        child: SelectableText.rich(
            TextSpan(style: theme.textTheme.bodyMedium, children: [
              TextSpan(
                  text: '${field.label}${longValue ? '\n' : ': '}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (comparison) ...[
                TextSpan(
                    text: '${longValue ? 'Before: ' : ''}${field.before}',
                    style: TextStyle(color: colors.onSurfaceVariant)),
                TextSpan(
                    text: longValue ? '\nAfter: ' : ' → ',
                    style: TextStyle(color: colors.primary)),
              ],
              TextSpan(
                  text: showAfter ? field.after : field.before,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            semanticsLabel: semantic));
  }
}
