import 'audit_values.dart';
import 'audit_record_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/audit_verify_service.dart';
import '../providers/audit_providers.dart';
import '../../../shared/presentation/financial_feedback.dart';

class AuditHistoryScreen extends ConsumerWidget {
  const AuditHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(budgetContextProvider);
    return Scaffold(
        appBar: AppBar(title: const Text('Audit History')),
        body: ref.watch(auditRowsProvider).when(
            skipLoadingOnRefresh: false,
            data: (rows) => _AuditBody(
                key: ValueKey(
                    '${scope.isShared}:${scope.profileId}:${scope.spaceId}'),
                rows: rows),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'History is unavailable. Check your profile and space permissions.')))));
  }
}

class _AuditBody extends ConsumerStatefulWidget {
  const _AuditBody({super.key, required this.rows});
  final List<AuditEvent> rows;
  @override
  ConsumerState<_AuditBody> createState() => _AuditBodyState();
}

class _AuditBodyState extends ConsumerState<_AuditBody> {
  int year = 0, month = 0, page = 0;
  String action = 'All actions';
  String? expandedRecord;
  bool verifying = false;
  final scroll = ScrollController();
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void change(VoidCallback fn) {
    setState(() {
      expandedRecord = null;
      fn();
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Future<void> verifyHistory() async {
    if (verifying) return;
    setState(() => verifying = true);
    try {
      final result = await ref.refresh(auditVerificationProvider.future);
      if (!mounted) return;
      showFinancialFeedback(context, result.message,
          kind: switch (result.status) {
            AuditStatus.verified => FinancialFeedbackKind.success,
            AuditStatus.failed => FinancialFeedbackKind.error,
            _ => FinancialFeedbackKind.warning,
          });
    } catch (_) {
      if (mounted) {
        showFinancialFeedback(
            context, 'History verification could not finish. Please retry.',
            kind: FinancialFeedbackKind.error);
      }
    } finally {
      if (mounted) setState(() => verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = [...widget.rows]..sort((a, b) {
        final time = b.timestamp.compareTo(a.timestamp);
        return time != 0 ? time : b.syncGuid.compareTo(a.syncGuid);
      });
    final years = rows.map((e) => e.timestamp.toLocal().year).toSet().toList();
    if (year != 0 && !years.contains(year)) years.add(year);
    years.sort((a, b) => b.compareTo(a));
    final actions = rows.map((e) => e.action).toSet().toList()..sort();
    if (action != 'All actions' && !actions.contains(action)) {
      actions.add(action);
    }
    final matches = rows.where((e) {
      final date = e.timestamp.toLocal();
      return (year == 0 || year == date.year) &&
          (month == 0 || month == date.month) &&
          (action == 'All actions' || action == e.action);
    }).toList();
    final pages = (matches.length + 19) ~/ 20;
    page = pages == 0 ? 0 : page.clamp(0, pages - 1);
    final visible = matches.skip(page * 20).take(20).toList();
    final verification = ref.watch(auditVerificationProvider);
    final names = ref.watch(auditAuthorNamesProvider).valueOrNull ??
        const <String, String>{};
    final colors = Theme.of(context).colorScheme, theme = Theme.of(context);
    Widget box(String label, Widget child) => InputDecorator(
        decoration: InputDecoration(
            labelText: label,
            isDense: true,
            filled: true,
            fillColor: colors.surfaceContainerLow,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none)),
        child: DropdownButtonHideUnderline(child: child));
    final yearPicker = box(
        'Year',
        DropdownButton<int>(
            key: const Key('auditYear'),
            isExpanded: true,
            value: year,
            items: [
              const DropdownMenuItem(
                  value: 0,
                  child: Text('All years', overflow: TextOverflow.ellipsis)),
              for (final y in years)
                DropdownMenuItem(value: y, child: Text('$y'))
            ],
            onChanged: (v) {
              if (v != null) {
                change(() {
                  year = v;
                  month = 0;
                  page = 0;
                });
              }
            }));
    final monthPicker = box(
        'Month',
        DropdownButton<int>(
            key: const Key('auditMonth'),
            isExpanded: true,
            value: month,
            items: [
              const DropdownMenuItem(
                  value: 0,
                  child: Text('All months', overflow: TextOverflow.ellipsis)),
              for (var m = 1; m <= 12; m++)
                DropdownMenuItem(
                    value: m,
                    child:
                        Text(_months[m - 1], overflow: TextOverflow.ellipsis))
            ],
            onChanged: (v) {
              if (v != null) {
                change(() {
                  month = v;
                  page = 0;
                });
              }
            }));
    return ListView(
        controller: scroll,
        padding: const EdgeInsets.all(16),
        children: [
          Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outlineVariant)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.history_rounded, color: colors.primary),
                            const SizedBox(width: 8),
                            Flexible(
                                child: Text('Financial timeline',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700)))
                          ]),
                          FilledButton.tonalIcon(
                              onPressed: verification.isLoading || verifying
                                  ? null
                                  : verifyHistory,
                              icon: verifying
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.fact_check_outlined,
                                      size: 18),
                              label: const Text('Verify history')),
                        ]),
                    const SizedBox(height: 4),
                    Text('Read-only history of recorded financial changes.',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 300
                                ? Row(children: [
                                    Expanded(child: yearPicker),
                                    const SizedBox(width: 8),
                                    Expanded(child: monthPicker)
                                  ])
                                : Column(children: [
                                    yearPicker,
                                    const SizedBox(height: 8),
                                    monthPicker
                                  ])),
                    const SizedBox(height: 10),
                    box(
                        'Action',
                        DropdownButton<String>(
                            key: const Key('auditAction'),
                            isExpanded: true,
                            value: action,
                            items: [
                              for (final value in ['All actions', ...actions])
                                DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                        value == 'All actions'
                                            ? value
                                            : auditActionLabel(value),
                                        overflow: TextOverflow.ellipsis))
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                change(() {
                                  action = v;
                                  page = 0;
                                });
                              }
                            })),
                    if (year != 0 || month != 0 || action != 'All actions')
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                              onPressed: () => change(() {
                                    year = 0;
                                    month = 0;
                                    action = 'All actions';
                                    page = 0;
                                  }),
                              icon: const Icon(Icons.filter_alt_off_outlined,
                                  size: 18),
                              label: const Text('Reset filters'))),
                  ])),
          Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                  '${matches.length} ${matches.length == 1 ? 'record' : 'records'}${year != 0 || month != 0 || action != 'All actions' ? ' match your filters' : ''}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: colors.onSurfaceVariant))),
          if (matches.isEmpty)
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Column(children: [
                  Icon(Icons.manage_search_rounded,
                      size: 40, color: colors.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('No audit records match these filters.',
                      textAlign: TextAlign.center)
                ])),
          for (final event in visible)
            AuditRecordCard(
                key: ValueKey('${event.id}:${event.syncGuid}'),
                event: event,
                author: names[event.userIdentity] ?? 'Recorded author',
                expanded: expandedRecord == '${event.id}:${event.syncGuid}',
                onExpansionChanged: (open) => setState(() => expandedRecord =
                    open ? '${event.id}:${event.syncGuid}' : null)),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  'Page ${pages == 0 ? 0 : page + 1} of $pages · ${matches.length} records',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall)),
          if (pages > 1)
            Wrap(alignment: WrapAlignment.center, spacing: 16, children: [
              OutlinedButton.icon(
                  onPressed: page > 0 ? () => change(() => page--) : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Previous')),
              OutlinedButton.icon(
                  onPressed:
                      page + 1 < pages ? () => change(() => page++) : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next')),
            ]),
        ]);
  }

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
}
