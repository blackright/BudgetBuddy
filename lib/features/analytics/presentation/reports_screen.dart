import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/financial_report.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/services/report_access.dart';
import '../../../core/services/report_format.dart';
import '../../../core/services/report_delivery.dart';
import '../../../shared/presentation/financial_feedback.dart';
import '../providers/report_providers.dart';
import 'widgets/report_results.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owner = ref.watch(budgetContextProvider),
        actor = ref.watch(actingProfileIdProvider);
    if (actor == null) {
      return const Scaffold(
          body: Center(child: Text('Select a personal profile first.')));
    }
    return _ReportsBody(
        key: ValueKey(
            '$actor:${owner.profileId}:${owner.spaceId}:${owner.yearMonth}'),
        owner: owner,
        actor: actor);
  }
}

class _ReportsBody extends ConsumerStatefulWidget {
  const _ReportsBody({super.key, required this.owner, required this.actor});
  final ContextRef owner;
  final int actor;
  @override
  ConsumerState<_ReportsBody> createState() => _ReportsBodyState();
}

class _ReportsBodyState extends ConsumerState<_ReportsBody> {
  late ReportScope scope;
  late String first, last;
  CurrencyCode currency = CurrencyCode.huf;
  String period = 'month', profile = 'main';
  int? space;
  final selectedSpaces = <int>{};
  bool busy = false, setup = true;
  FinancialReport? report;
  String? failure;
  @override
  void initState() {
    super.initState();
    first = last = widget.owner.yearMonth;
    scope = widget.owner.isShared ? ReportScope.space : ReportScope.personal;
    space = widget.owner.spaceId;
    currency =
        ref.read(activeProfileProvider).asData?.value?.primaryCurrency.code ??
            CurrencyCode.huf;
  }

  void change(VoidCallback action) {
    setState(() {
      action();
      report = null;
      failure = null;
      profile = 'main';
    });
  }

  Future<void> month(bool starting) async {
    final value = starting ? first : last;
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime(
            int.parse(value.substring(0, 4)), int.parse(value.substring(5))),
        firstDate: DateTime(1900),
        lastDate: DateTime(9999, 12, 31),
        initialDatePickerMode: DatePickerMode.year,
        helpText: starting
            ? 'Choose the first reporting month'
            : 'Choose the last reporting month');
    if (date == null || !mounted) return;
    change(() {
      final value = reportMonth(date);
      if (period == 'month') {
        first = last = value;
      } else if (period == 'year') {
        first = '${date.year}-01';
        last = '${date.year}-12';
      } else if (starting) {
        first = value;
      } else {
        last = value;
      }
    });
  }

  List<ReportOwner> owners() => switch (scope) {
        ReportScope.personal => [ReportOwner.personal(widget.actor)],
        ReportScope.space => [ReportOwner.space(space ?? -1)],
        ReportScope.financialProfile => [
            widget.owner.isShared
                ? ReportOwner.space(widget.owner.spaceId!)
                : ReportOwner.personal(widget.actor)
          ],
        ReportScope.consolidated => [
            ReportOwner.personal(widget.actor),
            ...selectedSpaces.map(ReportOwner.space)
          ]
      };
  Future<void> generate() async {
    setState(() {
      busy = true;
      failure = null;
    });
    try {
      final request = ReportRequest(
          scope: scope,
          personalProfileId: widget.actor,
          owners: owners(),
          firstMonth: first,
          lastMonth: last,
          currency: currency,
          financialProfile: profile);
      final result = await ref.read(generateFinancialReportProvider)(
          request, widget.actor);
      if (!mounted) return;
      setState(() {
        report = result;
        setup = false;
      });
      showFinancialFeedback(
          context,
          result.complete
              ? 'Report generated.'
              : 'Report generated with financial data issues to review.',
          kind: result.complete
              ? FinancialFeedbackKind.success
              : FinancialFeedbackKind.warning);
    } catch (e) {
      if (mounted) {
        setState(() => failure = e is StateError
            ? e.message
            : e is ArgumentError
                ? '${e.message}'
                : 'The report could not be generated. Please retry.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> export(FinancialReport snapshot) async {
    ReportFileKind kind = ReportFileKind.pdf;
    bool notes = false, appendix = false;
    final choice =
        await showModalBottomSheet<(ReportFileKind, bool, bool, bool)>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (sheet) => StatefulBuilder(
                builder: (sheet, update) => SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Export preview',
                              style: Theme.of(sheet).textTheme.headlineSmall),
                          Text(
                              '${snapshot.request.label}\n${snapshot.request.firstMonth} — ${snapshot.request.lastMonth}\n${snapshot.request.currency.code.toUpperCase()} · ${snapshot.transactions.length} transaction entries\nGenerated ${reportTime(snapshot.generatedAt)}'),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<ReportFileKind>(
                              initialValue: kind,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                  labelText: 'File format',
                                  border: OutlineInputBorder()),
                              items: const [
                                DropdownMenuItem(
                                    value: ReportFileKind.pdf,
                                    child: Text('PDF summary')),
                                DropdownMenuItem(
                                    value: ReportFileKind.summaryCsv,
                                    child: Text('Summary CSV')),
                                DropdownMenuItem(
                                    value: ReportFileKind.transactionsCsv,
                                    child: Text('Transactions CSV'))
                              ],
                              onChanged: (v) => update(() => kind = v!)),
                          if (kind == ReportFileKind.pdf)
                            SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Transaction appendix'),
                                subtitle: const Text(
                                    'Add all selected transaction details as extra pages.'),
                                value: appendix,
                                onChanged: (v) => update(() => appendix = v)),
                          if (kind == ReportFileKind.transactionsCsv ||
                              (kind == ReportFileKind.pdf && appendix))
                            SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Include notes'),
                                subtitle: const Text(
                                    'Off by default. Receipts and payment files are excluded.'),
                                value: notes,
                                onChanged: (v) => update(() => notes = v)),
                          const Text(
                              'Only permitted selected data is exported. Space figures represent full shared amounts. No automatic upload.'),
                          const SizedBox(height: 16),
                          Wrap(spacing: 12, runSpacing: 8, children: [
                            FilledButton.icon(
                                onPressed: () => Navigator.pop(
                                    sheet, (kind, notes, appendix, false)),
                                icon: const Icon(Icons.save_alt),
                                label: const Text('Save file')),
                            OutlinedButton.icon(
                                onPressed: () => Navigator.pop(
                                    sheet, (kind, notes, appendix, true)),
                                icon: const Icon(Icons.share_outlined),
                                label: const Text('Share file'))
                          ])
                        ]))));
    if (choice == null || !mounted) return;
    setState(() => busy = true);
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box == null ? null : box.localToGlobal(Offset.zero) & box.size;
      final result = await ref.read(sendFinancialReportProvider)(
          snapshot, choice.$1,
          share: choice.$4,
          options: ReportExportOptions(notes: choice.$2, appendix: choice.$3),
          origin: origin);
      if (!mounted) return;
      showFinancialFeedback(
          context,
          switch (result) {
            ReportDeliveryResult.saved => 'Report saved.',
            ReportDeliveryResult.shared =>
              'Report handed to the selected sharing app.',
            ReportDeliveryResult.cancelled => 'Export cancelled.',
            ReportDeliveryResult.unconfirmed =>
              'Share dialog closed; delivery confirmation is unavailable.'
          });
    } catch (e) {
      if (mounted) {
        showFinancialFeedback(
            context,
            e is StateError
                ? e.message
                : 'Export failed. Your financial data was not changed.',
            kind: FinancialFeedbackKind.error);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final choices = ref.watch(reportOwnersProvider);
    final permitted = choices.asData?.value ?? const <ReportOwnerChoice>[];
    final shared = permitted.where((c) => c.owner.shared).toList();
    final colors = Theme.of(context).colorScheme;
    final snapshot = report;
    final access = snapshot == null
        ? null
        : ref.watch(reportCurrentAccessProvider(snapshot));
    return PopScope(
        canPop: !busy,
        child: Scaffold(
            appBar: AppBar(title: const Text('Reports'), actions: [
              IconButton(
                  tooltip: 'Regenerate report',
                  onPressed: busy ? null : generate,
                  icon: const Icon(Icons.refresh))
            ]),
            bottomNavigationBar: snapshot == null
                ? null
                : SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: FilledButton.icon(
                            onPressed: busy ||
                                    access?.asData?.value != true ||
                                    !snapshot.complete
                                ? null
                                : () => export(snapshot),
                            icon: const Icon(Icons.ios_share),
                            label:
                                Text(busy ? 'Preparing…' : 'Export report')))),
            body: ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        colors.primaryContainer,
                        colors.secondaryContainer
                      ]),
                      borderRadius: BorderRadius.circular(24)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.insights_outlined, size: 32),
                        const SizedBox(height: 8),
                        Text('Your money, explained.',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const Text(
                            'One consistent view. Clear totals. Reports you can keep.')
                      ])),
              const SizedBox(height: 12),
              Card(
                  child: Column(children: [
                ListTile(
                    onTap: busy ? null : () => setState(() => setup = !setup),
                    title: Text(
                        '${scope == ReportScope.personal ? 'Personal overview' : scope == ReportScope.space ? 'Space' : scope == ReportScope.financialProfile ? 'Financial profile' : 'Consolidated'} · ${currency.code.toUpperCase()}'),
                    subtitle: Text('$first — $last'),
                    trailing: Icon(setup ? Icons.expand_less : Icons.tune)),
                if (setup)
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: AbsorbPointer(
                          absorbing: busy,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DropdownButtonFormField<ReportScope>(
                                    initialValue: scope,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: 'Reporting scope',
                                        border: OutlineInputBorder()),
                                    items: const [
                                      DropdownMenuItem(
                                          value: ReportScope.personal,
                                          child: Text(
                                              'Personal overview / Main Profile')),
                                      DropdownMenuItem(
                                          value: ReportScope.financialProfile,
                                          child: Text('Financial profile')),
                                      DropdownMenuItem(
                                          value: ReportScope.space,
                                          child: Text('Shared space')),
                                      DropdownMenuItem(
                                          value: ReportScope.consolidated,
                                          child: Text('Consolidated'))
                                    ],
                                    onChanged: (v) => change(() => scope = v!)),
                                const SizedBox(height: 12),
                                if (choices.isLoading)
                                  const LinearProgressIndicator(),
                                if (choices.hasError)
                                  TextButton(
                                      onPressed: () =>
                                          ref.invalidate(reportOwnersProvider),
                                      child: const Text(
                                          'Contexts could not load. Retry')),
                                if (scope == ReportScope.space)
                                  DropdownButtonFormField<int>(
                                      key: ValueKey(
                                          'spaces-${shared.map((s) => s.owner.id).join(',')}'),
                                      initialValue:
                                          shared.any((c) => c.owner.id == space)
                                              ? space
                                              : null,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                          labelText: 'Space',
                                          border: OutlineInputBorder()),
                                      items: [
                                        for (final c in shared)
                                          DropdownMenuItem(
                                              value: c.owner.id,
                                              enabled: !c.locked,
                                              child: Text(
                                                  '${c.name}${c.locked ? ' · Locked' : ''}',
                                                  overflow:
                                                      TextOverflow.ellipsis))
                                      ],
                                      onChanged: (v) =>
                                          change(() => space = v)),
                                if (scope == ReportScope.consolidated) ...[
                                  const Text(
                                      'Active personal profile + selected spaces. Each space contributes its full shared amounts once.'),
                                  for (final c in shared)
                                    CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(c.name),
                                        subtitle: Text(c.locked
                                            ? 'Locked: open its context to unlock.'
                                            : c.canExport
                                                ? 'Full shared amounts'
                                                : 'View only; selecting this space disables export.'),
                                        value:
                                            selectedSpaces.contains(c.owner.id),
                                        onChanged: c.locked
                                            ? null
                                            : (v) => change(() {
                                                  if (v == true) {
                                                    selectedSpaces
                                                        .add(c.owner.id);
                                                  } else {
                                                    selectedSpaces
                                                        .remove(c.owner.id);
                                                  }
                                                }))
                                ],
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                    initialValue: period,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: 'Period',
                                        border: OutlineInputBorder()),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'month',
                                          child: Text('One month')),
                                      DropdownMenuItem(
                                          value: 'year',
                                          child: Text('Calendar year')),
                                      DropdownMenuItem(
                                          value: 'range',
                                          child: Text('Whole-month range'))
                                    ],
                                    onChanged: (v) => change(() {
                                          period = v!;
                                          if (v == 'month') last = first;
                                          if (v == 'year') {
                                            first =
                                                '${first.substring(0, 4)}-01';
                                            last =
                                                '${first.substring(0, 4)}-12';
                                          }
                                        })),
                                Wrap(spacing: 12, children: [
                                  TextButton.icon(
                                      onPressed: () => month(true),
                                      icon: const Icon(Icons.date_range),
                                      label: Text(period == 'year'
                                          ? 'Year ${first.substring(0, 4)}'
                                          : 'From $first')),
                                  if (period == 'range')
                                    TextButton.icon(
                                        onPressed: () => month(false),
                                        icon: const Icon(Icons.event),
                                        label: Text('Through $last'))
                                ]),
                                DropdownButtonFormField<CurrencyCode>(
                                    initialValue: currency,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: 'Report currency',
                                        border: OutlineInputBorder()),
                                    items: [
                                      for (final c in CurrencyCode.values)
                                        DropdownMenuItem(
                                            value: c,
                                            child: Text(c.code.toUpperCase()))
                                    ],
                                    onChanged: (v) =>
                                        change(() => currency = v!)),
                                if (scope == ReportScope.financialProfile)
                                  _ProfileReportChoice(
                                      owner: widget.owner.isShared
                                          ? ReportOwner.space(
                                              widget.owner.spaceId!)
                                          : ReportOwner.personal(widget.actor),
                                      first: first,
                                      last: last,
                                      selected: profile,
                                      onChanged: (v) => setState(() {
                                            profile = v;
                                            report = null;
                                          })),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                    onPressed: choices.asData == null
                                        ? null
                                        : generate,
                                    icon: const Icon(Icons.auto_graph),
                                    label: const Text('Generate report')),
                              ])))
              ])),
              if (busy)
                const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator()),
              if (failure != null)
                Padding(
                    padding: const EdgeInsets.all(12),
                    child:
                        Text(failure!, style: TextStyle(color: colors.error))),
              if (snapshot == null && !busy)
                const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        'Choose your scope and period, then generate a report. Viewing reports does not change your money.')),
              if (snapshot != null) ...[
                if (access?.isLoading == true)
                  const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Checking report access…')),
                if (access?.hasError == true)
                  const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                          'Report access changed or a selected context is locked. Generate a new report.')),
                if (access?.asData != null) ...[
                  if (access?.asData?.value == false)
                    const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                            'View-only report. Every selected space needs Owner or Editor permission to export.')),
                  ReportResults(report: snapshot)
                ],
              ]
            ])));
  }
}

class _ProfileReportChoice extends ConsumerWidget {
  const _ProfileReportChoice(
      {required this.owner,
      required this.first,
      required this.last,
      required this.selected,
      required this.onChanged});
  final ReportOwner owner;
  final String first, last, selected;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (first.compareTo(last) > 0) {
      return const Text('Choose a valid month range first.');
    }
    final values =
        ref.watch(reportFinancialProfilesProvider((owner, first, last)));
    return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: values.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text(
                'Financial profiles are unavailable. Check the selected context and locks.'),
            data: (map) => DropdownButtonFormField<String>(
                key: ValueKey('$first:$last:${map.keys.join(',')}'),
                initialValue: map.containsKey(selected) ? selected : 'main',
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'Financial profile',
                    border: OutlineInputBorder()),
                items: [
                  for (final e in map.entries)
                    DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, overflow: TextOverflow.ellipsis))
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                })));
  }
}
